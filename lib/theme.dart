import 'package:flutter/material.dart';

import 'core/navigation/opei_page_transitions.dart';
import 'responsive/responsive_tokens.dart';

const String kPrimaryFontFamily = 'Outfit';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

/// Legacy palette kept for backwards compatibility.
///
/// Values are now aliased to the [OpeiBrand] tokens so every screen that still
/// references `OpeiColors.iosLabelSecondary`, `OpeiColors.errorRed`, etc.
/// automatically inherits the unified signup theme. Greys and the
/// pureWhite / pureBlack constants are kept untouched for explicit usage.
class OpeiColors {
  static const pureWhite = Color(0xFFFFFFFF);
  static const pureBlack = Color(0xFF000000);

  static const grey50 = Color(0xFFFAFAFA);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey600 = Color(0xFF757575);
  static const grey700 = Color(0xFF616161);
  static const grey800 = Color(0xFF424242);
  static const grey900 = Color(0xFF212121);

  // Semantic — aligned with OpeiBrand tokens
  static const errorRed = Color(0xFFE0394A); // = OpeiBrand.danger
  static const successGreen = Color(0xFF16A34A); // = OpeiBrand.success
  static const success = successGreen;
  static const warningYellow = Color(0xFFF59E0B); // = OpeiBrand.warning

  // Compact UI neutrals — aligned with OpeiBrand neutrals
  static const iosLabelSecondary = Color(0xFF5B6477); // = inkSecondary
  static const iosLabelTertiary = Color(0xFF8A93A6); // = inkTertiary
  static const iosSeparator = Color(0xFFEBEEF4); // = hairline
  static const iosSurfaceMuted = Color(0xFFF5F7FB); // = surfaceMuted
}

/// Opei premium brand tokens. Use these for new/redesigned screens.
/// Existing screens continue to use [OpeiColors] until migrated.
class OpeiBrand {
  // Brand — sampled from official Opei logo
  static const primary = Color(0xFF3D7BFF);
  static const primaryPressed = Color(0xFF2860E0);
  static const primaryHover = Color(0xFF5C92FF);
  static const primaryTint = Color(0xFFEFF4FF);
  static const primaryTintStrong = Color(0xFFDDE8FF);
  static const primaryGradientStart = Color(0xFF3D7BFF);
  static const primaryGradientEnd = Color(0xFF6E9DFF);

