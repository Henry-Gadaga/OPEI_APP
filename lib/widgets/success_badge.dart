import 'package:flutter/material.dart';
import 'package:tt1/theme.dart';

class SuccessBadge extends StatelessWidget {
  final Color accentColor;
  final double size;
  final double innerSize;

  const SuccessBadge({
    super.key,
    required this.accentColor,
    this.size = 110,
    this.innerSize = 68,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.92),
            accentColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.22),
            blurRadius: 32,
            offset: const Offset(0, 20),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: const BoxDecoration(
            color: OpeiColors.pureWhite,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: innerSize * 0.59,
            color: accentColor,
          ),
        ),
      ),
    );
  }
}