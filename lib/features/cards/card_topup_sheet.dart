import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/data/models/virtual_card.dart';
import 'package:opei/features/cards/card_topup_controller.dart';
import 'package:opei/features/cards/card_topup_state.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/reference_copy_value.dart';
import 'package:opei/widgets/success_hero.dart';

class CardTopUpSheet extends ConsumerStatefulWidget {
  final VirtualCard card;

  const CardTopUpSheet({super.key, required this.card});

  @override
  ConsumerState<CardTopUpSheet> createState() => _CardTopUpSheetState();
}

class _CardTopUpSheetState extends ConsumerState<CardTopUpSheet> {
  late final TextEditingController _amountController;
  late final CardTopUpController _topUpController;
  bool _hasScheduledReset = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _topUpController = ref.read(cardTopUpControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currency = widget.card.balance?.currency ?? 'USD';
      _topUpController.attachCard(
        cardId: widget.card.id,
        currency: currency,
      );
    });
  }

  @override
  void dispose() {
    _scheduleControllerReset();
    _amountController.dispose();
    super.dispose();
  }

  void _scheduleControllerReset() {
    if (_hasScheduledReset) return;
    _hasScheduledReset = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _topUpController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cardTopUpControllerProvider);

    return FractionallySizedBox(
      heightFactor: _sheetHeightFactor(context),
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          color: OpeiBrand.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(OpeiBrand.radiusSheet),
          ),
        ),
        child: SafeArea(
          top: false,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: OpeiBrand.hairlineStrong,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildHeader(context, state),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _buildStepContent(context, state),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _sheetHeightFactor(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (height >= 900) return 0.72;
    if (height >= 780) return 0.78;
    if (height >= 680) return 0.84;
    return 0.92;
  }

  Widget _buildHeader(BuildContext context, CardTopUpState state) {
    final theme = Theme.of(context);
    final showBack = state.step != CardTopUpStep.amountEntry;

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: showBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: OpeiBrand.ink),
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          ref.read(cardTopUpControllerProvider.notifier).goBack();
                        },
                )
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: Text(
            'Top up card',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.3,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 40,
          child: IconButton(
            icon: const Icon(CupertinoIcons.xmark,
                size: 18, color: OpeiBrand.inkSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(BuildContext context, CardTopUpState state) {
    switch (state.step) {
      case CardTopUpStep.amountEntry:
        return _AmountStep(
          controller: _amountController,
          state: state,
        );
      case CardTopUpStep.preview:
        return _PreviewStep(state: state);
      case CardTopUpStep.result:
        return _ResultStep(state: state);
    }
  }
}

class _AmountStep extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final CardTopUpState state;

  const _AmountStep({required this.controller, required this.state});

  @override
  ConsumerState<_AmountStep> createState() => _AmountStepState();
}

class _AmountStepState extends ConsumerState<_AmountStep> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _addAmount(int dollars) {
    final raw = widget.controller.text.trim().replaceAll(',', '');
    final current = double.tryParse(raw) ?? 0.0;
    final next = (current + dollars).toStringAsFixed(2);
    widget.controller.text = next;
    widget.controller.selection =
        TextSelection.fromPosition(TextPosition(offset: next.length));
    ref.read(cardTopUpControllerProvider.notifier).clearErrorMessage();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final raw = widget.controller.text.trim();
    final money = Money.parse(
        raw.isEmpty ? '0' : raw,
        currency: widget.state.currency);
    ref.read(cardTopUpControllerProvider.notifier).previewTopUp(money);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final currency = state.currency.toUpperCase();

    return Column(
      key: const ValueKey('amount-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        // ── Label ─────────────────────────────────────────────────────────
        const Text(
          'TOP UP AMOUNT',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: OpeiBrand.inkTertiary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 36),
        // ── Giant borderless number input ─────────────────────────────────
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currency,
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.inkSecondary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              IntrinsicWidth(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  enabled: !state.isPreviewLoading,
                  textAlign: TextAlign.center,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 58,
                    fontWeight: FontWeight.w800,
                    color: OpeiBrand.ink,
                    letterSpacing: -2,
                    height: 1,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 58,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDDE8FF),
                      letterSpacing: -2,
                      height: 1,
                    ),
                  ),
                  cursorColor: OpeiBrand.primary,
                  onChanged: (_) => ref
                      .read(cardTopUpControllerProvider.notifier)
                      .clearErrorMessage(),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // ── Quick-add chips ────────────────────────────────────────────────
        _QuickTopUpChips(onAdd: _addAmount),
        const SizedBox(height: 24),
        // ── Error ─────────────────────────────────────────────────────────
        if (state.errorMessage?.isNotEmpty == true) ...[
          _ErrorBanner(message: state.errorMessage!),
          const SizedBox(height: 16),
        ],
        // ── CTA ───────────────────────────────────────────────────────────
        _PrimaryButton(
          onPressed: state.isPreviewLoading ? null : _submit,
          label: 'Preview top-up',
          isLoading: state.isPreviewLoading,
        ),
      ],
    );
  }
}

