// import 'dart:math' as math;
// import 'dart:ui' as ui;
// import 'dart:io';
// import 'package:app/business_logic/auth/CheckPhoneCubit/check_phone_cubit.dart';
// import 'package:app/business_logic/warranty/cubit/warranty_cubit.dart';
// import 'package:app/data/constants/assets.dart';
// import 'package:app/functions/country_code_sheet.dart';
// import 'package:app/models/warranty_model.dart';
// import 'package:app/network/services/warranty_service.dart';
// import 'package:app/network/warranty_api.dart';
// import 'package:app/persentation/widgets/custom_date_picker.dart';
// import 'package:app/persentation/screens/warranty/warranty_strings.dart';
// import 'package:app/persentation/widgets/directional_arrow.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:image_picker/image_picker.dart';
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🎨 App Theme Colors - Official Brand Identity (Enhanced)
// // ═══════════════════════════════════════════════════════════════════════════
// class AppTheme {
//   AppTheme._();
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Primary Brand Colors (From User Request)
//   // ─────────────────────────────────────────────────────────────────────────
//   static const Color green = Color.fromRGBO(0, 200, 141, 1);
//   static const Color yellow = Color.fromRGBO(251, 191, 77, 1);
//   static const Color black = Color(0xFF1D1D25);
//   static const Color omnia = Color(0xFFE5E5F5);
//   static const Color dark = Color(0xFF081428);
//   static const Color purple = Color(0xFF6842E2);
//   static const Color lightGreen = Color(0xFF28E6C5);
//   static const Color darkGray = Color(0xFFC6CBE0);
//   static const Color lightGray = Color(0xFFF9FAFB);
//
//   // Extended UI Colors
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color red = Color(0xFFEF4444);
//   static const Color orange = Color(0xFFFF9F43);
//   static const Color blue = Color(0xFF3B82F6);
//   static const Color background = Color(0xFF15172A);
//   static const Color cardDark = Color(0xFF1E2030);
//   static const Color surfaceDark = Color(0xFF252836);
//   static const Color borderDark = Color(0xFF2D3748);
//   static const Color success = Color(0xFF10B981);
//   static const Color teal = Color(0xFF14B8A6);
//   static const Color pink = Color(0xFFEC4899);
//   static const Color indigo = Color(0xFF6366F1);
//   static const Color cyan = Color(0xFF06B6D4);
//   static const Color purpleLight = Color(0xFF8B5CF6);
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Dynamic Theme Helpers
//   // ─────────────────────────────────────────────────────────────────────────
//   static Color getBackground(bool isDark) => isDark ? background : omnia;
//   static Color getCard(bool isDark) => isDark ? cardDark : white;
//   static Color getSurface(bool isDark) => isDark ? surfaceDark : lightGray;
//   static Color getText(bool isDark) => isDark ? white : dark;
//   static Color getTextSecondary(bool isDark) =>
//       isDark ? darkGray : dark.withOpacity(0.6);
//   static Color getBorder(bool isDark) =>
//       isDark ? borderDark : darkGray.withOpacity(0.3);
//   static Color getDivider(bool isDark) =>
//       isDark ? white.withOpacity(0.08) : darkGray.withOpacity(0.2);
//   static Color getInputFill(bool isDark) =>
//       isDark ? surfaceDark.withOpacity(0.6) : lightGray;
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Gradient Presets
//   // ─────────────────────────────────────────────────────────────────────────
//   static LinearGradient primaryGradient({bool reversed = false}) =>
//       LinearGradient(
//         begin: reversed ? Alignment.bottomRight : Alignment.topLeft,
//         end: reversed ? Alignment.topLeft : Alignment.bottomRight,
//         colors: const [purple, purpleLight],
//       );
//
//   static LinearGradient successGradient() => const LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [green, lightGreen],
//   );
//
//   static LinearGradient goldGradient() => LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [yellow, yellow.withOpacity(0.85)],
//   );
//
//   static LinearGradient darkGradient() => LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [dark, dark.withOpacity(0.85)],
//   );
//
//   static LinearGradient glassGradient(bool isDark) => LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: isDark
//         ? [
//       white.withOpacity(0.1),
//       white.withOpacity(0.05),
//     ]
//         : [
//       white.withOpacity(0.8),
//       white.withOpacity(0.6),
//     ],
//   );
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Shadow Presets
//   // ─────────────────────────────────────────────────────────────────────────
//   static List<BoxShadow> softShadow(bool isDark) => [
//     BoxShadow(
//       color: isDark ? Colors.black38 : dark.withOpacity(0.06),
//       blurRadius: 24,
//       offset: const Offset(0, 8),
//       spreadRadius: 0,
//     ),
//   ];
//
//   static List<BoxShadow> elevatedShadow(Color color, bool isDark) => [
//     BoxShadow(
//       color: color.withOpacity(isDark ? 0.35 : 0.3),
//       blurRadius: 20,
//       offset: const Offset(0, 10),
//       spreadRadius: -4,
//     ),
//     BoxShadow(
//       color: color.withOpacity(isDark ? 0.2 : 0.15),
//       blurRadius: 40,
//       offset: const Offset(0, 20),
//       spreadRadius: -8,
//     ),
//   ];
//
//   static List<BoxShadow> glowShadow(Color color, {double intensity = 0.4}) => [
//     BoxShadow(
//       color: color.withOpacity(intensity),
//       blurRadius: 24,
//       spreadRadius: 0,
//     ),
//   ];
//
//   static List<BoxShadow> cardShadow(bool isDark) => [
//     BoxShadow(
//       color: isDark ? Colors.black26 : dark.withOpacity(0.04),
//       blurRadius: 16,
//       offset: const Offset(0, 4),
//     ),
//     BoxShadow(
//       color: isDark ? Colors.black12 : dark.withOpacity(0.02),
//       blurRadius: 32,
//       offset: const Offset(0, 12),
//     ),
//   ];
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Border Radius Presets
//   // ─────────────────────────────────────────────────────────────────────────
//   static const double radiusXS = 8.0;
//   static const double radiusSM = 12.0;
//   static const double radiusMD = 16.0;
//   static const double radiusLG = 20.0;
//   static const double radiusXL = 24.0;
//   static const double radiusXXL = 28.0;
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Animation Durations
//   // ─────────────────────────────────────────────────────────────────────────
//   static const Duration durationFast = Duration(milliseconds: 150);
//   // static const Duration durationNormal = Duration(milliseconds: 250);
//   static const Duration durationSlow = Duration(milliseconds: 400);
//   static const Duration durationSlower = Duration(milliseconds: 600);
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🛡️ Protected Areas Bottom Sheet - Premium UI
// // ═══════════════════════════════════════════════════════════════════════════
// class ProtectedAreasBottomSheet extends StatefulWidget {
//   final List<String> selectedAreas;
//   final List<String> availableAreas;
//   final bool isDark;
//   final String title;
//
//   const ProtectedAreasBottomSheet({
//     super.key,
//     required this.selectedAreas,
//     required this.availableAreas,
//     required this.isDark,
//     required this.title,
//   });
//
//   static Future<List<String>?> show({
//     required BuildContext context,
//     required List<String> selectedAreas,
//     required List<String> availableAreas,
//     String? title,
//   }) async {
//     HapticFeedback.selectionClick();
//
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return await showModalBottomSheet<List<String>>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       barrierColor: AppTheme.dark.withOpacity(0.6),
//       builder: (context) => ProtectedAreasBottomSheet(
//         selectedAreas: List.from(selectedAreas),
//         availableAreas: availableAreas,
//         isDark: isDark,
//         title: title ?? WarrantyStrings.protectedAreas,
//       ),
//     );
//   }
//
//   @override
//   State<ProtectedAreasBottomSheet> createState() =>
//       _ProtectedAreasBottomSheetState();
// }
//
// class _ProtectedAreasBottomSheetState extends State<ProtectedAreasBottomSheet>
//     with TickerProviderStateMixin {
//   late List<String> _tempSelectedAreas;
//   late AnimationController _slideController;
//   late AnimationController _itemsController;
//   late AnimationController _shimmerController;
//   late Animation<Offset> _slideAnimation;
//   late List<Animation<double>> _itemAnimations;
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Area Icons Map
//   // ─────────────────────────────────────────────────────────────────────────
//   final Map<String, IconData> _areaIcons = const {
//     'Front Window (L)': Icons.panorama_wide_angle_rounded,
//     'Front Window (R)': Icons.panorama_wide_angle_rounded,
//     'Rear Window (L)': Icons.panorama_wide_angle_outlined,
//     'Rear Window (R)': Icons.panorama_wide_angle_outlined,
//     'Side Windows': Icons.view_sidebar_rounded,
//     'Sunroof': Icons.wb_sunny_rounded,
//     'MPV - Rear Fix Window (L)': Icons.view_compact_alt_rounded,
//     'MPV - Rear Fix Window (R)': Icons.view_compact_alt_rounded,
//     'Full Vehicle': Icons.directions_car_rounded,
//     'Front Bumper': Icons.front_hand_rounded,
//     'Rear Bumper': Icons.back_hand_rounded,
//     'Hood': Icons.dashboard_rounded,
//     'Side Mirrors': Icons.view_in_ar_rounded,
//     'Doors (L)': Icons.door_front_door_rounded,
//     'Doors (R)': Icons.door_front_door_rounded,
//     'Roof': Icons.roofing_rounded,
//     'Trunk': Icons.inventory_2_rounded,
//     'Fenders (L)': Icons.rounded_corner_rounded,
//     'Fenders (R)': Icons.rounded_corner_rounded,
//     'Rocker Panel (L)': Icons.horizontal_rule_rounded,
//     'Rocker Panel (R)': Icons.horizontal_rule_rounded,
//     'Rear Fender (L)': Icons.rounded_corner_rounded,
//     'Rear Fender (R)': Icons.rounded_corner_rounded,
//   };
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Area Colors Map (Using Brand Colors)
//   // ─────────────────────────────────────────────────────────────────────────
//   final Map<String, Color> _areaColors = const {
//     'Front Window (L)': AppTheme.lightGreen,
//     'Front Window (R)': AppTheme.lightGreen,
//     'Rear Window (L)': AppTheme.blue,
//     'Rear Window (R)': AppTheme.blue,
//     'Side Windows': AppTheme.orange,
//     'Sunroof': AppTheme.yellow,
//     'MPV - Rear Fix Window (L)': AppTheme.cyan,
//     'MPV - Rear Fix Window (R)': AppTheme.cyan,
//     'Full Vehicle': AppTheme.purple,
//     'Front Bumper': AppTheme.pink,
//     'Rear Bumper': AppTheme.pink,
//     'Hood': AppTheme.purpleLight,
//     'Side Mirrors': AppTheme.cyan,
//     'Doors (L)': AppTheme.green,
//     'Doors (R)': AppTheme.green,
//     'Roof': AppTheme.orange,
//     'Trunk': AppTheme.indigo,
//     'Fenders (L)': AppTheme.teal,
//     'Fenders (R)': AppTheme.teal,
//     'Rocker Panel (L)': AppTheme.purple,
//     'Rocker Panel (R)': AppTheme.purple,
//     'Rear Fender (L)': AppTheme.teal,
//     'Rear Fender (R)': AppTheme.teal,
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _tempSelectedAreas = List.from(widget.selectedAreas);
//     _setupAnimations();
//   }
//
//   void _setupAnimations() {
//     _slideController = AnimationController(
//       duration: AppTheme.durationSlower,
//       vsync: this,
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.easeOutCubic,
//     ));
//
//     _itemsController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();
//
//     _itemAnimations = List.generate(widget.availableAreas.length, (index) {
//       final startInterval = (index / widget.availableAreas.length) * 0.5;
//       final endInterval = startInterval + 0.5;
//       return Tween<double>(begin: 0, end: 1).animate(
//         CurvedAnimation(
//           parent: _itemsController,
//           curve: Interval(
//             startInterval,
//             endInterval.clamp(0.0, 1.0),
//             curve: Curves.easeOutBack,
//           ),
//         ),
//       );
//     });
//
//     _slideController.forward();
//     Future.delayed(const Duration(milliseconds: 200), () {
//       if (mounted) _itemsController.forward();
//     });
//   }
//
//   @override
//   void dispose() {
//     _slideController.dispose();
//     _itemsController.dispose();
//     _shimmerController.dispose();
//     super.dispose();
//   }
//
//   void _toggleArea(String area) {
//     HapticFeedback.selectionClick();
//     setState(() {
//       if (_tempSelectedAreas.contains(area)) {
//         _tempSelectedAreas.remove(area);
//       } else {
//         _tempSelectedAreas.add(area);
//       }
//     });
//   }
//
//   void _selectAll() {
//     HapticFeedback.lightImpact();
//     setState(() => _tempSelectedAreas = List.from(widget.availableAreas));
//   }
//
//   void _clearAll() {
//     HapticFeedback.lightImpact();
//     setState(() => _tempSelectedAreas.clear());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: ui.TextDirection.ltr,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: Container(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.88,
//           ),
//           decoration: BoxDecoration(
//             color: AppTheme.getCard(widget.isDark),
//             borderRadius:
//             const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXXL)),
//             border: widget.isDark
//                 ? Border.all(color: AppTheme.borderDark.withOpacity(0.5))
//                 : null,
//             boxShadow: [
//               BoxShadow(
//                 color: AppTheme.dark.withOpacity(0.25),
//                 blurRadius: 40,
//                 offset: const Offset(0, -12),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHandle(),
//               _buildHeader(),
//               _buildQuickActions(),
//               _buildDivider(),
//               Flexible(child: _buildAreasGrid()),
//               _buildBottomActions(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHandle() {
//     return Container(
//       margin: const EdgeInsets.only(top: 12, bottom: 8),
//       width: 44,
//       height: 5,
//       decoration: BoxDecoration(
//         color: widget.isDark
//             ? AppTheme.white.withOpacity(0.12)
//             : AppTheme.darkGray.withOpacity(0.4),
//         borderRadius: BorderRadius.circular(3),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
//       child: Row(
//         children: [
//           // Animated Icon Container with Glow
//           TweenAnimationBuilder<double>(
//             tween: Tween(begin: 0, end: 1),
//             duration: const Duration(milliseconds: 700),
//             curve: Curves.elasticOut,
//             builder: (context, value, child) {
//               return Transform.scale(
//                 scale: value,
//                 child: Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     gradient: AppTheme.primaryGradient(),
//                     borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//                     boxShadow:
//                     AppTheme.elevatedShadow(AppTheme.purple, widget.isDark),
//                   ),
//                   child: const Icon(
//                     Icons.shield_rounded,
//                     color: Colors.white,
//                     size: 26,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.title,
//                   style: TextStyle(
//                     fontSize: 21,
//                     fontWeight: FontWeight.w800,
//                     color: AppTheme.getText(widget.isDark),
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   WarrantyStrings.selectAreasSubtitle,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: AppTheme.getTextSecondary(widget.isDark),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           _buildCloseButton(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCloseButton() {
//     return _PressableScale(
//       onPressed: () {
//         HapticFeedback.lightImpact();
//         Navigator.pop(context);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(11),
//         decoration: BoxDecoration(
//           color: AppTheme.getSurface(widget.isDark),
//           borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//           border: widget.isDark
//               ? Border.all(color: AppTheme.borderDark)
//               : Border.all(color: AppTheme.darkGray.withOpacity(0.2)),
//         ),
//         child: Icon(
//           Icons.close_rounded,
//           color: AppTheme.getTextSecondary(widget.isDark),
//           size: 20,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickActions() {
//     final allSelected =
//         _tempSelectedAreas.length == widget.availableAreas.length;
//     final noneSelected = _tempSelectedAreas.isEmpty;
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
//       child: Row(
//         children: [
//           Expanded(
//             child: _ModernQuickButton(
//               icon: Icons.select_all_rounded,
//               label: WarrantyStrings.selectAll,
//               isActive: allSelected,
//               isDark: widget.isDark,
//               color: AppTheme.green,
//               onTap: _selectAll,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _ModernQuickButton(
//               icon: Icons.deselect_rounded,
//               label: WarrantyStrings.clearAll,
//               isActive: noneSelected,
//               isDark: widget.isDark,
//               color: AppTheme.orange,
//               onTap: _clearAll,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDivider() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 24),
//       height: 1,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.transparent,
//             AppTheme.getDivider(widget.isDark),
//             Colors.transparent,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAreasGrid() {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(
//         parent: AlwaysScrollableScrollPhysics(),
//       ),
//       padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
//       child: Wrap(
//         spacing: 10,
//         runSpacing: 10,
//         children: widget.availableAreas.asMap().entries.map((entry) {
//           final index = entry.key;
//           final area = entry.value;
//           final isSelected = _tempSelectedAreas.contains(area);
//           final icon = _areaIcons[area] ?? Icons.check_circle_outline_rounded;
//           final color = _areaColors[area] ?? AppTheme.purple;
//
//           return AnimatedBuilder(
//             animation: _itemAnimations[index],
//             builder: (context, child) {
//               final value = _itemAnimations[index].value;
//               return Transform.scale(
//                 scale: value,
//                 child: Opacity(
//                   opacity: value.clamp(0.0, 1.0),
//                   child: child,
//                 ),
//               );
//             },
//             child: _ModernAreaChip(
//               area: area,
//               icon: icon,
//               color: color,
//               isSelected: isSelected,
//               isDark: widget.isDark,
//               onTap: () => _toggleArea(area),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildBottomActions() {
//     final hasSelection = _tempSelectedAreas.isNotEmpty;
//
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         24,
//         20,
//         24,
//         MediaQuery.of(context).padding.bottom + 24,
//       ),
//       decoration: BoxDecoration(
//         color: AppTheme.getSurface(widget.isDark),
//         borderRadius:
//         const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
//         border: Border(
//           top: BorderSide(
//             color: AppTheme.getDivider(widget.isDark),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Selection Status Badge
//           _buildSelectionStatus(hasSelection),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: _ModernActionButton(
//                   label: WarrantyStrings.cancel,
//                   isPrimary: false,
//                   isDark: widget.isDark,
//                   onTap: () => Navigator.pop(context),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 flex: 2,
//                 child: _ModernActionButton(
//                   label: WarrantyStrings.confirmSelection,
//                   isPrimary: true,
//                   isDark: widget.isDark,
//                   isEnabled: hasSelection,
//                   icon: Icons.check_rounded,
//                   onTap: hasSelection
//                       ? () {
//                     HapticFeedback.mediumImpact();
//                     Navigator.pop(context, _tempSelectedAreas);
//                   }
//                       : null,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSelectionStatus(bool hasSelection) {
//     return AnimatedContainer(
//       duration: AppTheme.durationNormal,
//       curve: Curves.easeOutCubic,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: hasSelection
//               ? [
//             AppTheme.green.withOpacity(0.15),
//             AppTheme.green.withOpacity(0.08),
//           ]
//               : [
//             AppTheme.yellow.withOpacity(0.15),
//             AppTheme.yellow.withOpacity(0.08),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//         border: Border.all(
//           color: hasSelection
//               ? AppTheme.green.withOpacity(0.35)
//               : AppTheme.yellow.withOpacity(0.35),
//           width: 1.5,
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedSwitcher(
//             duration: AppTheme.durationFast,
//             transitionBuilder: (child, animation) {
//               return ScaleTransition(scale: animation, child: child);
//             },
//             child: Icon(
//               hasSelection
//                   ? Icons.check_circle_rounded
//                   : Icons.warning_amber_rounded,
//               key: ValueKey(hasSelection),
//               color: hasSelection ? AppTheme.green : AppTheme.yellow,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 10),
//           AnimatedSwitcher(
//             duration: AppTheme.durationFast,
//             child: Text(
//               hasSelection
//                   ? '${WarrantyStrings.selected} ${_tempSelectedAreas.length} ${WarrantyStrings.from} ${widget.availableAreas.length} ${WarrantyStrings.areas}'
//                   : WarrantyStrings.selectOneAreaRequired,
//               key: ValueKey(hasSelection ? 'selected' : 'required'),
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: hasSelection ? AppTheme.green : AppTheme.yellow,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🎯 Modern Area Chip Widget - Enhanced
// // ═══════════════════════════════════════════════════════════════════════════
// class _ModernAreaChip extends StatefulWidget {
//   final String area;
//   final IconData icon;
//   final Color color;
//   final bool isSelected;
//   final bool isDark;
//   final VoidCallback onTap;
//
//   const _ModernAreaChip({
//     required this.area,
//     required this.icon,
//     required this.color,
//     required this.isSelected,
//     required this.isDark,
//     required this.onTap,
//   });
//
//   @override
//   State<_ModernAreaChip> createState() => _ModernAreaChipState();
// }
//
// class _ModernAreaChipState extends State<_ModernAreaChip>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   bool _isPressed = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: AppTheme.durationFast,
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _handleTapDown(TapDownDetails details) {
//     setState(() => _isPressed = true);
//     _controller.forward();
//   }
//
//   void _handleTapUp(TapUpDetails details) {
//     setState(() => _isPressed = false);
//     _controller.reverse();
//     widget.onTap();
//   }
//
//   void _handleTapCancel() {
//     setState(() => _isPressed = false);
//     _controller.reverse();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: _handleTapDown,
//       onTapUp: _handleTapUp,
//       onTapCancel: _handleTapCancel,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: AnimatedContainer(
//           duration: AppTheme.durationNormal,
//           curve: Curves.easeOutCubic,
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
//           decoration: BoxDecoration(
//             gradient: widget.isSelected
//                 ? LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [widget.color, widget.color.withOpacity(0.85)],
//             )
//                 : null,
//             color: widget.isSelected
//                 ? null
//                 : widget.isDark
//                 ? AppTheme.surfaceDark
//                 : AppTheme.white,
//             borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//             border: Border.all(
//               color: widget.isSelected
//                   ? Colors.transparent
//                   : widget.isDark
//                   ? AppTheme.borderDark
//                   : AppTheme.darkGray.withOpacity(0.25),
//               width: 1.5,
//             ),
//             boxShadow: widget.isSelected
//                 ? [
//               BoxShadow(
//                 color: widget.color
//                     .withOpacity(widget.isDark ? 0.35 : 0.3),
//                 blurRadius: 16,
//                 offset: const Offset(0, 6),
//                 spreadRadius: -2,
//               ),
//             ]
//                 : [
//               BoxShadow(
//                 color: widget.isDark
//                     ? Colors.black.withOpacity(0.15)
//                     : AppTheme.dark.withOpacity(0.04),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Icon Container
//               AnimatedContainer(
//                 duration: AppTheme.durationFast,
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: widget.isSelected
//                       ? Colors.white.withOpacity(0.22)
//                       : widget.color.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   widget.icon,
//                   size: 16,
//                   color: widget.isSelected ? Colors.white : widget.color,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               // Label
//               Text(
//                 widget.area,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight:
//                   widget.isSelected ? FontWeight.w600 : FontWeight.w500,
//                   color: widget.isSelected
//                       ? Colors.white
//                       : AppTheme.getText(widget.isDark),
//                   letterSpacing: -0.2,
//                 ),
//               ),
//               // Check Indicator
//               AnimatedSize(
//                 duration: AppTheme.durationFast,
//                 curve: Curves.easeOutCubic,
//                 child: widget.isSelected
//                     ? Padding(
//                   padding: const EdgeInsets.only(left: 8),
//                   child: Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.25),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.check_rounded,
//                       size: 12,
//                       color: Colors.white,
//                     ),
//                   ),
//                 )
//                     : const SizedBox.shrink(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // ⚡ Modern Quick Button - Enhanced
// // ═══════════════════════════════════════════════════════════════════════════
// class _ModernQuickButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool isActive;
//   final bool isDark;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _ModernQuickButton({
//     required this.icon,
//     required this.label,
//     required this.isActive,
//     required this.isDark,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return _PressableScale(
//       onPressed: onTap,
//       child: AnimatedContainer(
//         duration: AppTheme.durationNormal,
//         padding: const EdgeInsets.symmetric(vertical: 13),
//         decoration: BoxDecoration(
//           color: isActive
//               ? color.withOpacity(isDark ? 0.18 : 0.12)
//               : AppTheme.getSurface(isDark),
//           borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//           border: Border.all(
//             color: isActive
//                 ? color.withOpacity(0.4)
//                 : AppTheme.getBorder(isDark),
//             width: isActive ? 1.5 : 1,
//           ),
//           boxShadow: isActive
//               ? [
//             BoxShadow(
//               color: color.withOpacity(0.15),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ]
//               : null,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 18,
//               color: isActive ? color : AppTheme.getTextSecondary(isDark),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: isActive ? color : AppTheme.getTextSecondary(isDark),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🔘 Modern Action Button - Enhanced
// // ═══════════════════════════════════════════════════════════════════════════
// class _ModernActionButton extends StatefulWidget {
//   final String label;
//   final bool isPrimary;
//   final bool isDark;
//   final bool isEnabled;
//   final IconData? icon;
//   final VoidCallback? onTap;
//
//   const _ModernActionButton({
//     required this.label,
//     required this.isPrimary,
//     required this.isDark,
//     this.isEnabled = true,
//     this.icon,
//     this.onTap,
//   });
//
//   @override
//   State<_ModernActionButton> createState() => _ModernActionButtonState();
// }
//
// class _ModernActionButtonState extends State<_ModernActionButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isEnabled = widget.isEnabled && widget.onTap != null;
//
//     return GestureDetector(
//       onTapDown: isEnabled ? (_) => _controller.forward() : null,
//       onTapUp: isEnabled
//           ? (_) {
//         _controller.reverse();
//         widget.onTap?.call();
//       }
//           : null,
//       onTapCancel: isEnabled ? () => _controller.reverse() : null,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: AnimatedContainer(
//           duration: AppTheme.durationNormal,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           decoration: BoxDecoration(
//             gradient: widget.isPrimary && isEnabled
//                 ? AppTheme.primaryGradient()
//                 : null,
//             color: widget.isPrimary
//                 ? (isEnabled ? null : AppTheme.darkGray.withOpacity(0.4))
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//             border: widget.isPrimary
//                 ? null
//                 : Border.all(
//               color: AppTheme.getBorder(widget.isDark),
//               width: 1.5,
//             ),
//             boxShadow: widget.isPrimary && isEnabled
//                 ? AppTheme.elevatedShadow(AppTheme.purple, widget.isDark)
//                 : null,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (widget.icon != null && widget.isPrimary) ...[
//                 Icon(widget.icon, color: Colors.white, size: 20),
//                 const SizedBox(width: 8),
//               ],
//               Text(
//                 widget.label,
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                   color: widget.isPrimary
//                       ? (isEnabled ? Colors.white : AppTheme.darkGray)
//                       : AppTheme.getTextSecondary(widget.isDark),
//                   letterSpacing: -0.2,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 👆 Pressable Scale Widget - Reusable Interaction
// // ═══════════════════════════════════════════════════════════════════════════
// class _PressableScale extends StatefulWidget {
//   final Widget child;
//   final VoidCallback onPressed;
//   final double scaleFactor;
//
//   const _PressableScale({
//     required this.child,
//     required this.onPressed,
//     this.scaleFactor = 0.96,
//   });
//
//   @override
//   State<_PressableScale> createState() => _PressableScaleState();
// }
//
// class _PressableScaleState extends State<_PressableScale>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => _controller.forward(),
//       onTapUp: (_) {
//         _controller.reverse();
//         widget.onPressed();
//       },
//       onTapCancel: () => _controller.reverse(),
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: widget.child,
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🎯 New Warranty Screen - Premium UI/UX
// // ═══════════════════════════════════════════════════════════════════════════
// class NewWarrantyScreen extends StatelessWidget {
//   const NewWarrantyScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: ui.TextDirection.ltr,
//       child: MultiBlocProvider(
//         providers: [
//           BlocProvider(create: (_) => WarrantyCubit(WarrantyService())),
//           BlocProvider(create: (_) => CheckPhoneCubit()),
//         ],
//         child: const _NewWarrantyContent(),
//       ),
//     );
//   }
// }
//
// class _NewWarrantyContent extends StatefulWidget {
//   const _NewWarrantyContent();
//
//   @override
//   State<_NewWarrantyContent> createState() => _NewWarrantyContentState();
// }
//
// class _NewWarrantyContentState extends State<_NewWarrantyContent>
//     with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _scrollController = ScrollController();
//
//   late AnimationController _headerController;
//   late AnimationController _formController;
//   late AnimationController _pulseController;
//   late AnimationController _floatingController;
//   late List<Animation<double>> _sectionAnimations;
//   late Animation<double> _headerSlideAnimation;
//
//   bool get _isDark => Theme.of(context).brightness == Brightness.dark;
//
//   // Form Controllers
//   late final Map<String, TextEditingController> _controllers;
//   final Map<String, FocusNode> _focusNodes = {};
//
//   // Windows Areas
//   final List<String> _selectedWindowAreas = [];
//   List<String> _availableWindowAreas = [];
//
//   // PPF/Vinyl Areas
//   final List<String> _selectedPPFAreas = [];
//   List<String> _availablePPFAreas = [];
//
//   // Images
//   final List<XFile> _selectedImages = [];
//   final int _maxImages = 5;
//   final ImagePicker _imagePicker = ImagePicker();
//
//   // Loading state
//   bool _isLoadingLists = false;
//
//   // Stepper
//   int _currentStep = 0;
//   final int _totalSteps = 3;
//
//   // Scroll offset for parallax effects
//   double _scrollOffset = 0;
//   bool _isScrolled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initControllers();
//     _setupAnimations();
//     _loadPPFAndWindowLists();
//     _scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     setState(() {
//       _scrollOffset = _scrollController.offset;
//       _isScrolled = _scrollOffset > 20;
//     });
//   }
//
//   void _initControllers() {
//     final fields = [
//       'ownerFirstName',
//       'ownerLastName',
//       'ownerPhoneAreaCode',
//       'ownerPhone',
//       'ownerEmail',
//       'warrantyCode',
//       'serialCode',
//       'installDate',
//       'vehicleMake',
//       'vehicleModel',
//       'vehicleYear',
//       'vehicleColor',
//       'vehicleLicense',
//       'usedMeters'
//     ];
//
//     _controllers = {for (var field in fields) field: TextEditingController()};
//
//     for (var field in fields) {
//       _focusNodes[field] = FocusNode();
//     }
//
//     // Initialize with US country code as default
//     _controllers['ownerPhoneAreaCode']!.text = '+1';
//   }
//
//   Future<void> _loadPPFAndWindowLists() async {
//     setState(() => _isLoadingLists = true);
//
//     try {
//       print('\n🔍 Loading PPF & Windows Lists...');
//
//       // Load PPF and Windows from single endpoint
//       final apiResponse = await WarrantyApi.getPPFList();
//
//       print('📦 Response Status: ${apiResponse.statusCode}');
//       print('📦 Response Data: ${apiResponse.data}');
//
//       if (apiResponse.statusCode == 200) {
//         final response = apiResponse.data;
//         print('✅ Response type: ${response.runtimeType}');
//
//         if (response is Map<String, dynamic> && response.containsKey('data')) {
//           final data = response['data'];
//           print('📂 Data contents: $data');
//
//           // Load PPF Areas
//           if (data.containsKey('ppf') && data['ppf'] is List) {
//             final List<dynamic> ppfList = data['ppf'];
//             print('🎨 PPF Areas found: ${ppfList.length} items');
//             print('   PPF List: $ppfList');
//             setState(() => _availablePPFAreas = ppfList.cast<String>());
//           } else {
//             print('⚠️ No PPF data in response');
//             setState(() => _availablePPFAreas = []);
//           }
//
//           // Load Window Areas
//           if (data.containsKey('window') && data['window'] is List) {
//             final List<dynamic> windowList = data['window'];
//             print('🪟 Window Areas found: ${windowList.length} items');
//             print('   Window List: $windowList');
//             setState(() => _availableWindowAreas = windowList.cast<String>());
//           } else if (data.containsKey('windowOptions') && data['windowOptions'] is List) {
//             // Support windowOptions format
//             final List<dynamic> windowList = data['windowOptions'];
//             print('🪟 Window Areas found (windowOptions): ${windowList.length} items');
//             print('   Window List: $windowList');
//             setState(() => _availableWindowAreas = windowList.cast<String>());
//           } else {
//             print('⚠️ No Window data in response');
//             // Try loading from separate endpoint
//             print('🔄 Attempting to load windows from separate endpoint...');
//             try {
//               final windowResponse = await WarrantyApi.getWindowList();
//               if (windowResponse.statusCode == 200) {
//                 final windowData = windowResponse.data;
//                 print('📦 Window Response: $windowData');
//
//                 if (windowData is Map<String, dynamic> && windowData.containsKey('data')) {
//                   final innerData = windowData['data'];
//                   List<dynamic>? windowList;
//
//                   // Try multiple possible keys
//                   if (innerData is Map<String, dynamic>) {
//                     if (innerData.containsKey('window') && innerData['window'] is List) {
//                       windowList = innerData['window'];
//                     } else if (innerData.containsKey('windowOptions') && innerData['windowOptions'] is List) {
//                       windowList = innerData['windowOptions'];
//                     }
//                   } else if (innerData is List) {
//                     windowList = innerData;
//                   }
//
//                   if (windowList != null) {
//                     print('✅ Windows loaded from separate endpoint: ${windowList.length} items');
//                     setState(() => _availableWindowAreas = windowList!.cast<String>());
//                   } else {
//                     print('⚠️ Could not extract window list from response');
//                     setState(() => _availableWindowAreas = []);
//                   }
//                 }
//               }
//             } catch (e) {
//               print('❌ Failed to load from window endpoint: $e');
//               setState(() => _availableWindowAreas = []);
//             }
//           }
//
//           // Backward compatibility - Only apply if PPF is empty
//           if (_availablePPFAreas.isEmpty &&
//               !data.containsKey('ppf') &&
//               data.containsKey('ppfOptions')) {
//             final List<dynamic> ppfOptions = data['ppfOptions'];
//             print('⚙️ Using backward compatible ppfOptions: ${ppfOptions.length} items');
//             setState(() {
//               _availablePPFAreas = ppfOptions.cast<String>();
//               // Don't touch window areas if already loaded
//             });
//           }
//
//           print('\n📊 Final counts:');
//           print('   PPF Areas: ${_availablePPFAreas.length}');
//           print('   Window Areas: ${_availableWindowAreas.length}\n');
//         } else {
//           print('❌ Invalid response structure - using defaults');
//           _setDefaultLists();
//         }
//       } else {
//         print('❌ API returned status ${apiResponse.statusCode} - using defaults');
//         _setDefaultLists();
//       }
//     } catch (e) {
//       print('❌ Exception loading lists: $e');
//       _setDefaultLists();
//     } finally {
//       setState(() => _isLoadingLists = false);
//     }
//   }
//
//   void _setDefaultLists() {
//     setState(() {
//       _availableWindowAreas = [];
//       _availablePPFAreas = [
//         'Full Vehicle',
//         'Front Bumper',
//         'Rear Bumper',
//         'Hood',
//         'Rocker Panel (L)',
//         'Rocker Panel (R)',
//       ];
//     });
//   }
//
//   void _setupAnimations() {
//     _headerController = AnimationController(
//       duration: AppTheme.durationSlower,
//       vsync: this,
//     );
//
//     _headerSlideAnimation = Tween<double>(begin: -80, end: 0).animate(
//       CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
//     );
//
//     _formController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
//
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _floatingController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _sectionAnimations = List.generate(6, (index) {
//       return Tween<double>(begin: 0, end: 1).animate(
//         CurvedAnimation(
//           parent: _formController,
//           curve: Interval(
//             index * 0.08,
//             0.4 + index * 0.08,
//             curve: Curves.easeOutCubic,
//           ),
//         ),
//       );
//     });
//
//     _headerController.forward();
//     Future.delayed(const Duration(milliseconds: 150), () {
//       if (mounted) _formController.forward();
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     _headerController.dispose();
//     _formController.dispose();
//     _pulseController.dispose();
//     _floatingController.dispose();
//     for (var controller in _controllers.values) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes.values) {
//       node.dispose();
//     }
//     super.dispose();
//   }
//
//   Future<void> _selectDate() async {
//     HapticFeedback.selectionClick();
//     final DateTime? picked = await CustomDatePicker.showBottomSheet(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       title: WarrantyStrings.installationDate,
//     );
//
//     if (picked != null) {
//       _controllers['installDate']!.text =
//           DateFormat('yyyy-MM-dd').format(picked);
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Image Selection Methods
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Future<void> _pickImageFromGallery() async {
//     if (_selectedImages.length >= _maxImages) {
//       _showInfoSnackBar('Maximum $_maxImages images allowed');
//       return;
//     }
//
//     HapticFeedback.selectionClick();
//     try {
//       final XFile? image = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         setState(() => _selectedImages.add(image));
//         HapticFeedback.lightImpact();
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to pick image: ${e.toString()}');
//     }
//   }
//
//   Future<void> _pickImageFromCamera() async {
//     if (_selectedImages.length >= _maxImages) {
//       _showInfoSnackBar('Maximum $_maxImages images allowed');
//       return;
//     }
//
//     HapticFeedback.selectionClick();
//     try {
//       final XFile? image = await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         setState(() => _selectedImages.add(image));
//         HapticFeedback.lightImpact();
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to capture image: ${e.toString()}');
//     }
//   }
//
//   void _removeImage(int index) {
//     HapticFeedback.mediumImpact();
//     setState(() => _selectedImages.removeAt(index));
//   }
//
//   void _showImagePickerOptions() {
//     HapticFeedback.selectionClick();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).padding.bottom + 24,
//           top: 24,
//           left: 24,
//           right: 24,
//         ),
//         decoration: BoxDecoration(
//           color: AppTheme.getCard(_isDark),
//           borderRadius: const BorderRadius.vertical(
//             top: Radius.circular(AppTheme.radiusXXL),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 44,
//               height: 5,
//               margin: const EdgeInsets.only(bottom: 20),
//               decoration: BoxDecoration(
//                 color: AppTheme.darkGray.withOpacity(0.4),
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//             Text(
//               'Add Image',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: AppTheme.getText(_isDark),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 Expanded(
//                   child: _ImagePickerOption(
//                     icon: Icons.photo_library_rounded,
//                     label: 'Gallery',
//                     color: AppTheme.purple,
//                     isDark: _isDark,
//                     onTap: () {
//                       Navigator.pop(context);
//                       _pickImageFromGallery();
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _ImagePickerOption(
//                     icon: Icons.camera_alt_rounded,
//                     label: 'Camera',
//                     color: AppTheme.green,
//                     isDark: _isDark,
//                     onTap: () {
//                       Navigator.pop(context);
//                       _pickImageFromCamera();
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _openWindowAreasSheet() async {
//     if (_isLoadingLists) {
//       _showInfoSnackBar(WarrantyStrings.loadingData);
//       return;
//     }
//
//     if (_availableWindowAreas.isEmpty) {
//       _showInfoSnackBar(WarrantyStrings.noDataAvailable);
//       return;
//     }
//
//     final result = await ProtectedAreasBottomSheet.show(
//       context: context,
//       selectedAreas: _selectedWindowAreas,
//       availableAreas: _availableWindowAreas,
//       title: 'Windows Areas',
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedWindowAreas.clear();
//         _selectedWindowAreas.addAll(result);
//       });
//     }
//   }
//
//   Future<void> _openPPFAreasSheet() async {
//     if (_isLoadingLists) {
//       _showInfoSnackBar(WarrantyStrings.loadingData);
//       return;
//     }
//
//     if (_availablePPFAreas.isEmpty) {
//       _showInfoSnackBar(WarrantyStrings.noDataAvailable);
//       return;
//     }
//
//     final result = await ProtectedAreasBottomSheet.show(
//       context: context,
//       selectedAreas: _selectedPPFAreas,
//       availableAreas: _availablePPFAreas,
//       title: 'PPF/Vinyl Areas',
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedPPFAreas.clear();
//         _selectedPPFAreas.addAll(result);
//       });
//     }
//   }
//
//   void _submitForm() async {
//     HapticFeedback.mediumImpact();
//
//     if (_formKey.currentState!.validate()) {
//       if (_selectedWindowAreas.isEmpty && _selectedPPFAreas.isEmpty) {
//         _showValidationError(
//             'يرجى اختيار منطقة واحدة على الأقل (Windows أو PPF/Vinyl)');
//         return;
//       }
//
//       try {
//         final List<Map<String, dynamic>> products = [
//           {
//             'usedMeters': double.tryParse(_controllers['usedMeters']!.text) ?? 0.0,
//             'warrantyCode': _controllers['warrantyCode']!.text,
//             'serialCode': _controllers['serialCode']!.text,
//             'protectedArea': [
//               ..._selectedWindowAreas,
//               ..._selectedPPFAreas,
//             ],
//           }
//         ];
//
//         final response = await WarrantyApi.registerWarranty(
//           installDate: _controllers['installDate']!.text,
//           ownerFirstName: _controllers['ownerFirstName']!.text,
//           ownerLastName: _controllers['ownerLastName']!.text,
//           ownerPhoneAreaCode: _controllers['ownerPhoneAreaCode']!.text,
//           ownerPhone: _controllers['ownerPhone']!.text,
//           ownerEmail: _controllers['ownerEmail']!.text,
//           vehicleMake: _controllers['vehicleMake']!.text,
//           vehicleModel: _controllers['vehicleModel']!.text,
//           vehicleYear: _controllers['vehicleYear']!.text,
//           vehicleColor: _controllers['vehicleColor']!.text,
//           vehicleLicense: _controllers['vehicleLicense']!.text,
//           products: products,
//           remarks: null,
//         );
//
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           Navigator.pushReplacement(
//             context,
//             _createPageRoute(const WarrantySuccessScreen()),
//           );
//         } else {
//           _showValidationError(WarrantyStrings.registrationError);
//         }
//       } catch (e) {
//         _showValidationError('${WarrantyStrings.error}: ${e.toString()}');
//       }
//     } else {
//       HapticFeedback.heavyImpact();
//       _showValidationError(WarrantyStrings.fillRequiredFields);
//     }
//   }
//
//   PageRouteBuilder _createPageRoute(Widget page) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         final curvedAnimation = CurvedAnimation(
//           parent: animation,
//           curve: Curves.easeOutCubic,
//         );
//         return FadeTransition(
//           opacity: curvedAnimation,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0, 0.03),
//               end: Offset.zero,
//             ).animate(curvedAnimation),
//             child: child,
//           ),
//         );
//       },
//       transitionDuration: AppTheme.durationSlow,
//     );
//   }
//
//   void _showValidationError([String? message]) {
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.warning_amber_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message ?? WarrantyStrings.fillRequiredFields,
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.yellow,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//         ),
//         margin: const EdgeInsets.all(16),
//         elevation: 12,
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }
//
//   void _showInfoSnackBar(String message) {
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.info_outline_rounded, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(fontWeight: FontWeight.w500),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.blue,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//         ),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.error_outline_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//         ),
//         margin: const EdgeInsets.all(16),
//         elevation: 12,
//         action: SnackBarAction(
//           label: WarrantyStrings.close,
//           textColor: Colors.white,
//           onPressed: () {},
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.getBackground(_isDark),
//       body: BlocListener<WarrantyCubit, WarrantyState>(
//         listener: (context, state) {
//           if (state is WarrantyError) {
//             _showErrorSnackBar(state.message);
//           } else if (state is WarrantySuccess) {
//             HapticFeedback.heavyImpact();
//             _showInfoSnackBar('Certificate issued successfully!');
//             Navigator.pop(context);
//           }
//         },
//         child: BlocBuilder<WarrantyCubit, WarrantyState>(
//           builder: (context, state) {
//             return Stack(
//               children: [
//                 // Background Decorations
//                 _buildBackgroundDecorations(),
//
//                 SafeArea(
//                   child: Column(
//                     children: [
//                       _buildCustomAppBar(),
//                       _buildModernStepper(),
//                       Expanded(
//                         child: SingleChildScrollView(
//                           controller: _scrollController,
//                           physics: const BouncingScrollPhysics(
//                             parent: AlwaysScrollableScrollPhysics(),
//                           ),
//                           padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
//                           child: Form(
//                             key: _formKey,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // 1️⃣ Installation Date - First Field
//                                 _buildAnimatedSection(
//                                   0,
//                                   _buildInstallationDateField(),
//                                 ),
//                                 const SizedBox(height: 20),
//
//                                 // 2️⃣ Customer Information
//                                 _buildAnimatedSection(
//                                   0,
//                                   _buildOwnerInfoSection(),
//                                 ),
//                                 const SizedBox(height: 20),
//
//                                 // 3️⃣ Warranty Information (includes Installation Details, PPF, Windows)
//                                 _buildAnimatedSection(
//                                   1,
//                                   _buildWarrantyInfoSection(),
//                                 ),
//                                 const SizedBox(height: 20),
//
//                                 // 4️⃣ Vehicle Information
//                                 _buildAnimatedSection(
//                                   2,
//                                   _buildCarInfoSection(),
//                                 ),
//                                 const SizedBox(height: 20),
//
//                                 // 5️⃣ Images Section
//                                 _buildAnimatedSection(
//                                   3,
//                                   _buildImagesSection(),
//                                 ),
//                                 const SizedBox(height: 36),
//
//                                 // Submit Button
//                                 _buildAnimatedSection(
//                                   5,
//                                   _buildSubmitButton(state),
//                                 ),
//                                 const SizedBox(height: 40),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 if (state is WarrantyLoading) _buildModernLoadingOverlay(),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBackgroundDecorations() {
//     return Stack(
//       children: [
//         // Top Right Gradient Orb
//         AnimatedBuilder(
//           animation: _floatingController,
//           builder: (context, child) {
//             return Positioned(
//               top: -80 - (_scrollOffset * 0.2),
//               right: -60 + (_floatingController.value * 15),
//               child: Opacity(
//                 opacity: _isDark ? 0.08 : 0.1,
//                 child: Container(
//                   width: 280,
//                   height: 280,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: RadialGradient(
//                       colors: [
//                         AppTheme.purple,
//                         AppTheme.purple.withOpacity(0),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//
//         // Bottom Left Gradient Orb
//         AnimatedBuilder(
//           animation: _floatingController,
//           builder: (context, child) {
//             return Positioned(
//               bottom: 100,
//               left: -100 - (_floatingController.value * 10),
//               child: Opacity(
//                 opacity: _isDark ? 0.06 : 0.08,
//                 child: Container(
//                   width: 220,
//                   height: 220,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: RadialGradient(
//                       colors: [
//                         AppTheme.green,
//                         AppTheme.green.withOpacity(0),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCustomAppBar() {
//     return AnimatedBuilder(
//       animation: _headerSlideAnimation,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, _headerSlideAnimation.value),
//           child: Opacity(
//             opacity: ((_headerSlideAnimation.value + 80) / 80).clamp(0.0, 1.0),
//             child: child,
//           ),
//         );
//       },
//       child: AnimatedContainer(
//         duration: AppTheme.durationNormal,
//         padding: const EdgeInsets.fromLTRB(16, 12, 20, 16),
//         decoration: BoxDecoration(
//           color: _isScrolled
//               ? AppTheme.getCard(_isDark).withOpacity(0.95)
//               : AppTheme.getCard(_isDark),
//           border: _isDark
//               ? Border(
//             bottom: BorderSide(
//               color: _isScrolled
//                   ? AppTheme.borderDark.withOpacity(0.6)
//                   : AppTheme.borderDark.withOpacity(0.3),
//             ),
//           )
//               : null,
//           boxShadow: _isScrolled ? AppTheme.softShadow(_isDark) : null,
//         ),
//         child: Row(
//           children: [
//             _buildBackButton(),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     WarrantyStrings.newTitle,
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w800,
//                       color: AppTheme.getText(_isDark),
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 3),
//                   Text(
//                     WarrantyStrings.newSubtitle,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: AppTheme.getTextSecondary(_isDark),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _buildHelpButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBackButton() {
//     return _PressableScale(
//       onPressed: () {
//         HapticFeedback.lightImpact();
//         Navigator.pop(context);
//       },
//       child: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           gradient: AppTheme.primaryGradient(),
//           borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//           boxShadow: AppTheme.elevatedShadow(AppTheme.purple, _isDark),
//         ),
//         child: DirectionalArrow(
//           direction: ArrowDirection.backIos,
//           color: Colors.white,
//           size: 18,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHelpButton() {
//     return _PressableScale(
//       onPressed: _showHelpDialog,
//       child: Container(
//         width: 46,
//         height: 46,
//         decoration: BoxDecoration(
//           color: AppTheme.getSurface(_isDark),
//           borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//           border: Border.all(
//             color: AppTheme.getBorder(_isDark),
//             width: 1,
//           ),
//         ),
//         child: Icon(
//           Icons.help_outline_rounded,
//           color: AppTheme.getTextSecondary(_isDark),
//           size: 22,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildModernStepper() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//       child: Column(
//         children: [
//           // Progress Bar with Steps
//           Row(
//             children: List.generate(_totalSteps, (index) {
//               final isActive = index <= _currentStep;
//               final isCompleted = index < _currentStep;
//               final isCurrent = index == _currentStep;
//
//               return Expanded(
//                 child: Row(
//                   children: [
//                     // Step Circle
//                     AnimatedBuilder(
//                       animation: _pulseController,
//                       builder: (context, child) {
//                         return Transform.scale(
//                           scale: isCurrent
//                               ? 1.0 + (_pulseController.value * 0.03)
//                               : 1.0,
//                           child: child,
//                         );
//                       },
//                       child: AnimatedContainer(
//                         duration: AppTheme.durationNormal,
//                         curve: Curves.easeOutCubic,
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           gradient: isActive
//                               ? AppTheme.primaryGradient()
//                               : null,
//                           color: isActive
//                               ? null
//                               : AppTheme.getSurface(_isDark),
//                           shape: BoxShape.circle,
//                           border: !isActive
//                               ? Border.all(
//                             color: AppTheme.getBorder(_isDark),
//                             width: 2,
//                           )
//                               : null,
//                           boxShadow: isActive
//                               ? AppTheme.elevatedShadow(
//                             AppTheme.purple,
//                             _isDark,
//                           )
//                               : null,
//                         ),
//                         child: Center(
//                           child: AnimatedSwitcher(
//                             duration: AppTheme.durationNormal,
//                             transitionBuilder: (child, animation) {
//                               return ScaleTransition(
//                                 scale: animation,
//                                 child: child,
//                               );
//                             },
//                             child: isCompleted
//                                 ? const Icon(
//                               Icons.check_rounded,
//                               key: ValueKey('check'),
//                               color: Colors.white,
//                               size: 20,
//                             )
//                                 : Text(
//                               '${index + 1}',
//                               key: ValueKey('number_$index'),
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w700,
//                                 color: isActive
//                                     ? Colors.white
//                                     : AppTheme.getTextSecondary(_isDark),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // Connector Line
//                     if (index < _totalSteps - 1)
//                       Expanded(
//                         child: Container(
//                           height: 3,
//                           margin: const EdgeInsets.symmetric(horizontal: 8),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                           child: Stack(
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: AppTheme.getSurface(_isDark),
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                               ),
//                               AnimatedContainer(
//                                 duration: AppTheme.durationSlow,
//                                 curve: Curves.easeOutCubic,
//                                 width: isCompleted ? double.infinity : 0,
//                                 decoration: BoxDecoration(
//                                   gradient: AppTheme.primaryGradient(),
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//
//           const SizedBox(height: 14),
//
//           // Step Labels
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildStepLabel(WarrantyStrings.stepCustomerInfo, 0),
//               _buildStepLabel(WarrantyStrings.stepServiceInfo, 1),
//               _buildStepLabel(WarrantyStrings.stepVehicleInfo, 2),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStepLabel(String label, int index) {
//     final isActive = index <= _currentStep;
//     return Expanded(
//       child: Text(
//         label,
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
//           color: isActive
//               ? AppTheme.purple
//               : AppTheme.getTextSecondary(_isDark),
//           letterSpacing: -0.2,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAnimatedSection(int index, Widget child) {
//     final safeIndex = index.clamp(0, _sectionAnimations.length - 1);
//     return AnimatedBuilder(
//       animation: _sectionAnimations[safeIndex],
//       builder: (context, _) {
//         final value = _sectionAnimations[safeIndex].value;
//         return Transform.translate(
//           offset: Offset(0, 25 * (1 - value)),
//           child: Opacity(
//             opacity: value,
//             child: child,
//           ),
//         );
//       },
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Section Builders
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Widget _buildInstallationDateField() {
//     return _ModernSectionCard(
//       title: WarrantyStrings.installationDate,
//       icon: Icons.calendar_today_outlined,
//       iconColor: AppTheme.green,
//       isDark: _isDark,
//       children: [
//         _buildModernTextField(
//           key: 'installDate',
//           label: WarrantyStrings.installationDate,
//           hint: WarrantyStrings.selectInstallDate,
//           prefixIcon: Icons.event_rounded,
//           readOnly: true,
//           onTap: _selectDate,
//           suffixIcon: Icons.keyboard_arrow_down_rounded,
//           validator: _requiredValidator,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOwnerInfoSection() {
//     return _ModernSectionCard(
//       title: WarrantyStrings.customerInfoTitle,
//       icon: Icons.person_outline_rounded,
//       iconColor: AppTheme.purple,
//       isDark: _isDark,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildModernTextField(
//                 key: 'ownerFirstName',
//                 label: WarrantyStrings.firstName,
//                 hint: WarrantyStrings.enterFirstName,
//                 prefixIcon: Icons.badge_outlined,
//                 validator: _requiredValidator,
//                 onChanged: (_) => _updateStep(0),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _buildModernTextField(
//                 key: 'ownerLastName',
//                 label: WarrantyStrings.lastName,
//                 hint: WarrantyStrings.enterLastName,
//                 prefixIcon: Icons.badge_outlined,
//                 validator: _requiredValidator,
//                 onChanged: (_) => _updateStep(0),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         _buildModernTextField(
//           key: 'ownerEmail',
//           label: WarrantyStrings.emailAddress,
//           hint: 'example@email.com',
//           prefixIcon: Icons.email_outlined,
//           keyboardType: TextInputType.emailAddress,
//           validator: _emailValidator,
//           onChanged: (_) => _updateStep(0),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             SizedBox(
//               width: 100,
//               child: BlocConsumer<CheckPhoneCubit, CheckPhoneState>(
//                 listener: (context, state) {
//                   print('🎯 BlocConsumer listener fired! State: $state');
//                   if (state is CountryCodeChanged) {
//                     final cubit = CheckPhoneCubit.get(context);
//                     print('✅ Country code changed to: ${cubit.selectedCounty.code}');
//                     setState(() {
//                       _controllers['ownerPhoneAreaCode']!.text = cubit.selectedCounty.code;
//                       print('📝 Controller updated to: ${_controllers['ownerPhoneAreaCode']!.text}');
//                     });
//                   }
//                 },
//                 builder: (context, state) {
//                   final cubit = CheckPhoneCubit.get(context);
//                   print('🔄 Builder called - Current code: ${cubit.selectedCounty.code}');
//
//                   return GestureDetector(
//                     onTap: () {
//                       HapticFeedback.lightImpact();
//                       showCountryCodeBottomSheet(context);
//                     },
//                     child: AbsorbPointer(
//                       child: TextFormField(
//                         readOnly: true,
//                         controller: _controllers['ownerPhoneAreaCode'],
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: AppBrandColors.dark,
//                         ),
//                         decoration: InputDecoration(
//                           labelText: WarrantyStrings.areaCode,
//                           labelStyle: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                             color: AppBrandColors.darkGray,
//                           ),
//                           hintText: '+1',
//                           hintStyle: TextStyle(
//                             color: AppBrandColors.darkGray.withOpacity(0.5),
//                           ),
//                           prefixIcon: Icon(
//                             Icons.public,
//                             color: AppBrandColors.purple,
//                             size: 20,
//                           ),
//                           filled: true,
//                           fillColor: AppBrandColors.lightGray.withOpacity(0.5),
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 16,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(
//                               color: AppBrandColors.darkGray.withOpacity(0.2),
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(
//                               color: AppBrandColors.purple,
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                         validator: _requiredValidator,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _buildModernTextField(
//                 key: 'ownerPhone',
//                 label: WarrantyStrings.mobileNumber,
//                 hint: '5xxxxxxxx',
//                 prefixIcon: Icons.phone_android_rounded,
//                 keyboardType: TextInputType.phone,
//                 validator: _mobileValidator,
//                 onChanged: (_) => _updateStep(0),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildWarrantyInfoSection() {
//     final hasWindowSelection = _selectedWindowAreas.isNotEmpty;
//     final hasPPFSelection = _selectedPPFAreas.isNotEmpty;
//
//     return _ModernSectionCard(
//       title: WarrantyStrings.warrantyInfoTitle,
//       icon: Icons.verified_user_outlined,
//       iconColor: AppTheme.green,
//       isDark: _isDark,
//       children: [
//         // Warranty Code & Serial Number
//         Row(
//           children: [
//             Expanded(
//               child: _buildModernTextField(
//                 key: 'warrantyCode',
//                 label: WarrantyStrings.code,
//                 hint: '910981',
//                 prefixIcon: Icons.confirmation_number_outlined,
//                 validator: _requiredValidator,
//                 onChanged: (_) => _updateStep(1),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _buildModernTextField(
//                 key: 'serialCode',
//                 label: WarrantyStrings.serialNumber,
//                 hint: 'SC001234569',
//                 prefixIcon: Icons.qr_code_rounded,
//                 validator: _requiredValidator,
//                 onChanged: (_) => _updateStep(1),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//
//         // Installation Details (Meters Used)
//         _buildSubSectionHeader(
//           'Installation Details',
//           Icons.construction_outlined,
//           AppTheme.lightGreen,
//         ),
//         const SizedBox(height: 12),
//         _buildModernTextField(
//           key: 'usedMeters',
//           label: WarrantyStrings.metersUsed,
//           hint: '12.5',
//           prefixIcon: Icons.straighten_outlined,
//           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//           validator: _requiredValidator,
//         ),
//         const SizedBox(height: 20),
//
//         // PPF/Vinyl Protection Area
//         _buildSubSectionHeader(
//           'PPF/Vinyl Protection Area',
//           Icons.shield_outlined,
//           AppTheme.purple,
//         ),
//         const SizedBox(height: 12),
//         _buildAreaSelector(
//           isLoading: _isLoadingLists,
//           hasSelection: hasPPFSelection,
//           selectedCount: _selectedPPFAreas.length,
//           color: AppTheme.purple,
//           icon: Icons.shield_rounded,
//           title: hasPPFSelection
//               ? '${_selectedPPFAreas.length} PPF/Vinyl Selected'
//               : 'Select PPF/Vinyl Areas',
//           subtitle: 'Optional',
//           onTap: _openPPFAreasSheet,
//         ),
//         if (hasPPFSelection) ...[
//           const SizedBox(height: 14),
//           _buildSelectedAreasWrap(
//             areas: _selectedPPFAreas,
//             color: AppTheme.purple,
//             useGradient: true,
//           ),
//         ],
//
//         // Windows Area (only if available)
//         if (_availableWindowAreas.isNotEmpty) ...[
//           const SizedBox(height: 20),
//           _buildSubSectionHeader(
//             'Windows Protection Area',
//             Icons.window_outlined,
//             AppTheme.orange,
//           ),
//           const SizedBox(height: 12),
//           _buildAreaSelector(
//             isLoading: _isLoadingLists,
//             hasSelection: hasWindowSelection,
//             selectedCount: _selectedWindowAreas.length,
//             color: AppTheme.orange,
//             icon: Icons.window_rounded,
//             title: hasWindowSelection
//                 ? '${_selectedWindowAreas.length} Windows Selected'
//                 : 'Select Windows Areas',
//             subtitle: 'Optional',
//             onTap: _openWindowAreasSheet,
//           ),
//           if (hasWindowSelection) ...[
//             const SizedBox(height: 14),
//             _buildSelectedAreasWrap(
//               areas: _selectedWindowAreas,
//               color: AppTheme.orange,
//             ),
//           ],
//         ],
//       ],
//     );
//   }
//
//   Widget _buildSubSectionHeader(String title, IconData icon, Color color) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [color, color.withOpacity(0.85)],
//             ),
//             borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//             boxShadow: [
//               BoxShadow(
//                 color: color.withOpacity(0.3),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Icon(icon, color: Colors.white, size: 18),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: AppTheme.getText(_isDark),
//               letterSpacing: -0.3,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCarInfoSection() {
//     return _ModernSectionCard(
//       title: WarrantyStrings.vehicleInfoTitle,
//       icon: Icons.directions_car_outlined,
//       iconColor: AppTheme.yellow,
//       isDark: _isDark,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildModernTextField(
//                 key: 'vehicleMake',
//                 label: WarrantyStrings.vehicleMake,
//                 hint: 'Mercedes, BMW...',
//                 prefixIcon: Icons.branding_watermark_outlined,
//                 validator: _requiredValidator,
//                 onChanged: (_) => _updateStep(2),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _buildModernTextField(
//                 key: 'vehicleModel',
//                 label: WarrantyStrings.vehicleModel,
//                 hint: 'S-Class, X5...',
//                 prefixIcon: Icons.model_training_outlined,
//                 validator: _requiredValidator,
//                 onChanged: (_) => _updateStep(2),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: _buildModernTextField(
//                 key: 'vehicleYear',
//                 label: WarrantyStrings.vehicleYear,
//                 hint: '2024',
//                 prefixIcon: Icons.calendar_month,
//                 keyboardType: TextInputType.number,
//                 validator: _requiredValidator,
//                 onChanged: (_) => _updateStep(2),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _buildModernTextField(
//                 key: 'vehicleColor',
//                 label: WarrantyStrings.vehicleColor,
//                 hint: WarrantyStrings.vehicleColorHint,
//                 prefixIcon: Icons.palette_outlined,
//                 validator: _requiredValidator,
//                 onChanged: (_) => _updateStep(2),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         _buildModernTextField(
//           key: 'vehicleLicense',
//           label: WarrantyStrings.plateNumber,
//           hint: 'KSA123',
//           prefixIcon: Icons.pin_outlined,
//           validator: _requiredValidator,
//           onChanged: (_) => _updateStep(2),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildImagesSection() {
//     final canAddMore = _selectedImages.length < _maxImages;
//     final hasImages = _selectedImages.isNotEmpty;
//
//     return _ModernSectionCard(
//       title: 'Installation Images',
//       icon: Icons.photo_library_outlined,
//       iconColor: AppTheme.blue,
//       isDark: _isDark,
//       children: [
//         // Info Banner
//         Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: AppTheme.blue.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//             border: Border.all(
//               color: AppTheme.blue.withOpacity(0.3),
//               width: 1.5,
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.info_outline_rounded,
//                 color: AppTheme.blue,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   'Upload up to $_maxImages images of the installation (Optional)',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: AppTheme.getText(_isDark),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // Images Grid
//         if (hasImages) ...[
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//               childAspectRatio: 1,
//             ),
//             itemCount: _selectedImages.length + (canAddMore ? 1 : 0),
//             itemBuilder: (context, index) {
//               if (index < _selectedImages.length) {
//                 return _buildImageThumbnail(_selectedImages[index], index);
//               } else {
//                 return _buildAddImageButton();
//               }
//             },
//           ),
//         ] else ...[
//           _buildEmptyImagesPlaceholder(),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildImageThumbnail(XFile image, int index) {
//     return _PressableScale(
//       onPressed: () => _showImagePreview(image, index),
//       scaleFactor: 0.95,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//           border: Border.all(
//             color: AppTheme.getBorder(_isDark),
//             width: 1.5,
//           ),
//           boxShadow: AppTheme.cardShadow(_isDark),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(AppTheme.radiusSM - 1),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.file(
//                 File(image.path),
//                 fit: BoxFit.cover,
//               ),
//               // Delete Button
//               Positioned(
//                 top: 4,
//                 right: 4,
//                 child: GestureDetector(
//                   onTap: () => _removeImage(index),
//                   child: Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: AppTheme.red,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppTheme.red.withOpacity(0.5),
//                           blurRadius: 8,
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.close_rounded,
//                       color: Colors.white,
//                       size: 14,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddImageButton() {
//     return _PressableScale(
//       onPressed: _showImagePickerOptions,
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppTheme.getSurface(_isDark),
//           borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//           border: Border.all(
//             color: AppTheme.purple.withOpacity(0.5),
//             width: 2,
//             style: BorderStyle.solid,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.primaryGradient(),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.add_rounded,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               'Add',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.getTextSecondary(_isDark),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyImagesPlaceholder() {
//     return _PressableScale(
//       onPressed: _showImagePickerOptions,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 60),
//         decoration: BoxDecoration(
//           color: AppTheme.getSurface(_isDark),
//           borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//           border: Border.all(
//             color: AppTheme.getBorder(_isDark),
//             width: 2,
//             style: BorderStyle.solid,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.primaryGradient(),
//                 shape: BoxShape.circle,
//                 boxShadow: AppTheme.glowShadow(AppTheme.purple, intensity: 0.3),
//               ),
//               child: const Icon(
//                 Icons.add_photo_alternate_rounded,
//                 color: Colors.white,
//                 size: 32,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Add Images',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: AppTheme.getText(_isDark),
//               ),
//             ),
//             const SizedBox(height: 6,width: 30),
//             Text(
//               'Tap to upload from gallery or camera',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: AppTheme.getTextSecondary(_isDark),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showImagePreview(XFile image, int index) {
//     HapticFeedback.lightImpact();
//     showDialog(
//       context: context,
//       barrierColor: Colors.black87,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Close Button
//             Align(
//               alignment: Alignment.topRight,
//               child: _PressableScale(
//                 onPressed: () => Navigator.pop(context),
//                 child: ClipOval(
//                   child: BackdropFilter(
//                     filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.close_rounded,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(AppTheme.radiusLG),
//               child: Image.file(
//                 File(image.path),
//                 fit: BoxFit.contain,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Delete Button
//             _PressableScale(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _removeImage(index);
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                 decoration: BoxDecoration(
//                   color: AppTheme.red,
//                   borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//                   boxShadow: AppTheme.elevatedShadow(AppTheme.red, _isDark),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.delete_outline_rounded,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Delete Image',
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAreaSelector({
//     required bool isLoading,
//     required bool hasSelection,
//     required int selectedCount,
//     required Color color,
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     if (isLoading) {
//       return _buildLoadingIndicator(color);
//     }
//
//     return _PressableScale(
//       onPressed: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppTheme.getSurface(_isDark),
//           borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//           border: Border.all(
//             color: hasSelection
//                 ? color.withOpacity(0.4)
//                 : AppTheme.getBorder(_isDark),
//             width: hasSelection ? 1.5 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             AnimatedContainer(
//               duration: AppTheme.durationNormal,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 gradient: hasSelection
//                     ? LinearGradient(
//                   colors: [color, color.withOpacity(0.8)],
//                 )
//                     : null,
//                 color: hasSelection
//                     ? null
//                     : color.withOpacity(_isDark ? 0.15 : 0.1),
//                 borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//                 boxShadow: hasSelection
//                     ? AppTheme.glowShadow(color, intensity: 0.25)
//                     : null,
//               ),
//               child: Icon(
//                 hasSelection ? icon : Icons.add_rounded,
//                 color: hasSelection
//                     ? Colors.white
//                     : color,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: hasSelection
//                           ? AppTheme.getText(_isDark)
//                           : AppTheme.getTextSecondary(_isDark),
//                     ),
//                   ),
//                   if (!hasSelection) ...[
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppTheme.getTextSecondary(_isDark),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(_isDark ? 0.15 : 0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: DirectionalArrow(
//                 direction: ArrowDirection.forwardIos,
//                 color: color,
//                 size: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadingIndicator(Color color) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppTheme.getSurface(_isDark),
//         borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 20,
//             height: 20,
//             child: CircularProgressIndicator(
//               strokeWidth: 2.5,
//               valueColor: AlwaysStoppedAnimation(color),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Text(
//             'جاري تحميل البيانات...',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: AppTheme.getTextSecondary(_isDark),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSelectedAreasWrap({
//     required List<String> areas,
//     required Color color,
//     bool useGradient = false,
//   }) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: areas.map((area) {
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             gradient: useGradient
//                 ? LinearGradient(
//               colors: [color, color.withOpacity(0.8)],
//             )
//                 : null,
//             color: useGradient
//                 ? null
//                 : color.withOpacity(_isDark ? 0.18 : 0.12),
//             borderRadius: BorderRadius.circular(20),
//             border: useGradient
//                 ? null
//                 : Border.all(color: color.withOpacity(0.35)),
//             boxShadow: useGradient
//                 ? [
//               BoxShadow(
//                 color: color.withOpacity(0.25),
//                 blurRadius: 8,
//                 offset: const Offset(0, 3),
//               ),
//             ]
//                 : null,
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.check_rounded,
//                 color: useGradient ? Colors.white : color,
//                 size: 14,
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 area,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: useGradient ? Colors.white : color,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildModernTextField({
//     required String key,
//     required String label,
//     required String hint,
//     required IconData prefixIcon,
//     String? Function(String?)? validator,
//     TextInputType? keyboardType,
//     int maxLines = 1,
//     bool readOnly = false,
//     VoidCallback? onTap,
//     IconData? suffixIcon,
//     ValueChanged<String>? onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Label with required indicator
//         Row(
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.getText(_isDark),
//                 letterSpacing: -0.2,
//               ),
//             ),
//             if (validator != null) ...[
//               const SizedBox(width: 4),
//               Text(
//                 '*',
//                 style: TextStyle(
//                   color: AppTheme.red,
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ],
//         ),
//         const SizedBox(height: 8),
//
//         // Text Field
//         TextFormField(
//           controller: _controllers[key],
//           focusNode: _focusNodes[key],
//           validator: validator,
//           keyboardType: keyboardType,
//           maxLines: maxLines,
//           readOnly: readOnly,
//           onTap: onTap,
//           onChanged: onChanged,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w500,
//             color: AppTheme.getText(_isDark),
//           ),
//           cursorColor: AppTheme.purple,
//           cursorRadius: const Radius.circular(2),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(
//               color: AppTheme.getTextSecondary(_isDark),
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//             ),
//             prefixIcon: Padding(
//               padding: const EdgeInsets.only(left: 14, right: 10),
//               child: Icon(
//                 prefixIcon,
//                 size: 20,
//                 color: AppTheme.getTextSecondary(_isDark),
//               ),
//             ),
//             prefixIconConstraints: const BoxConstraints(minWidth: 44),
//             suffixIcon: suffixIcon != null
//                 ? Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: Icon(
//                 suffixIcon,
//                 color: AppTheme.purple,
//                 size: 22,
//               ),
//             )
//                 : null,
//             filled: true,
//             fillColor: AppTheme.getInputFill(_isDark),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 18,
//               vertical: maxLines > 1 ? 14 : 0,
//             ),
//             border: _buildInputBorder(AppTheme.getBorder(_isDark)),
//             enabledBorder: _buildInputBorder(AppTheme.getBorder(_isDark)),
//             focusedBorder: _buildInputBorder(AppTheme.purple, width: 2),
//             errorBorder: _buildInputBorder(AppTheme.red),
//             focusedErrorBorder: _buildInputBorder(AppTheme.red, width: 2),
//             errorStyle: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//               color: AppTheme.red,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   OutlineInputBorder _buildInputBorder(Color color, {double width = 1.5}) {
//     return OutlineInputBorder(
//       borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//       borderSide: BorderSide(color: color, width: width),
//     );
//   }
//
//   String? _requiredValidator(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return WarrantyStrings.required;
//     }
//     return null;
//   }
//
//   String? _emailValidator(String? value) {
//     if (value == null || value.isEmpty) {
//       return WarrantyStrings.required;
//     }
//     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//       return WarrantyStrings.invalidEmail;
//     }
//     return null;
//   }
//
//   String? _mobileValidator(String? value) {
//     if (value == null || value.isEmpty) {
//       return WarrantyStrings.required;
//     }
//     if (value.length < 9) {
//       return WarrantyStrings.invalidMobile;
//     }
//     return null;
//   }
//
//   void _updateStep(int step) {
//     if (_currentStep < step + 1) {
//       setState(() => _currentStep = step);
//     }
//   }
//
//   Widget _buildSubmitButton(WarrantyState state) {
//     final isLoading = state is WarrantyLoading;
//
//     return _PressableScale(
//       onPressed: isLoading ? () {} : _submitForm,
//       scaleFactor: isLoading ? 1.0 : 0.97,
//       child: AnimatedContainer(
//         duration: AppTheme.durationNormal,
//         width: double.infinity,
//         height: 60,
//         decoration: BoxDecoration(
//           gradient: isLoading ? null : AppTheme.primaryGradient(),
//           color: isLoading ? AppTheme.darkGray.withOpacity(0.4) : null,
//           borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//           boxShadow: isLoading
//               ? null
//               : AppTheme.elevatedShadow(AppTheme.purple, _isDark),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (isLoading)
//               const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   valueColor: AlwaysStoppedAnimation(Colors.white),
//                 ),
//               )
//             else ...[
//               const Icon(
//                 Icons.verified_user_rounded,
//                 color: Colors.white,
//                 size: 24,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 WarrantyStrings.issueCertificateButton,
//                 style: const TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildModernLoadingOverlay() {
//     return AnimatedOpacity(
//       opacity: 1.0,
//       duration: AppTheme.durationFast,
//       child: BackdropFilter(
//         filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//         child: Container(
//           color: AppTheme.dark.withOpacity(0.4),
//           child: Center(
//             child: TweenAnimationBuilder<double>(
//               tween: Tween(begin: 0.85, end: 1.0),
//               duration: AppTheme.durationNormal,
//               curve: Curves.easeOutCubic,
//               builder: (context, value, child) {
//                 return Transform.scale(scale: value, child: child);
//               },
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 40),
//                 padding: const EdgeInsets.all(32),
//                 decoration: BoxDecoration(
//                   color: AppTheme.getCard(_isDark),
//                   borderRadius: BorderRadius.circular(AppTheme.radiusXL),
//                   border: _isDark
//                       ? Border.all(
//                     color: AppTheme.borderDark.withOpacity(0.5),
//                   )
//                       : null,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 50,
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Animated Loading Ring
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         SizedBox(
//                           width: 75,
//                           height: 75,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 3,
//                             valueColor: AlwaysStoppedAnimation(
//                               AppTheme.purple.withOpacity(0.2),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 75,
//                           height: 75,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 3.5,
//                             valueColor: const AlwaysStoppedAnimation(
//                               AppTheme.purple,
//                             ),
//                             strokeCap: StrokeCap.round,
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             gradient: AppTheme.glassGradient(_isDark),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.shield_rounded,
//                             color: AppTheme.purple,
//                             size: 26,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 28),
//                     Text(
//                       WarrantyStrings.issuingCertificate,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: AppTheme.getText(_isDark),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       WarrantyStrings.pleaseWait,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: AppTheme.getTextSecondary(_isDark),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showHelpDialog() {
//     HapticFeedback.lightImpact();
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'Help Dialog',
//       barrierColor: AppTheme.dark.withOpacity(0.6),
//       transitionDuration: AppTheme.durationNormal,
//       pageBuilder: (context, animation, secondaryAnimation) {
//         return Center(
//           child: Material(
//             color: Colors.transparent,
//             child: ScaleTransition(
//               scale: CurvedAnimation(
//                 parent: animation,
//                 curve: Curves.easeOutBack,
//               ),
//               child: Container(
//                 margin: const EdgeInsets.all(24),
//                 padding: const EdgeInsets.all(28),
//                 decoration: BoxDecoration(
//                   color: AppTheme.getCard(_isDark),
//                   borderRadius: BorderRadius.circular(AppTheme.radiusXL),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 40,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Icon with animation
//                     TweenAnimationBuilder<double>(
//                       tween: Tween(begin: 0.7, end: 1.0),
//                       duration: const Duration(milliseconds: 500),
//                       curve: Curves.elasticOut,
//                       builder: (context, value, child) {
//                         return Transform.scale(scale: value, child: child);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(22),
//                         decoration: BoxDecoration(
//                           gradient: AppTheme.primaryGradient(),
//                           shape: BoxShape.circle,
//                           boxShadow: AppTheme.elevatedShadow(
//                             AppTheme.purple,
//                             _isDark,
//                           ),
//                         ),
//                         child: const Icon(
//                           Icons.help_outline_rounded,
//                           color: Colors.white,
//                           size: 40,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       WarrantyStrings.help,
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w800,
//                         color: AppTheme.getText(_isDark),
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                     Text(
//                       WarrantyStrings.helpDescription,
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: AppTheme.getTextSecondary(_isDark),
//                         height: 1.6,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 28),
//                     SizedBox(
//                       width: double.infinity,
//                       child: _PressableScale(
//                         onPressed: () => Navigator.pop(context),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           decoration: BoxDecoration(
//                             gradient: AppTheme.primaryGradient(),
//                             borderRadius:
//                             BorderRadius.circular(AppTheme.radiusMD),
//                             boxShadow: AppTheme.elevatedShadow(
//                               AppTheme.purple,
//                               _isDark,
//                             ),
//                           ),
//                           child: Center(
//                             child: Text(
//                               WarrantyStrings.understood,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 📦 Modern Section Card Widget
// // ═══════════════════════════════════════════════════════════════════════════
// class _ModernSectionCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color iconColor;
//   final bool isDark;
//   final List<Widget> children;
//
//   const _ModernSectionCard({
//     required this.title,
//     required this.icon,
//     required this.iconColor,
//     required this.isDark,
//     required this.children,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppTheme.getCard(isDark),
//         borderRadius: BorderRadius.circular(AppTheme.radiusLG),
//         border: Border.all(
//           color: AppTheme.getBorder(isDark),
//           width: 1,
//         ),
//         boxShadow: AppTheme.cardShadow(isDark),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Header
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(11),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       iconColor.withOpacity(isDark ? 0.2 : 0.15),
//                       iconColor.withOpacity(isDark ? 0.1 : 0.08),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: iconColor,
//                   size: 22,
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w700,
//                     color: AppTheme.getText(isDark),
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 18),
//           Container(
//             height: 1,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.transparent,
//                   AppTheme.getDivider(isDark),
//                   Colors.transparent,
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 18),
//           ...children,
//         ],
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🔧 Custom Animated Builder Helper (Removed - Using Flutter's Built-in)
// // ═══════════════════════════════════════════════════════════════════════════
// // Note: We use Flutter's built-in AnimatedBuilder instead of custom implementation
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 📸 Image Picker Option Widget
// // ═══════════════════════════════════════════════════════════════════════════
// class _ImagePickerOption extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final bool isDark;
//   final VoidCallback onTap;
//
//   const _ImagePickerOption({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.isDark,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return _PressableScale(
//       onPressed: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [color, color.withOpacity(0.85)],
//           ),
//           borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.4),
//               blurRadius: 12,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: Colors.white, size: 32),
//             const SizedBox(height: 10),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // 🎉 Warranty Success Screen - Premium Animation
// // ═══════════════════════════════════════════════════════════════════════════
// class WarrantySuccessScreen extends StatefulWidget {
//   const WarrantySuccessScreen({super.key});
//
//   @override
//   State<WarrantySuccessScreen> createState() => _WarrantySuccessScreenState();
// }
//
// class _WarrantySuccessScreenState extends State<WarrantySuccessScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _mainController;
//   late AnimationController _pulseController;
//   late AnimationController _particlesController;
//
//   late Animation<double> _checkScaleAnimation;
//   late Animation<double> _containerScaleAnimation;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _slideAnimation;
//   late Animation<double> _ringAnimation;
//
//   bool get _isDark => Theme.of(context).brightness == Brightness.dark;
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     HapticFeedback.heavyImpact();
//   }
//
//   void _setupAnimations() {
//     _mainController = AnimationController(
//       duration: const Duration(milliseconds: 1400),
//       vsync: this,
//     );
//
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _particlesController = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );
//
//     _containerScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
//       ),
//     );
//
//     _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
//       ),
//     );
//
//     _checkScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.35, 0.75, curve: Curves.elasticOut),
//       ),
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
//       ),
//     );
//
//     _slideAnimation = Tween<double>(begin: 35, end: 0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
//       ),
//     );
//
//     _mainController.forward();
//     _particlesController.forward();
//   }
//
//   @override
//   void dispose() {
//     _mainController.dispose();
//     _pulseController.dispose();
//     _particlesController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Directionality(
//       textDirection: ui.TextDirection.ltr,
//       child: Scaffold(
//         backgroundColor: AppTheme.getBackground(_isDark),
//         body: Stack(
//           children: [
//             // Background Decorations
//             _buildBackgroundOrbs(size),
//
//             // Floating Particles
//             _buildFloatingParticles(size),
//
//             SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 28),
//                 child: Column(
//                   children: [
//                     const Spacer(flex: 2),
//
//                     // Success Animation
//                     AnimatedBuilder(
//                       animation: _containerScaleAnimation,
//                       builder: (context, child) {
//                         return Transform.scale(
//                           scale: _containerScaleAnimation.value,
//                           child: child,
//                         );
//                       },
//                       child: _buildSuccessCircle(size),
//                     ),
//
//                     const SizedBox(height: 50),
//
//                     // Text Content
//                     AnimatedBuilder(
//                       animation: _fadeAnimation,
//                       builder: (context, child) {
//                         return Transform.translate(
//                           offset: Offset(0, _slideAnimation.value),
//                           child: Opacity(
//                             opacity: _fadeAnimation.value,
//                             child: child,
//                           ),
//                         );
//                       },
//                       child: _buildTextContent(size),
//                     ),
//
//                     const SizedBox(height: 32),
//
//                     // Info Card
//                     AnimatedBuilder(
//                       animation: _fadeAnimation,
//                       builder: (context, child) {
//                         return Transform.translate(
//                           offset: Offset(0, _slideAnimation.value * 1.4),
//                           child: Opacity(
//                             opacity: _fadeAnimation.value,
//                             child: child,
//                           ),
//                         );
//                       },
//                       child: _buildInfoCard(size),
//                     ),
//
//                     const Spacer(flex: 3),
//
//                     // Home Button
//                     AnimatedBuilder(
//                       animation: _fadeAnimation,
//                       builder: (context, child) {
//                         return Opacity(
//                           opacity: _fadeAnimation.value,
//                           child: child,
//                         );
//                       },
//                       child: _buildHomeButton(size),
//                     ),
//
//                     SizedBox(
//                         height: MediaQuery.of(context).padding.bottom + 28),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBackgroundOrbs(Size size) {
//     return Stack(
//       children: [
//         // Top Right Green Orb
//         AnimatedBuilder(
//           animation: _pulseController,
//           builder: (context, child) {
//             return Positioned(
//               top: -60,
//               right: -50,
//               child: Transform.scale(
//                 scale: 1.0 + (_pulseController.value * 0.08),
//                 child: Opacity(
//                   opacity: _isDark ? 0.12 : 0.18,
//                   child: Container(
//                     width: 220,
//                     height: 220,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: RadialGradient(
//                         colors: [
//                           AppTheme.green,
//                           AppTheme.green.withOpacity(0),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//
//         // Bottom Left Purple Orb
//         AnimatedBuilder(
//           animation: _pulseController,
//           builder: (context, child) {
//             return Positioned(
//               bottom: size.height * 0.18,
//               left: -80,
//               child: Transform.scale(
//                 scale: 1.0 + ((1 - _pulseController.value) * 0.06),
//                 child: Opacity(
//                   opacity: _isDark ? 0.08 : 0.12,
//                   child: Container(
//                     width: 200,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: RadialGradient(
//                         colors: [
//                           AppTheme.purple,
//                           AppTheme.purple.withOpacity(0),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFloatingParticles(Size size) {
//     return AnimatedBuilder(
//       animation: _particlesController,
//       builder: (context, child) {
//         final particleProgress = _particlesController.value;
//         return Stack(
//           children: List.generate(12, (index) {
//             final random = math.Random(index * 42);
//             final startX = random.nextDouble() * size.width;
//             final startY = size.height * 0.4 + (random.nextDouble() * 100);
//             final endY = startY - 200 - (random.nextDouble() * 150);
//             final delay = random.nextDouble() * 0.3;
//
//             final progress = ((particleProgress - delay) / 0.7).clamp(0.0, 1.0);
//             final curve = Curves.easeOutCubic.transform(progress);
//
//             return Positioned(
//               left: startX + (math.sin(progress * math.pi * 2) * 20),
//               top: ui.lerpDouble(startY, endY, curve)!,
//               child: Opacity(
//                 opacity: (1.0 - progress).clamp(0.0, 0.6),
//                 child: Container(
//                   width: 6 + (random.nextDouble() * 6),
//                   height: 6 + (random.nextDouble() * 6),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: index % 3 == 0
//                         ? AppTheme.green
//                         : index % 3 == 1
//                         ? AppTheme.yellow
//                         : AppTheme.lightGreen,
//                   ),
//                 ),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
//
//   Widget _buildSuccessCircle(Size size) {
//     final circleSize = size.width * 0.44;
//
//     return SizedBox(
//       width: circleSize + 40,
//       height: circleSize + 40,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Outer Pulse Ring
//           AnimatedBuilder(
//             animation: _pulseController,
//             builder: (context, child) {
//               return Container(
//                 width: circleSize + 30 + (_pulseController.value * 20),
//                 height: circleSize + 30 + (_pulseController.value * 20),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: AppTheme.green.withOpacity(
//                       0.3 - (_pulseController.value * 0.2),
//                     ),
//                     width: 2,
//                   ),
//                 ),
//               );
//             },
//           ),
//
//           // Ring Animation
//           AnimatedBuilder(
//             animation: _ringAnimation,
//             builder: (context, child) {
//               return Container(
//                 width: circleSize + 10,
//                 height: circleSize + 10,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: AppTheme.green.withOpacity(0.2),
//                     width: 3 * _ringAnimation.value,
//                   ),
//                 ),
//               );
//             },
//           ),
//
//           // Main Circle with Glow
//           AnimatedBuilder(
//             animation: _pulseController,
//             builder: (context, child) {
//               return Container(
//                 width: circleSize,
//                 height: circleSize,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: AppTheme.successGradient(),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppTheme.green.withOpacity(
//                         0.35 + (_pulseController.value * 0.15),
//                       ),
//                       blurRadius: 40 + (_pulseController.value * 25),
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: child,
//               );
//             },
//             child: ScaleTransition(
//               scale: _checkScaleAnimation,
//               child: Icon(
//                 Icons.check_rounded,
//                 color: Colors.white,
//                 size: circleSize * 0.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextContent(Size size) {
//     return Column(
//       children: [
//         Text(
//           WarrantyStrings.requestSent,
//           style: TextStyle(
//             fontSize: size.width * 0.068,
//             fontWeight: FontWeight.w800,
//             color: AppTheme.getText(_isDark),
//             letterSpacing: -0.5,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 12),
//         Text(
//           'تم تسجيل طلب الضمان بنجاح',
//           style: TextStyle(
//             fontSize: size.width * 0.042,
//             color: AppTheme.getTextSecondary(_isDark),
//             height: 1.5,
//             fontWeight: FontWeight.w500,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInfoCard(Size size) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.green.withOpacity(_isDark ? 0.15 : 0.1),
//             AppTheme.lightGreen.withOpacity(_isDark ? 0.08 : 0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(AppTheme.radiusLG),
//         border: Border.all(
//           color: AppTheme.green.withOpacity(0.3),
//           width: 1.5,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               gradient: AppTheme.successGradient(),
//               borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//               boxShadow: AppTheme.glowShadow(AppTheme.green, intensity: 0.25),
//             ),
//             child: Icon(
//               Icons.email_outlined,
//               color: Colors.white,
//               size: size.width * 0.06,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               WarrantyStrings.emailNotification,
//               style: TextStyle(
//                 fontSize: size.width * 0.036,
//                 color: AppTheme.getText(_isDark),
//                 height: 1.5,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHomeButton(Size size) {
//     return _PressableScale(
//       onPressed: () {
//         HapticFeedback.lightImpact();
//         Navigator.of(context).popUntil((route) => route.isFirst);
//       },
//       child: Container(
//         width: double.infinity,
//         height: 60,
//         decoration: BoxDecoration(
//           gradient: AppTheme.primaryGradient(),
//           borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//           boxShadow: AppTheme.elevatedShadow(AppTheme.purple, _isDark),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.home_rounded,
//               color: Colors.white,
//               size: size.width * 0.06,
//             ),
//             const SizedBox(width: 12),
//             Text(
//               WarrantyStrings.backHome,
//               style: TextStyle(
//                 fontSize: size.width * 0.044,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//                 letterSpacing: -0.3,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }