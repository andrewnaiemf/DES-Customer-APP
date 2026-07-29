import 'package:app/persentation/screens/warranty/sections/warranty_basic_info_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/persentation/screens/warranty/models/service_entry_model.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_theme.dart';
import 'package:app/persentation/screens/warranty/widgets/pressable_scale.dart';
import 'package:app/persentation/screens/warranty/widgets/modern_section_card.dart';
import 'package:app/persentation/screens/warranty/widgets/modern_text_field.dart';
import 'package:app/persentation/screens/warranty/widgets/protected_areas_bottom_sheet.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Dynamic Service Entries Section - Premium Design
// ═══════════════════════════════════════════════════════════════════════════
// Allows adding/removing multiple service entries dynamically
// Each entry: Service Type + Used Meters + Protected Areas
// ═══════════════════════════════════════════════════════════════════════════

class DynamicServiceEntriesSection extends StatefulWidget {
  final List<ServiceEntryModel> entries;
  final Function(List<ServiceEntryModel>) onEntriesChanged;
  final List<String> windowsAreas;
  final List<String> ppfAreas;
  final bool isDark;

  const DynamicServiceEntriesSection({
    super.key,
    required this.entries,
    required this.onEntriesChanged,
    required this.windowsAreas,
    required this.ppfAreas,
    this.isDark = false,
  });

  @override
  State<DynamicServiceEntriesSection> createState() =>
      _DynamicServiceEntriesSectionState();
}

