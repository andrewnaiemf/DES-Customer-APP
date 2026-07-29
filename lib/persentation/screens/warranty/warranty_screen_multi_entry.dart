import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/business_logic/warranty/cubit/warranty_cubit.dart';
import 'package:app/persentation/screens/warranty/models/service_entry_model.dart';
import 'package:app/persentation/screens/warranty/models/warranty_model_multi_entry.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_exports.dart';
import 'package:app/persentation/screens/warranty/widgets/premium_form_header.dart';
import 'package:app/persentation/screens/warranty/widgets/premium_loading_overlay.dart';
import 'package:app/persentation/screens/warranty/widgets/premium_dialog.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_success_screen.dart';
import 'package:app/persentation/widgets/custom_date_picker.dart';
import 'package:app/network/dio_helper.dart';
import 'package:dio/dio.dart' as dio;

// ═══════════════════════════════════════════════════════════════════════════
// 📝 Multi-Entry Warranty Screen - Production Ready
// ═══════════════════════════════════════════════════════════════════════════
// ✨ Supports multiple service entries per warranty
// 🎯 Each warranty can have unlimited service logs
// 📦 Scalable architecture for future service types
// ═══════════════════════════════════════════════════════════════════════════

class WarrantyScreenMultiEntry extends StatefulWidget {
  const WarrantyScreenMultiEntry({super.key});

  @override
  State<WarrantyScreenMultiEntry> createState() =>
      _WarrantyScreenMultiEntryState();
}

