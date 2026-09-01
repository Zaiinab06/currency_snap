import 'package:flutter/material.dart';

/// Application color palette defining WCAG AA accessible tokens, Deep Plum & Neon Glow Dark theme, and Clean Light theme.
class AppColors {
  AppColors._();

  // Dark Theme Tokens (Deep Plum & Neon Glow Canvas)
  static const Color darkBackground = Color(0xFF07060A); // Deep canvas
  static const Color darkCardSurface = Color(0xFF160F23); // Deep plum
  static const Color darkInputBox = Color(0xFF231738); // Inner input surface / chips
  static const Color darkBorder = Color(0xFF382352); // Card hairline borders
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8); // High contrast text on dark
  static const Color darkNavBackground = Color(0xFF0D0914);

  // Light Theme Tokens (Fintech Clean Light)
  static const Color lightBackground = Color(0xFFF4F5FA);
  static const Color lightCardSurface = Color(0xFFFFFFFF);
  static const Color lightInputBox = Color(0xFFF8FAFC);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569); // High contrast text on light
  static const Color lightNavBackground = Color(0xFFFFFFFF);

  // Default Dark Tokens
  static const Color background = darkBackground;
  static const Color scaffoldBackground = darkBackground;
  static const Color surface = darkCardSurface;
  static const Color cardSurface = darkCardSurface;
  static const Color surfaceAlt = darkInputBox;
  static const Color inputBox = darkInputBox;
  static const Color surfaceElevated = Color(0xFF231738);
  static const Color navBackground = darkNavBackground;

  // WCAG AA Accessible Neon & Accent Colors
  static const Color neonPink = Color(0xFFF43F5E); // Accessible on #07060A (>4.5:1)
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color primary = neonPurple;
  static const Color primaryLight = neonPink;
  static const Color primaryDark = Color(0xFF6D28D9);
  static const Color accent = neonPink;
  static const Color neonGlow = Color(0x668B5CF6);
  static const Color neonPinkGlow = Color(0x66F43F5E);

  // Borders & Dividers
  static const Color cardBorder = darkBorder;
  static const Color border = darkBorder;
  static const Color borderHighlight = Color(0xFF4A306D);

  // Typography
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = darkTextSecondary;

  // Status & Financial Deltas
  static const Color liveGreen = Color(0xFF10B981);
  static const Color success = liveGreen;
  static const Color deltaPositive = liveGreen;
  static const Color alertRed = Color(0xFFF43F5E);
  static const Color error = alertRed;
  static const Color deltaNegative = alertRed;
  static const Color warning = Color(0xFFF59E0B);

  // On-tokens
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFFFFFFF);

  /// Subtle neutral card decoration utility for dark mode surfaces.
  static BoxDecoration neonCardDecoration({
    Color? color,
    Color? borderColor,
    double borderRadius = 18.0,
    bool glow = false,
    BorderSide? borderSide,
  }) {
    return BoxDecoration(
      color: color ?? cardSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderSide != null
          ? Border.fromBorderSide(borderSide)
          : Border.all(
              color: borderColor ?? cardBorder,
              width: 1.2,
            ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