class _DynamicServiceEntriesSectionState
    extends State<DynamicServiceEntriesSection> with TickerProviderStateMixin {

  late AnimationController _addButtonController;
  late Animation<double> _addButtonAnimation;

  @override
  void initState() {
    super.initState();
    _addButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _addButtonAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _addButtonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _addButtonController.dispose();
    super.dispose();
  }

  void _addEntry() {
    HapticFeedback.mediumImpact();
    _addButtonController.forward().then((_) => _addButtonController.reverse());

    final newEntry = ServiceEntryModel.empty(
      'entry_${DateTime.now().millisecondsSinceEpoch}',
    );
    final updatedEntries = [...widget.entries, newEntry];
    widget.onEntriesChanged(updatedEntries);
  }

  void _removeEntry(String entryId) {
    HapticFeedback.lightImpact();
    final updatedEntries = widget.entries.where((e) => e.id != entryId).toList();
    widget.onEntriesChanged(updatedEntries);
  }

  void _updateEntry(ServiceEntryModel updatedEntry) {
    final updatedEntries = widget.entries.map((entry) {
      return entry.id == updatedEntry.id ? updatedEntry : entry;
    }).toList();
    widget.onEntriesChanged(updatedEntries);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _ServiceSummaryHelper.fromEntries(widget.entries);
    final validEntries = widget.entries.where((e) => e.isValid).length;

    return ModernSectionCard(
      title: 'Service Entries',
      icon: Icons.construction_rounded,
      iconColor: AppTheme.purple,
      isDark: widget.isDark,
      children: [
        // ═══════════════════════════════════════════════════════════════
        // 📊 Enhanced Summary Card
        // ═══════════════════════════════════════════════════════════════
        if (widget.entries.isNotEmpty) ...[
          _buildEnhancedSummaryCard(summary, validEntries),
          const SizedBox(height: 20),
        ],

        // ═══════════════════════════════════════════════════════════════
        // 📋 Service Entries List with Animations
        // ═══════════════════════════════════════════════════════════════
        ...widget.entries.asMap().entries.map((mapEntry) {
          final index = mapEntry.key;
          final entry = mapEntry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0, end: 1),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PremiumServiceEntryCard(
                key: ValueKey(entry.id),
                entry: entry,
                index: index,
                windowsAreas: widget.windowsAreas,
                ppfAreas: widget.ppfAreas,
                isDark: widget.isDark,
                onUpdate: _updateEntry,
                onRemove: () => _removeEntry(entry.id),
                canRemove: widget.entries.length > 1,
              ),
            ),
          );
        }).toList(),

        // ═══════════════════════════════════════════════════════════════
        // ➕ Animated Add Entry Button
        // ═══════════════════════════════════════════════════════════════
        ScaleTransition(
          scale: _addButtonAnimation,
          child: PressableScale(
            onPressed: _addEntry,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.purple.withOpacity(0.12),
                    AppTheme.purpleLight.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(
                  color: AppTheme.purple.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.purple.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: AppTheme.purple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Add Another Product',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.purple,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 Enhanced Summary Card
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildEnhancedSummaryCard(_ServiceSummaryHelper summary, int validEntries) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.purple.withOpacity(widget.isDark ? 0.2 : 0.12),
            AppTheme.blue.withOpacity(widget.isDark ? 0.15 : 0.08),
            AppTheme.green.withOpacity(widget.isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.purple.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withOpacity(widget.isDark ? 0.15 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: AppTheme.purple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Total Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getText(widget.isDark),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildAnimatedSummaryItem(
                  'Windows',
                  '${summary.totalWindowsMeters}m',
                  Icons.window_rounded,
                  AppTheme.blue,
                  0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAnimatedSummaryItem(
                  'PPF',
                  '${summary.totalPPFMeters}m',
                  Icons.security_rounded,
                  AppTheme.orange,
                  1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAnimatedSummaryItem(
                  'Valid',
                  '$validEntries/${widget.entries.length}',
                  Icons.check_circle_rounded,
                  AppTheme.green,
                  2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSummaryItem(
      String label,
      String value,
      IconData icon,
      Color color,
      int index,
      ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animValue),
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(widget.isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextSecondary(widget.isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Service Summary Helper (Private - لتجنب التعارض)
// ═══════════════════════════════════════════════════════════════════════════
class _ServiceSummaryHelper {
  final int totalWindowsMeters;
  final int totalPPFMeters;
  final int totalEntries;

  _ServiceSummaryHelper({
    required this.totalWindowsMeters,
    required this.totalPPFMeters,
    required this.totalEntries,
  });

  factory _ServiceSummaryHelper.fromEntries(List<ServiceEntryModel> entries) {
    int windowsMeters = 0;
    int ppfMeters = 0;

    for (final entry in entries) {
      if (entry.serviceType == 'windows') {
        windowsMeters += entry.usedMeters;
      } else if (entry.serviceType == 'ppf') {
        ppfMeters += entry.usedMeters;
      }
    }

    return _ServiceSummaryHelper(
      totalWindowsMeters: windowsMeters,
      totalPPFMeters: ppfMeters,
      totalEntries: entries.length,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎴 Premium Service Entry Card
// ═════════════════════════���════��════════════════════════════════════════════
class _PremiumServiceEntryCard extends StatefulWidget {
  final ServiceEntryModel entry;
  final int index;
  final List<String> windowsAreas;
  final List<String> ppfAreas;
  final bool isDark;
  final Function(ServiceEntryModel) onUpdate;
  final VoidCallback onRemove;
  final bool canRemove;

  const _PremiumServiceEntryCard({
    super.key,
    required this.entry,
    required this.index,
    required this.windowsAreas,
    required this.ppfAreas,
    required this.isDark,
    required this.onUpdate,
    required this.onRemove,
    required this.canRemove,
  });

  @override
  State<_PremiumServiceEntryCard> createState() => _PremiumServiceEntryCardState();
}

class _PremiumServiceEntryCardState extends State<_PremiumServiceEntryCard>
    with SingleTickerProviderStateMixin {
  late TextEditingController _metersController;
  late AnimationController _validationController;
  late Animation<double> _validationAnimation;
  // Warranty Info
  late TextEditingController _warrantyCodeController;
  late TextEditingController _serialNumberController;
  final _installDateController = TextEditingController();
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    _metersController = TextEditingController(
      text: widget.entry.usedMeters > 0 ? widget.entry.usedMeters.toString() : '',
    );

    _warrantyCodeController = TextEditingController(text: widget.entry.warrantyCode);
    _serialNumberController = TextEditingController(text: widget.entry.serialCode);

    _warrantyCodeController.addListener(() {
      if (widget.entry.warrantyCode != _warrantyCodeController.text) {
        widget.onUpdate(widget.entry.copyWith(warrantyCode: _warrantyCodeController.text));
      }
    });

    _serialNumberController.addListener(() {
      if (widget.entry.serialCode != _serialNumberController.text) {
        widget.onUpdate(widget.entry.copyWith(serialCode: _serialNumberController.text));
      }
    });

    _validationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _validationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _validationController, curve: Curves.elasticOut),
    );

    if (widget.entry.isValid) {
      _showValidation = true;
      _validationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _PremiumServiceEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entry.isValid && !_showValidation) {
      _showValidation = true;
      _validationController.forward();
    } else if (!widget.entry.isValid && _showValidation) {
      _showValidation = false;
      _validationController.reverse();
    }
  }

  @override
  void dispose() {
    _metersController.dispose();
    _warrantyCodeController.dispose();
    _serialNumberController.dispose();
    _installDateController.dispose();
    _validationController.dispose();
    super.dispose();
  }

  void _updateServiceType(String? value) {
    if (value != null) {
      HapticFeedback.selectionClick();
      final updated = widget.entry.copyWith(
        serviceType: value,
        protectedAreas: [],
      );
      widget.onUpdate(updated);
    }
  }

  void _updateMeters(String value) {
    final meters = int.tryParse(value) ?? 0;
    final updated = widget.entry.copyWith(usedMeters: meters);
    widget.onUpdate(updated);
  }

  void _selectAreas() async {
    HapticFeedback.mediumImpact();

    final availableAreas = widget.entry.serviceType == 'windows'
        ? widget.windowsAreas
        : widget.ppfAreas;

    final result = await ProtectedAreasBottomSheet.show(
      context: context,
      selectedAreas: widget.entry.protectedAreas,
      availableAreas: availableAreas,
      title: widget.entry.serviceDisplayName,
    );

    if (result != null) {
      final updated = widget.entry.copyWith(protectedAreas: result);
      widget.onUpdate(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid = widget.entry.isValid;
    final color = widget.entry.serviceType == 'windows'
        ? AppTheme.blue
        : AppTheme.orange;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.getSurface(widget.isDark),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: isValid
              ? color.withOpacity(0.6)
              : AppTheme.getBorder(widget.isDark),
          width: isValid ? 2 : 1,
        ),
        boxShadow: isValid ? [
          BoxShadow(
            color: color.withOpacity(widget.isDark ? 0.25 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ] : AppTheme.softShadow(widget.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // 🏷️ Header with Badge
          // ═══════════════════════════════════════════════════════════════
          Row(
            children: [
              // Entry Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.entry.serviceType == 'windows'
                          ? Icons.window_rounded
                          : Icons.security_rounded,
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Entry ${widget.index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Validation Indicator
              ScaleTransition(
                scale: _validationAnimation,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.green.withOpacity(0.3)),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppTheme.green,
                  ),
                ),
              ),

              if (widget.canRemove) ...[
                const SizedBox(width: 8),
                // Delete Button
                PressableScale(
                  onPressed: () => _showDeleteConfirmation(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                      border: Border.all(color: AppTheme.red.withOpacity(0.2)),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppTheme.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          // const SizedBox(height: 20),

          // 🛡️ Basic Warranty Information (Code + Serial only)
          WarrantyBasicInfoSection(
            codeController: _warrantyCodeController,
            serialController: _serialNumberController,
            isDark: isDark,
          ),

          // ═══════════════════════════════════════════════════════════════
          // 🔘 Service Type Selector
          // ═══════════════════════════════════════════════════════════════
          Text(
            'Service Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.getText(widget.isDark),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPremiumServiceTypeButton(
                  label: 'Windows',
                  value: 'windows',
                  icon: Icons.window_rounded,
                  color: AppTheme.blue,
                  description: 'Tinting & Film',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPremiumServiceTypeButton(
                  label: 'PPF',
                  value: 'ppf',
                  icon: Icons.security_rounded,
                  color: AppTheme.orange,
                  description: 'Protection Film',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // 📏 Used Meters Input
          // ═══════════════════════════════════════════════════════════════
          _buildMetersField(),
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // 📍 Protected Areas Selector
          // ═══════════════════════════════════════════════════════════════
          Text(
            'Protected Areas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.getText(widget.isDark),
            ),
          ),
          const SizedBox(height: 10),
          _buildAreasSelector(color),

          // Selected Areas Chips
          if (widget.entry.protectedAreas.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSelectedAreasChips(color),
          ],
        ],
      ),
    );
  }

  Widget _buildMetersField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Used Meters',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextSecondary(widget.isDark),
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            border: Border.all(color: AppTheme.getBorder(widget.isDark)),
            color: AppTheme.getSurface(widget.isDark),
          ),
          child: TextFormField(
            controller: _metersController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.getText(widget.isDark),
            ),
            decoration: InputDecoration(
              hintText: 'Enter meters used',
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.getTextSecondary(widget.isDark).withOpacity(0.6),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  Icons.straighten_rounded,
                  color: AppTheme.getTextSecondary(widget.isDark),
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: _updateMeters,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
        ),
      ],
    );
  }

  Widget _buildAreasSelector(Color color) {
    return PressableScale(
      onPressed: _selectAreas,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.entry.protectedAreas.isEmpty
              ? AppTheme.getSurface(widget.isDark)
              : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(
            color: widget.entry.protectedAreas.isEmpty
                ? AppTheme.getBorder(widget.isDark)
                : color.withOpacity(0.4),
            width: widget.entry.protectedAreas.isEmpty ? 1 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusXS),
              ),
              child: Icon(
                Icons.map_rounded,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.entry.protectedAreas.isEmpty
                        ? 'Tap to select areas'
                        : '${widget.entry.protectedAreas.length} areas selected',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.entry.protectedAreas.isEmpty
                          ? AppTheme.getTextSecondary(widget.isDark)
                          : AppTheme.getText(widget.isDark),
                    ),
                  ),
                  if (widget.entry.protectedAreas.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.entry.protectedAreas.take(3).join(', ') +
                          (widget.entry.protectedAreas.length > 3 ? '...' : ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getTextSecondary(widget.isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.getTextSecondary(widget.isDark),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAreasChips(Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.entry.protectedAreas.map((area) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                area,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPremiumServiceTypeButton({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    final isSelected = widget.entry.serviceType == value;

    return PressableScale(
      onPressed: () => _updateServiceType(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          )
              : null,
          color: isSelected ? null : AppTheme.getSurface(widget.isDark),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(
            color: isSelected ? color : AppTheme.getBorder(widget.isDark),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : AppTheme.getBorder(widget.isDark).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? color : AppTheme.getTextSecondary(widget.isDark),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? color : AppTheme.getText(widget.isDark),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextSecondary(widget.isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCard(widget.isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Remove Entry?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.getText(widget.isDark),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove Entry ${widget.index + 1}?',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.getTextSecondary(widget.isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.getTextSecondary(widget.isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onRemove();
            },
            child: Text(
              'Remove',
              style: TextStyle(
                color: AppTheme.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}