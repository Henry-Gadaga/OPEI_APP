import 'package:flutter/material.dart';

import 'responsive_breakpoints.dart';

class ResponsiveTokenSet {
  final double baseFontSize;
  final double headingScale;
  final double horizontalPadding;
  final double verticalSpacingUnit;
  final double contentMaxWidth;
  final double sheetMaxWidth;
  final double buttonHeight;

  const ResponsiveTokenSet({
    required this.baseFontSize,
    required this.headingScale,
    required this.horizontalPadding,
    required this.verticalSpacingUnit,
    required this.contentMaxWidth,
    required this.sheetMaxWidth,
    required this.buttonHeight,
  });
}

class OpeiResponsiveTheme extends ThemeExtension<OpeiResponsiveTheme> {
  final Map<ResponsiveSize, ResponsiveTokenSet> tokens;

  const OpeiResponsiveTheme({required this.tokens});

  ResponsiveTokenSet forSize(ResponsiveSize size) =>
      tokens[size] ?? tokens[ResponsiveSize.phone]!;

  @override
  OpeiResponsiveTheme copyWith({
    Map<ResponsiveSize, ResponsiveTokenSet>? tokens,
  }) =>
      OpeiResponsiveTheme(
        tokens: tokens ?? this.tokens,
      );

  @override
  ThemeExtension<OpeiResponsiveTheme> lerp(
    ThemeExtension<OpeiResponsiveTheme>? other,
    double t,
  ) {
    if (other is! OpeiResponsiveTheme) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}

const OpeiResponsiveTheme kDefaultResponsiveTheme = OpeiResponsiveTheme(
  tokens: {
    ResponsiveSize.compact: ResponsiveTokenSet(
      baseFontSize: 13,
      headingScale: 1.15,
      horizontalPadding: 14,
      verticalSpacingUnit: 6,
      contentMaxWidth: double.infinity,
      sheetMaxWidth: double.infinity,
      buttonHeight: 48,
    ),
    ResponsiveSize.phone: ResponsiveTokenSet(
      baseFontSize: 14,
      headingScale: 1.2,
      horizontalPadding: 20,
      verticalSpacingUnit: 8,
      contentMaxWidth: double.infinity,
      sheetMaxWidth: double.infinity,
      buttonHeight: 50,
    ),
    ResponsiveSize.largePhone: ResponsiveTokenSet(
      baseFontSize: 15,
      headingScale: 1.3,
      horizontalPadding: 24,
      verticalSpacingUnit: 10,
      contentMaxWidth: 560,
      sheetMaxWidth: 600,
      buttonHeight: 52,
    ),
    ResponsiveSize.tabletDesktop: ResponsiveTokenSet(
      baseFontSize: 16,
      headingScale: 1.4,
      horizontalPadding: 32,
      verticalSpacingUnit: 12,
      contentMaxWidth: 720,
      sheetMaxWidth: 720,
      buttonHeight: 54,
    ),
  },
);

extension ResponsiveContext on BuildContext {
  ResponsiveSize get responsiveSize => ResponsiveBreakpoints.of(this);

  OpeiResponsiveTheme get _responsiveTheme =>
      Theme.of(this).extension<OpeiResponsiveTheme>() ??
      kDefaultResponsiveTheme;

  ResponsiveTokenSet get responsiveTokens =>
      _responsiveTheme.forSize(responsiveSize);

  EdgeInsets get responsiveScreenPadding =>
      EdgeInsets.symmetric(horizontal: responsiveTokens.horizontalPadding);

  double get responsiveSpacingUnit => responsiveTokens.verticalSpacingUnit;
}
