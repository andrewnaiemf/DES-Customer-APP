import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🔤 English Only Input Formatter
// Allows: A-Z, a-z, 0-9, spaces, and common punctuation
// Blocks: Arabic letters, emojis, special characters
// ═══════════════════════════════════════════════════════════════════════════
class EnglishOnlyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only English letters, numbers, spaces, and common punctuation
    // Pattern: A-Z, a-z, 0-9, space, dash, underscore, dot, comma, parentheses
    final regExp = RegExp(r'^[a-zA-Z0-9 \-_.,()@#&]*$');
    
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    
    // If new text contains non-English characters, keep old value
    return oldValue;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔢 English & Numbers Only Input Formatter (No Spaces or Special Chars)
// Allows: A-Z, a-z, 0-9 only
// Blocks: Everything else including spaces, Arabic, punctuation
// ═══════════════════════════════════════════════════════════════════════════
class EnglishNumbersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only English letters and numbers (no spaces or special chars)
    final regExp = RegExp(r'^[a-zA-Z0-9]*$');
    
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    
    return oldValue;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔠 English Letters Only (No Numbers)
// Allows: A-Z, a-z, spaces
// Blocks: Numbers, Arabic, special characters
// ═══════════════════════════════════════════════════════════════════════════
class EnglishLettersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only English letters and spaces
    final regExp = RegExp(r'^[a-zA-Z ]*$');
    
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    
    return oldValue;
  }
}
