import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/persentation/screens/warranty/warranty_strings.dart';
import 'warranty_theme.dart';
import 'pressable_scale.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🛡️ Protected Areas Bottom Sheet - Premium UI
// ═══════════════════════════════════════════════════════════════════════════
class ProtectedAreasBottomSheet extends StatefulWidget {
  final List<String> selectedAreas;
  final List<String> availableAreas;
  final bool isDark;
  final String title;

  const ProtectedAreasBottomSheet({
    super.key,
    required this.selectedAreas,
    required this.availableAreas,
    required this.isDark,
    required this.title,
  });

  static Future<List<String>?> show({
    required BuildContext context,
    required List<String> selectedAreas,
    required List<String> availableAreas,
    String? title,
  }) async {
    HapticFeedback.selectionClick();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppTheme.dark.withOpacity(0.6),
      builder: (context) => ProtectedAreasBottomSheet(
        selectedAreas: List.from(selectedAreas),
        availableAreas: availableAreas,
        isDark: isDark,
        title: title ?? WarrantyStrings.protectedAreas,
      ),
    );
  }

  @override
  State<ProtectedAreasBottomSheet> createState() =>
      _ProtectedAreasBottomSheetState();
}

class _ProtectedAreasBottomSheetState extends State<ProtectedAreasBottomSheet>
    with TickerProviderStateMixin {
  late List<String> _tempSelectedAreas;
  late AnimationController _slideController;
  late AnimationController _itemsController;
  late AnimationController _shimmerController;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _itemAnimations;

  // Area Icons Map
  final Map<String, IconData> _areaIcons = const {
    'Front Window (L)': Icons.panorama_wide_angle_rounded,
    'Front Window (R)': Icons.panorama_wide_angle_rounded,
    'Rear Window (L)': Icons.panorama_wide_angle_outlined,
    'Rear Window (R)': Icons.panorama_wide_angle_outlined,
    'Side Windows': Icons.view_sidebar_rounded,
    'Sunroof': Icons.wb_sunny_rounded,
    'MPV - Rear Fix Window (L)': Icons.view_compact_alt_rounded,
    'MPV - Rear Fix Window (R)': Icons.view_compact_alt_rounded,
    'Front Windshield': Icons.panorama_wide_angle_rounded,
    'Rear Windshield': Icons.panorama_wide_angle_outlined,
    'Full Vehicle': Icons.directions_car_rounded,
    'Front Bumper': Icons.front_hand_rounded,
    'Rear Bumper': Icons.back_hand_rounded,
    'Hood': Icons.dashboard_rounded,
    'Side Mirrors': Icons.view_in_ar_rounded,
    'Doors (L)': Icons.door_front_door_rounded,
    'Doors (R)': Icons.door_front_door_rounded,
    'Roof': Icons.roofing_rounded,
    'Trunk': Icons.inventory_2_rounded,
  };

  // Area Colors Map
  final Map<String, Color> _areaColors = const {
    'Front Window (L)': AppTheme.lightGreen,
    'Front Window (R)': AppTheme.lightGreen,
    'Rear Window (L)': AppTheme.blue,
    'Rear Window (R)': AppTheme.blue,
    'Side Windows': AppTheme.orange,
    'Sunroof': AppTheme.yellow,
    'Front Windshield': AppTheme.lightGreen,
    'Rear Windshield': AppTheme.blue,
    'MPV - Rear Fix Window (L)': AppTheme.cyan,
    'MPV - Rear Fix Window (R)': AppTheme.cyan,
    'Full Vehicle': AppTheme.purple,
    'Front Bumper': AppTheme.pink,
    'Rear Bumper': AppTheme.pink,
    'Hood': AppTheme.purpleLight,
    'Side Mirrors': AppTheme.cyan,
    'Doors (L)': AppTheme.green,
    'Doors (R)': AppTheme.green,
    'Roof': AppTheme.orange,
    'Trunk': AppTheme.indigo,
  };

  @override
  void initState() {
    super.initState();
    _tempSelectedAreas = List.from(widget.selectedAreas);
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: AppTheme.durationSlower,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _itemsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _itemAnimations = List.generate(widget.availableAreas.length, (index) {
      final startInterval = (index / widget.availableAreas.length) * 0.5;
      final endInterval = startInterval + 0.5;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _itemsController,
          curve: Interval(
            startInterval.clamp(0.0, 1.0),
            endInterval.clamp(0.0, 1.0),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _itemsController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _itemsController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _toggleArea(String area) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_tempSelectedAreas.contains(area)) {
        _tempSelectedAreas.remove(area);
      } else {
        _tempSelectedAreas.add(area);
      }
    });
  }

  void _selectAll() {
    HapticFeedback.lightImpact();
    setState(() => _tempSelectedAreas = List.from(widget.availableAreas));
  }

  void _clearAll() {
    HapticFeedback.lightImpact();
    setState(() => _tempSelectedAreas.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: AppTheme.getCard(widget.isDark),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXXL),
            ),
            border: widget.isDark
                ? Border.all(color: AppTheme.borderDark.withOpacity(0.5))
                : null,
            boxShadow: [
              BoxShadow(
                color: AppTheme.dark.withOpacity(0.25),
                blurRadius: 40,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              _buildHeader(),
              _buildQuickActions(),
              _buildDivider(),
              Flexible(child: _buildAreasGrid()),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppTheme.white.withOpacity(0.12)
            : AppTheme.darkGray.withOpacity(0.4),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient(),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              boxShadow: AppTheme.elevatedShadow(AppTheme.purple, widget.isDark),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getText(widget.isDark),
                  ),
                ),
                Text(
                  'Choose the protected areas',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.getTextSecondary(widget.isDark),
                  ),
                ),
              ],
            ),
          ),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return PressableScale(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppTheme.getSurface(widget.isDark),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: widget.isDark
              ? Border.all(color: AppTheme.borderDark)
              : Border.all(color: AppTheme.darkGray.withOpacity(0.2)),
        ),
        child: Icon(
          Icons.close_rounded,
          color: AppTheme.getTextSecondary(widget.isDark),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final allSelected = _tempSelectedAreas.length == widget.availableAreas.length;
    final noneSelected = _tempSelectedAreas.isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickButton(
              icon: Icons.clear_all_rounded,
              label: 'Clear All',
              isActive: !noneSelected,
              color: AppTheme.orange,
              onTap: _clearAll,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickButton(
              icon: Icons.select_all_rounded,
              label: 'Select All',
              isActive: !allSelected,
              color: AppTheme.purple,
              onTap: _selectAll,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationNormal,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.12) : AppTheme.getSurface(widget.isDark),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(
            color: isActive ? color.withOpacity(0.4) : AppTheme.getBorder(widget.isDark),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.getText(widget.isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.getDivider(widget.isDark),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildAreasGrid() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: widget.availableAreas.asMap().entries.map((entry) {
          final index = entry.key;
          final area = entry.value;
          final isSelected = _tempSelectedAreas.contains(area);
          final icon = _areaIcons[area] ?? Icons.check_circle_outline_rounded;
          final color = _areaColors[area] ?? AppTheme.purple;

          return AnimatedBuilder(
            animation: _itemAnimations[index],
            builder: (context, child) {
              final value = _itemAnimations[index].value;
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: _ModernAreaChip(
                    area: area,
                    icon: icon,
                    color: color,
                    isSelected: isSelected,
                    isDark: widget.isDark,
                    onTap: () => _toggleArea(area),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomActions() {
    final hasSelection = _tempSelectedAreas.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getSurface(widget.isDark),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.getDivider(widget.isDark),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSelectionStatus(hasSelection),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: WarrantyStrings.cancel,
                  isPrimary: false,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildActionButton(
                  label: 'Confirm Selection',
                  isPrimary: true,
                  icon: Icons.check_circle_rounded,
                  isEnabled: hasSelection,
                  onTap: hasSelection
                      ? () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context, _tempSelectedAreas);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionStatus(bool hasSelection) {
    return AnimatedContainer(
      duration: AppTheme.durationNormal,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasSelection
              ? [
                  AppTheme.green.withOpacity(0.12),
                  AppTheme.green.withOpacity(0.08),
                ]
              : [
                  AppTheme.yellow.withOpacity(0.12),
                  AppTheme.yellow.withOpacity(0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(
          color: hasSelection
              ? AppTheme.green.withOpacity(0.35)
              : AppTheme.yellow.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSelection ? Icons.check_circle_rounded : Icons.info_rounded,
            color: hasSelection ? AppTheme.green : AppTheme.yellow,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            hasSelection
                ? '${_tempSelectedAreas.length} selected'
                : 'Please select at least one area',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getText(widget.isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isPrimary,
    IconData? icon,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return PressableScale(
      onPressed: isEnabled && onTap != null ? onTap : () {},
      scaleFactor: isEnabled ? 0.96 : 1.0,
      child: AnimatedContainer(
        duration: AppTheme.durationNormal,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary && isEnabled
              ? AppTheme.primaryGradient()
              : null,
          color: !isPrimary
              ? AppTheme.getSurface(widget.isDark)
              : (isEnabled ? null : AppTheme.darkGray.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: !isPrimary
              ? Border.all(color: AppTheme.getBorder(widget.isDark))
              : null,
          boxShadow: isPrimary && isEnabled
              ? AppTheme.elevatedShadow(AppTheme.purple, widget.isDark)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppTheme.getText(widget.isDark),
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : AppTheme.getText(widget.isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Modern Area Chip Widget
// ═══════════════════════════════════════════════════════════════════════════
class _ModernAreaChip extends StatefulWidget {
  final String area;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ModernAreaChip({
    required this.area,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ModernAreaChip> createState() => _ModernAreaChipState();
}

class _ModernAreaChipState extends State<_ModernAreaChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppTheme.durationNormal,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [
                      widget.color.withOpacity(0.2),
                      widget.color.withOpacity(0.12),
                    ],
                  )
                : null,
            color: !widget.isSelected ? AppTheme.getSurface(widget.isDark) : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            border: Border.all(
              color: widget.isSelected
                  ? widget.color.withOpacity(0.5)
                  : AppTheme.getBorder(widget.isDark),
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.area,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: AppTheme.getText(widget.isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle_rounded,
                  color: widget.color,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
