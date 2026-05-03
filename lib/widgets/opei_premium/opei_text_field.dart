import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:opei/theme.dart';

/// Premium Opei text field for new auth flows.
///
/// - Hairline-bordered card on white surface (bank-like, not greybox)
/// - Border smoothly turns brand-blue when focused
/// - Optional small label above the field, helper text below
/// - Optional prefix widget (icon, country picker, etc.) and suffix
/// - Inline error coloring
class OpeiTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final TextCapitalization textCapitalization;

  const OpeiTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<OpeiTextField> createState() => _OpeiTextFieldState();
}

class _OpeiTextFieldState extends State<OpeiTextField> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final isFocused = _focusNode.hasFocus;

    final borderColor = hasError
        ? OpeiBrand.danger
        : isFocused
            ? OpeiBrand.primary
            : OpeiBrand.hairline;
    final borderWidth = isFocused || hasError ? 1.5 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              widget.label!,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: OpeiBrand.inkSecondary,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
        AnimatedContainer(
          duration: OpeiBrand.motionFast,
          curve: OpeiBrand.motionCurve,
          height: 52,
          decoration: BoxDecoration(
            color: widget.enabled
                ? OpeiBrand.surface
                : OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                widget.prefix!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  enabled: widget.enabled,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  maxLength: widget.maxLength,
                  onChanged: widget.onChanged,
                  onFieldSubmitted: widget.onSubmitted,
                  validator: widget.validator,
                  autovalidateMode: widget.autovalidateMode,
                  textCapitalization: widget.textCapitalization,
                  cursorColor: OpeiBrand.primary,
                  cursorWidth: 1.6,
                  cursorHeight: 18,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: OpeiBrand.ink,
                    letterSpacing: -0.2,
                    height: 1.25,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    counterText: '',
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: OpeiBrand.inkPlaceholder,
                      letterSpacing: -0.2,
                      height: 1.25,
                    ),
                    errorStyle: const TextStyle(
                      height: 0,
                      fontSize: 0,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
              if (widget.suffix != null) ...[
                const SizedBox(width: 6),
                widget.suffix!,
              ],
            ],
          ),
        ),
        AnimatedSize(
          duration: OpeiBrand.motionFast,
          curve: OpeiBrand.motionCurve,
          alignment: Alignment.topLeft,
          child: hasError || (widget.helperText?.isNotEmpty ?? false)
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    hasError ? widget.errorText! : widget.helperText!,
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: hasError
                          ? OpeiBrand.danger
                          : OpeiBrand.inkTertiary,
                      letterSpacing: -0.1,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
