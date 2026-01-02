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

  static const errorRed = Color(0xFFDC2626);
  static const successGreen = Color(0xFF16A34A);
  static const success = successGreen;
  static const warningYellow = Color(0xFFF59E0B);

  // iOS-like neutrals for subtle, compact UI
  static const iosLabelSecondary = Color(0xFF8E8E93); // secondary label
  static const iosLabelTertiary = Color(0xFFC7C7CC); // tertiary label
  static const iosSeparator = Color(0xFFE5E5EA); // separator line
  static const iosSurfaceMuted = Color(0xFFF5F5F7); // subtle surface
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: OpeiColors.pureBlack,
        onPrimary: OpeiColors.pureWhite,
        secondary: OpeiColors.grey700,
        onSecondary: OpeiColors.pureWhite,
        surface: OpeiColors.pureWhite,
        onSurface: OpeiColors.pureBlack,
        error: OpeiColors.errorRed,
        onError: OpeiColors.pureWhite,
        outline: OpeiColors.grey300,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: OpeiColors.pureWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: OpeiColors.pureWhite,
        foregroundColor: OpeiColors.pureBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: OpeiColors.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: OpeiColors.grey200, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OpeiColors.pureBlack,
          foregroundColor: OpeiColors.pureWhite,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _primaryTextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1.2, // prevent descender clipping
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OpeiColors.pureBlack,
          side: const BorderSide(color: OpeiColors.grey300, width: 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _primaryTextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1.2, // prevent descender clipping
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OpeiColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: OpeiColors.pureBlack, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: OpeiColors.errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: OpeiColors.errorRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: _primaryTextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.4,
          color: OpeiColors.grey500,
        ),
        labelStyle: _primaryTextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.4,
          color: OpeiColors.grey700,
        ),
        errorStyle: _primaryTextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: OpeiColors.errorRed,
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

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: OpeiColors.pureWhite,
        onPrimary: OpeiColors.pureBlack,
        secondary: OpeiColors.grey400,
        onSecondary: OpeiColors.pureBlack,
        surface: OpeiColors.pureBlack,
        onSurface: OpeiColors.pureWhite,
        error: OpeiColors.errorRed,
        onError: OpeiColors.pureWhite,
        outline: OpeiColors.grey800,
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: OpeiColors.pureBlack,
      appBarTheme: const AppBarTheme(
        backgroundColor: OpeiColors.pureBlack,
        foregroundColor: OpeiColors.pureWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: OpeiColors.grey900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: OpeiColors.grey800, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OpeiColors.pureWhite,
          foregroundColor: OpeiColors.pureBlack,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _primaryTextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1.2, // prevent descender clipping
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OpeiColors.pureWhite,
          side: const BorderSide(color: OpeiColors.grey700, width: 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _primaryTextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1.2, // prevent descender clipping
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OpeiColors.grey900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: OpeiColors.pureWhite, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: OpeiColors.errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: OpeiColors.errorRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: _primaryTextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.4,
          color: OpeiColors.grey600,
        ),
        labelStyle: _primaryTextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.4,
          color: OpeiColors.grey400,
        ),
        errorStyle: _primaryTextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: OpeiColors.errorRed,
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
