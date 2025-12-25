import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tt1/theme.dart';

class ReferenceCopyValue extends StatefulWidget {
  final String label;
  final String reference;
  final bool labelOnTop;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry pillPadding;
  final double pillRadius;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const ReferenceCopyValue({
    super.key,
    required this.label,
    required this.reference,
    this.labelOnTop = false,
    this.padding = EdgeInsets.zero,
    this.pillPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.pillRadius = 12,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  State<ReferenceCopyValue> createState() => _ReferenceCopyValueState();
}

class _ReferenceCopyValueState extends State<ReferenceCopyValue> {
  bool _copied = false;
  Timer? _copiedTimer;

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trimmed = widget.reference.trim();
    final sanitized = (trimmed == '—') ? '' : trimmed;
    final isEmpty = sanitized.isEmpty;
    final truncated = sanitized.length <= 15 ? sanitized : '${sanitized.substring(0, 15)}…';

    final resolvedLabelStyle = widget.labelStyle ?? theme.textTheme.bodyMedium?.copyWith(
          color: OpeiColors.grey600,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        );

    final resolvedValueStyle = widget.valueStyle ?? theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: -0.1,
        );

    final action = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _copied && !isEmpty
          ? const _CopiedBadge(key: ValueKey('copied'))
          : _CopyButton(
              key: const ValueKey('copy'),
              onTap: isEmpty ? null : () => _copyReference(context, sanitized),
            ),
    );

    final pill = AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      opacity: isEmpty ? 0.5 : 1,
      child: Container(
        padding: widget.pillPadding,
        decoration: BoxDecoration(
          color: OpeiColors.pureWhite,
          borderRadius: BorderRadius.circular(widget.pillRadius),
          border: Border.all(
            color: OpeiColors.grey200.withValues(alpha: 0.9),
            width: 0.7,
          ),
          boxShadow: theme.brightness == Brightness.dark
              ? null
              : [
                  BoxShadow(
                    color: OpeiColors.pureBlack.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                isEmpty ? '—' : truncated,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: resolvedValueStyle,
              ),
            ),
            if (!isEmpty) ...[
              const SizedBox(width: 10),
              action,
            ],
          ],
        ),
      ),
    );

    final content = widget.labelOnTop
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label, style: resolvedLabelStyle),
              const SizedBox(height: 6),
              pill,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.label, style: resolvedLabelStyle),
              const SizedBox(width: 12),
              Expanded(child: pill),
            ],
          );

    return Padding(
      padding: widget.padding,
      child: content,
    );
  }

  Future<void> _copyReference(BuildContext context, String value) async {
    if (value.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: value));
    await HapticFeedback.selectionClick();

    _copiedTimer?.cancel();
    setState(() => _copied = true);

    _copiedTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() => _copied = false);
    });
  }
}

class _CopyButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _CopyButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: onTap == null ? OpeiColors.grey200 : OpeiColors.grey100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          CupertinoIcons.doc_on_doc,
          size: 16,
          color: onTap == null ? OpeiColors.grey500 : OpeiColors.pureBlack,
        ),
      ),
    );
  }
}

class _CopiedBadge extends StatelessWidget {
  const _CopiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: OpeiColors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            CupertinoIcons.check_mark_circled_solid,
            size: 16,
            color: OpeiColors.success,
          ),
          SizedBox(width: 6),
          Text(
            'Copied',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
              color: OpeiColors.success,
            ),
          ),
        ],
      ),
    );
  }
}