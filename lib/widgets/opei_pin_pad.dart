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
    // Slightly bigger gutter than before so keys feel breathable while
    // still letting the row span more of the screen width.
    final spacing = buttonSize * 0.20;
    final totalWidth = buttonSize * 3 + spacing * 2;
    // FittedBox scaleDown keeps the keypad at its designed size when
    // there's room, and gently shrinks it when a tight parent
    // constraint (e.g. inside an `IntrinsicHeight` test surface) would
    // otherwise cause an overflow. We never scale up.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: SizedBox(
        width: totalWidth,
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
      ),
    );
  }

  /// Per-key size, sized so the full row spans most of the available
  /// width on common phones (the parent screen leaves ~24-32px of
  /// horizontal padding). The previous brackets were ~10-15% smaller,
  /// which left obvious dead space on the left/right.
  double _resolveButtonSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) return 96;
    if (width >= 420) return 90;
    if (width >= 380) return 84;
    if (width >= 340) return 76;
    return 68;
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
              size: 24,
              color: OpeiBrand.ink,
            )
          : Text(
              key,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w400,
                color: OpeiBrand.ink,
                letterSpacing: -0.3,
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
  const _KeyTile({
    required this.size,
    required this.onTap,
    required this.child,
    required this.enabled,
  });

  @override
  State<_KeyTile> createState() => _KeyTileState();
}

class _KeyTileState extends State<_KeyTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 60),
    reverseDuration: const Duration(milliseconds: 160),
  );

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _flash.forward();
  void _onTapUp(TapUpDetails _) {
    _flash.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _flash.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? _onTapDown : null,
      onTapUp: widget.enabled ? _onTapUp : null,
      onTapCancel: widget.enabled ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _flash,
        builder: (context, child) => Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            // Borderless: barely-visible press flash — just enough to
            // register the tap without looking like a heavy button.
            color: Color.lerp(
              Colors.transparent,
              const Color(0x18000000),
              _flash.value,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(child: child),
        ),
        child: widget.child,
      ),
    );
  }
}
