import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Central theme configuration for CurrencySnap providing Deep Plum & Neon Glow Dark theme and Clean Light theme.
class AppTheme {
  AppTheme._();

  /// Clean, bright Material 3 fintech light theme.
  static final ThemeData lightTheme = _buildTheme(
    isDark: false,
    background: AppColors.lightBackground,
    surface: AppColors.lightCardSurface,
    surfaceAlt: AppColors.lightInputBox,
    surfaceElevated: const Color(0xFFF1F5F9),
    primary: AppColors.neonPurple,
    primaryLight: AppColors.neonPink,
    cardBorder: AppColors.lightBorder,
    borderHighlight: const Color(0xFFCBD5E1),
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: const Color(0xFF94A3B8),
  );

  /// Deep Plum Canvas & Neon Glow Dark theme (Default).
  static final ThemeData darkTheme = _buildTheme(
    isDark: true,
    background: AppColors.darkBackground,
    surface: AppColors.darkCardSurface,
    surfaceAlt: AppColors.darkInputBox,
    surfaceElevated: AppColors.surfaceElevated,
    primary: AppColors.neonPurple,
    primaryLight: AppColors.neonPink,
    cardBorder: AppColors.darkBorder,
    borderHighlight: AppColors.borderHighlight,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextSecondary,
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
    final baseTextTheme =
        (isDark ? ThemeData.dark() : ThemeData.light()).textTheme;
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
              error: AppColors.alertRed,
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
              error: AppColors.alertRed,
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
          side: BorderSide(color: cardBorder, width: 1.2),
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
        indicatorColor:
            isDark ? const Color(0xFF4B1528) : const Color(0xFFFCE7F3),
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF6B8A),
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: Color(0xFFFF6B8A),
              size: 23,
            );
          }
          return IconThemeData(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            size: 22,
          );
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
