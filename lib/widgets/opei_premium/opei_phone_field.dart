import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:opei/core/constants/countries.dart';
import 'package:opei/core/constants/country_dial_codes.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';
import 'opei_text_field.dart';

/// Premium phone-number field with a tappable country selector on the left.
///
/// - User picks a country → dial code is auto-filled and locked
/// - User types only the local subscriber number (digits only)
/// - Per-country length validation via [validate]
/// - Calls [onPhoneChanged] with the full E.164 string `+{dial}{number}`
class OpeiPhoneField extends StatefulWidget {
  final String? label;
  final String? errorText;
  final String? helperText;
  final String selectedIso;
  final String localNumber;
  final ValueChanged<String> onIsoChanged;
  final ValueChanged<String> onLocalNumberChanged;
  final ValueChanged<String>? onPhoneChanged;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const OpeiPhoneField({
    super.key,
    this.label,
    this.errorText,
    this.helperText,
    required this.selectedIso,
    required this.localNumber,
    required this.onIsoChanged,
    required this.onLocalNumberChanged,
    this.onPhoneChanged,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  /// Validate a local-number string against the selected country's plan.
  /// Returns null if valid, or an error message describing the issue.
  static String? validate(
    BuildContext context,
    String iso,
    String localNumber,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final dial = dialCodeFor(iso);
    final clean = localNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return l10n.phoneNumberRequiredError;
    if (clean.length < dial.minDigits) {
      if (dial.minDigits == dial.maxDigits) {
        return l10n.phoneNumberExactDigitsError(dial.minDigits);
      }
      return l10n.phoneNumberMinDigitsError(dial.minDigits);
    }
    if (clean.length > dial.maxDigits) {
      if (dial.minDigits == dial.maxDigits) {
        return l10n.phoneNumberExactDigitsError(dial.maxDigits);
      }
      return l10n.phoneNumberMaxDigitsError(dial.maxDigits);
    }
    return null;
  }

  /// Convenience: build the full E.164 string `+234810…`.
  static String e164(String iso, String localNumber) {
    final dial = dialCodeFor(iso);
    final clean = localNumber.replaceAll(RegExp(r'\D'), '');
    return '+${dial.dialCode}$clean';
  }

  @override
  State<OpeiPhoneField> createState() => _OpeiPhoneFieldState();
}

class _OpeiPhoneFieldState extends State<OpeiPhoneField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.localNumber);
    _focusNode = FocusNode()..addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant OpeiPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localNumber != widget.localNumber &&
        widget.localNumber != _controller.text) {
      _controller.text = widget.localNumber;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_rebuild);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _openCountryPicker() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (sheetContext) => _DialCountrySheet(
        selectedIso: widget.selectedIso,
        onSelected: (iso) {
          widget.onIsoChanged(iso);
          Navigator.pop(sheetContext);
          // Re-focus number input + keep typed digits.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _focusNode.requestFocus();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dial = dialCodeFor(widget.selectedIso);
    final effectiveLabel = (widget.label?.trim().isNotEmpty ?? false)
        ? widget.label!
        : l10n.phoneNumberLabel;
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            effectiveLabel,
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ),
        AnimatedContainer(
          duration: OpeiBrand.motionFast,
          curve: OpeiBrand.motionCurve,
          height: 52,
          decoration: BoxDecoration(
            color: widget.enabled ? OpeiBrand.surface : OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              // --- Country chip ---
              InkWell(
                onTap: widget.enabled ? _openCountryPicker : null,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(OpeiBrand.radiusField - 1),
                  bottomLeft: Radius.circular(OpeiBrand.radiusField - 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 10, 0),
                  child: Row(
                    children: [
                      Text(
                        dial.emoji,
                        style: const TextStyle(fontSize: 20, height: 1.0),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+${dial.dialCode}',
                        style: const TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: OpeiBrand.ink,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: OpeiBrand.inkTertiary,
                      ),
                    ],
                  ),
                ),
              ),
              // --- vertical divider ---
              Container(width: 1, height: 24, color: OpeiBrand.hairline),
              // --- number input ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFormField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    keyboardType: TextInputType.phone,
                    textInputAction: widget.textInputAction,
                    cursorColor: OpeiBrand.primary,
                    cursorWidth: 1.6,
                    cursorHeight: 18,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(dial.maxDigits),
                    ],
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
                      counterText: '',
                      hintText: l10n.phoneNumberLabel,
                      hintStyle: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: OpeiBrand.inkPlaceholder,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    onChanged: (v) {
                      widget.onLocalNumberChanged(v);
                      widget.onPhoneChanged?.call(
                        OpeiPhoneField.e164(widget.selectedIso, v),
                      );
                    },
                    onFieldSubmitted: widget.onSubmitted,
                  ),
                ),
              ),
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

class _DialCountrySheet extends StatefulWidget {
  final String selectedIso;
  final ValueChanged<String> onSelected;

  const _DialCountrySheet({
    required this.selectedIso,
    required this.onSelected,
  });

  @override
  State<_DialCountrySheet> createState() => _DialCountrySheetState();
}

class _DialCountrySheetState extends State<_DialCountrySheet> {
  final _searchCtrl = TextEditingController();
  late List<Country> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = _baseList();
  }

  /// Show only countries we have a known dial code for, alphabetically.
  List<Country> _baseList() {
    return allowedCountries
        .where((c) => kDialCodes.containsKey(c.iso))
        .toList(growable: false);
  }

  void _filter(String q) {
    setState(() {
      if (q.isEmpty) {
        _filtered = _baseList();
        return;
      }
      final ql = q.toLowerCase();
      _filtered = _baseList()
          .where((c) {
            final dial = kDialCodes[c.iso]!;
            return c.name.toLowerCase().contains(ql) ||
                c.iso.toLowerCase().contains(ql) ||
                dial.dialCode.contains(ql.replaceAll('+', ''));
          })
          .toList(growable: false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        height: media.size.height * 0.78,
        decoration: const BoxDecoration(
          color: OpeiBrand.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(OpeiBrand.radiusSheet),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: OpeiBrand.hairlineStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.selectCountryCodeTitle,
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: OpeiBrand.ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OpeiTextField(
                controller: _searchCtrl,
                hint: AppLocalizations.of(context)!.searchCountryCodeHint,
                onChanged: _filter,
                prefix: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: OpeiBrand.inkTertiary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _filtered.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: OpeiBrand.hairline,
                  indent: 60,
                ),
                itemBuilder: (context, index) {
                  final country = _filtered[index];
                  final dial = kDialCodes[country.iso]!;
                  final isSelected = widget.selectedIso == country.iso;
                  return InkWell(
                    onTap: () => widget.onSelected(country.iso),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Text(
                            dial.emoji,
                            style: const TextStyle(fontSize: 22, height: 1.0),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              country.name,
                              style: TextStyle(
                                fontFamily: kPrimaryFontFamily,
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: OpeiBrand.ink,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Text(
                            '+${dial.dialCode}',
                            style: TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? OpeiBrand.primary
                                  : OpeiBrand.inkSecondary,
                              letterSpacing: -0.1,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: OpeiBrand.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
