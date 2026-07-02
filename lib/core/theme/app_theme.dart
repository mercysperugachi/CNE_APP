import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryContainer = Color(0xFFFFDD00);
  static const Color onPrimaryContainer = Color(0xFF716100);
  static const Color primaryFixed = Color(0xFFFFE251);
  static const Color secondary = Color(0xFF3456C1);
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFF718FFD);
  static const Color onSecondaryContainer = Color(0xFF00257B);
  static const Color tertiary = Color(0xFFC00014);
  static const Color onTertiary = Colors.white;
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF4C4732);
  static const Color outline = Color(0xFF7E775F);
  static const Color outlineVariantSolid = Color(0xFFCFC6AB);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Colors.white;

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

  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceGray = Color(0xFFF5F5F7);

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [Color(0xFFFFDD00), Color(0xFFFFC107)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static LinearGradient get blueGradient => const LinearGradient(
        colors: [Color(0xFF3456C1), Color(0xFF1A3A9E)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static LinearGradient get headerGradient => const LinearGradient(
        colors: [Color(0xFFFFDD00), Color(0xFFFFC107)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get loginGradient => const LinearGradient(
        colors: [Color(0xFFFFDD00), Color(0xFFFFF3C4)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      colorScheme: const ColorScheme.light(
        primary: secondary,
        onPrimary: Colors.white,
        secondary: primaryContainer,
        onSecondary: onPrimaryContainer,
        error: error,
        onError: onError,
        surface: surface,
        onSurface: onSurface,
        outline: outlineVariantSolid,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 30,
          height: 38 / 30,
          letterSpacing: -0.02,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 24,
          height: 32 / 24,
          letterSpacing: -0.01,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 20,
          height: 28 / 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 11,
          height: 14 / 11,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: onSurface,
          elevation: 0,
          shadowColor: const Color(0x26716100),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
        fillColor: const Color(0xFFF5F5F7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(color: onSurface, fontSize: 12, fontWeight: FontWeight.w600),
        floatingLabelStyle: const TextStyle(color: secondary, fontSize: 12, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: onSurfaceVariant, fontSize: 14),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        selectedItemColor: secondary,
        unselectedItemColor: onSurfaceVariant,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8E8EC),
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: secondary,
        linearTrackColor: Color(0xFFE8E8EC),
      ),
      iconTheme: const IconThemeData(color: onSurfaceVariant, size: 24),
    );
  }

  static BoxDecoration modernCard({Color? color}) {
    return BoxDecoration(
      color: color ?? cardBg,
      borderRadius: BorderRadius.circular(16),
      boxShadow: cardShadow,
    );
  }

  static BoxDecoration gradientButton({List<Color>? colors}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors ?? [const Color(0xFFFFDD00), const Color(0xFFFFC107)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFFDD00).withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration statCard({Color? accentColor}) {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      boxShadow: cardShadow,
    );
  }

  static BoxDecoration statusChip({required Color color}) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    );
  }

  static BoxDecoration inputDecoration() {
    return BoxDecoration(
      color: const Color(0xFFF5F5F7),
      borderRadius: BorderRadius.circular(12),
    );
  }

  static InputDecoration modernInput({
    String? label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
      suffixIcon: suffix,
    );
  }
}

class ModernCurve extends StatelessWidget {
  final Color color;
  final double height;
  const ModernCurve({super.key, this.color = const Color(0xFFFFDD00), this.height = 180});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.5, size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 60,
      size.width, size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldDelegate) => false;
}
