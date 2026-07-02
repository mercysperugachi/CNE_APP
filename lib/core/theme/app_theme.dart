import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors based on the Tailwind config
  static const Color primaryContainer = Color(0xFFFFDD00);
  static const Color onPrimaryContainer = Color(0xFF716100);
  
  static const Color primaryFixed = Color(0xFFFFE251);
  static const Color secondary = Color(0xFF3456C1);
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFF718FFD);
  static const Color onSecondaryContainer = Color(0xFF00257B);
  
  static const Color tertiary = Color(0xFFC00014);
  static const Color onTertiary = Colors.white;

  // Surface Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  
  // Text & Outline Colors
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF4C4732);
  static const Color outline = Color(0xFF7E775F);
  static const Color outlineVariant = Color(0xCFC6AB); // Con transparencia o solido
  static const Color outlineVariantSolid = Color(0xFFCFC6AB);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Colors.white;

  // Backward compatibility aliases
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textMuted = outline;
  static const Color primary = secondary;
  static const Color danger = error;
  static const Color success = Color(0xFF198754);
  static const Color warning = primaryContainer;
  static const Color info = secondary;
  static const Color border = outlineVariantSolid;
  static const Color surfaceMuted = surfaceContainerLow;
  static const Color ecYellow = primaryContainer;
  static const Color ecBlue = secondary;
  static const Color ecRed = tertiary;

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: secondary, // Usamos secondary azul como primary de la app para botones y focus
        onPrimary: Colors.white,
        secondary: primaryContainer, // El amarillo como secundario
        onSecondary: onPrimaryContainer,
        error: error,
        onError: onError,
        surface: surface,
        onSurface: onSurface,
        outline: outlineVariantSolid,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 30, height: 38/30, letterSpacing: -0.02, fontWeight: FontWeight.w700, color: onSurface
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 24, height: 32/24, letterSpacing: -0.01, fontWeight: FontWeight.w600, color: onSurface
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 20, height: 28/20, fontWeight: FontWeight.w600, color: onSurface
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16, height: 24/16, fontWeight: FontWeight.w400, color: onSurfaceVariant
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14, height: 20/14, fontWeight: FontWeight.w400, color: onSurfaceVariant
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 12, height: 16/12, fontWeight: FontWeight.w600, color: onSurface
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 11, height: 14/11, fontWeight: FontWeight.w500, color: onSurfaceVariant
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: secondary, size: 24),
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: outlineVariantSolid, width: 1)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // rounded-xl is roughly 12px
          side: const BorderSide(color: outlineVariantSolid, width: 1),
        ),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: onSurface,
          elevation: 0,
          shadowColor: const Color(0x26716100), // shadow for buttons
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999), // full for primary button usually
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outlineVariantSolid, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outlineVariantSolid, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: onSurface, fontSize: 12, fontWeight: FontWeight.w600),
        floatingLabelStyle: const TextStyle(color: secondary, fontSize: 12, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: onSurfaceVariant, fontSize: 14),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceContainerLowest,
        elevation: 0,
        selectedItemColor: primaryContainer,
        unselectedItemColor: onSurfaceVariant,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: outlineVariantSolid,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryContainer,
        linearTrackColor: surfaceContainerHigh,
      ),
      iconTheme: const IconThemeData(color: onSurfaceVariant, size: 24),
    );
  }

  static BoxDecoration cardDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: outlineVariantSolid, width: 1),
    );
  }

  static BoxDecoration statusBadge({Color? color, Color? bgColor}) {
    return BoxDecoration(
      color: bgColor ?? (color != null ? color.withValues(alpha:0.1) : Colors.transparent),
      borderRadius: BorderRadius.circular(4),
    );
  }

  // Backward compatibility method
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
    );
  }
}