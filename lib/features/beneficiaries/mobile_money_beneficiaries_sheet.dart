import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/beneficiary.dart';
import 'package:opei/data/repositories/beneficiary_repository.dart';
import 'package:opei/features/money_movement/availability_controller.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';

import 'beneficiaries_controller.dart';

/// Bottom sheet listing existing mobile-money receivers for [country], with an
/// "Add new" option that opens [_AddMobileMoneyReceiverSheet].
///
/// Always force-refreshes when opened so the user sees fresh data.
class MobileMoneyBeneficiariesSheet extends ConsumerStatefulWidget {
  final String country;
  final String countryName;
  final String flag;

  const MobileMoneyBeneficiariesSheet({
    super.key,
    required this.country,
    required this.countryName,
    required this.flag,
  });

  @override
  ConsumerState<MobileMoneyBeneficiariesSheet> createState() =>
      _MobileMoneyBeneficiariesSheetState();
}

class _MobileMoneyBeneficiariesSheetState
    extends ConsumerState<MobileMoneyBeneficiariesSheet> {
  @override
  void initState() {
    super.initState();
    // Force-refresh so the user always sees the latest list, no matter how
    // many times they switch countries in the same session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(beneficiariesControllerProvider(widget.country).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(beneficiariesControllerProvider(widget.country));
    final controller = ref.read(
      beneficiariesControllerProvider(widget.country).notifier,
    );
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 14),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: OpeiBrand.hairlineStrong,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(widget.flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.countryName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: OpeiBrand.ink,
                          letterSpacing: -0.4,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.mobileMoneyReceiversTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: OpeiBrand.inkSecondary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: OpeiBrand.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 0.5, color: OpeiBrand.hairline),

          // Body
          Flexible(
            child: RefreshIndicator(
              color: OpeiBrand.primary,
              onRefresh: controller.load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AddNewRow(onTap: () => _openAddSheet(context)),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: OpeiBrand.hairline,
                    ),

                    if (state.isLoading && state.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: OpeiBrand.primary,
                          ),
                        ),
                      )
                    else if (state.error != null)
                      _ErrorBlock(
                        message: state.error!,
                        onRetry: controller.load,
                      )
                    else if (state.items.isEmpty)
                      const _EmptyBlock()
                    else
                      ...List.generate(state.items.length * 2 - 1, (i) {
                        if (i.isOdd) {
                          return const Divider(
                            height: 1,
                            thickness: 0.5,
                            color: OpeiBrand.hairline,
                          );
                        }
                        final b = state.items[i ~/ 2];
                        return _ReceiverRow(
                          beneficiary: b,
                          onTap: () => Navigator.of(context).pop(b),
                        );
                      }),

                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: OpeiBrand.hairline,
                    ),
                    SizedBox(height: 16 + bottomPadding),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddSheet(BuildContext context) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MobileMoneyAddReceiverSheet(
        country: widget.country,
        countryName: widget.countryName,
        flag: widget.flag,
      ),
    );
    if (added == true && mounted) {
      ref.read(beneficiariesControllerProvider(widget.country).notifier).load();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIST ROW WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _AddNewRow extends StatelessWidget {
  final VoidCallback onTap;
  const _AddNewRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: OpeiBrand.primary.withValues(alpha: 0.05),
        highlightColor: OpeiBrand.surfaceMuted,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: OpeiBrand.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: OpeiBrand.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.mobileMoneyAddNewReceiverCta,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: OpeiBrand.primary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: OpeiBrand.inkTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiverRow extends StatelessWidget {
  final Beneficiary beneficiary;
  final VoidCallback onTap;

  const _ReceiverRow({required this.beneficiary, required this.onTap});

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name =
        beneficiary.accountName ??
        AppLocalizations.of(context)!.mobileMoneyUnnamedReceiver;
    final masked = beneficiary.accountNumberMasked ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: OpeiBrand.primary.withValues(alpha: 0.04),
        highlightColor: OpeiBrand.surfaceMuted,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: OpeiBrand.surfaceMuted,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Center(
                  child: Text(
                    _initials(beneficiary.accountName),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.inkSecondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.2,
                        height: 1.15,
                      ),
                    ),
                    if (masked.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        masked,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: OpeiBrand.inkSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: OpeiBrand.inkTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          Text(
            l10n.mobileMoneyNoReceiversTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 6),
          Text(
            l10n.mobileMoneyNoReceiversSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: OpeiBrand.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 22,
              color: OpeiBrand.danger,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.mobileMoneyLoadReceiversFailed,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: OpeiBrand.primary,
              side: const BorderSide(color: OpeiBrand.primary, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            child: Text(
              l10n.retryCta,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD RECEIVER — FORM SHEET (public so other screens can reuse it)
// ─────────────────────────────────────────────────────────────────────────────

class MobileMoneyAddReceiverSheet extends ConsumerStatefulWidget {
  final String country;
  final String countryName;
  final String flag;

  const MobileMoneyAddReceiverSheet({
    super.key,
    required this.country,
    required this.countryName,
    required this.flag,
  });

  @override
  ConsumerState<MobileMoneyAddReceiverSheet> createState() =>
      _MobileMoneyAddReceiverSheetState();
}

class _MobileMoneyAddReceiverSheetState
    extends ConsumerState<MobileMoneyAddReceiverSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  String? _selectedNetwork;

  bool get _requiresName =>
      BeneficiaryRepository.requiresAccountName(widget.country);

  List<String> _networksForAvailability() {
    final availability = availabilityFromWidgetRef(ref);
    final networks =
        BeneficiaryRepository.mobileMoneyNetworks[widget.country] ?? const [];
    return networks
        .where(
          (network) => availability.withdrawal.mobileMoney.isNetworkEnabled(
            widget.country,
            network,
          ),
        )
        .toList(growable: false);
  }

  ({String dialCode, int nationalLength}) get _phoneMeta =>
      BeneficiaryRepository.mobileMoneyPhoneMeta[widget.country] ??
      (dialCode: '+', nationalLength: 9);

  /// Source-of-truth for the Save button's enabled state. We don't rely on
  /// `_formKey.currentState.validate()` here because that triggers all the
  /// red-error rendering — we just want to know "is everything filled in
  /// correctly so the button can light up?".
  bool get _isFormReady {
    if (_selectedNetwork == null) return false;

    if (_requiresName) {
      final name = _nameCtrl.text.trim();
      if (name.length < 2 || !name.contains(' ')) return false;
    }

    final phone = _numberCtrl.text.trim();
    if (phone.isEmpty) return false;
    if (phone.length != _phoneMeta.nationalLength) return false;
    if (phone.startsWith('0')) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();
    final networks = _networksForAvailability();
    if (networks.length == 1) {
      _selectedNetwork = networks.first;
    }
    // Re-evaluate `_isFormReady` on every keystroke so the button enables
    // the moment everything is valid (and disables again the moment it's not).
    _nameCtrl.addListener(_onFieldChange);
    _numberCtrl.addListener(_onFieldChange);
    // Reset any stale create-error from a previous attempt for this country.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(beneficiariesControllerProvider(widget.country).notifier)
          .clearCreateError();
    });
  }

  void _onFieldChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onFieldChange);
    _numberCtrl.removeListener(_onFieldChange);
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  String _composeAccountNumber() {
    // Backend expects `<dialCodeNoPlus><nationalDigits>`, e.g. 254712200002.
    final dial = _phoneMeta.dialCode.replaceAll('+', '');
    final national = _numberCtrl.text.trim();
    return '$dial$national';
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    // Belt-and-suspenders: even though the button is gated by [_isFormReady],
    // run Form.validate() so we render any field-level errors if something
    // slipped through.
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedNetwork == null) {
      showError(context, l10n.mobileMoneyChooseNetworkError);
      return;
    }
    final availability = availabilityFromWidgetRef(ref);
    if (!availability.withdrawal.mobileMoney.isNetworkEnabled(
      widget.country,
      _selectedNetwork!,
    )) {
      showError(context, l10n.errServiceUnavailable);
      return;
    }

    final controller = ref.read(
      beneficiariesControllerProvider(widget.country).notifier,
    );
    final ok = await controller.createMobileMoney(
      network: _selectedNetwork!,
      accountNumber: _composeAccountNumber(),
      accountName: _requiresName ? _nameCtrl.text : null,
    );
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
      showSuccess(context, l10n.mobileMoneyReceiverAdded);
    } else {
      // Error banner inside the sheet is already bound via Riverpod; also
      // surface the snackbar so it's impossible to miss.
      final err = ref
          .read(beneficiariesControllerProvider(widget.country))
          .createError;
      if (err != null) {
        showError(context, err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(beneficiariesControllerProvider(widget.country));
    ref.watch(moneyMovementAvailabilityProvider);
    final viewInsets = MediaQuery.of(context).viewInsets;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final networks = _networksForAvailability();
    if (_selectedNetwork != null && !networks.contains(_selectedNetwork)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedNetwork = null);
      });
    }
    final canSubmit = _isFormReady && !state.isCreating;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: OpeiBrand.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Drag handle ─────────────────────────────────
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: OpeiBrand.hairlineStrong,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // ── Centered title ──────────────────────────────
                Text(
                  l10n.mobileMoneyNewReceiverTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: OpeiBrand.ink,
                    letterSpacing: -0.4,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.flag}  ${widget.countryName} · ${l10n.mobileMoneyLabel}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: OpeiBrand.inkSecondary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 22),

                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: OpeiBrand.hairline,
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 18 + bottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Network ─────────────────────────────────
                      Row(
                        children: [
                          _FieldLabel(l10n.networkLabel),
                          const Spacer(),
                          if (_selectedNetwork != null)
                            const _CheckPill()
                          else
                            const _RequiredPill(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _NetworkSelector(
                        networks: networks,
                        selected: _selectedNetwork,
                        onSelect: (v) => setState(() => _selectedNetwork = v),
                      ),
                      const SizedBox(height: 22),

                      // ── Receiver name (only when corridor needs it) ───
                      if (_requiresName) ...[
                        Row(
                          children: [
                            _FieldLabel(l10n.mobileMoneyReceiverNameLabel),
                            const Spacer(),
                            if (_nameCtrl.text.trim().length >= 2 &&
                                _nameCtrl.text.trim().contains(' '))
                              const _CheckPill()
                            else
                              const _RequiredPill(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            hint: l10n.mobileMoneyReceiverFullNameHint,
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.length < 2) {
                              return l10n.mobileMoneyReceiverFullNameRequired;
                            }
                            if (!value.contains(' ')) {
                              return l10n
                                  .mobileMoneyReceiverFirstLastNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                      ],

                      // ── Phone number ─────────────────────────────
                      Row(
                        children: [
                          _FieldLabel(l10n.phoneNumberLabel),
                          const Spacer(),
                          if (_numberCtrl.text.trim().length ==
                                  _phoneMeta.nationalLength &&
                              !_numberCtrl.text.trim().startsWith('0'))
                            const _CheckPill()
                          else
                            _CounterPill(
                              current: _numberCtrl.text.trim().length,
                              total: _phoneMeta.nationalLength,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _numberCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            _phoneMeta.nationalLength,
                          ),
                        ],
                        decoration: _inputDecoration(
                          hint: l10n.mobileMoneyDigitsHint(
                            _phoneMeta.nationalLength,
                          ),
                          prefix: _DialPrefix(dialCode: _phoneMeta.dialCode),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) {
                            return l10n.mobileMoneyPhoneRequired;
                          }
                          if (value.length != _phoneMeta.nationalLength) {
                            return l10n.mobileMoneyPhoneExactDigitsForCountry(
                              _phoneMeta.nationalLength,
                              widget.countryName,
                            );
                          }
                          if (value.startsWith('0')) {
                            return l10n.mobileMoneyPhoneLeadingZeroError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.mobileMoneyLocalNumberHelper(_phoneMeta.dialCode),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: OpeiBrand.inkTertiary,
                          letterSpacing: -0.1,
                          height: 1.4,
                        ),
                      ),

                      // ── Inline error banner ──────────────────────
                      if (state.createError != null) ...[
                        const SizedBox(height: 16),
                        _InlineError(
                          message: state.createError!,
                          onClose: () => ref
                              .read(
                                beneficiariesControllerProvider(
                                  widget.country,
                                ).notifier,
                              )
                              .clearCreateError(),
                        ),
                      ],

                      const SizedBox(height: 22),

                      // ── Save button ──────────────────────────────
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: canSubmit ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OpeiBrand.primary,
                            disabledBackgroundColor: OpeiBrand.primary
                                .withValues(alpha: 0.30),
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white.withValues(
                              alpha: 0.85,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: state.isCreating
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.mobileMoneySaveReceiverCta,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: OpeiBrand.inkTertiary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      filled: true,
      fillColor: OpeiBrand.surfaceMuted,
      prefixIcon: prefix,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OpeiBrand.hairline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OpeiBrand.hairline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OpeiBrand.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OpeiBrand.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OpeiBrand.danger, width: 1.5),
      ),
    );
  }
}

// ── Field-status pills ───────────────────────────────────────────────────────

class _RequiredPill extends StatelessWidget {
  const _RequiredPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        AppLocalizations.of(context)!.requiredLabel,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: OpeiBrand.inkTertiary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  final int current;
  final int total;
  const _CounterPill({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$current / $total',
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: OpeiBrand.inkSecondary,
          letterSpacing: 0.4,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _CheckPill extends StatelessWidget {
  const _CheckPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: OpeiBrand.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 11, color: OpeiBrand.success),
          SizedBox(width: 3),
          Text(
            AppLocalizations.of(context)!.okLabel,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: OpeiBrand.success,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialPrefix extends StatelessWidget {
  final String dialCode;
  const _DialPrefix({required this.dialCode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 10, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dialCode,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 18, color: OpeiBrand.hairlineStrong),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  const _InlineError({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: OpeiBrand.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: OpeiBrand.danger.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: OpeiBrand.danger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: OpeiBrand.danger,
                height: 1.3,
                letterSpacing: -0.1,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: OpeiBrand.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: OpeiBrand.ink,
        letterSpacing: -0.1,
      ),
    );
  }
}

class _NetworkSelector extends StatelessWidget {
  final List<String> networks;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _NetworkSelector({
    required this.networks,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (networks.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.mobileMoneyNoNetworksForCountry,
        style: TextStyle(fontSize: 13, color: OpeiBrand.inkSecondary),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: networks.map((n) {
        final active = n == selected;
        return Material(
          color: active ? OpeiBrand.primaryTint : OpeiBrand.surfaceMuted,
          borderRadius: BorderRadius.circular(99),
          child: InkWell(
            onTap: () => onSelect(n),
            borderRadius: BorderRadius.circular(99),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: active ? OpeiBrand.primary : OpeiBrand.hairlineStrong,
                  width: active ? 1.2 : 0.8,
                ),
              ),
              child: Text(
                n,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? OpeiBrand.primary : OpeiBrand.ink,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
