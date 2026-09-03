import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../business_logic/auth/CheckPhoneCubit/check_phone_cubit.dart';
import '../models/country_code.dart';
import '../theme/colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 ألوان الهوية البصرية للتطبيق
// ═══════════════════════════════════════════════════════════════════════════
class AppBrandColors {
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;
  static const Color background = Color(0xFF15172A);
  static const Color cardDark = Color(0xFF1E2139);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, Color(0xFF8B5CF6)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, Color(0xFF10B981)],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 🌍 Country Code Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════════
Future<void> showCountryCodeBottomSheet(BuildContext context) {
  // Haptic feedback for better UX
  HapticFeedback.lightImpact();

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (BuildContext context) {
      return const _CountryCodeBottomSheetContent();
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 🌍 Country Code Bottom Sheet - English Only (For Warranty Screen)
// ═══════════════════════════════════════════════════════════════════════════
void showCountryCodeBottomSheetEnglish(BuildContext context) {
  // Haptic feedback for better UX
  HapticFeedback.lightImpact();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (BuildContext context) {
      // Force English locale for this bottom sheet only
      return const _CountryCodeBottomSheetContent(forceEnglish: true);
    },
  );
}

class _CountryCodeBottomSheetContent extends StatefulWidget {
  final bool forceEnglish;
  
  const _CountryCodeBottomSheetContent({this.forceEnglish = false});

  @override
  State<_CountryCodeBottomSheetContent> createState() =>
      _CountryCodeBottomSheetContentState();
}

class _CountryCodeBottomSheetContentState
    extends State<_CountryCodeBottomSheetContent>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // 🌙 Theme Helper
  // ─────────────────────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  
  // ─────────────────────────────────────────────────────────────────────────
  // 🌍 Translation Helper - Returns English text if forceEnglish is true
  // ─────────────────────────────────────────────────────────────────────────
  String _getText(String key) {
    if (widget.forceEnglish) {
      // English translations
      final englishTexts = {
        'Select Country': 'Select Country',
        'countries available': 'countries available',
        'Search country or code...': 'Search country or code...',
        'No countries found': 'No countries found',
        'Try adjusting your search': 'Try adjusting your search',
        'Try a different search term': 'Try adjusting your search',
      };
      return englishTexts[key] ?? key;
    }
    return key.tr();
  }
  
  String _getCountryName(CountryCode country) {
    if (widget.forceEnglish) {
      return country.name;
    }
    return country.localizedName(context.locale.languageCode);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📝 Controllers & Variables
  // ─────────────────────────────────────────────────────────────────────────
  late final TextEditingController _searchController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  List<CountryCode> _filteredCountries = [];
  String _searchQuery = '';
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCountries = List.from(countryCodesList);

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔍 Search Filter
  // ─────────────────────────────────────────────────────────────────────────
  void _filterCountries(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCountries = List.from(countryCodesList);
      } else {
        _filteredCountries = countryCodesList.where((country) {
          final nameEn = country.name.toLowerCase();
          final nameAr = country.nameAr.toLowerCase();
          final code = country.code.toLowerCase();
          return nameEn.contains(_searchQuery) ||
              nameAr.contains(_searchQuery) ||
              code.contains(_searchQuery);
        }).toList();
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎨 Build Method
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.75,
      ),
      decoration: BoxDecoration(
        color: _isDark ? AppBrandColors.background : AppBrandColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: (_isDark ? Colors.black : const Color(0x1A000000))
                .withOpacity(_isDark ? 0.5 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: _isDark
            ? Border.all(
          color: AppBrandColors.white.withOpacity(0.08),
          width: 1,
        )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // 📌 Drag Handle
          // ═══════════════════════════════════════════════════════════════
          _buildDragHandle(),

          // ═══════════════════════════════════════════════════════════════
          // 🏷️ Header
          // ═══════════════════════════════════════════════════════════════
          _buildHeader(),

          // ═══════════════════════════════════════════════════════════════
          // 🔍 Search Bar
          // ═══════════════════════════════════════════════════════════════
          _buildSearchBar(),

          // ═══════════════════════════════════════════════════════════════
          // 📋 Country List
          // ═══════════════════════════════════════════════════════════════
          Flexible(
            child: _buildCountryList(),
          ),

          // Bottom padding for keyboard
          SizedBox(height: bottomPadding > 0 ? bottomPadding : 16),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📌 Drag Handle Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: _isDark
            ? AppBrandColors.white.withOpacity(0.2)
            : AppBrandColors.darkGray.withOpacity(0.5),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🏷️ Header Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppBrandColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppBrandColors.purple.withOpacity(_isDark ? 0.4 : 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.public_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getText('Select Country'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${countryCodesList.length} ${_getText('countries available')}',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isDark
                        ? AppBrandColors.darkGray.withOpacity(0.8)
                        : AppBrandColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Close Button
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isDark
                ? AppBrandColors.white.withOpacity(0.1)
                : AppBrandColors.lightGray,
            borderRadius: BorderRadius.circular(12),
            border: _isDark
                ? Border.all(
              color: AppBrandColors.white.withOpacity(0.08),
            )
                : null,
          ),
          child: Icon(
            Icons.close_rounded,
            color: _isDark
                ? AppBrandColors.white.withOpacity(0.7)
                : AppBrandColors.dark.withOpacity(0.6),
            size: 20,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔍 Search Bar Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isDark
              ? AppBrandColors.cardDark
              : AppBrandColors.lightGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _searchQuery.isNotEmpty
                ? AppBrandColors.purple.withOpacity(_isDark ? 0.5 : 0.3)
                : _isDark
                ? AppBrandColors.white.withOpacity(0.08)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: _searchQuery.isNotEmpty
              ? [
            BoxShadow(
              color: AppBrandColors.purple
                  .withOpacity(_isDark ? 0.15 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterCountries,
          style: TextStyle(
            fontSize: 15,
            color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppBrandColors.purple,
          decoration: InputDecoration(
            hintText: _getText('Search country or code...'),
            hintStyle: TextStyle(
              color: _isDark
                  ? AppBrandColors.darkGray.withOpacity(0.6)
                  : AppBrandColors.darkGray,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search_rounded,
                color: _searchQuery.isNotEmpty
                    ? AppBrandColors.purple
                    : _isDark
                    ? AppBrandColors.darkGray.withOpacity(0.6)
                    : AppBrandColors.darkGray,
                size: 22,
              ),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              onPressed: () {
                _searchController.clear();
                _filterCountries('');
                HapticFeedback.selectionClick();
              },
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _isDark
                      ? AppBrandColors.white.withOpacity(0.15)
                      : AppBrandColors.darkGray.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: _isDark
                      ? AppBrandColors.white
                      : AppBrandColors.dark,
                  size: 14,
                ),
              ),
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📋 Country List Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCountryList() {
    if (_filteredCountries.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemCount: _filteredCountries.length,
          itemBuilder: (context, index) {
            return _buildCountryTile(
              country: _filteredCountries[index],
              index: index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCountryTile({
    required CountryCode country,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final currentCountry = context.read<CheckPhoneCubit>().selectedCounty;
    final isCurrentlySelected = currentCountry.code == country.code;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 30).clamp(0, 300)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectCountry(country, index),
            onTapDown: (_) => setState(() => _selectedIndex = index),
            onTapUp: (_) => setState(() => _selectedIndex = null),
            onTapCancel: () => setState(() => _selectedIndex = null),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isCurrentlySelected
                    ? AppBrandColors.purple.withOpacity(_isDark ? 0.2 : 0.08)
                    : isSelected
                    ? _isDark
                    ? AppBrandColors.white.withOpacity(0.08)
                    : AppBrandColors.lightGray
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentlySelected
                      ? AppBrandColors.purple.withOpacity(_isDark ? 0.5 : 0.3)
                      : _isDark && isSelected
                      ? AppBrandColors.white.withOpacity(0.1)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Flag Container
                  _buildFlagContainer(country, isCurrentlySelected),

                  const SizedBox(width: 14),

                  // Country Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCountryName(country),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isCurrentlySelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: _isDark
                                ? AppBrandColors.white
                                : AppBrandColors.dark,
                          ),
                        ),
                        if (isCurrentlySelected) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Currently selected'.tr(),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppBrandColors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Country Code
                  _buildCountryCodeBadge(country, isCurrentlySelected),

                  // Check Icon (if selected)
                  if (isCurrentlySelected) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        gradient: AppBrandColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlagContainer(CountryCode country, bool isSelected) {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: (_isDark ? Colors.black : AppBrandColors.dark)
                .withOpacity(_isDark ? 0.3 : 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SvgPicture.asset(
          country.flag,
          width: 44,
          height: 32,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCountryCodeBadge(CountryCode country, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppBrandColors.purple.withOpacity(_isDark ? 0.25 : 0.15)
            : _isDark
            ? AppBrandColors.white.withOpacity(0.1)
            : AppBrandColors.lightGray,
        borderRadius: BorderRadius.circular(8),
        border: _isDark && !isSelected
            ? Border.all(
          color: AppBrandColors.white.withOpacity(0.08),
        )
            : null,
      ),
      child: Text(
        country.code,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isSelected
              ? AppBrandColors.purple
              : _isDark
              ? AppBrandColors.white
              : AppBrandColors.dark,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔘 Empty State Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isDark
                    ? AppBrandColors.white.withOpacity(0.08)
                    : AppBrandColors.lightGray,
                shape: BoxShape.circle,
                border: _isDark
                    ? Border.all(
                  color: AppBrandColors.white.withOpacity(0.1),
                )
                    : null,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: _isDark
                    ? AppBrandColors.darkGray.withOpacity(0.6)
                    : AppBrandColors.darkGray,
              ),
            ),
            const SizedBox(height: 20),

            // Empty Text
            Text(
              _getText('No countries found'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isDark ? AppBrandColors.white : AppBrandColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getText('Try adjusting your search'),
              style: TextStyle(
                fontSize: 14,
                color: _isDark
                    ? AppBrandColors.darkGray.withOpacity(0.7)
                    : AppBrandColors.darkGray,
              ),
            ),

            const SizedBox(height: 20),

            // Clear Search Button
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                _filterCountries('');
              },
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              label: Text('Clear search'.tr()),
              style: TextButton.styleFrom(
                foregroundColor: AppBrandColors.purple,
                backgroundColor:
                AppBrandColors.purple.withOpacity(_isDark ? 0.15 : 0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎯 Select Country Action
  // ─────────────────────────────────────────────────────────────────────────
  void _selectCountry(CountryCode country, int index) {
    HapticFeedback.selectionClick();

    // Update state and close
    context.read<CheckPhoneCubit>().changeCountryCode(country);

    // Animate out then close
    _animationController.reverse().then((_) {
      Navigator.pop(context);
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🌍 Quick Country Selector (Alternative Compact Version)
// ═══════════════════════════════════════════════════════════════════════════
class QuickCountrySelector extends StatelessWidget {
  final VoidCallback onTap;
  final CountryCode selectedCountry;

  const QuickCountrySelector({
    super.key,
    required this.onTap,
    required this.selectedCountry,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppBrandColors.cardDark : AppBrandColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppBrandColors.white.withOpacity(0.1)
                  : AppBrandColors.darkGray.withOpacity(0.3),
            ),
            boxShadow: isDark
                ? null
                : [
              BoxShadow(
                color: AppBrandColors.dark.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SvgPicture.asset(
                  selectedCountry.flag,
                  width: 24,
                  height: 18,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark
                    ? AppBrandColors.darkGray.withOpacity(0.8)
                    : AppBrandColors.dark.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}