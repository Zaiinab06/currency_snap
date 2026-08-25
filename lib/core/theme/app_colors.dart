import 'package:flutter/material.dart';

/// Application color palette defining Midnight Neon Purple fintech theme tokens.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0B0C1E);
  static const Color surface = Color(0xFF14152D);
  static const Color surfaceAlt = Color(0xFF1B1C38);
  static const Color surfaceElevated = Color(0xFF22244C);

  // Primary & Accents (Neon Purple)
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8C7CFF);
  static const Color primaryDark = Color(0xFF5142CA);
  static const Color accent = Color(0xFF8C7CFF);
  static const Color neonPurple = Color(0xFF6C5CE7);
  static const Color neonPurpleLight = Color(0xFF8C7CFF);
  static const Color neonGlow = Color(0x666C5CE7);

  // Borders & Dividers
  static const Color cardBorder = Color(0xFF252648);
  static const Color border = Color(0xFF252648);
  static const Color borderHighlight = Color(0xFF383A6B);

  // Typography
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8EA8);
  static const Color textMuted = Color(0xFF5E5E7A);

  // Financial Deltas & Status
  static const Color success = Color(0xFF00E676); // Mint Green
  static const Color deltaPositive = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252); // Coral Red
  static const Color deltaNegative = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFB300);

  // On-tokens
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFFFFFFF);
}
