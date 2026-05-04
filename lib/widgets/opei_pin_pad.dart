import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opei/theme.dart';

/// 6-digit PIN dot indicator. Filled dots scale in with a spring, and the
/// row shakes horizontally when [errored] flips to true.
class OpeiPinDots extends StatefulWidget {
  final int filled;
  final int total;
  final bool errored;
  final double dotSize;
  final double spacing;

  const OpeiPinDots({
    super.key,
    required this.filled,
    this.total = 6,
    this.errored = false,
    this.dotSize = 14,
    this.spacing = 18,
  });

  @override
  State<OpeiPinDots> createState() => _OpeiPinDotsState();
}

class _OpeiPinDotsState extends State<OpeiPinDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 440),
  );

  @override
  void didUpdateWidget(covariant OpeiPinDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errored && !oldWidget.errored) {
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final t = _shake.value;
        // Damped sine wave: fast oscillation that decays as t → 1.
        final dx = t == 0 ? 0.0 : (1 - t) * 9 * math.sin(t * math.pi * 6);
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.total, (i) {
          final isFilled = i < widget.filled;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              scale: isFilled ? 1.0 : 0.86,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: widget.dotSize,
                height: widget.dotSize,
                decoration: BoxDecoration(
                  color: isFilled ? OpeiBrand.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFilled
                        ? OpeiBrand.primary
                        : OpeiBrand.hairlineStrong,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Sleek 3x4 numeric keypad (1-9, blank, 0, delete) with brand styling.
class OpeiPinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  /// Optional widget for the bottom-left slot (e.g. a biometric icon).
  final Widget? leadingAction;

  final bool enabled;

  const OpeiPinKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.leadingAction,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = _resolveButtonSize(context);
    final spacing = buttonSize * 0.18;
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: buttonSize * 3 + spacing * 2 + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['leading', '0', 'del'],
          ])
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < row.length; i++) ...[
                    if (i > 0) SizedBox(width: spacing),
                    _buildKey(context, row[i], buttonSize),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  double _resolveButtonSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 420) return 78;
    if (width >= 380) return 72;
    if (width >= 340) return 66;
    return 60;
  }

  Widget _buildKey(BuildContext context, String key, double size) {
    if (key == 'leading') {
      return SizedBox(
        width: size,
        height: size,
        child: leadingAction ?? const SizedBox.shrink(),
      );
    }

    final isDelete = key == 'del';
    return _KeyTile(
      size: size,
      enabled: enabled,
      transparentBg: isDelete,
      onTap: () {
        if (!enabled) return;
        HapticFeedback.selectionClick();
        if (isDelete) {
          onDelete();
        } else {
          onDigit(key);
        }
      },
      child: isDelete
          ? const Icon(
              Icons.backspace_outlined,
              size: 22,
              color: OpeiBrand.ink,
            )
          : Text(
              key,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.ink,
                letterSpacing: -0.4,
                height: 1.0,
              ),
            ),
    );
  }
}

class _KeyTile extends StatefulWidget {
  final double size;
  final VoidCallback onTap;
  final Widget child;
  final bool enabled;
  final bool transparentBg;
  const _KeyTile({
    required this.size,
    required this.onTap,
    required this.child,
    required this.enabled,
    required this.transparentBg,
  });

  @override
  State<_KeyTile> createState() => _KeyTileState();
}

class _KeyTileState extends State<_KeyTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:
          widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel:
          widget.enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.transparentBg
                ? (_pressed
                    ? OpeiBrand.hairline
                    : Colors.transparent)
                : (_pressed
                    ? OpeiBrand.hairline
                    : OpeiBrand.surfaceMuted),
            shape: BoxShape.circle,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
