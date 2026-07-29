// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Tracking Colors - الألوان الرسمية للتتبع
// ═══════════════════════════════════════════════════════════════════════════
// ألوان نظام التتبع المباشر
//
// Path: lib/core/live_tracking/theme/tracking_colors.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class TrackingColors {
  TrackingColors._(); // Private constructor

  // Brand Colors
  static const Color green = Color.fromRGBO(0, 200, 141, 1);
  static const Color yellow = Color.fromRGBO(251, 191, 77, 1);
  static const Color black = Color(0xFF1D1D25);
  static const Color omnia = Color(0xFFE5E5F5);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;

  // Status Colors
  static const Color orderPlaced = purple;
  static const Color confirmed = Color(0xFF10B981); // Green for confirmed
  static const Color preparing = yellow;
  static const Color ready = Color(0xFFFF9500); // Orange for ready
  static const Color pickedUp = Color(0xFF00BCD4); // Cyan for picked up
  static const Color outForDelivery = Color(0xFF3B82F6); // Blue for on the way
  static const Color arrived = Color(0xFF8B5CF6); // Light purple for arrived
  static const Color delivered = green;
  static const Color cancelled = Color(0xFFEF4444);
  
  // Additional Status Colors
  static const Color success = Color(0xFF28E6C5);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF6842E2);

  // Gradients as LinearGradient
  static const LinearGradient purpleGradientLinear = LinearGradient(
    colors: [purple, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradientLinear = LinearGradient(
    colors: [green, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradients as List<Color> for compatibility
  static const List<Color> purpleGradient = [
    purple,
    Color(0xFF8B5CF6),
  ];

  static const List<Color> greenGradient = [
    green,
    lightGreen,
  ];

  static const List<Color> yellowGradient = [
    yellow,
    Color(0xFFFFD93D),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF1D1D25),
    Color(0xFF15172A),
  ];
}