  // Neutrals — banking minimal scale
  static const ink = Color(0xFF0B1220);
  static const inkSecondary = Color(0xFF5B6477);
  static const inkTertiary = Color(0xFF8A93A6);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF5F7FB);
  static const surfaceElevated = Color(0xFFFAFBFD);
  // Hairlines tuned to be just visible against pure white surfaces — fields
  // should feel CLEAR inside, not grey.
  static const hairline = Color(0xFFEBEEF4);
  static const hairlineStrong = Color(0xFFD4D9E3);
  // Lighter placeholder colour so empty fields don't look "grey filled".
  static const inkPlaceholder = Color(0xFFB7BDC9);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFE0394A);

  // Geometry
  static const radiusField = 14.0;
  static const radiusCta = 14.0;
  static const radiusCard = 16.0;
  static const radiusSheet = 24.0;
  static const heightCta = 56.0;
  static const heightField = 56.0;

  // Motion
  static const motionFast = Duration(milliseconds: 160);
  static const motion = Duration(milliseconds: 240);
  static const motionSlow = Duration(milliseconds: 360);
  static const motionCurve = Curves.easeOutCubic;

  // Gradients
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGradientStart, primaryGradientEnd],
  );
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: OpeiBrand.primary,
        onPrimary: OpeiBrand.surface,
        secondary: OpeiBrand.primary,
        onSecondary: OpeiBrand.surface,
        surface: OpeiBrand.surface,
        onSurface: OpeiBrand.ink,
        surfaceContainerHighest: OpeiBrand.surfaceMuted,
        error: OpeiBrand.danger,
        onError: OpeiBrand.surface,
        outline: OpeiBrand.hairline,
        outlineVariant: OpeiBrand.hairline,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: OpeiBrand.surface,
      canvasColor: OpeiBrand.surface,
      dividerColor: OpeiBrand.hairline,
      splashColor: OpeiBrand.primary.withValues(alpha: 0.06),
      highlightColor: OpeiBrand.primary.withValues(alpha: 0.04),
      appBarTheme: const AppBarTheme(
        backgroundColor: OpeiBrand.surface,
        foregroundColor: OpeiBrand.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: kPrimaryFontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: OpeiBrand.ink,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: OpeiBrand.ink, size: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: OpeiBrand.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
          side: const BorderSide(color: OpeiBrand.hairline, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OpeiBrand.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: OpeiBrand.primaryTintStrong,
          disabledForegroundColor:
              OpeiBrand.primary.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCta),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: _primaryTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OpeiBrand.primary,
          side: const BorderSide(color: OpeiBrand.hairline, width: 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCta),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: _primaryTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OpeiBrand.primary,
          textStyle: _primaryTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: OpeiBrand.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OpeiBrand.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          borderSide: const BorderSide(color: OpeiBrand.hairline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          borderSide: const BorderSide(color: OpeiBrand.hairline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          borderSide: const BorderSide(color: OpeiBrand.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          borderSide: const BorderSide(color: OpeiBrand.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          borderSide: const BorderSide(color: OpeiBrand.danger, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          borderSide: const BorderSide(color: OpeiBrand.hairline, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: _primaryTextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
          color: OpeiBrand.inkPlaceholder,
        ),
        labelStyle: _primaryTextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: OpeiBrand.inkSecondary,
        ),
        floatingLabelStyle: _primaryTextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: OpeiBrand.primary,
        ),
        errorStyle: _primaryTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
          color: OpeiBrand.danger,
        ),
        prefixIconColor: OpeiBrand.inkSecondary,
        suffixIconColor: OpeiBrand.inkSecondary,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: OpeiBrand.primary,
      ),
      dividerTheme: const DividerThemeData(
        color: OpeiBrand.hairline,
        thickness: 0.6,
        space: 0.6,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: OpeiBrand.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: OpeiBrand.surface,
        modalBarrierColor: Color(0x73000000),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: OpeiBrand.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: _primaryTextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: OpeiBrand.ink,
          letterSpacing: -0.3,
        ),
        contentTextStyle: _primaryTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: OpeiBrand.inkSecondary,
          letterSpacing: -0.2,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: OpeiBrand.ink,
        contentTextStyle: _primaryTextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: OpeiBrand.surfaceMuted,
        selectedColor: OpeiBrand.primaryTint,
        secondarySelectedColor: OpeiBrand.primaryTint,
        side: const BorderSide(color: OpeiBrand.hairline, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: OpeiBrand.hairline, width: 1),
        ),
        labelStyle: _primaryTextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: OpeiBrand.ink,
          letterSpacing: -0.1,
        ),
        secondaryLabelStyle: _primaryTextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: OpeiBrand.primary,
          letterSpacing: -0.1,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: OpeiBrand.primary,
        unselectedLabelColor: OpeiBrand.inkSecondary,
        indicatorColor: OpeiBrand.primary,
        dividerColor: OpeiBrand.hairline,
        labelStyle: _primaryTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: _primaryTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return OpeiBrand.primary;
          return OpeiBrand.hairlineStrong;
        }),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
      ),
      textTheme: _buildTextTheme(),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: OpeiPageTransitionsBuilder(),
          TargetPlatform.iOS: OpeiPageTransitionsBuilder(),
          TargetPlatform.macOS: OpeiPageTransitionsBuilder(),
          TargetPlatform.windows: OpeiPageTransitionsBuilder(),
          TargetPlatform.linux: OpeiPageTransitionsBuilder(),
        },
      ),
      extensions: const <ThemeExtension<dynamic>>[
        kDefaultResponsiveTheme,
      ],
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: OpeiBrand.primary,
        onPrimary: Colors.white,
        secondary: OpeiBrand.primaryGradientEnd,
        onSecondary: OpeiBrand.ink,
        surface: OpeiBrand.ink,
        onSurface: Colors.white,
        error: OpeiBrand.danger,
        onError: Colors.white,
        outline: Color(0xFF26303F),
        outlineVariant: Color(0xFF1A2332),
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: OpeiBrand.ink,
      canvasColor: OpeiBrand.ink,
      dividerColor: const Color(0xFF26303F),
      appBarTheme: const AppBarTheme(
        backgroundColor: OpeiBrand.ink,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF111A2C),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
          side: const BorderSide(color: Color(0xFF26303F), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OpeiBrand.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCta),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: _primaryTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF26303F), width: 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCta),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: _primaryTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111A2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          borderSide: const BorderSide(color: Color(0xFF26303F), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          borderSide: const BorderSide(color: Color(0xFF26303F), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          borderSide: const BorderSide(color: OpeiBrand.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          borderSide: const BorderSide(color: OpeiBrand.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          borderSide: const BorderSide(color: OpeiBrand.danger, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: _primaryTextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
          color: const Color(0xFF6B7385),
        ),
        labelStyle: _primaryTextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: const Color(0xFF9AA3B5),
        ),
        errorStyle: _primaryTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: OpeiBrand.danger,
        ),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: OpeiBrand.primary),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: OpeiBrand.ink,
        modalBackgroundColor: OpeiBrand.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      textTheme: _buildTextTheme(),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: OpeiPageTransitionsBuilder(),
          TargetPlatform.iOS: OpeiPageTransitionsBuilder(),
          TargetPlatform.macOS: OpeiPageTransitionsBuilder(),
          TargetPlatform.windows: OpeiPageTransitionsBuilder(),
          TargetPlatform.linux: OpeiPageTransitionsBuilder(),
        },
      ),
      extensions: const <ThemeExtension<dynamic>>[
        kDefaultResponsiveTheme,
      ],
    );

TextTheme _buildTextTheme() => TextTheme(
      displayLarge: _primaryTextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      displayMedium: _primaryTextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      displaySmall: _primaryTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineLarge: _primaryTextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
      ),
      headlineMedium: _primaryTextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      headlineSmall: _primaryTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: _primaryTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleMedium: _primaryTextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      titleSmall: _primaryTextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      bodyLarge: _primaryTextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.4,
      ),
      bodyMedium: _primaryTextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.3,
      ),
      bodySmall: _primaryTextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
      ),
      labelLarge: _primaryTextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      labelMedium: _primaryTextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
      labelSmall: _primaryTextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    );

TextStyle _primaryTextStyle({
  required double fontSize,
  required FontWeight fontWeight,
  double letterSpacing = 0,
  double? height,
  Color? color,
}) {
  return TextStyle(
    fontFamily: kPrimaryFontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
  );
}
