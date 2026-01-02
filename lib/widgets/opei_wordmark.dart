import 'package:flutter/material.dart';
import 'package:tt1/theme.dart';

class OpeiWordmark extends StatelessWidget {
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final double letterSpacing;
  final double? circleStrokeWidth;

  const OpeiWordmark({
    super.key,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w600,
    this.color = OpeiColors.pureBlack,
    this.letterSpacing = -0.3,
    this.circleStrokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.titleLarge ??
        TextStyle(
          fontFamily: kPrimaryFontFamily,
          fontSize: fontSize,
        );

    final textStyle = baseStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );

    final circleDiameter = fontSize * 0.92;
    final strokeWidth =
        circleStrokeWidth ?? (fontSize * 0.14).clamp(1.6, 3.6);
    final baselineOffset = fontSize * 0.04;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: baselineOffset),
          child: Container(
            width: circleDiameter,
            height: circleDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: strokeWidth),
            ),
          ),
        ),
        SizedBox(width: fontSize * 0.08),
        Text(
          'pei',
          style: textStyle,
        ),
      ],
    );
  }
}
