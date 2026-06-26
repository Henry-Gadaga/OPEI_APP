import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/data/models/virtual_card.dart';
import 'package:opei/features/cards/card_withdraw_controller.dart';
import 'package:opei/features/cards/card_withdraw_state.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/reference_copy_value.dart';
import 'package:opei/widgets/success_hero.dart';

class CardWithdrawSheet extends ConsumerStatefulWidget {
  final VirtualCard card;

  const CardWithdrawSheet({super.key, required this.card});

  @override
  ConsumerState<CardWithdrawSheet> createState() => _CardWithdrawSheetState();
}

class _CardWithdrawSheetState extends ConsumerState<CardWithdrawSheet> {
  late final TextEditingController _amountController;
  late final CardWithdrawController _withdrawController;
  bool _hasScheduledReset = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _withdrawController = ref.read(cardWithdrawControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currency = widget.card.balance?.currency ?? 'USD';
      _withdrawController.attachCard(
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
      _withdrawController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cardWithdrawControllerProvider);

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
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildHeader(context, state),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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

  Widget _buildHeader(BuildContext context, CardWithdrawState state) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final showBack = state.step != CardWithdrawStep.amountEntry;

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: showBack
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: OpeiBrand.ink,
                  ),
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(cardWithdrawControllerProvider.notifier)
                              .goBack();
                        },
                )
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: Text(
            l10n.withdrawSheetTitle,
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
            icon: const Icon(
              CupertinoIcons.xmark,
              size: 18,
              color: OpeiBrand.inkSecondary,
            ),
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(BuildContext context, CardWithdrawState state) {
    switch (state.step) {
      case CardWithdrawStep.amountEntry:
        return _AmountStep(controller: _amountController, state: state);
      case CardWithdrawStep.preview:
        return _PreviewStep(state: state);
      case CardWithdrawStep.result:
        return _ResultStep(state: state);
    }
  }
}

class _AmountStep extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final CardWithdrawState state;

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
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: next.length),
    );
    ref.read(cardWithdrawControllerProvider.notifier).clearErrorMessage();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final raw = widget.controller.text.trim();
    final money = Money.parse(
      raw.isEmpty ? '0' : raw,
      currency: widget.state.currency,
    );
    ref.read(cardWithdrawControllerProvider.notifier).previewWithdraw(money);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = widget.state;
    final currency = state.currency.toUpperCase();

    return Column(
      key: const ValueKey('withdraw-amount-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        // ── Label ─────────────────────────────────────────────────────────
        Text(
          l10n.withdrawAmountLabel,
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                      .read(cardWithdrawControllerProvider.notifier)
                      .clearErrorMessage(),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // ── Quick-add chips ────────────────────────────────────────────────
        _QuickWithdrawChips(onAdd: _addAmount),
        const SizedBox(height: 24),
        // ── Error ─────────────────────────────────────────────────────────
        if (state.errorMessage?.isNotEmpty == true) ...[
          _ErrorBanner(message: state.errorMessage!),
          const SizedBox(height: 16),
        ],
        // ── CTA ───────────────────────────────────────────────────────────
        _PrimaryButton(
          onPressed: state.isPreviewLoading ? null : _submit,
          label: l10n.withdrawPreviewCta,
          isLoading: state.isPreviewLoading,
        ),
      ],
    );
  }
}

class _QuickWithdrawChips extends StatelessWidget {
  final void Function(int) onAdd;
  const _QuickWithdrawChips({required this.onAdd});

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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
  final CardWithdrawState state;

  const _PreviewStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final preview = state.preview;

    if (preview == null) {
      return Column(
        key: const ValueKey('withdraw-preview-loading'),
        children: [
          const SizedBox(height: 40),
          const CupertinoActivityIndicator(radius: 14),
          const SizedBox(height: 16),
          Text(l10n.loadingPreview, style: theme.textTheme.bodyMedium),
        ],
      );
    }

    final controller = ref.read(cardWithdrawControllerProvider.notifier);
    final infoMessage = state.errorMessage;
    final isBlocking = !preview.canWithdraw;

