import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/business_logic/warranty/cubit/warranty_cubit.dart';
import 'package:app/network/services/warranty_service.dart';
import 'package:app/persentation/screens/warranty/models/warranty_model_simple.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_exports.dart';
import 'package:app/persentation/screens/warranty/widgets/premium_form_header.dart';
import 'package:app/persentation/screens/warranty/widgets/premium_loading_overlay.dart';
import 'package:app/persentation/screens/warranty/widgets/premium_dialog.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📝 New Warranty Screen - REFACTORED VERSION
// ═══════════════════════════════════════════════════════════════════════════
// ✨ Modern, Clean, Component-Based Architecture
// 🎯 Uses reusable sections for maintainability
// 📦 Total: ~500 lines vs 4200+ lines original
// ═══════════════════════════════════════════════════════════════════════════

class WarrantyScreenRefactored extends StatefulWidget {
  const WarrantyScreenRefactored({super.key});

  @override
  State<WarrantyScreenRefactored> createState() =>
      _WarrantyScreenRefactoredState();
}

class _WarrantyScreenRefactoredState extends State<WarrantyScreenRefactored>
    with SingleTickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════
  // 📋 Form Controllers
  // ═══════════════════════════════════════════════════════════════════════
  final _formKey = GlobalKey<FormState>();

  // Customer Info
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Warranty Info
  final _warrantyCodeController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _installDateController = TextEditingController();
  final _currentMetersController = TextEditingController();

  // Vehicle Info
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _licensePlateController = TextEditingController();

  // Protected Areas
  List<String> _selectedWindowsProtection = [];
  List<String> _selectedPPFProtection = [];

  // Images
  List<File> _images = [];

  // UI State
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Lifecycle
  // ═══════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  double _calculateProgress() {
    int filled = 0;
    int total = 8;

    if (_firstNameController.text.isNotEmpty) filled++;
    if (_lastNameController.text.isNotEmpty) filled++;
    if (_emailController.text.isNotEmpty) filled++;
    if (_phoneController.text.isNotEmpty) filled++;
    if (_warrantyCodeController.text.isNotEmpty) filled++;
    if (_installDateController.text.isNotEmpty) filled++;
    if (_currentMetersController.text.isNotEmpty) filled++;
    if (_images.isNotEmpty) filled++;

    return filled / total;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _warrantyCodeController.dispose();
    _serialNumberController.dispose();
    _installDateController.dispose();
    _currentMetersController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _vehicleColorController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 Build UI
  // ═══════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.getBackground(isDark),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                PremiumFormHeader(
                  title: 'New Warranty',
                  subtitle: 'Complete all required fields',
                  icon: Icons.verified_user_rounded,
                  accentColor: AppTheme.primary,
                  isDark: isDark,
                  currentStep: (_calculateProgress() * 8).toInt(),
                  totalSteps: 8,
                  progress: _calculateProgress(),
                  onClose: () => Navigator.pop(context),
                ),
                Expanded(
                  child: PremiumLoadingOverlay(
                    isLoading: _isSubmitting,
                    isDark: isDark,
                    message: 'Submitting warranty...',
                    accentColor: AppTheme.primary,
                    style: LoadingStyle.overlay,
                    child: Form(
                      key: _formKey,
                      child: _buildFormContent(isDark),
                    ),
                  ),
                ),
                _buildBottomActions(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 💡 Help Dialog
  // ═══════════════════════════════════════════════════════════════════════
  void _showHelpDialog() {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    PremiumDialog.show(
      context: context,
      title: 'Help',
      message: 'Fill in all required fields marked with * to register a new warranty. You can add vehicle photos to complete the registration.',
      icon: Icons.help_outline_rounded,
      accentColor: AppTheme.primary,
      confirmText: 'Got it',
      onConfirm: () => Navigator.of(context).pop(),
      isDark: isDark,
      type: DialogType.info,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📋 Form Content
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildFormContent(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          // 📅 Installation Date (First Section)
          InstallationDateSection(
            dateController: _installDateController,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // 👤 Customer Information
          CustomerInfoSection(
            firstNameController: _firstNameController,
            lastNameController: _lastNameController,
            emailController: _emailController,
            phoneController: _phoneController,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // 🛡️ Warranty Information
          WarrantyInfoSection(
            codeController: _warrantyCodeController,
            serialController: _serialNumberController,
            metersController: _currentMetersController,
            selectedWindowsProtection: _selectedWindowsProtection,
            selectedPPFProtection: _selectedPPFProtection,
            onWindowsChanged: (areas) {
              setState(() => _selectedWindowsProtection = areas);
            },
            onPPFChanged: (areas) {
              setState(() => _selectedPPFProtection = areas);
            },
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // 🚗 Vehicle Information
          VehicleInfoSection(
            makeController: _vehicleMakeController,
            modelController: _vehicleModelController,
            yearController: _vehicleYearController,
            colorController: _vehicleColorController,
            licensePlateController: _licensePlateController,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // 📷 Images Section
          ImagesSection(
            images: _images,
            onImageAdded: (image) {
              setState(() => _images.add(image));
            },
            onImageRemoved: (index) {
              setState(() => _images.removeAt(index));
            },
            isDark: isDark,
          ),
          const SizedBox(height: 100), // Space for bottom actions
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ⚡ Bottom Actions
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildBottomActions(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDark),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXXL),
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.getDivider(isDark),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.dark.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Reset Button
          Expanded(
            child: _buildActionButton(
              label: WarrantyStrings.reset,
              icon: Icons.refresh_rounded,
              isPrimary: false,
              isDark: isDark,
              onTap: _resetForm,
            ),
          ),
          const SizedBox(width: 12),

          // Submit Button
          Expanded(
            flex: 2,
            child: _buildActionButton(
              label: WarrantyStrings.submit,
              icon: Icons.check_circle_rounded,
              isPrimary: true,
              isDark: isDark,
              isLoading: _isSubmitting,
              onTap: _submitWarranty,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required bool isDark,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return PressableScale(
      onPressed: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationNormal,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient() : null,
          color: !isPrimary ? AppTheme.getSurface(isDark) : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: !isPrimary
              ? Border.all(color: AppTheme.getBorder(isDark))
              : null,
          boxShadow: isPrimary
              ? AppTheme.elevatedShadow(AppTheme.purple, isDark)
              : null,
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isPrimary ? Colors.white : AppTheme.getText(isDark),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color:
                          isPrimary ? Colors.white : AppTheme.getText(isDark),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Actions
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> _submitWarranty() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      PremiumToast.show(
        context: context,
        message: 'Please fill all required fields',
        type: ToastType.error,
        isDark: Theme.of(context).brightness == Brightness.dark,
      );
      return;
    }

    if (_images.isEmpty) {
      HapticFeedback.mediumImpact();
      PremiumToast.show(
        context: context,
        message: 'Please add at least one image',
        type: ToastType.error,
        isDark: Theme.of(context).brightness == Brightness.dark,
      );
      return;
    }

    if (_selectedWindowsProtection.isEmpty && _selectedPPFProtection.isEmpty) {
      HapticFeedback.mediumImpact();
      PremiumToast.show(
        context: context,
        message: 'Please select at least one protected area',
        type: ToastType.error,
        isDark: Theme.of(context).brightness == Brightness.dark,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      HapticFeedback.mediumImpact();

      // Create warranty model
      final warranty = WarrantyModel(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        warrantyCode: _warrantyCodeController.text.trim(),
        serialNumber: _serialNumberController.text.trim(),
        installationDate: _installDateController.text.trim(),
        currentMileage: int.tryParse(_currentMetersController.text.trim()) ?? 0,
        vehicleMake: _vehicleMakeController.text.trim(),
        vehicleModel: _vehicleModelController.text.trim(),
        vehicleYear: int.tryParse(_vehicleYearController.text.trim()) ?? 0,
        vehicleColor: _vehicleColorController.text.trim(),
        licensePlate: _licensePlateController.text.trim(),
        windowsProtection: _selectedWindowsProtection,
        ppfProtection: _selectedPPFProtection,
        images: _images.map((f) => f.path).toList(),
      );

      // TODO: Submit via your actual API
      // final service = WarrantyService();
      // await service.submitWarranty(warranty);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      HapticFeedback.heavyImpact();

      if (mounted) {
        setState(() => _isSubmitting = false);
        await PremiumDialog.showSuccess(
          context: context,
          title: 'Registration Complete!',
          message: 'Your warranty has been registered successfully.',
          isDark: Theme.of(context).brightness == Brightness.dark,
        );
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      HapticFeedback.mediumImpact();
      if (mounted) {
        setState(() => _isSubmitting = false);
        PremiumToast.show(
          context: context,
          message: 'Failed to submit warranty: $e',
          type: ToastType.error,
          isDark: Theme.of(context).brightness == Brightness.dark,
        );
      }
    }
  }

  void _resetForm() async {
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await PremiumDialog.showConfirm(
      context: context,
      title: 'Reset Form?',
      message: 'Are you sure you want to reset all fields? This action cannot be undone.',
      confirmText: 'Reset',
      cancelText: 'Cancel',
      isDark: isDark,
    );

    if (confirmed == true && mounted) {
      setState(() {
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _warrantyCodeController.clear();
        _serialNumberController.clear();
        _installDateController.clear();
        _currentMetersController.clear();
        _vehicleMakeController.clear();
        _vehicleModelController.clear();
        _vehicleYearController.clear();
        _vehicleColorController.clear();
        _licensePlateController.clear();
        _selectedWindowsProtection.clear();
        _selectedPPFProtection.clear();
        _images.clear();
      });
      HapticFeedback.mediumImpact();
      PremiumToast.show(
        context: context,
        message: 'Form reset successfully',
        type: ToastType.success,
        isDark: isDark,
      );
    }
  }

}
