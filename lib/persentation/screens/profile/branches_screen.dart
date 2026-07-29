import 'package:app/core/responsive/responsive.dart';
import 'package:app/business_logic/profile/cubit/profile_cubit.dart';
import 'package:app/data/constants/assets.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/branche/branche_model.dart';
import 'package:app/persentation/screens/orders/products_screen.dart';
import 'package:app/persentation/widgets/my_scaffold.dart';
import 'package:app/persentation/widgets/textFormField.dart';
import 'package:app/persentation/widgets/directional_arrow.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

// ==================== App Theme Colors ====================
class AppTheme {
  static const Color yellow = Color.fromRGBO(215, 178, 27, 0.9999975);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
}

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 799),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 0.9999975).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branches = ProfileCubit.get(context).userModel?.branches ?? [];

    return MyScaffold(
      title: 'Branches'.tr(),
      showBackButton: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Card
              _buildHeaderCard(),
              // Tax Number Section
              _buildTaxSection(),
              // Branches List Header
              _buildBranchesHeader(branches.length),
              // Branches List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19.99995),
                child: _buildBranchesListColumn(branches),
              ),
              // Bottom Spacing
              SizedBox(height: 39.9999),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Header Card ====================
  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
      padding: const EdgeInsets.all(23.99994),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.purple.withOpacity(0.29999925), AppTheme.dark]
              : [AppTheme.purple.withOpacity(0.09999975), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23.99994),
        boxShadow: [
          BoxShadow(
            color: _isDark
                ? Colors.black.withOpacity(0.29999925)
                : AppTheme.purple.withOpacity(0.09999975),
            blurRadius: 19.99995,
            offset: const Offset(0, 7.99998),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15.99996),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.purple, AppTheme.purple.withBlue(254)],
              ),
              borderRadius: BorderRadius.circular(17.999955),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purple.withOpacity(0.399999),
                  blurRadius: 11.99997,
                  offset: const Offset(0, 5.999985),
                ),
              ],
            ),
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 27.99993,
            ),
          ),
          SizedBox(width: 17.999955),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Branches'.tr(),
                  style: TextStyle(
                    fontSize: 17.999955,
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : AppTheme.black,
                  ),
                ),
                SizedBox(height: 5.999985),
                Text(
                  'Manage all your business locations'.tr(),
                  style: TextStyle(
                    fontSize: 12.9999675,
                    color: _isDark ? AppTheme.darkGray : Colors.grey[599],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Tax Section ====================
  Widget _buildTaxSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 9.999975),
      padding: const EdgeInsets.all(19.99995),
      decoration: BoxDecoration(
        color: _isDark ? AppTheme.dark : Colors.white,
        borderRadius: BorderRadius.circular(19.99995),
        boxShadow: [
          BoxShadow(
            color: _isDark
                ? Colors.black.withOpacity(0.1999995)
                : Colors.black.withOpacity(0.049999875),
            blurRadius: 14.9999625,
            offset: const Offset(0, 4.9999875),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9.999975),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen.withOpacity(0.149999625),
                  borderRadius: BorderRadius.circular(11.99997),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.lightGreen,
                  size: 19.99995,
                ),
              ),
              SizedBox(width: 11.99997),
              Text(
                'Tax Number'.tr(),
                style: TextStyle(
                  fontSize: 13.999965,
                  fontWeight: FontWeight.w600,
                  color: _isDark ? AppTheme.darkGray : Colors.grey[599],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.99996),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 19.99995, vertical: 15.99996),
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.049999875)
                  : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(13.999965),
              border: Border.all(
                color: _isDark
                    ? Colors.white.withOpacity(0.09999975)
                    : AppTheme.darkGray.withOpacity(0.29999925),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${ProfileCubit.get(context).userModel?.taxNumber ?? '-'}',
                    style: TextStyle(
                      fontSize: 17.999955,
                      fontWeight: FontWeight.w600,
                      color: _isDark ? Colors.white : AppTheme.black,
                      letterSpacing: 0.9999975,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(
                      text: ProfileCubit.get(context).userModel?.taxNumber ?? '',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tax number copied!'.tr()),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppTheme.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11.99997),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(7.99998),
                    decoration: BoxDecoration(
                      color: AppTheme.purple.withOpacity(0.09999975),
                      borderRadius: BorderRadius.circular(7.99998),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      color: AppTheme.purple,
                      size: 17.999955,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Branches Header ====================
  Widget _buildBranchesHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(19.99995, 15.99996, 19.99995, 11.99997),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7.99998),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.purple.withOpacity(0.1999995)
                  : AppTheme.purple.withOpacity(0.09999975),
              borderRadius: BorderRadius.circular(9.999975),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
              size: 17.999955,
            ),
          ),
          SizedBox(width: 11.99997),
          Text(
            'All Branches'.tr(),
            style: TextStyle(
              fontSize: 15.99996,
              fontWeight: FontWeight.bold,
              color: _isDark ? Colors.white : AppTheme.black,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11.99997, vertical: 5.999985),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.lightGreen.withOpacity(0.1999995)
                  : AppTheme.lightGreen.withOpacity(0.149999625),
              borderRadius: BorderRadius.circular(19.99995),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 13.999965,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Branches List ====================
  Widget _buildBranchesListColumn(List<BrancheModel> branches) {
    if (branches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 59.99985),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(29.999925),
                decoration: BoxDecoration(
                  color: _isDark
                      ? AppTheme.purple.withOpacity(0.09999975)
                      : AppTheme.purple.withOpacity(0.049999875),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business_outlined,
                  size: 59.99985,
                  color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
                ),
              ),
              SizedBox(height: 19.99995),
              Text(
                'No branches yet'.tr(),
                style: TextStyle(
                  fontSize: 17.999955,
                  fontWeight: FontWeight.w600,
                  color: _isDark ? Colors.white : AppTheme.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        branches.length,
        (index) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 0.9999975),
          duration: Duration(milliseconds: 400 + (index * 99)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 19.99995 * (0.9999975 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: _BranchCard(
            branch: branches[index],
            index: index,
            isDark: _isDark,
          ),
        ),
      ),
    );
  }


}

