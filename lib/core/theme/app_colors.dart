import 'package:flutter/material.dart';

class AppColors {
  // Brand Gradient
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF00C9A7);

  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF8B85FF),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF00C9A7),
    Color(0xFF5EEAD4),
  ];

  // Background Layers
  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Colors.white;

  // Glass Effect
  static final Color glass = Colors.white.withValues(alpha: 0.25);
  static final Color glassStrong = Colors.white.withValues(alpha: 0.4);

  static const Color border = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}