class _WarrantyScreenMultiEntryState extends State<WarrantyScreenMultiEntry>
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
  final _installDateController = TextEditingController();

  // Vehicle Info
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _licensePlateController = TextEditingController();

  // 🔥 MULTI-ENTRY SERVICE ENTRIES
  List<ServiceEntryModel> _serviceEntries = [];

  // Available Areas (from API)
  List<String> _windowsAreas = [];
  List<String> _ppfAreas = [];

  // Images
  List<File> _images = [];

  // UI State
  bool _isSubmitting = false;
  bool _isLoadingAreas = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Lifecycle
  // ═══════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeServiceEntries();
    _loadProtectedAreas();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  void _initializeServiceEntries() {
    // Start with one empty entry
    _serviceEntries = [
      ServiceEntryModel.empty('entry_${DateTime.now().millisecondsSinceEpoch}'),
    ];
    print('🔧 [DEBUG] Initialized service entries: ${_serviceEntries.length}');
  }

  Future<void> _loadProtectedAreas() async {
    try {
      print('🔄 [DEBUG] Loading protected areas...');
      setState(() => _isLoadingAreas = true);

      // ✅ Call actual API endpoints
      print('📡 [DEBUG] Calling list-windows API...');
      final windowsResponse = await DioHelper.get(path: '/api/user/ext/list-windows');

      print('📡 [DEBUG] Calling list-ppf API...');
      final ppfResponse = await DioHelper.get(path: '/api/user/ext/list-ppf');

      print('✅ [DEBUG] API calls successful');
      print('   Windows Response: ${windowsResponse.data}');
      print('   PPF Response: ${ppfResponse.data}');

      // Parse the response data - Extract from nested structure
      final windowsData = windowsResponse.data['data']?['windowOptions'] as List?;
      final ppfData = ppfResponse.data['data']?['ppfOptions'] as List?;

      print('🔍 [DEBUG] Parsed data:');
      print('   - Windows data: $windowsData');
      print('   - PPF data: $ppfData');

      if (windowsData == null || ppfData == null) {
        throw Exception('Invalid response format - windowOptions or ppfOptions not found');
      }

      setState(() {
        _windowsAreas = windowsData.map((item) => item.toString()).toList();
        _ppfAreas = ppfData.map((item) => item.toString()).toList();
        _isLoadingAreas = false;
      });

      print('✅ [DEBUG] Protected areas loaded from API');
      print('   - Windows areas: ${_windowsAreas.length} areas');
      print('   - PPF areas: ${_ppfAreas.length} areas');
      print('   - Windows list: $_windowsAreas');
      print('   - PPF list: $_ppfAreas');
    } catch (e) {
      print('❌ [DEBUG] Error loading areas: $e');
      print('⚠️ [DEBUG] API FAILED - Using fallback MOCK data (NOT from backend)');

      // Fallback to mock data if API fails
      setState(() {
        _windowsAreas = [
          'Front Window (L)',
          'Front Window (R)',
          'Rear Window (L)',
          'Rear Window (R)',
          'Side Windows',
          'Sunroof',
          'Front Windshield',
          'Rear Windshield',
        ];

        _ppfAreas = [
          'Full Vehicle',
          'Front Bumper',
          'Rear Bumper',
          'Hood',
          'Side Mirrors',
          'Doors (L)',
          'Doors (R)',
          'Roof',
          'Trunk',
        ];

        _isLoadingAreas = false;
      });

      print('⚠️ [DEBUG] Fallback data loaded: ${_windowsAreas.length} windows, ${_ppfAreas.length} ppf');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _installDateController.dispose();
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
                  title: 'New Warranty Registration',
                  subtitle: 'Complete warranty details',
                  icon: Icons.shield_rounded,
                  accentColor: AppTheme.primary,
                  isDark: isDark,
                  onClose: () => Navigator.pop(context),
                ),
                Expanded(
                  child: PremiumLoadingOverlay(
                    isLoading: _isLoadingAreas || _isSubmitting,
                    isDark: isDark,
                    message: _isSubmitting
                        ? 'Submitting warranty...'
                        : 'Loading service areas...',
                    accentColor: AppTheme.primary,
                    style: _isSubmitting
                        ? LoadingStyle.overlay
                        : LoadingStyle.skeleton,
                    child: _isLoadingAreas
                        ? const SizedBox.shrink()
                        : _buildForm(context, isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomActions(context, isDark),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isDark) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 📅 Installation Date - FIRST SECTION
          InstallationDateSection(
            dateController: _installDateController,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // �👤 Customer Information
          CustomerInfoSection(
            firstNameController: _firstNameController,
            lastNameController: _lastNameController,
            emailController: _emailController,
            phoneController: _phoneController,
            isDark: isDark,
          ),
          // const SizedBox(height: 20),
          //
          // // 🛡️ Basic Warranty Information (Code + Serial only)
          // WarrantyBasicInfoSection(
          //   codeController: _warrantyCodeController,
          //   serialController: _serialNumberController,
          //   isDark: isDark,
          // ),
          const SizedBox(height: 20),

          // 🔧 MULTI-ENTRY SERVICE ENTRIES
          DynamicServiceEntriesSection(
            entries: _serviceEntries,
            onEntriesChanged: (entries) {
              setState(() => _serviceEntries = entries);
            },
            windowsAreas: _windowsAreas,
            ppfAreas: _ppfAreas,
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
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    print('📅 [DEBUG] Opening date picker from WarrantyScreenMultiEntry...');
    final now = DateTime.now();

    try {
      print('📅 [DEBUG] Calling CustomDatePicker.showBottomSheet with English locale');
      final picked = await CustomDatePicker.showBottomSheet(
        context: context,
        initialDate: now,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        title: 'Select Installation Date',
        locale: const Locale('en', 'US'), // Force English
      );

      if (picked != null) {
        setState(() {
          _installDateController.text = picked.toString().split(' ')[0];
        });
        print('✅ [DEBUG] Date selected: ${_installDateController.text}');
      } else {
        print('⚠️ [DEBUG] Date picker cancelled');
      }
    } catch (e, stackTrace) {
      print('❌ [DEBUG] Error opening custom date picker: $e');
      print('📍 [DEBUG] Stack trace: $stackTrace');

      // Fallback to default date picker
      print('⚠️ [DEBUG] Falling back to default Material date picker');
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );

      if (picked != null) {
        setState(() {
          _installDateController.text = picked.toString().split(' ')[0];
        });
      }
    }
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurface(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: PressableScale(
                onPressed: _resetForm,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurface(isDark),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    border: Border.all(
                      color: AppTheme.getBorder(isDark),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.getTextSecondary(isDark),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reset Form',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PressableScale(
                onPressed: _isSubmitting ? null : _submitForm,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _isSubmitting
                        ? null
                        : LinearGradient(
                            colors: [AppTheme.purple, AppTheme.purpleLight],
                          ),
                    color: _isSubmitting ? AppTheme.darkGray : null,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    boxShadow: _isSubmitting
                        ? null
                        : [
                            BoxShadow(
                              color: AppTheme.purple.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSubmitting)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _isSubmitting ? 'Submitting...' : 'Submit Warranty',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🚀 Form Actions
  // ═══════════════════════════════════════════════════════════════════════
  void _resetForm() async {
    HapticFeedback.mediumImpact();
    print('🔄 [DEBUG] Reset form requested');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await PremiumDialog.showConfirm(
      context: context,
      title: 'Reset Form?',
      message: 'This will clear all entered data.',
      confirmText: 'Reset',
      cancelText: 'Cancel',
      isDark: isDark,
    );

    if (confirmed == true && mounted) {
      print('✅ [DEBUG] Form reset confirmed');
      setState(() {
        _formKey.currentState?.reset();
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _installDateController.clear();
        _vehicleMakeController.clear();
        _vehicleModelController.clear();
        _vehicleYearController.clear();
        _vehicleColorController.clear();
        _licensePlateController.clear();
        _serviceEntries = [
          ServiceEntryModel.empty(
              'entry_${DateTime.now().millisecondsSinceEpoch}'),
        ];
        _images.clear();
      });
      print('   - All fields cleared');
      print('   - Service entries reset to 1');
      print('   - Images cleared');
      HapticFeedback.mediumImpact();
      PremiumToast.show(
        context: context,
        message: 'Form reset successfully',
        type: ToastType.success,
        isDark: isDark,
      );
    } else {
      print('⚠️ [DEBUG] Reset cancelled');
    }
  }

  Future<void> _submitForm() async {
    print('📤 [DEBUG] Submit form initiated');
    print('   - Validating form...');

    if (!_formKey.currentState!.validate()) {
      print('❌ [DEBUG] Form validation failed');
      _showError('Please fill all required fields');
      return;
    }
    print('✅ [DEBUG] Form validation passed');

    print('   - Checking service entries...');
    print('   - Total entries: ${_serviceEntries.length}');
    for (var i = 0; i < _serviceEntries.length; i++) {
      final entry = _serviceEntries[i];
      print('   - Entry $i: ${entry.serviceType}, ${entry.usedMeters}m, ${entry.protectedAreas.length} areas, valid: ${entry.isValid}');
    }

    if (_serviceEntries.isEmpty || !_serviceEntries.every((e) => e.isValid)) {
      print('❌ [DEBUG] Service entries validation failed');
      _showError('Please add at least one valid service entry');
      return;
    }
    print('✅ [DEBUG] Service entries validation passed');

    // Validate images (required - max 5)
    print('🖼️ [DEBUG] Validating images...');
    print('   - Images count: ${_images.length}');
    if (_images.isEmpty) {
      print('❌ [DEBUG] No images added');
      _showError('Please add at least one vehicle photo');
      return;
    }
    if (_images.length > 5) {
      print('❌ [DEBUG] Too many images (max 5)');
      _showError('Maximum 5 images allowed');
      return;
    }
    print('✅ [DEBUG] Images validation passed (${_images.length} images)');

    setState(() => _isSubmitting = true);

    try {
      print('🔨 [DEBUG] Creating warranty model...');
      final warranty = WarrantyModelMultiEntry(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        installationDate: _installDateController.text.trim(),
        vehicleMake: _vehicleMakeController.text.trim(),
        vehicleModel: _vehicleModelController.text.trim(),
        vehicleYear: int.tryParse(_vehicleYearController.text.trim()) ?? 0,
        vehicleColor: _vehicleColorController.text.trim(),
        licensePlate: _licensePlateController.text.trim(),
        serviceEntries: _serviceEntries,
        images: _images.map((f) => f.path).toList(),
      );

      print('✅ [DEBUG] Warranty model created');
      print('   - Customer: ${warranty.firstName} ${warranty.lastName}');
      print('   - Email: ${warranty.email}');
      print('   - Phone: ${warranty.phone}');
      print('   - Install Date: ${warranty.installationDate}');
      print('   - Vehicle: ${warranty.vehicleMake} ${warranty.vehicleModel}');
      print('   - Year: ${warranty.vehicleYear}');
      print('   - License: ${warranty.licensePlate}');
      print('   - Service Entries: ${warranty.serviceEntries.length}');
      print('   - Images: ${warranty.images.length}');

      final summary = warranty.summary;
      print('   - Summary:');
      print('     • Windows Total: ${summary.totalWindowsMeters}m');
      print('     • PPF Total: ${summary.totalPPFMeters}m');
      print('     • Total Entries: ${summary.totalEntries}');

      // ✅ Submit to API - Multi-Entry Format
      print('📡 [DEBUG] Submitting to API...');
      print('🔨 [DEBUG] Preparing FormData with multi-entry products...');

      // Prepare FormData for multipart/form-data
      final formData = dio.FormData();

      // Basic warranty info
      formData.fields.addAll([
        MapEntry('installDate', warranty.installationDate),
        MapEntry('ownerFirstName', warranty.firstName),
        MapEntry('ownerLastName', warranty.lastName),
        MapEntry('ownerPhoneAreaCode', '+966'),
        MapEntry('ownerPhone', warranty.phone),
        MapEntry('ownerEmail', warranty.email),
        MapEntry('vehicleMake', warranty.vehicleMake),
        MapEntry('vehicleModel', warranty.vehicleModel),
        MapEntry('vehicleYear', warranty.vehicleYear.toString()),
        MapEntry('vehicleColor', warranty.vehicleColor),
        MapEntry('vehicleLicense', warranty.licensePlate),
      ]);

      print('   - Basic info added to FormData');
      print('   - Fields: installDate, ownerFirstName, ownerLastName, ownerPhoneAreaCode, ownerPhone, ownerEmail, vehicleMake, vehicleModel, vehicleYear, vehicleColor, vehicleLicense');

      // Add products array (multi-entry services)
      for (var i = 0; i < warranty.serviceEntries.length; i++) {
        final entry = warranty.serviceEntries[i];
        formData.fields.add(MapEntry('products[$i][usedMeters]', entry.usedMeters.toString()));
        formData.fields.add(MapEntry('products[$i][warrantyCode]', entry.warrantyCode));
        formData.fields.add(MapEntry('products[$i][serialCode]', entry.serialCode));

        // Add protected areas for this product
        for (var j = 0; j < entry.protectedAreas.length; j++) {
          formData.fields.add(MapEntry('products[$i][protectedArea][$j]', entry.protectedAreas[j]));
        }

        print('   - Product $i added: ${entry.serviceType}, ${entry.usedMeters}m, ${entry.protectedAreas.length} areas');
      }

      // Add vehicle photos
      print('📷 [DEBUG] Adding ${_images.length} vehicle photos...');
      for (var i = 0; i < _images.length; i++) {
        final file = _images[i];
        final fileName = file.path.split('/').last;
        final fileSize = await file.length();

        formData.files.add(MapEntry(
          'vehiclePhotos[$i]',
          await dio.MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        ));
        print('   - vehiclePhotos[$i]: $fileName (${(fileSize / 1024).toStringAsFixed(1)} KB)');
      }
      print('✅ [DEBUG] All ${_images.length} images added to FormData');

      print('📤 [DEBUG] Sending request to /api/user/ext/warranty-registration');
// 👇 ADD PRINT HERE
      for (final field in formData.fields) {
        print('${field.key}: ${field.value}');
      }


      final response = await DioHelper.post(
        path: '/api/user/ext/warranty-registration',
        data: formData,
      );

      print('📡 [DEBUG] API Response received');
      print('   - HTTP Status Code: ${response.statusCode}');
      print('   - Response Data: ${response.data}');

      // Parse response data
      final responseData = response.data;

      // Check backend status code (not HTTP status)
      if (responseData is Map && responseData['statusCode'] == 200) {
        // ✅ Success - Backend returned 200
        print('✅ [DEBUG] Warranty registration successful!');
        print('   - Registration ID: ${responseData['data']?['id']}');

        if (mounted) {
          setState(() => _isSubmitting = false);
          print('🎉 [DEBUG] Navigating to Success Screen...');

          // Navigate to full Success Screen (replaces current form)
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const WarrantySuccessScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      } else if (responseData is Map && responseData['statusCode'] == 400) {
        // ❌ Validation Error - Backend returned 400
        print('❌ [DEBUG] Backend validation failed (400)');
        print('❌ [DEBUG] Full response: $responseData');

        String errorMessage = 'Warranty Registration Failed';
        final errorsList = <String>[];

        // Check for "message" field (API error description)
        if (responseData.containsKey('message')) {
          final message = responseData['message'];
          print('⚠️ [DEBUG] API message: $message');
          errorsList.add('• $message');
        }

        // Check for "error" field
        if (responseData.containsKey('error')) {
          final error = responseData['error'];
          print('⚠️ [DEBUG] API error: $error');
          if (error is String && !errorsList.contains('• $error')) {
            errorsList.add('• $error');
          }
        }

        // Parse form errors
        if (responseData.containsKey('formErrors')) {
          final formErrors = responseData['formErrors'] as List?;
          if (formErrors != null && formErrors.isNotEmpty) {
            print('⚠️ [DEBUG] Form validation errors:');

            for (var error in formErrors) {
              if (error is Map) {
                final property = error['property'] ?? 'Unknown';
                final type = error['type'] ?? 'UNKNOWN_ERROR';
                print('   ❌ $property: $type');

                // Build user-friendly error messages
                if (property.contains('warrantyCode')) {
                  if (type == 'INVALID_WARRANTY_CODE') {
                    errorsList.add('• Invalid or non-existent warranty code');
                  } else {
                    errorsList.add('• Error in warranty code');
                  }
                } else if (property.contains('serialCode')) {
                  if (type == 'INVALID_SERIAL_CODE') {
                    errorsList.add('• Invalid serial number');
                  } else {
                    errorsList.add('• Error in serial number');
                  }
                } else if (property.contains('email')) {
                  errorsList.add('• Invalid email address');
                } else if (property.contains('phone')) {
                  errorsList.add('• Invalid phone number');
                } else {
                  errorsList.add('• $property: $type');
                }
              }
            }
          }
        }

        // Build final error message
        if (errorsList.isNotEmpty) {
          errorMessage = 'Registration Failed:\n\n${errorsList.join('\n')}';
        } else {
          // Generic error message if no specific errors found
          errorMessage = 'Registration Failed\n\nPlease check your input and try again.';
        }

        print('❌ [DEBUG] Showing error to user: $errorMessage');

        if (mounted) {
          setState(() => _isSubmitting = false);
          _showError(errorMessage);
        }
      } else {
        // ❌ Unknown response format
        print('❌ [DEBUG] Unexpected response format');
        print('   - Response: $responseData');

        if (mounted) {
          setState(() => _isSubmitting = false);
          _showError('حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى');
        }
      }
    } catch (e) {
      print('❌ [DEBUG] Exception during submission: $e');

      String errorMessage = 'حدث خطأ أثناء التسجيل';

      // Handle DioException specifically
      if (e.toString().contains('DioException') || e.toString().contains('Network')) {
        errorMessage = 'خطأ في الاتصال بالخادم. تحقق من الاتصال بالإنترنت';
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError(errorMessage);
      }
    }
  }

  void _showError(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PremiumDialog.showError(
      context: context,
      title: 'Error',
      message: message,
      isDark: isDark,
    );
  }

  void _showSuccess(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PremiumDialog.showSuccess(
      context: context,
      title: 'Success!',
      message: message,
      isDark: isDark,
    );
  }
}
