import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/money/money.dart';
import 'package:tt1/data/models/virtual_card.dart';
import 'package:tt1/features/cards/card_topup_controller.dart';
import 'package:tt1/features/cards/card_topup_state.dart';
import 'package:tt1/theme.dart';
import 'package:tt1/widgets/reference_copy_value.dart';
import 'package:tt1/widgets/success_hero.dart';

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
      child: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiColors.grey300,
                  borderRadius: BorderRadius.circular(2),
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
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
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
                  fontSize: 18,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 40,
          child: IconButton(
            icon: const Icon(CupertinoIcons.xmark, size: 18),
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

class _AmountStep extends ConsumerWidget {
  final TextEditingController controller;
  final CardTopUpState state;

  const _AmountStep({required this.controller, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      key: const ValueKey('amount-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Enter the amount',
          style: theme.textTheme.bodyMedium?.copyWith(
                color: OpeiColors.grey600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: OpeiColors.grey100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(
                state.currency.toUpperCase(),
                style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: OpeiColors.grey600,
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !state.isPreviewLoading,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                  cursorColor: OpeiColors.pureBlack,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (_) => ref.read(cardTopUpControllerProvider.notifier).clearErrorMessage(),
                  onSubmitted: (_) => _submit(ref, state.currency),
                ),
              ),
            ],
          ),
        ),
        if (state.errorMessage?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _ErrorBanner(message: state.errorMessage!),
        ],
        const SizedBox(height: 20),
        _PrimaryButton(
          onPressed: state.isPreviewLoading ? null : () => _submit(ref, state.currency),
          label: 'Preview',
          isLoading: state.isPreviewLoading,
        ),
      ],
    );
  }

  void _submit(WidgetRef ref, String currency) {
    FocusManager.instance.primaryFocus?.unfocus();
    final raw = controller.text.trim();
    final money = Money.parse(raw.isEmpty ? '0' : raw, currency: currency);
    ref.read(cardTopUpControllerProvider.notifier).previewTopUp(money);
  }
}

class _PreviewStep extends ConsumerWidget {
  final CardTopUpState state;

  const _PreviewStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final preview = state.preview;

    if (preview == null) {
      return Column(
        key: const ValueKey('preview-step-empty'),
        children: [
          const SizedBox(height: 40),
          const CupertinoActivityIndicator(radius: 14),
          const SizedBox(height: 16),
          Text(
            'Loading preview...',
            style: theme.textTheme.bodyMedium,
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
        const SizedBox(height: 8),
        Text(
          'Review',
          style: theme.textTheme.bodyMedium?.copyWith(
                color: OpeiColors.grey600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: OpeiColors.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _PreviewRow(
                label: 'Top-up amount',
                value: preview.topUpAmountMoney.format(includeCurrencySymbol: true),
              ),
              const SizedBox(height: 10),
              _PreviewRow(
                label: 'Fee',
                value: preview.feeMoney.format(includeCurrencySymbol: true),
              ),
              const SizedBox(height: 10),
              _PreviewRow(
                label: 'Total debit',
                value: preview.totalDebitMoney.format(includeCurrencySymbol: true),
                isEmphasis: true,
              ),
              const SizedBox(height: 10),
              Divider(color: OpeiColors.grey300.withValues(alpha: 0.6)),
              const SizedBox(height: 10),
              _PreviewRow(
                label: 'Wallet balance after',
                value: preview.walletBalanceAfterMoney.format(includeCurrencySymbol: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (infoMessage?.isNotEmpty == true) ...[
          _StatusBanner(
            message: infoMessage!,
            variant: isBlocking ? _BannerVariant.warning : _BannerVariant.error,
          ),
          const SizedBox(height: 12),
        ],
        _PrimaryButton(
          onPressed: (state.isSubmitting || !preview.canTopUp)
              ? null
              : () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await controller.confirmTopUp();
                },
          label: 'Confirm',
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
            padding: const EdgeInsets.symmetric(vertical: 9),
            foregroundColor: OpeiColors.pureBlack,
          ),
          child: Text(
            'Edit amount',
            style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _ResultStep extends ConsumerWidget {
  final CardTopUpState state;

  const _ResultStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final success = state.isSuccess && state.result != null;
    final result = state.result;

    return Column(
      key: const ValueKey('result-step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        if (success) ...[
          const SuccessHero(iconHeight: 56, gap: 2),
          const SizedBox(height: 14),
        ] else ...[
          const Icon(
            Icons.error_rounded,
            size: 48,
            color: OpeiColors.errorRed,
          ),
          const SizedBox(height: 14),
        ],
        Text(
          success ? 'Top-up in progress' : 'Top-up failed',
          style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        if (success && result != null)
          Text(
            'Processing ${result.amountMoney.format(includeCurrencySymbol: true)}',
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: OpeiColors.grey600,
                  fontSize: 13,
                ),
            textAlign: TextAlign.center,
          )
        else if (state.errorMessage?.isNotEmpty == true)
          Text(
            state.errorMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: OpeiColors.grey600,
                  fontSize: 13,
                ),
            textAlign: TextAlign.center,
          )
        else
          Text(
            'Unable to complete top-up. Try again.',
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: OpeiColors.grey600,
                  fontSize: 13,
                ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 20),
        if (success && result != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OpeiColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ReferenceCopyValue(
                  label: 'Reference',
                  reference: result.reference,
                ),
                const SizedBox(height: 8),
                Divider(color: OpeiColors.grey300.withValues(alpha: 0.6)),
                const SizedBox(height: 8),
                _PreviewRow(
                  label: 'Amount',
                  value: result.amountMoney.format(includeCurrencySymbol: true),
                ),
                const SizedBox(height: 6),
                _PreviewRow(
                  label: 'Fee',
                  value: result.feeMoney.format(includeCurrencySymbol: true),
                ),
                const SizedBox(height: 6),
                _PreviewRow(
                  label: 'Total debit',
                  value: result.totalDebitMoney.format(includeCurrencySymbol: true),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: _PrimaryButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            label: success ? 'Done' : 'Close',
          ),
        ),
        if (!success) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ref.read(cardTopUpControllerProvider.notifier).goBack();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Text(
              'Try again',
              style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
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
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
                color: isEmphasis ? OpeiColors.pureBlack : OpeiColors.grey600,
                fontWeight: isEmphasis ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isEmphasis ? FontWeight.w600 : FontWeight.w600,
                  fontSize: isEmphasis ? 15 : 13,
                ),
          ),
        ),
      ],
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

    return ElevatedButton(
      onPressed: isBusy ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: OpeiColors.pureBlack,
        foregroundColor: Colors.white,
        disabledBackgroundColor: OpeiColors.grey300,
        disabledForegroundColor: OpeiColors.grey600,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: Colors.white,
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
        color: OpeiColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: OpeiColors.errorRed, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                    color: OpeiColors.errorRed,
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
      background = OpeiColors.errorRed.withValues(alpha: 0.08);
      foreground = OpeiColors.errorRed;
      icon = Icons.error_outline;
    } else if (isWarning) {
      background = const Color(0xFFFFF8E6);
      foreground = const Color(0xFFB25B00);
      icon = Icons.info_outline_rounded;
    } else {
      background = OpeiColors.pureBlack.withValues(alpha: 0.05);
      foreground = OpeiColors.pureBlack;
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