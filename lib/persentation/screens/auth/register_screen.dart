import 'dart:developer';
import 'dart:ui' as ui;

import 'package:app/business_logic/auth/CheckPhoneCubit/check_phone_cubit.dart';
import 'package:app/functions/country_code_sheet.dart' show showCountryCodeBottomSheet;
import 'package:app/network/services/auth_services.dart';
import 'package:app/persentation/screens/auth/login_screen.dart' show LoginScreen;
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class _RegColors {
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color background = Color(0xFF15172A);
  static const Color cardDark = Color(0xFF1E2139);
  static const Color error = Color(0xFFEF4444);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, Color(0xFF8B5CF6)],
  );

  static LinearGradient buttonGradient(bool isDark) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: isDark
            ? [purple, const Color(0xFF8B5CF6)]
            : [dark, const Color(0xFF0D1F3C)],
      );
}

/// Professional multi-step customer registration:
/// form → account agreement → SMS OTP.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _tradeCtrl = TextEditingController();
  final _managerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _vatRegistered = false;
  bool _sendingOtp = false;
  bool _verifyingOtp = false;
  bool _showOtpStep = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  String _otpInput = '';

  PlatformFile? _commercialRegFile;
  PlatformFile? _taxFile;
  PlatformFile? _nationalAddressFile;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _companyCtrl.dispose();
    _tradeCtrl.dispose();
    _managerCtrl.dispose();
    _phoneCtrl.dispose();
    _taxCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  String get _fullPhone {
    final cubit = CheckPhoneCubit.get(context);
    return '${cubit.selectedCounty.code}${_phoneCtrl.text.trim()}';
  }

  Future<void> _pickFile({
    required void Function(PlatformFile file) onPicked,
  }) async {
    HapticFeedback.selectionClick();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      // Required for web uploads (path is null in browser).
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    // Web must have bytes; path is unavailable.
    if (kIsWeb && (file.bytes == null || file.bytes!.isEmpty)) {
      _toast('reg_file_web_bytes_required'.tr());
      return;
    }
    setState(() => onPicked(file));
  }

  PlatformFileLike _toFileLike(PlatformFile file) {
    // On web, reading `file.path` throws — use bytes only.
    return PlatformFileLike(
      name: file.name,
      path: kIsWeb ? null : file.path,
      bytes: file.bytes,
    );
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_commercialRegFile == null) {
      _toast('reg_attach_commercial_required'.tr());
      return false;
    }
    if (_nationalAddressFile == null) {
      _toast('reg_attach_address_required'.tr());
      return false;
    }
    if (_vatRegistered &&
        (_taxFile == null || _taxCtrl.text.trim().isEmpty)) {
      _toast('reg_tax_required_when_vat'.tr());
      return false;
    }
    if (_vatRegistered) {
      final taxDigits =
          _taxCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
      if (taxDigits.length != 15) {
        _toast('reg_tax_invalid'.tr());
        return false;
      }
    }
    return true;
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _RegColors.purple,
      ),
    );
  }

  Future<void> _onRegisterPressed() async {
    FocusScope.of(context).unfocus();
    if (!_validateForm()) return;
    HapticFeedback.mediumImpact();

    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RegisterAgreementSheet(
        companyName: _companyCtrl.text.trim(),
        taxNumber: _vatRegistered ? _taxCtrl.text.trim() : null,
        isDark: _isDark,
      ),
    );

    if (accepted == true && mounted) {
      await _sendOtp();
    }
  }

  Future<void> _sendOtp() async {
    if (_sendingOtp || _verifyingOtp) return;
    setState(() => _sendingOtp = true);
    try {
      final result = await AuthServices().sendRegisterOtp(phone: _fullPhone);
      if (!mounted) return;
      final ok = result != null && result['status'] == true;
      if (!ok) {
        _toast((result?['msg'] ?? 'reg_otp_send_failed'.tr()).toString());
        return;
      }
      final data = result['data'];
      final debugOtp = data is Map ? data['debug_otp']?.toString() : null;

      setState(() {
        _showOtpStep = true;
        if (debugOtp != null && debugOtp.length == 6) {
          _otpInput = debugOtp;
          _otpCtrl.text = debugOtp;
        } else {
          _otpInput = '';
          _otpCtrl.clear();
        }
      });

      if (debugOtp != null && debugOtp.isNotEmpty) {
        _toast('OTP (test): $debugOtp');
      } else {
        _toast((result['msg'] ?? 'reg_otp_sent'.tr()).toString());
      }
    } catch (_) {
      if (!mounted) return;
      _toast('reg_otp_send_failed'.tr());
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_verifyingOtp || _sendingOtp) return;
    if (_otpInput.length < 6) {
      _toast('reg_otp_incomplete'.tr());
      return;
    }
    if (_commercialRegFile == null || _nationalAddressFile == null) {
      _toast('reg_attach_commercial_required'.tr());
      return;
    }

    setState(() => _verifyingOtp = true);
    try {
      final phone = _fullPhone;
      final otp = _otpInput;
      final commercial = _toFileLike(_commercialRegFile!);
      final national = _toFileLike(_nationalAddressFile!);
      final taxDoc = _taxFile == null ? null : _toFileLike(_taxFile!);
      final vat = _vatRegistered;

      final verify = await AuthServices().verifyRegisterOtp(
        phone: phone,
        otp: otp,
      );
      if (!mounted) return;

      final verified = verify != null && verify['status'] == true;
      if (!verified) {
        _toast((verify?['msg'] ?? 'reg_otp_wrong'.tr()).toString());
        return;
      }

      // Fast account create (no files) so customer is not blocked by large docs.
      final result = await AuthServices().registerCustomer(
        companyName: _companyCtrl.text.trim(),
        tradeName: _tradeCtrl.text.trim(),
        managerName: _managerCtrl.text.trim(),
        phone: phone,
        password: _passwordCtrl.text,
        passwordConfirmation: _passwordConfirmCtrl.text,
        isVatRegistered: vat,
        taxNumber: vat
            ? _taxCtrl.text.trim().replaceAll(RegExp(r'\D'), '')
            : null,
        otp: otp,
      );

      if (!mounted) return;

      final ok = result != null && result['status'] == true;
      if (!ok) {
        _toast((result?['msg'] ?? 'reg_submit_failed'.tr()).toString());
        return;
      }

      // Upload documents in background (do not block UI).
      // ignore: unawaited_futures
      AuthServices()
          .uploadRegisterDocuments(
        phone: phone,
        otp: otp,
        isVatRegistered: vat,
        commercialRegistration: commercial,
        taxDocument: taxDoc,
        nationalAddress: national,
      )
          .then((upload) {
        final uploadOk = upload != null && upload['status'] == true;
        log(
          uploadOk
              ? 'Register documents uploaded in background'
              : 'Register documents upload failed: ${upload?['msg']}',
        );
      });

      HapticFeedback.heavyImpact();
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('reg_success_title'.tr()),
          content: Text('reg_success_body_bg_upload'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              child: Text(
                'reg_back_to_login'.tr(),
                style: const TextStyle(
                  color: _RegColors.purple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _verifyingOtp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor:
            _isDark ? _RegColors.background : _RegColors.lightGray,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  child: _showOtpStep ? _buildOtpStep() : _buildFormStep(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_showOtpStep) {
                setState(() => _showOtpStep = false);
              } else {
                Navigator.of(context).maybePop();
              }
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: _isDark ? Colors.white : _RegColors.dark,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showOtpStep
                      ? 'reg_otp_title'.tr()
                      : 'reg_screen_title'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _isDark ? Colors.white : _RegColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _showOtpStep
                      ? 'reg_otp_subtitle'.tr()
                      : 'reg_screen_subtitle'.tr(),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormStep() {
    return Form(
      key: _formKey,
      child: ListView(
        key: const ValueKey('register-form'),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _heroCard(),
          const SizedBox(height: 18),
          _sectionLabel('reg_section_company'.tr()),
          const SizedBox(height: 10),
          _field(
            controller: _companyCtrl,
            label: 'reg_company_name'.tr(),
            icon: Icons.apartment_rounded,
            validator: _required,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _tradeCtrl,
            label: 'reg_trade_name_optional'.tr(),
            icon: Icons.storefront_rounded,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _managerCtrl,
            label: 'reg_manager_name'.tr(),
            icon: Icons.badge_outlined,
            validator: _required,
          ),
          const SizedBox(height: 18),
          _sectionLabel('reg_section_contact'.tr()),
          const SizedBox(height: 10),
          _phoneField(),
          const SizedBox(height: 12),
          _passwordField(
            controller: _passwordCtrl,
            label: 'reg_password'.tr(),
            obscure: _obscurePassword,
            onToggle: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            validator: (v) {
              if (v == null || v.length < 6) {
                return 'reg_password_invalid'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _passwordField(
            controller: _passwordConfirmCtrl,
            label: 'reg_password_confirm'.tr(),
            obscure: _obscurePasswordConfirm,
            onToggle: () => setState(
              () => _obscurePasswordConfirm = !_obscurePasswordConfirm,
            ),
            validator: (v) {
              if (v != _passwordCtrl.text) {
                return 'reg_password_mismatch'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          _sectionLabel('reg_section_vat'.tr()),
          const SizedBox(height: 10),
          _vatToggle(),
          if (_vatRegistered) ...[
            const SizedBox(height: 12),
            _field(
              controller: _taxCtrl,
              label: 'reg_tax_number'.tr(),
              icon: Icons.receipt_long_rounded,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (!_vatRegistered) return null;
                if (v == null || v.trim().isEmpty) {
                  return 'reg_field_required'.tr();
                }
                final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                if (digits.length != 15) {
                  return 'reg_tax_invalid'.tr();
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 18),
          _sectionLabel('reg_section_attachments'.tr()),
          const SizedBox(height: 6),
          Text(
            'reg_attachments_hint'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: _isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 12),
          _attachmentTile(
            title: 'reg_attach_commercial'.tr(),
            subtitle: 'reg_attach_required'.tr(),
            file: _commercialRegFile,
            onTap: () => _pickFile(
              onPicked: (f) => _commercialRegFile = f,
            ),
            onClear: () => setState(() => _commercialRegFile = null),
          ),
          const SizedBox(height: 10),
          _attachmentTile(
            title: 'reg_attach_tax'.tr(),
            subtitle: _vatRegistered
                ? 'reg_attach_required'.tr()
                : 'reg_attach_optional'.tr(),
            file: _taxFile,
            onTap: () => _pickFile(onPicked: (f) => _taxFile = f),
            onClear: () => setState(() => _taxFile = null),
          ),
          const SizedBox(height: 10),
          _attachmentTile(
            title: 'reg_attach_address'.tr(),
            subtitle: 'reg_attach_required'.tr(),
            file: _nationalAddressFile,
            onTap: () => _pickFile(
              onPicked: (f) => _nationalAddressFile = f,
            ),
            onClear: () => setState(() => _nationalAddressFile = null),
          ),
          const SizedBox(height: 28),
          _primaryButton(
            label: 'reg_submit'.tr(),
            loading: _sendingOtp,
            onTap: _onRegisterPressed,
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(
                'reg_have_account'.tr(),
                style: const TextStyle(
                  color: _RegColors.purple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    return ListView(
      key: const ValueKey('register-otp'),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: _RegColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: _RegColors.purple.withValues(alpha: 0.28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.sms_rounded, color: Colors.white, size: 36),
              const SizedBox(height: 12),
              Text(
                'reg_otp_sent_to'.tr(namedArgs: {'phone': _fullPhone}),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Directionality(
          textDirection: ui.TextDirection.ltr,
          child: PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            animationType: AnimationType.fade,
            autoFocus: true,
            cursorColor: _RegColors.purple,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(12),
              fieldHeight: 52,
              fieldWidth: 44,
              activeFillColor:
                  _isDark ? _RegColors.cardDark : Colors.white,
              inactiveFillColor:
                  _isDark ? _RegColors.cardDark : Colors.white,
              selectedFillColor:
                  _isDark ? _RegColors.cardDark : Colors.white,
              activeColor: _RegColors.purple,
              selectedColor: _RegColors.purple,
              inactiveColor:
                  _isDark ? Colors.white24 : const Color(0xFFE5E7EB),
            ),
            enableActiveFill: true,
            onChanged: (v) => setState(() => _otpInput = v),
            onCompleted: (_) {
              if (!_verifyingOtp && !_sendingOtp) {
                _verifyOtp();
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: (_sendingOtp || _verifyingOtp) ? null : _sendOtp,
            child: _sendingOtp
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'reg_resend_otp'.tr(),
                    style: const TextStyle(
                      color: _RegColors.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 18),
        _primaryButton(
          label: 'reg_verify_otp'.tr(),
          loading: _verifyingOtp,
          onTap: _verifyOtp,
        ),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C4DFF), Color(0xFF6842E2), Color(0xFF2F1C7A)],
        ),
        boxShadow: [
          BoxShadow(
            color: _RegColors.purple.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.how_to_reg_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'reg_hero_title'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'reg_hero_subtitle'.tr(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
        color: _isDark ? _RegColors.lightGreen : _RegColors.purple,
      ),
    );
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return 'reg_field_required'.tr();
    return null;
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: _isDark ? Colors.white : _RegColors.dark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: _isDark ? Colors.white54 : Colors.black45,
        ),
        prefixIcon: Icon(icon, color: _RegColors.purple, size: 20),
        filled: true,
        fillColor: _isDark ? _RegColors.cardDark : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: _isDark ? Colors.white12 : const Color(0xFFE8EAF0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: _isDark ? Colors.white12 : const Color(0xFFE8EAF0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: _RegColors.purple, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _RegColors.error),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: _isDark ? Colors.white : _RegColors.dark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: _isDark ? Colors.white54 : Colors.black45,
        ),
        prefixIcon:
            const Icon(Icons.lock_outline_rounded, color: _RegColors.purple, size: 20),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        filled: true,
        fillColor: _isDark ? _RegColors.cardDark : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: _isDark ? Colors.white12 : const Color(0xFFE8EAF0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: _isDark ? Colors.white12 : const Color(0xFFE8EAF0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: _RegColors.purple, width: 1.4),
        ),
      ),
    );
  }

  Widget _phoneField() {
    return BlocBuilder<CheckPhoneCubit, CheckPhoneState>(
      builder: (context, state) {
        final cubit = CheckPhoneCubit.get(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => showCountryCodeBottomSheet(context),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color:
                          _isDark ? _RegColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isDark
                            ? Colors.white12
                            : const Color(0xFFE8EAF0),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SvgPicture.asset(
                            cubit.selectedCounty.flag,
                            width: 26,
                            height: 18,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cubit.selectedCounty.code,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: _isDark
                                ? Colors.white
                                : _RegColors.dark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _isDark ? Colors.white54 : Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'reg_field_required'.tr();
                      }
                      if (v.trim().length < 8) {
                        return 'reg_phone_invalid'.tr();
                      }
                      return null;
                    },
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color:
                          _isDark ? Colors.white : _RegColors.dark,
                    ),
                    decoration: InputDecoration(
                      hintText: '5XX XXX XXXX',
                      filled: true,
                      fillColor:
                          _isDark ? _RegColors.cardDark : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: _isDark
                              ? Colors.white12
                              : const Color(0xFFE8EAF0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: _isDark
                              ? Colors.white12
                              : const Color(0xFFE8EAF0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _RegColors.purple,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'reg_phone_hint_saudi'.tr(),
              style: TextStyle(
                fontSize: 11.5,
                color: _isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _vatToggle() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isDark ? _RegColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDark ? Colors.white12 : const Color(0xFFE8EAF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'reg_vat_question'.tr(),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: _isDark ? Colors.white : _RegColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _choiceChip(
                  label: 'reg_yes'.tr(),
                  selected: _vatRegistered,
                  onTap: () => setState(() => _vatRegistered = true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _choiceChip(
                  label: 'reg_no'.tr(),
                  selected: !_vatRegistered,
                  onTap: () => setState(() {
                    _vatRegistered = false;
                    _taxCtrl.clear();
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: selected ? _RegColors.primaryGradient : null,
          color: selected
              ? null
              : (_isDark ? const Color(0xFF15172A) : const Color(0xFFF3F4F8)),
          border: selected
              ? null
              : Border.all(
                  color: _isDark ? Colors.white12 : const Color(0xFFE5E7EB),
                ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: selected
                  ? Colors.white
                  : (_isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _attachmentTile({
    required String title,
    required String subtitle,
    required PlatformFile? file,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final hasFile = file != null;
    return Material(
      color: _isDark ? _RegColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasFile
                  ? _RegColors.lightGreen.withValues(alpha: 0.55)
                  : (_isDark ? Colors.white12 : const Color(0xFFE8EAF0)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: hasFile
                      ? _RegColors.lightGreen.withValues(alpha: 0.15)
                      : _RegColors.purple.withValues(alpha: 0.12),
                ),
                child: Icon(
                  hasFile
                      ? Icons.check_circle_rounded
                      : Icons.upload_file_rounded,
                  color: hasFile
                      ? _RegColors.lightGreen
                      : _RegColors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _isDark ? Colors.white : _RegColors.dark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasFile ? (file.name) : subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: hasFile
                            ? _RegColors.lightGreen
                            : (_isDark ? Colors.white54 : Colors.black45),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFile)
                IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: _isDark ? Colors.white54 : Colors.black45,
                    size: 20,
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded,
                    color: _RegColors.purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _RegColors.buttonGradient(_isDark),
          boxShadow: [
            BoxShadow(
              color: _RegColors.purple.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Account agreement sheet (demo contract text + company / tax from form)
// ═══════════════════════════════════════════════════════════════════════════
class _RegisterAgreementSheet extends StatelessWidget {
  final String companyName;
  final String? taxNumber;
  final bool isDark;

  const _RegisterAgreementSheet({
    required this.companyName,
    required this.taxNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.86;
    final hasTax = taxNumber != null && taxNumber!.isNotEmpty;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? _RegColors.background : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: _RegColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.gavel_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'reg_agreement_title'.tr(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : _RegColors.dark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _RegColors.purple.withValues(
                        alpha: isDark ? 0.18 : 0.08,
                      ),
                      border: Border.all(
                        color: _RegColors.purple.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'reg_agreement_party'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          companyName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _RegColors.purple,
                          ),
                        ),
                        if (hasTax) ...[
                          const SizedBox(height: 10),
                          Text(
                            'reg_agreement_tax_label'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            taxNumber!,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color:
                                  isDark ? Colors.white : _RegColors.dark,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'reg_agreement_body'.tr(),
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.65,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context, true);
              },
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: _RegColors.buttonGradient(isDark),
                  boxShadow: [
                    BoxShadow(
                      color: _RegColors.purple.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'reg_read_terms'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
