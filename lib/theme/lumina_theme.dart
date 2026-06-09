import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lumina_colors.dart';

abstract final class LuminaTheme {
  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      surface: LuminaColors.surface,
      onSurface: LuminaColors.onSurface,
      onSurfaceVariant: LuminaColors.onSurfaceVariant,
      primary: LuminaColors.primary,
      onPrimary: LuminaColors.onPrimary,
      primaryContainer: LuminaColors.primaryContainer,
      onPrimaryContainer: LuminaColors.onPrimaryContainer,
      secondary: LuminaColors.secondary,
      onSecondary: LuminaColors.onSecondary,
      secondaryContainer: LuminaColors.secondaryContainer,
      onSecondaryContainer: LuminaColors.onSecondaryContainer,
      tertiary: LuminaColors.tertiary,
      tertiaryContainer: LuminaColors.tertiaryContainer,
      error: LuminaColors.error,
      onError: LuminaColors.onError,
      outline: LuminaColors.outline,
      outlineVariant: LuminaColors.outlineVariant,
      surfaceContainerLowest: LuminaColors.surfaceContainerLowest,
      surfaceContainerLow: LuminaColors.surfaceContainerLow,
      surfaceContainer: LuminaColors.surfaceContainer,
      surfaceContainerHigh: LuminaColors.surfaceContainerHigh,
      surfaceContainerHighest: LuminaColors.surfaceContainerHighest,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LuminaColors.background,
      dividerColor: LuminaColors.outlineVariant.withValues(alpha: 0.3),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LuminaColors.surfaceContainerHigh,
        contentTextStyle: GoogleFonts.inter(color: LuminaColors.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: LuminaColors.primary,
        inactiveTrackColor: LuminaColors.surfaceContainerHighest,
        thumbColor: LuminaColors.primary,
        overlayColor: LuminaColors.primary.withValues(alpha: 0.12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return LuminaColors.onPrimary;
          }
          return LuminaColors.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return LuminaColors.primary;
          }
          return LuminaColors.surfaceContainerHighest;
        }),
      ),
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: LuminaColors.surface.withValues(alpha: 0.8),
        foregroundColor: LuminaColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: LuminaColors.primary,
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return TextTheme(
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        letterSpacing: -0.48,
        color: LuminaColors.onSurface,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        letterSpacing: -0.2,
        color: LuminaColors.onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: LuminaColors.onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: LuminaColors.onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.6,
        color: LuminaColors.onSurfaceVariant,
      ),
      bodySmall: GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 20 / 13,
        color: LuminaColors.primary,
      ),
    );
  }
}
