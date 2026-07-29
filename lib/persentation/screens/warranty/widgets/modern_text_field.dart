import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'warranty_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📝 Modern Text Field Widget
// ═══════════════════════════════════════════════════════════════════════════
class ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool isDark;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.isDark = false, // Optional with default
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.onChanged,
    this.focusNode,
    this.isRequired = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.getText(isDark),
                letterSpacing: -0.2,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: AppTheme.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Text Field
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppTheme.getText(isDark),
            letterSpacing: -0.2,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.getTextSecondary(isDark),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppTheme.purple,
              size: 20,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(
                    suffixIcon,
                    color: AppTheme.getTextSecondary(isDark),
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: AppTheme.getInputFill(isDark),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: _buildInputBorder(
              AppTheme.getBorder(isDark),
              width: 1,
            ),
            enabledBorder: _buildInputBorder(
              AppTheme.getBorder(isDark),
              width: 1,
            ),
            focusedBorder: _buildInputBorder(
              AppTheme.purple,
              width: 1.5,
            ),
            errorBorder: _buildInputBorder(
              AppTheme.red,
              width: 1.5,
            ),
            focusedErrorBorder: _buildInputBorder(
              AppTheme.red,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildInputBorder(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