    return Column(
      key: const ValueKey('withdraw-preview-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        // ── Hero amount ────────────────────────────────────────────────
        _HeroAmount(
          amount: preview.withdrawAmountMoney.format(
            includeCurrencySymbol: true,
          ),
        ),
        const SizedBox(height: 18),

        // ── Breakdown ─────────────────────────────────────────────────
        _SectionLabel(l10n.paymentBreakdown),
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
                label: l10n.withdrawAmountRow,
                value: preview.withdrawAmountMoney.format(
                  includeCurrencySymbol: true,
                ),
              ),
              const _Divider(),
              _PreviewRow(
                label: l10n.feeRow,
                value: preview.feeMoney.format(includeCurrencySymbol: true),
              ),
              const _Divider(),
              _PreviewRow(
                label: l10n.youWillReceiveRow,
                value: preview.netMoney.format(includeCurrencySymbol: true),
                isEmphasis: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Card impact ────────────────────────────────────────────────
        _SectionLabel(l10n.afterThisWithdrawal),
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
                label: l10n.cardBalanceNowRow,
                value: preview.cardBalanceMoney.format(
                  includeCurrencySymbol: true,
                ),
              ),
              const _Divider(),
              _PreviewRow(
                label: l10n.cardBalanceAfterRow,
                value: preview.cardBalanceAfterMoney.format(
                  includeCurrencySymbol: true,
                ),
                isEmphasis: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (infoMessage?.isNotEmpty == true) ...[
          _StatusBanner(
            message: infoMessage!,
            variant: isBlocking ? _BannerVariant.warning : _BannerVariant.info,
          ),
          const SizedBox(height: 12),
        ],
        _PrimaryButton(
          onPressed: (state.isSubmitting || !preview.canWithdraw)
              ? null
              : () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await controller.confirmWithdraw();
                },
          label: l10n.confirmWithdrawalCta,
          isLoading: state.isSubmitting,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: state.isSubmitting
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  ref.read(cardWithdrawControllerProvider.notifier).goBack();
                },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            foregroundColor: OpeiBrand.primary,
          ),
          child: Text(
            l10n.editAmountCta,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
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

class _ResultStep extends ConsumerWidget {
  final CardWithdrawState state;
  const _ResultStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final success = state.isSuccess && state.result != null;
    final result = state.result;

    if (success && result != null) {
      return Column(
        key: const ValueKey('withdraw-result-step-success'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // ── Success icon ────────────────────────────────────────────
          const Center(child: SuccessHero(iconHeight: 64, gap: 2)),
          const SizedBox(height: 20),
          // ── Amount ──────────────────────────────────────────────────
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
          Text(
            l10n.withdrawalCompleteTitle,
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
          Text(
            l10n.withdrawalCompleteSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13,
              color: OpeiBrand.inkSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          // ── Transaction details ──────────────────────────────────────
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
                    label: l10n.referenceLabel,
                    reference: result.reference,
                  ),
                ),
                const _Divider(),
                _PreviewRow(
                  label: l10n.statusLabel,
                  value: _titleCase(result.status, l10n),
                ),
                const _Divider(),
                _PreviewRow(
                  label: l10n.amountLabel,
                  value: result.amountMoney.format(includeCurrencySymbol: true),
                ),
                const _Divider(),
                _PreviewRow(
                  label: l10n.feeRow,
                  value: result.feeMoney.format(includeCurrencySymbol: true),
                ),
                const _Divider(),
                _PreviewRow(
                  label: l10n.youWillReceiveRow,
                  value: result.netMoney.format(includeCurrencySymbol: true),
                  isEmphasis: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(onPressed: () => context.pop(), label: l10n.doneCta),
        ],
      );
    }

    // ── Failure state ───────────────────────────────────────────────────
    return Column(
      key: const ValueKey('withdraw-result-step-failure'),
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
        Text(
          l10n.withdrawalFailedTitle,
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
              : l10n.withdrawalFailedSubtitle,
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
          onPressed: () =>
              ref.read(cardWithdrawControllerProvider.notifier).goBack(),
          label: l10n.tryAgainCta,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            foregroundColor: OpeiBrand.inkSecondary,
          ),
          child: Text(
            l10n.closeCta,
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

  String _titleCase(String value, AppLocalizations l10n) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return l10n.pendingStatus;
    return trimmed
        .toLowerCase()
        .split(RegExp(r'[_\s]+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }
}

class _HeroAmount extends StatelessWidget {
  final String amount;
  const _HeroAmount({required this.amount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          Text(
            l10n.youAreWithdrawingLabel,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
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
                fontFamily: kPrimaryFontFamily,
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
          fontFamily: kPrimaryFontFamily,
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
              fontFamily: kPrimaryFontFamily,
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
                  fontFamily: kPrimaryFontFamily,
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
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCta),
          ),
        ),
        child: isBusy
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
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

enum _BannerVariant { info, warning }

class _StatusBanner extends StatelessWidget {
  final String message;
  final _BannerVariant variant;

  const _StatusBanner({
    required this.message,
    this.variant = _BannerVariant.info,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWarning = variant == _BannerVariant.warning;

    final Color background;
    final Color foreground;
    final IconData icon;

    if (isWarning) {
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
