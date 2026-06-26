import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:opei/core/navigation/opei_page_transitions.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/beneficiary.dart';
import 'package:opei/data/repositories/beneficiary_repository.dart';
import 'package:opei/features/beneficiaries/send/send_mobile_money_controller.dart';
import 'package:opei/features/beneficiaries/send/send_preview_screen.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_app_bar.dart';
import 'package:opei/widgets/opei_premium/opei_primary_button.dart';

/// Step 1 — amount entry. The user types the amount the **receiver** will
/// get in the receiver's local currency (e.g. UGX, KES, GHS).
class SendAmountScreen extends ConsumerStatefulWidget {
  final Beneficiary beneficiary;
  final String countryName;
  final String flag;

  const SendAmountScreen({
    super.key,
    required this.beneficiary,
    required this.countryName,
    required this.flag,
  });

  @override
  ConsumerState<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends ConsumerState<SendAmountScreen> {
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String? _amountError;
  String? _descriptionError;

  late final ({
    String code,
    String symbol,
    int decimals,
    List<int> quickAmounts,
  })
  _meta;

  @override
  void initState() {
    super.initState();
    // Resolve currency once at mount time. Beneficiary has a country code
    // (e.g. "UG"), but we also accept the screen-level country prop.
    final country =
        (widget.beneficiary.country.isNotEmpty
                ? widget.beneficiary.country
                : '')
            .toUpperCase();
    _meta = BeneficiaryRepository.currencyMetaFor(country);
    final currentState = ref.read(
      sendMobileMoneyControllerProvider(widget.beneficiary),
    );
    if (currentState.paymentDescription.isNotEmpty) {
      _descriptionCtrl.text = currentState.paymentDescription;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  /// Converts the typed text into the smallest unit of the receiver's
  /// currency. For 0-decimal currencies (UGX, RWF, XOF, XAF, CDF) this
  /// is just the integer value. For 2-decimal ones it's value × 100.
  int _parseToMinor(String text) {
    final clean = text.replaceAll(',', '').trim();
    if (clean.isEmpty) return 0;
    if (_meta.decimals == 0) {
      return int.tryParse(clean) ?? 0;
    }
    final asNum = double.tryParse(clean) ?? 0;
    return (asNum * 100).round();
  }

  String _formatMajor(int major) {
    return NumberFormat.decimalPattern().format(major);
  }

  String _quickAmountLabel(int amount) {
    return '${_meta.symbol} ${_formatMajor(amount)}';
  }

  void _onAmountChanged(String text) {
    if (_amountError != null) setState(() => _amountError = null);
    ref
        .read(sendMobileMoneyControllerProvider(widget.beneficiary).notifier)
        .setTargetAmountMinor(_parseToMinor(text));
  }

  void _onDescriptionChanged(String text) {
    if (_descriptionError != null) setState(() => _descriptionError = null);
    ref
        .read(sendMobileMoneyControllerProvider(widget.beneficiary).notifier)
        .setPaymentDescription(text);
  }

  void _setQuick(int majorAmount) {
    final txt = _meta.decimals == 0
        ? majorAmount.toString()
        : majorAmount.toString();
    _amountCtrl.text = txt;
    _amountCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountCtrl.text.length),
    );
    _onAmountChanged(_amountCtrl.text);
  }

  Future<void> _onContinue() async {
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    final amountMinor = _parseToMinor(_amountCtrl.text);
    final description = _descriptionCtrl.text.trim();
    String? amountError;
    String? descriptionError;

    if (amountMinor <= 0) {
      amountError = l10n.sendAmountAmountError(_meta.code);
    }
    if (description.length < 3) {
      descriptionError = l10n.sendAmountDescriptionMinError;
    } else if (description.length > 120) {
      descriptionError = l10n.sendAmountDescriptionMaxError;
    }

    if (amountError != null || descriptionError != null) {
      setState(() {
        _amountError = amountError;
        _descriptionError = descriptionError;
      });
      return;
    }

    ref
        .read(sendMobileMoneyControllerProvider(widget.beneficiary).notifier)
        .setPaymentDescription(description);

    final ok = await ref
        .read(sendMobileMoneyControllerProvider(widget.beneficiary).notifier)
        .createReview();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).push(
        OpeiPageRoute(
          builder: (_) => SendPreviewScreen(
            beneficiary: widget.beneficiary,
            countryName: widget.countryName,
            flag: widget.flag,
          ),
        ),
      );
    } else {
      final err = ref
          .read(sendMobileMoneyControllerProvider(widget.beneficiary))
          .reviewError;
      if (err != null) showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(
      sendMobileMoneyControllerProvider(widget.beneficiary),
    );
    final name = widget.beneficiary.accountName ?? l10n.sendReceiverFallback;
    final masked = widget.beneficiary.accountNumberMasked ?? '';
    final currentMinor = state.targetAmountMinor;

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: const OpeiAppBar(),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sendAmountTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: OpeiBrand.ink,
                          letterSpacing: -0.4,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.sendAmountSubtitle(_meta.code),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: OpeiBrand.inkSecondary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 18),

