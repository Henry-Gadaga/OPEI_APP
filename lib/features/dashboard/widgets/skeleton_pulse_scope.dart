import 'package:flutter/material.dart';
import 'package:tt1/theme.dart';

class SkeletonPulseScope extends InheritedWidget {
  final double value;

  const SkeletonPulseScope({
    super.key,
    required this.value,
    required super.child,
  });

  static double of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SkeletonPulseScope>()?.value ?? 0;
  }

  @override
  bool updateShouldNotify(covariant SkeletonPulseScope oldWidget) => value != oldWidget.value;
}

Color skeletonSurfaceColor(BuildContext context, {double intensity = 1}) {
  final pulse = SkeletonPulseScope.of(context);
  final base = OpeiColors.iosSurfaceMuted;
  final highlight = OpeiColors.pureWhite.withOpacity(0.35);
  final factor = (pulse * 0.7 * intensity).clamp(0.0, 1.0);
  return Color.lerp(base, highlight, factor) ?? base;
}

class SkeletonPulseProvider extends StatefulWidget {
  final Widget child;

  const SkeletonPulseProvider({super.key, required this.child});

  @override
  State<SkeletonPulseProvider> createState() => _SkeletonPulseProviderState();
}

class _SkeletonPulseProviderState extends State<SkeletonPulseProvider> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => SkeletonPulseScope(
        value: _animation.value,
        child: child!,
      ),
      child: widget.child,
    );
  }
}

