import 'package:flutter/material.dart';

/// CurrencySnap color palette — matches the approved design system
/// (Primary blue accent, light neutral surfaces, dark text).
class AppColors {
  AppColors._();

  // Primary — blue accent used for buttons, links, active states
  static const Color primary = Color(0xFF0057FF);
  static const Color primaryDark = Color(0xFF0040C4);
  static const Color primaryLight = Color(0xFF5C8DFF);

  // Secondary — near-black, used for headings / high-contrast text
  static const Color secondary = Color(0xFF0B0B0F);

  // Tertiary — soft gray, used for secondary text / icons
  static const Color tertiary = Color(0xFF717A7A);

  // Neutrals — surfaces and borders
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF6F7F9);
  static const Color surfaceAlt = Color(0xFFEFF1F4);
  static const Color border = Color(0xFFE3E6EA);

  // Text
  static const Color textPrimary = Color(0xFF0B0B0F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);

  // On-primary (text/icons placed on top of primary blue)
  static const Color onPrimary = Color(0xFFFFFFFF);
}
