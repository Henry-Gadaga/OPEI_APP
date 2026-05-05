import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:opei/theme.dart';

/// Apple-grade activity indicator: a slim ring with a single rotating
/// arc. Restrained, monochromatic, no bounce — designed to feel at home
/// in a banking-grade quick-auth flow.
///
/// Usage:
///   const OpeiActivityIndicator()                       // 56px brand primary
///   OpeiActivityIndicator(size: 64, color: Colors.white)
class OpeiActivityIndicator extends StatefulWidget {
  /// Outer diameter of the indicator. The arc inset half a stroke so
  /// the rendered circle exactly fits this size.
  final double size;
  final double strokeWidth;
  final Color color;
  final Color? trackColor;
  final Duration period;

  const OpeiActivityIndicator({
    super.key,
    this.size = 56,
    this.strokeWidth = 2.8,
    this.color = OpeiBrand.primary,
    this.trackColor,
    this.period = const Duration(milliseconds: 1100),
  });

  @override
  State<OpeiActivityIndicator> createState() =>
      _OpeiActivityIndicatorState();
}

class _OpeiActivityIndicatorState extends State<OpeiActivityIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.trackColor ??
        widget.color.withValues(alpha: 0.10);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _OpeiActivityPainter(
              progress: _controller.value,
              strokeWidth: widget.strokeWidth,
              foreground: widget.color,
              background: track,
            ),
          );
        },
      ),
    );
  }
}

class _OpeiActivityPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color foreground;
  final Color background;

  _OpeiActivityPainter({
    required this.progress,
    required this.strokeWidth,
    required this.foreground,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Faint full ring (background track).
    final trackPaint = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    // Foreground arc — ~75 degrees, rotating once per period.
    final foregroundPaint = Paint()
      ..color = foreground
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const sweep = math.pi * 0.42; // ≈ 75°
    final start = -math.pi / 2 + progress * math.pi * 2;
    canvas.drawArc(rect, start, sweep, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant _OpeiActivityPainter old) =>
      old.progress != progress ||
      old.strokeWidth != strokeWidth ||
      old.foreground != foreground ||
      old.background != background;
}
