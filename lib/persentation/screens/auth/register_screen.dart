import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app/business_logic/auth/CheckPhoneCubit/check_phone_cubit.dart';
import 'package:app/data/constants/account_agreement.dart';
import 'package:app/functions/account_agreement_pdf.dart';
import 'package:app/functions/country_code_sheet.dart' show showCountryCodeBottomSheet;
import 'package:app/functions/download_bytes.dart';
import 'package:app/network/services/auth_services.dart';
import 'package:app/persentation/screens/auth/login_screen.dart' show LoginScreen;
import 'package:app/persentation/screens/auth/widgets/register_signature_pad.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:share_plus/share_plus.dart';

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

enum _RegStep { form, agreement, sign, otp }

/// Professional multi-step customer registration:
/// form → account agreement → signature/stamp → SMS OTP.
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
  final _crCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _additionalCtrl = TextEditingController();
  final _signerNameCtrl = TextEditingController();
  final _signerTitleCtrl = TextEditingController();
  final _signPadKey = GlobalKey<RegisterSignaturePadState>();

  bool _vatRegistered = false;
  bool _acceptedTerms = false;
  bool _sendingOtp = false;
  bool _verifyingOtp = false;
  bool _downloadingPdf = false;
  _RegStep _step = _RegStep.form;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  String _otpInput = '';
  List<int>? _signatureBytes;
  PlatformFile? _stampFile;

  PlatformFile? _commercialRegFile;
  PlatformFile? _taxFile;
  PlatformFile? _nationalAddressFile;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _companyCtrl.dispose();
    _tradeCtrl.dispose();
    _managerCtrl.dispose();
    _crCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _taxCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    _otpCtrl.dispose();
    _buildingCtrl.dispose();
    _streetCtrl.dispose();
    _districtCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _additionalCtrl.dispose();
    _signerNameCtrl.dispose();
    _signerTitleCtrl.dispose();
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

  bool _isBlockingOtpError(String msg) {
    final lower = msg.toLowerCase();
    return lower.contains('already') ||
        lower.contains('wait') ||
        lower.contains('too many') ||
        lower.contains('مسجل') ||
        lower.contains('انتظر');
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
    if (_signerNameCtrl.text.trim().isEmpty) {
      _signerNameCtrl.text = _managerCtrl.text.trim();
    }
    setState(() => _step = _RegStep.agreement);
  }

  Future<void> _sendOtp() async {
    if (_sendingOtp || _verifyingOtp) return;
    setState(() => _sendingOtp = true);
    try {
      final result = await AuthServices().sendRegisterOtp(phone: _fullPhone);
      if (!mounted) return;
      final msg = (result?['msg'] ?? '').toString();
      final ok = result != null && result['status'] == true;
      if (!ok && _isBlockingOtpError(msg)) {
        _toast(msg.isNotEmpty ? msg : 'reg_otp_send_failed'.tr());
        return;
      }
      final data = result?['data'];
      final debugOtp = data is Map ? data['debug_otp']?.toString() : null;

      setState(() {
        _step = _RegStep.otp;
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
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _step = _RegStep.otp);
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
        commercialRegistrationNumber: _crCtrl.text.trim(),
        phone: phone,
        password: _passwordCtrl.text,
        passwordConfirmation: _passwordConfirmCtrl.text,
        isVatRegistered: vat,
        taxNumber: vat
            ? _taxCtrl.text.trim().replaceAll(RegExp(r'\D'), '')
            : null,
        otp: otp,
        email: _emailCtrl.text.trim(),
        buildingNumber: _buildingCtrl.text.trim(),
        street: _streetCtrl.text.trim(),
        district: _districtCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        postalCode: _postalCtrl.text.trim(),
        additionalNumber: _additionalCtrl.text.trim(),
        signerName: _signerNameCtrl.text.trim(),
        signerTitle: _signerTitleCtrl.text.trim(),
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
        signature: PlatformFileLike(
          name: 'signature.png',
          bytes: _signatureBytes,
        ),
        stamp: _toFileLike(_stampFile!),
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
                  child: switch (_step) {
                    _RegStep.form => _buildFormStep(),
                    _RegStep.agreement => _buildAgreementStep(),
                    _RegStep.sign => _buildSignStep(),
                    _RegStep.otp => _buildOtpStep(),
                  },
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
              if (_step == _RegStep.otp) {
                setState(() => _step = _RegStep.sign);
              } else if (_step == _RegStep.sign) {
                setState(() => _step = _RegStep.agreement);
              } else if (_step == _RegStep.agreement) {
                setState(() => _step = _RegStep.form);
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
                  switch (_step) {
                    _RegStep.otp => 'reg_otp_title'.tr(),
                    _RegStep.agreement => 'reg_agreement_title'.tr(),
                    _RegStep.sign => 'reg_sign_title'.tr(),
                    _RegStep.form => 'reg_screen_title'.tr(),
                  },
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _isDark ? Colors.white : _RegColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  switch (_step) {
                    _RegStep.otp => 'reg_otp_subtitle'.tr(),
                    _RegStep.agreement => 'reg_agreement_subtitle'.tr(),
                    _RegStep.sign => 'reg_sign_subtitle'.tr(),
                    _RegStep.form => 'reg_screen_subtitle'.tr(),
                  },
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
          const SizedBox(height: 12),
          _field(
            controller: _crCtrl,
            label: 'reg_cr_number'.tr(),
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
            validator: _required,
          ),
          const SizedBox(height: 18),
          _sectionLabel('reg_section_contact'.tr()),
          const SizedBox(height: 10),
          _phoneField(),
          const SizedBox(height: 12),
          _field(
            controller: _emailCtrl,
            label: 'reg_email_optional'.tr(),
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _passwordField(
            controller: _passwordCtrl,
            label: 'reg_password'.tr(),
            obscure: _obscurePassword,
            onToggle: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            keyboardType: TextInputType.number,
            inputFormatters: const [_EnglishDigitsFormatter()],
            validator: (v) {
              if (v == null || v.length < 6 || !RegExp(r'^[0-9]+$').hasMatch(v)) {
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
            keyboardType: TextInputType.number,
            inputFormatters: const [_EnglishDigitsFormatter()],
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
              inputFormatters: const [_EnglishDigitsFormatter(maxLength: 15)],
              validator: (v) {
                if (!_vatRegistered) return null;
                final digits = (v ?? '').trim();
                if (digits.isEmpty) {
                  return 'reg_field_required'.tr();
                }
                if (!RegExp(r'^3[0-9]{13}3$').hasMatch(digits)) {
                  return 'reg_tax_invalid'.tr();
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 18),
          _sectionLabel('reg_section_address'.tr()),
          const SizedBox(height: 10),
          _field(
            controller: _buildingCtrl,
            label: 'reg_building_number'.tr(),
            icon: Icons.home_work_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: const [_EnglishDigitsFormatter(maxLength: 4)],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'reg_field_required'.tr();
              }
              if (!RegExp(r'^[0-9]{4}$').hasMatch(v.trim())) {
                return 'reg_building_invalid'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _field(
            controller: _streetCtrl,
            label: 'reg_street'.tr(),
            icon: Icons.signpost_outlined,
            validator: _required,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _districtCtrl,
            label: 'reg_district'.tr(),
            icon: Icons.map_outlined,
            validator: _required,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _cityCtrl,
            label: 'reg_city'.tr(),
            icon: Icons.location_city_outlined,
            validator: _required,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _postalCtrl,
            label: 'reg_postal_code'.tr(),
            icon: Icons.local_post_office_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: const [_EnglishDigitsFormatter(maxLength: 5)],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'reg_field_required'.tr();
              }
              if (!RegExp(r'^[0-9]{5}$').hasMatch(v.trim())) {
                return 'reg_postal_invalid'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _field(
            controller: _additionalCtrl,
            label: 'reg_additional_number_optional'.tr(),
            icon: Icons.tag_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: const [_EnglishDigitsFormatter(maxLength: 4)],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              if (!RegExp(r'^[0-9]{4}$').hasMatch(v.trim())) {
                return 'reg_additional_invalid'.tr();
              }
              return null;
            },
          ),
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
            label: 'reg_continue'.tr(),
            loading: false,
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

  Widget _buildAgreementStep() {
    final data = AccountAgreementData.fromForm(
      companyName: _companyCtrl.text,
      crNumber: _crCtrl.text,
      buildingNumber: _buildingCtrl.text,
      street: _streetCtrl.text,
      district: _districtCtrl.text,
      city: _cityCtrl.text,
      postalCode: _postalCtrl.text,
      signerName: _signerNameCtrl.text.isEmpty
          ? _managerCtrl.text
          : _signerNameCtrl.text,
      signerTitle: _signerTitleCtrl.text,
    );

    return ListView(
      key: const ValueKey('register-agreement'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
          decoration: BoxDecoration(
            color: _isDark ? _RegColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFE8E4F8),
            ),
            boxShadow: [
              BoxShadow(
                color: _RegColors.purple.withValues(alpha: _isDark ? 0.12 : 0.08),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'reg_agreement_title'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'GraphikArabic',
                  fontSize: 20,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                  color: _isDark ? Colors.white : _RegColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 72,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: _RegColors.primaryGradient,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(data.intro, style: _agreementBodyStyle()),
              const SizedBox(height: 12),
              _agreementPartyCard(data.partyOne),
              const SizedBox(height: 10),
              _agreementPartyCard(data.partyTwo),
              const SizedBox(height: 12),
              Text(
                'وقد اتفق الطرفان، وهما بكامل أهليتهما الشرعية والنظامية، على ما يلي:',
                style: _agreementBodyStyle(weight: FontWeight.w600),
              ),
              for (final clause in data.clauses) ...[
                const SizedBox(height: 14),
                Text(
                  clause['title']!,
                  style: TextStyle(
                    fontFamily: 'GraphikArabic',
                    fontSize: 14.5,
                    height: 1.45,
                    fontWeight: FontWeight.w800,
                    color: _RegColors.purple,
                  ),
                ),
                const SizedBox(height: 6),
                Text(clause['body']!, style: _agreementBodyStyle()),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _acceptedTerms = !_acceptedTerms);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: _isDark ? _RegColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _acceptedTerms
                    ? _RegColors.purple
                    : (_isDark ? Colors.white12 : const Color(0xFFE8EAF0)),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  activeColor: _RegColors.purple,
                  onChanged: (v) {
                    setState(() => _acceptedTerms = v ?? false);
                  },
                ),
                Expanded(
                  child: Text(
                    'reg_read_terms'.tr(),
                    style: TextStyle(
                      fontFamily: 'GraphikArabic',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _isDark ? Colors.white : _RegColors.dark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _primaryButton(
          label: 'reg_accept_agreement'.tr(),
          onTap: () {
            if (!_acceptedTerms) {
              _toast('reg_terms_required'.tr());
              return;
            }
            HapticFeedback.mediumImpact();
            setState(() => _step = _RegStep.sign);
          },
        ),
      ],
    );
  }

  Widget _agreementPartyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF7F5FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: _agreementBodyStyle()),
    );
  }

  TextStyle _agreementBodyStyle({FontWeight weight = FontWeight.w500}) {
    return TextStyle(
      fontFamily: 'GraphikArabic',
      fontSize: 13.4,
      height: 1.85,
      fontWeight: weight,
      color: _isDark ? Colors.white70 : const Color(0xFF2A2D3A),
    );
  }

  Widget _buildSignStep() {
    return ListView(
      key: const ValueKey('register-sign'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        _sectionLabel('reg_sign_name'.tr()),
        const SizedBox(height: 10),
        _field(
          controller: _signerNameCtrl,
          label: 'reg_sign_name'.tr(),
          icon: Icons.person_outline,
          validator: _required,
        ),
        const SizedBox(height: 12),
        _sectionLabel('reg_sign_title_field'.tr()),
        const SizedBox(height: 10),
        _field(
          controller: _signerTitleCtrl,
          label: 'reg_sign_title_field'.tr(),
          icon: Icons.work_outline,
          validator: _required,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _sectionLabel('reg_sign_draw'.tr())),
            TextButton(
              onPressed: () => _signPadKey.currentState?.clear(),
              child: Text('reg_sign_clear'.tr()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RegisterSignaturePad(
          key: _signPadKey,
          isDark: _isDark,
          onChanged: () {},
        ),
        const SizedBox(height: 16),
        _sectionLabel('reg_stamp'.tr()),
        const SizedBox(height: 8),
        Text(
          'reg_stamp_hint'.tr(),
          style: TextStyle(
            fontSize: 12,
            color: _isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 10),
        _stampGuide(),
        const SizedBox(height: 12),
        _attachmentTile(
          title: 'reg_stamp_upload'.tr(),
          subtitle: 'reg_attach_required'.tr(),
          file: _stampFile,
          onTap: _pickStamp,
          onClear: () => setState(() => _stampFile = null),
        ),
        const SizedBox(height: 22),
        _primaryButton(
          label: 'reg_download_agreement'.tr(),
          loading: _downloadingPdf,
          onTap: _downloadAgreementPdf,
        ),
        const SizedBox(height: 12),
        _primaryButton(
          label: 'reg_continue_otp'.tr(),
          loading: _sendingOtp,
          onTap: _onSignContinue,
        ),
      ],
    );
  }

  Widget _stampGuide() {
    final steps = [
      ('1', 'reg_stamp_step_1'.tr(), Icons.photo_camera_outlined),
      ('2', 'reg_stamp_step_2'.tr(), Icons.crop_free_rounded),
      ('3', 'reg_stamp_step_3'.tr(), Icons.upload_rounded),
    ];
    return Column(
      children: [
        for (final step in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isDark ? _RegColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _RegColors.purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(step.$3, color: _RegColors.purple, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${step.$1}. ${step.$2}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _isDark ? Colors.white : _RegColors.dark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickStamp() async {
    HapticFeedback.selectionClick();
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _stampFile = PlatformFile(
        name: image.name,
        size: bytes.length,
        bytes: bytes,
        path: kIsWeb ? null : image.path,
      );
    });
  }

  Future<bool> _captureSignature() async {
    final bytes = await _signPadKey.currentState?.exportPng();
    if (bytes == null || bytes.isEmpty) {
      _toast('reg_sign_required'.tr());
      return false;
    }
    _signatureBytes = bytes;
    return true;
  }

  Future<void> _onSignContinue() async {
    if (_signerNameCtrl.text.trim().isEmpty ||
        _signerTitleCtrl.text.trim().isEmpty) {
      _toast('reg_field_required'.tr());
      return;
    }
    if (_stampFile == null) {
      _toast('reg_stamp_required'.tr());
      return;
    }
    if (!await _captureSignature()) return;
    await _sendOtp();
  }

  Future<void> _downloadAgreementPdf() async {
    if (_downloadingPdf) return;
    if (_signerNameCtrl.text.trim().isEmpty ||
        _signerTitleCtrl.text.trim().isEmpty) {
      _toast('reg_field_required'.tr());
      return;
    }
    if (_stampFile == null) {
      _toast('reg_stamp_required'.tr());
      return;
    }
    if (!await _captureSignature()) return;

    setState(() => _downloadingPdf = true);
    try {
      final stampBytes = _stampFile?.bytes;
      if (stampBytes == null || stampBytes.isEmpty) {
        _toast('reg_stamp_required'.tr());
        return;
      }
      final data = AccountAgreementData.fromForm(
        companyName: _companyCtrl.text,
        crNumber: _crCtrl.text,
        buildingNumber: _buildingCtrl.text,
        street: _streetCtrl.text,
        district: _districtCtrl.text,
        city: _cityCtrl.text,
        postalCode: _postalCtrl.text,
        signerName: _signerNameCtrl.text,
        signerTitle: _signerTitleCtrl.text,
      );
      final bytes = await AccountAgreementPdf.build(
        data: data,
        signatureBytes: _signatureBytes!,
        stampBytes: stampBytes,
      );
      if (!mounted) return;
      final file = XFile.fromData(
        bytes,
        mimeType: 'application/pdf',
        name: 'DES-account-agreement.pdf',
      );
      if (kIsWeb) {
        await downloadBytes(bytes, 'DES-account-agreement.pdf', 'application/pdf');
      } else {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/DES-account-agreement.pdf';
        await file.saveTo(path);
        await Share.shareXFiles([XFile(path)]);
      }
    } catch (e) {
      log('download agreement pdf: $e');
      if (mounted) _toast('reg_pdf_failed'.tr());
    } finally {
      if (mounted) setState(() => _downloadingPdf = false);
    }
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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
                      const _EnglishDigitsFormatter(),
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

class _EnglishDigitsFormatter extends TextInputFormatter {
  const _EnglishDigitsFormatter({this.maxLength});

  final int? maxLength;

  static const _arabic = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
    '۰': '0',
    '۱': '1',
    '۲': '2',
    '۳': '3',
    '۴': '4',
    '۵': '5',
    '۶': '6',
    '۷': '7',
    '۸': '8',
    '۹': '9',
  };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    for (final rune in newValue.text.runes) {
      final char = String.fromCharCode(rune);
      final mapped = _arabic[char] ?? char;
      if (RegExp(r'[0-9]').hasMatch(mapped)) {
        buffer.write(mapped);
      }
    }
    var text = buffer.toString();
    if (maxLength != null && text.length > maxLength!) {
      text = text.substring(0, maxLength!);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
