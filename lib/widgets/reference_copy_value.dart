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
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const ReferenceCopyValue({
    super.key,
    required this.label,
    required this.reference,
    this.labelOnTop = false,
    this.padding = EdgeInsets.zero,
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

    final resolvedLabelStyle = widget.labelStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: OpeiColors.grey600,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        );

    final resolvedValueStyle = widget.valueStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: -0.1,
        );

    final valueRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            isEmpty ? '—' : sanitized,
            style: resolvedValueStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isEmpty) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _copyReference(context, sanitized),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 48,
              height: 20,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _copied
                    ? Align(
                        key: const ValueKey('copied'),
                        alignment: Alignment.center,
              child: Text(
                          'Copied',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: OpeiColors.grey600,
                            letterSpacing: -0.1,
              ),
            ),
                      )
                    : Align(
                        key: const ValueKey('copy'),
                        alignment: Alignment.center,
                        child: Icon(
                          CupertinoIcons.doc_on_doc,
                          size: 16,
                          color: OpeiColors.grey600,
                        ),
                      ),
              ),
        ),
      ),
        ],
      ],
    );

    final content = widget.labelOnTop
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label, style: resolvedLabelStyle),
              const SizedBox(height: 6),
              valueRow,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.label, style: resolvedLabelStyle),
              const SizedBox(width: 12),
              Expanded(child: valueRow),
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
