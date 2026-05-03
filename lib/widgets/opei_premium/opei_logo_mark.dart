import 'package:flutter/material.dart';

import 'package:opei/theme.dart';

/// Stylized rendering of the Opei logo mark (the rounded squircle with a
/// diagonal split). Drawn programmatically so it scales crisp at any size
/// and matches the brand color exactly.
class OpeiLogoMark extends StatelessWidget {
  final double size;
  final Color color;

  const OpeiLogoMark({
    super.key,
    this.size = 56,
    this.color = OpeiBrand.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _OpeiMarkPainter(color: color)),
    );
  }
}

class _OpeiMarkPainter extends CustomPainter {
  final Color color;

  _OpeiMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final cornerRadius = size.shortestSide * 0.34;
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cornerRadius),
    );

    final fill = Paint()
      ..isAntiAlias = true
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRRect(rrect, fill);

    // Diagonal cut — paint white stripe across the center of the squircle.
    final stripe = Paint()
      ..isAntiAlias = true
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final stripeWidth = h * 0.18;
    final path = Path()
      ..moveTo(0, h * 0.50 - stripeWidth)
      ..lineTo(w, h * 0.50 - stripeWidth + h * 0.10)
      ..lineTo(w, h * 0.50 + stripeWidth + h * 0.10)
      ..lineTo(0, h * 0.50 + stripeWidth)
      ..close();
    canvas.drawPath(path, stripe);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OpeiMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Mark + "Opei" wordmark side by side, white-on-blue brand lockup.
class OpeiLockup extends StatelessWidget {
  final double height;
  final Color color;

  const OpeiLockup({
    super.key,
    this.height = 48,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OpeiLogoMark(size: height, color: color),
        SizedBox(width: height * 0.22),
        Text(
          'Opei',
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: height * 0.85,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
      ],
    );
  }
}