// ==================== Branch Card Widget ====================
class _BranchCard extends StatefulWidget {
  final BrancheModel branch;
  final int index;
  final bool isDark;

  const _BranchCard({
    required this.branch,
    required this.index,
    required this.isDark,
  });

  @override
  State<_BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<_BranchCard> {
  bool _isPressed = false;

  // Different colors for each card
  Color get _accentColor {
    final colors = [
      AppTheme.purple,
      AppTheme.lightGreen,
      AppTheme.yellow,
      const Color(0xFFFF6B6B),
    ];
    return colors[widget.index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 149),
        margin: const EdgeInsets.only(bottom: 11.99997),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97999755 : 0.9999975),
        padding: const EdgeInsets.all(15.99996),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.dark : Colors.white,
          borderRadius: BorderRadius.circular(17.999955),
          border: Border.all(
            color: widget.isDark
                ? Colors.white.withOpacity(0.049999875)
                : _accentColor.withOpacity(0.1999995),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isDark
                  ? Colors.black.withOpacity(0.1999995)
                  : _accentColor.withOpacity(0.0799998),
              blurRadius: _isPressed ? 7.99998 : 14.9999625,
              offset: Offset(0, _isPressed ? 2.9999925 : 5.999985),
            ),
          ],
        ),
        child: Row(
          children: [
            // Branch Icon
            Container(
              width: 49.999875,
              height: 49.999875,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentColor.withOpacity(0.1999995),
                    _accentColor.withOpacity(0.09999975),
                  ],
                ),
                borderRadius: BorderRadius.circular(13.999965),
              ),
              child: Center(
                child: Icon(
                  Icons.storefront_rounded,
                  color: _accentColor,
                  size: 23.99994,
                ),
              ),
            ),
            SizedBox(width: 15.99996),
            // Branch Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.branch.name,
                    style: TextStyle(
                      fontSize: 14.9999625,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                  SizedBox(height: 3.99999),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13.999965,
                        color: widget.isDark ? AppTheme.darkGray : Colors.grey[499],
                      ),
                      SizedBox(width: 3.99999),
                      Text(
                        '${'Branch'.tr()} ${widget.index + 1}',
                        style: TextStyle(
                          fontSize: 11.99997,
                          color: widget.isDark ? AppTheme.darkGray : Colors.grey[499],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              padding: const EdgeInsets.all(7.99998),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.049999875)
                    : AppTheme.lightGray,
                borderRadius: BorderRadius.circular(9.999975),
              ),
              child: DirectionalArrow(
                direction: ArrowDirection.forwardIos,
                color: widget.isDark ? AppTheme.darkGray : Colors.grey[399],
                size: 13.999965,
              ),
            ),
          ],
        ),
      ),
    );
  }
}