class _QuickTopUpChips extends StatelessWidget {
  final void Function(int) onAdd;
  const _QuickTopUpChips({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    const amounts = <int>[5, 10, 25, 50];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: amounts.asMap().entries.map((e) {
        return Padding(
          padding: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onAdd(e.value);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: OpeiBrand.primaryTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '+\$${e.value}',
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.primary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PreviewStep extends ConsumerWidget {
  final CardTopUpState state;

  const _PreviewStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = state.preview;

    if (preview == null) {
      return const Column(
        key: ValueKey('preview-step-empty'),
        children: [
          SizedBox(height: 40),
          CupertinoActivityIndicator(radius: 14),
          SizedBox(height: 16),
          Text(
            'Loading preview…',
            style: TextStyle(
              fontSize: 13,
              color: OpeiBrand.inkSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    final controller = ref.read(cardTopUpControllerProvider.notifier);
    final infoMessage = state.errorMessage;
    final isBlocking = !preview.canTopUp;

    return Column(
      key: const ValueKey('preview-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Hero amount ─────────────────────────────────────────────────
        _HeroAmount(
          amount: preview.topUpAmountMoney.format(includeCurrencySymbol: true),
        ),
        const SizedBox(height: 18),

        // ── Breakdown ────────────────────────────────────────────────────
        _SectionLabel('PAYMENT BREAKDOWN'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
            border: Border.all(color: OpeiBrand.hairline, width: 1),
          ),
          child: Column(
            children: [
              _PreviewRow(
                label: 'Top-up amount',
                value: preview.topUpAmountMoney
                    .format(includeCurrencySymbol: true),
              ),
              const _Divider(),
              _PreviewRow(
                label: 'Fee',
                value: preview.feeMoney.format(includeCurrencySymbol: true),
              ),
              const _Divider(),
              _PreviewRow(
                label: 'Total to pay',
                value: preview.totalDebitMoney
                    .format(includeCurrencySymbol: true),
                isEmphasis: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── Wallet impact ───────────────────────────────────────────────
        _SectionLabel('AFTER THIS PAYMENT'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
            border: Border.all(color: OpeiBrand.hairline, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: OpeiBrand.primaryTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: OpeiBrand.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Wallet balance',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: OpeiBrand.inkSecondary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Text(
                preview.walletBalanceAfterMoney
                    .format(includeCurrencySymbol: true),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),

        if (infoMessage?.isNotEmpty == true) ...[
          const SizedBox(height: 14),
          _StatusBanner(
            message: infoMessage!,
            variant: isBlocking ? _BannerVariant.warning : _BannerVariant.error,
          ),
        ],

        const SizedBox(height: 22),
        _PrimaryButton(
          onPressed: (state.isSubmitting || !preview.canTopUp)
              ? null
              : () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await controller.confirmTopUp();
                },
          label: 'Confirm top-up',
          isLoading: state.isSubmitting,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: state.isSubmitting
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  ref.read(cardTopUpControllerProvider.notifier).goBack();
                },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            foregroundColor: OpeiBrand.primary,
          ),
          child: const Text(
            'Edit amount',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroAmount extends StatelessWidget {
  final String amount;
  const _HeroAmount({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OpeiBrand.primaryGradientStart,
            OpeiBrand.primaryGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: OpeiBrand.primary.withValues(alpha: 0.18),
            offset: const Offset(0, 8),
            blurRadius: 22,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOU\'RE TOPPING UP',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white70,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.8,
                height: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: OpeiBrand.inkTertiary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        thickness: 0.5,
        color: OpeiBrand.hairline,
        indent: 14,
        endIndent: 14,
      );
}

class _ResultStep extends ConsumerWidget {
  final CardTopUpState state;
  const _ResultStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final success = state.isSuccess && state.result != null;
    final result = state.result;

    if (success && result != null) {
      return Column(
        key: const ValueKey('result-step-success'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // ── Success icon ──────────────────────────────────────────────
          const Center(child: SuccessHero(iconHeight: 64, gap: 2)),
          const SizedBox(height: 20),
          // ── Amount ────────────────────────────────────────────────────
          Text(
            result.amountMoney.format(includeCurrencySymbol: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: OpeiBrand.ink,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Top-up complete',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: OpeiBrand.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your card balance will update shortly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13,
              color: OpeiBrand.inkSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          // ── Transaction details ───────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: OpeiBrand.surfaceMuted,
              borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
              border: Border.all(color: OpeiBrand.hairline),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: ReferenceCopyValue(
                    label: 'Reference',
                    reference: result.reference,
                  ),
                ),
                const _Divider(),
                _PreviewRow(
                  label: 'Amount',
                  value: result.amountMoney.format(includeCurrencySymbol: true),
                ),
                const _Divider(),
                _PreviewRow(
                  label: 'Fee',
                  value: result.feeMoney.format(includeCurrencySymbol: true),
                ),
                const _Divider(),
                _PreviewRow(
                  label: 'Total paid',
                  value: result.totalDebitMoney.format(includeCurrencySymbol: true),
                  isEmphasis: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Done',
          ),
        ],
      );
    }

    // ── Failure state ─────────────────────────────────────────────────────
    return Column(
      key: const ValueKey('result-step-failure'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: OpeiBrand.danger.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: OpeiBrand.danger,
              size: 38,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Top-up failed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: OpeiBrand.ink,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          state.errorMessage?.isNotEmpty == true
              ? state.errorMessage!
              : 'Unable to complete top-up. Please try again.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13,
            color: OpeiBrand.inkSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        _PrimaryButton(
          onPressed: () => ref
              .read(cardTopUpControllerProvider.notifier)
              .goBack(),
          label: 'Try again',
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            foregroundColor: OpeiBrand.inkSecondary,
          ),
          child: const Text(
            'Close',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEmphasis;

  const _PreviewRow({
    required this.label,
    required this.value,
    this.isEmphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isEmphasis ? FontWeight.w700 : FontWeight.w500,
              color: isEmphasis ? OpeiBrand.ink : OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isEmphasis ? 15 : 13.5,
                  fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w700,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  const _PrimaryButton({
    required this.onPressed,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = isLoading;

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isBusy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: OpeiBrand.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: OpeiBrand.primaryTintStrong,
          disabledForegroundColor: OpeiBrand.primary.withValues(alpha: 0.6),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(OpeiBrand.radiusCta)),
        ),
        child: isBusy
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
              ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: OpeiBrand.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: OpeiBrand.danger, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                    color: OpeiBrand.danger,
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _BannerVariant { info, warning, error }

class _StatusBanner extends StatelessWidget {
  final String message;
  final _BannerVariant variant;

  const _StatusBanner({required this.message, this.variant = _BannerVariant.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWarning = variant == _BannerVariant.warning;
    final isError = variant == _BannerVariant.error;

    final Color background;
    final Color foreground;
    final IconData icon;

    if (isError) {
      background = OpeiBrand.danger.withValues(alpha: 0.08);
      foreground = OpeiBrand.danger;
      icon = Icons.error_outline;
    } else if (isWarning) {
      background = const Color(0xFFFFF6E0);
      foreground = const Color(0xFF8A5A00);
      icon = Icons.info_outline_rounded;
    } else {
      background = OpeiBrand.primaryTint;
      foreground = OpeiBrand.primary;
      icon = CupertinoIcons.lightbulb;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                    color: foreground,
                    fontSize: 11,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}