                      _ReceiverPill(
                        name: name,
                        masked: masked,
                        flag: widget.flag,
                        countryName: widget.countryName,
                      ),
                      const SizedBox(height: 20),

                      _AmountInput(
                        controller: _amountCtrl,
                        onChanged: _onAmountChanged,
                        hasError: _amountError != null,
                        meta: _meta,
                      ),

                      if (_amountError != null) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            _amountError!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: OpeiBrand.danger,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _DescriptionInput(
                        controller: _descriptionCtrl,
                        onChanged: _onDescriptionChanged,
                        hasError: _descriptionError != null,
                      ),
                      if (_descriptionError != null) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            _descriptionError!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: OpeiBrand.danger,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Quick amounts (currency-specific values)
                      Row(
                        children: [
                          for (final amt in _meta.quickAmounts) ...[
                            Expanded(
                              child: _QuickAmount(
                                label: _quickAmountLabel(amt),
                                isActive:
                                    currentMinor ==
                                    (_meta.decimals == 0 ? amt : amt * 100),
                                onTap: () => _setQuick(amt),
                              ),
                            ),
                            if (amt != _meta.quickAmounts.last)
                              const SizedBox(width: 6),
                          ],
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 12,
                            color: OpeiBrand.inkTertiary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.sendAmountCostHint,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: OpeiBrand.inkTertiary,
                                letterSpacing: -0.1,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (state.reviewError?.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            state.reviewError!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: OpeiBrand.danger,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).viewPadding.bottom + 14,
                ),
                child: OpeiPrimaryButton(
                  label: l10n.continueCta,
                  onPressed: state.isReviewing ? null : _onContinue,
                  loading: state.isReviewing,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ReceiverPill extends StatelessWidget {
  final String name;
  final String masked;
  final String flag;
  final String countryName;

  const _ReceiverPill({
    required this.name,
    required this.masked,
    required this.flag,
    required this.countryName,
  });

  String _initials(String n) {
    if (n.trim().isEmpty) return '?';
    final parts = n.trim().split(RegExp(r'\s+'));
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: OpeiBrand.primaryTint,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Center(
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: OpeiBrand.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: OpeiBrand.surfaceMuted,
                      width: 1.5,
                    ),
                  ),
                  child: Text(flag, style: const TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: OpeiBrand.ink,
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  masked.isNotEmpty ? '$masked · $countryName' : countryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: OpeiBrand.inkSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: OpeiBrand.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              l10n.sendReceiverBadge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.primary,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final ({String code, String symbol, int decimals, List<int> quickAmounts})
  meta;

  const _AmountInput({
    required this.controller,
    required this.onChanged,
    required this.hasError,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? OpeiBrand.danger : OpeiBrand.hairline,
          width: hasError ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          // Currency symbol prefix
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 6, 0),
            child: Text(
              meta.symbol,
              style: TextStyle(
                fontSize: meta.symbol.length > 2 ? 14 : 18,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.inkTertiary.withValues(alpha: 0.85),
                height: 1,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: meta.decimals == 0
                  ? TextInputType.number
                  : const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  meta.decimals == 0 ? RegExp(r'[0-9]') : RegExp(r'[0-9.]'),
                ),
              ],
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.ink,
                letterSpacing: -0.6,
                height: 1.1,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: meta.decimals == 0 ? '0' : '0.00',
                hintStyle: const TextStyle(
                  color: OpeiBrand.inkPlaceholder,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  letterSpacing: -0.6,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: OpeiBrand.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: OpeiBrand.hairline, width: 1),
            ),
            child: Text(
              meta.code,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.ink,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool hasError;

  const _DescriptionInput({
    required this.controller,
    required this.onChanged,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? OpeiBrand.danger : OpeiBrand.hairline,
          width: hasError ? 1.4 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLength: 120,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: l10n.sendDescriptionLabel,
          hintText: l10n.sendDescriptionHint,
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _QuickAmount extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickAmount({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? OpeiBrand.primary : OpeiBrand.surfaceMuted,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? OpeiBrand.primary : OpeiBrand.hairline,
              width: 1,
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isActive ? Colors.white : OpeiBrand.ink,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
