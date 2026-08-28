import 'package:flutter/material.dart';

/// Application color palette defining Obsidian Dark & Fintech Clean Light theme tokens.
class AppColors {
  AppColors._();

  // Dark Theme Tokens (Obsidian Dark)
  static const Color darkBackground = Color(0xFF0B0C1E);
  static const Color darkCardSurface = Color(0xFF14152D);
  static const Color darkInputBox = Color(0xFF1B1C38);
  static const Color darkBorder = Color(0xFF2E2F52);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8EA9);
  static const Color darkNavBackground = Color(0xFF0E0F24);

  // Light Theme Tokens (Fintech Clean Light)
  static const Color lightBackground = Color(0xFFF4F5FA);
  static const Color lightCardSurface = Color(0xFFFFFFFF);
  static const Color lightInputBox = Color(0xFFF8FAFC);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightNavBackground = Color(0xFFFFFFFF);

  // Default Dark Tokens
  static const Color background = darkBackground;
  static const Color scaffoldBackground = darkBackground;
  static const Color surface = darkCardSurface;
  static const Color cardSurface = darkCardSurface;
  static const Color surfaceAlt = darkInputBox;
  static const Color inputBox = darkInputBox;
  static const Color surfaceElevated = Color(0xFF22244C);
  static const Color navBackground = darkNavBackground;

  // Primary & Accents (Neon Purple)
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8C7CFF);
  static const Color primaryDark = Color(0xFF5142CA);
  static const Color accent = Color(0xFF8C7CFF);
  static const Color neonPurple = Color(0xFF6C5CE7);
  static const Color neonPurpleLight = Color(0xFF8C7CFF);
  static const Color neonGlow = Color(0x666C5CE7);

  // Borders & Dividers
  static const Color cardBorder = darkBorder;
  static const Color border = darkBorder;
  static const Color borderHighlight = Color(0xFF383A6B);

  // Typography
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = darkTextSecondary;

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
