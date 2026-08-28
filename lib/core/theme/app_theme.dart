import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central theme configuration for CurrencySnap providing Material 3 Light & Midnight Dark themes adhering to Apple iOS Human Interface Guidelines (HIG).
class AppTheme {
  AppTheme._();

  /// Clean, bright Material 3 fintech light theme.
  static final ThemeData lightTheme = _buildTheme(
    isDark: false,
    background: const Color(0xFFF4F5FA), // Light scaffold background #F4F5FA
    surface: const Color(0xFFFFFFFF),    // Solid white cards #FFFFFF
    surfaceAlt: const Color(0xFFF8FAFC), // Input background #F8FAFC
    surfaceElevated: const Color(0xFFF1F5F9),
    primary: const Color(0xFF6C5CE7),
    primaryLight: const Color(0xFF8C7CFF),
    cardBorder: const Color(0xFFE2E8F0), // Subtle light border #E2E8F0
    borderHighlight: const Color(0xFFCBD5E1),
    textPrimary: const Color(0xFF0F172A), // Dark slate text #0F172A
    textSecondary: const Color(0xFF64748B), // Legible muted slate #64748B
    textMuted: const Color(0xFF94A3B8),
  );

  /// Deep Midnight Obsidian Dark & Neon Purple fintech theme (Permanent default).
  static final ThemeData darkTheme = _buildTheme(
    isDark: true,
    background: const Color(0xFF0B0C1E),
    surface: const Color(0xFF14152D),
    surfaceAlt: const Color(0xFF1B1C38),
    surfaceElevated: const Color(0xFF22244C),
    primary: const Color(0xFF6C5CE7),
    primaryLight: const Color(0xFF8C7CFF),
    cardBorder: const Color(0xFF2E2F52),
    borderHighlight: const Color(0xFF383A6B),
    textPrimary: const Color(0xFFFFFFFF),
    textSecondary: const Color(0xFF8E8EA9),
    textMuted: const Color(0xFF8E8EA9),
  );

  static ThemeData _buildTheme({
    required bool isDark,
    required Color background,
    required Color surface,
    required Color surfaceAlt,
    required Color surfaceElevated,
    required Color primary,
    required Color primaryLight,
    required Color cardBorder,
    required Color borderHighlight,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
  }) {
    final baseTextTheme = (isDark ? ThemeData.dark() : ThemeData.light()).textTheme;
    final interTheme = GoogleFonts.interTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: cardBorder,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              secondary: primaryLight,
              surface: surface,
              error: const Color(0xFFFF5252),
              onPrimary: Colors.white,
              onSurface: textPrimary,
              onSurfaceVariant: textSecondary,
              surfaceContainerHighest: surfaceAlt,
              outline: cardBorder,
              outlineVariant: borderHighlight,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: primaryLight,
              surface: surface,
              error: const Color(0xFFFF5252),
              onPrimary: Colors.white,
              onSurface: textPrimary,
              onSurfaceVariant: textSecondary,
              surfaceContainerHighest: surfaceAlt,
              outline: cardBorder,
              outlineVariant: borderHighlight,
            ),
      textTheme: interTheme.copyWith(
        displayLarge: interTheme.displayLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: textPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        headlineMedium: interTheme.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: textPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        headlineSmall: interTheme.headlineSmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: textPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        titleLarge: interTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        titleMedium: interTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        bodyLarge: interTheme.bodyLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
          color: textPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        bodyMedium: interTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
          color: textSecondary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        labelSmall: interTheme.labelSmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.0,
          color: textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          backgroundColor: surface,
          side: BorderSide(color: cardBorder),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: isDark ? 0.22 : 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? primaryLight : primary,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: isDark ? primaryLight : primary,
              size: 23,
            );
          }
          return IconThemeData(color: textSecondary, size: 22);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: TextStyle(color: textMuted),
      ),
      dividerTheme: DividerThemeData(
        color: cardBorder,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        modalBackgroundColor: background,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceElevated : textPrimary,
        contentTextStyle: GoogleFonts.inter(
          color: isDark ? textPrimary : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cardBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
