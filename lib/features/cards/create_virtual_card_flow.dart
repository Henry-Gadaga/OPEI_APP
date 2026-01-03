import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/money/money.dart';
import 'package:tt1/features/cards/card_creation_controller.dart';
import 'package:tt1/features/cards/card_creation_state.dart';
import 'package:tt1/features/cards/cards_controller.dart';
import 'package:tt1/theme.dart';
import 'package:tt1/widgets/success_hero.dart';

class CreateVirtualCardFlow extends ConsumerStatefulWidget {
  const CreateVirtualCardFlow({super.key});

  @override
  ConsumerState<CreateVirtualCardFlow> createState() => _CreateVirtualCardFlowState();
}

class _CreateVirtualCardFlowState extends ConsumerState<CreateVirtualCardFlow> {
  late final TextEditingController _amountController;
  late final FocusNode _amountFocusNode;
  final _amountFormKey = GlobalKey<FormState>();
  late final ProviderSubscription<CardCreationState> _cardStateSubscription;
  bool _hasCompleted = false;
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _amountFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(cardCreationControllerProvider.notifier);
      controller.reset();
      controller.startRegistration();
    });

    _cardStateSubscription = ref.listenManual<CardCreationState>(
      cardCreationControllerProvider,
      (previous, next) {
        if (!mounted) return;

        if (next.stage == CardCreationStage.success && previous?.stage != CardCreationStage.success) {
          FocusScope.of(context).unfocus();
        }

        if (next.stage == CardCreationStage.amountEntry) {
          final amount = next.amount;
          if (amount != null && amount.cents > 0) {
            final formatted = amount.inMajorUnits.toStringAsFixed(2);
            _amountController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          } else if (next.amount == null) {
            _amountController.clear();
          }
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _cardStateSubscription.close();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cardCreationControllerProvider);
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async => !_isFinishing,
      child: Scaffold(
        backgroundColor: OpeiColors.pureWhite,
        appBar: AppBar(
          backgroundColor: OpeiColors.pureWhite,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            _appBarTitle(state.stage),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Padding(
              key: ValueKey(state.stage),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildStage(state, theme),
            ),
          ),
        ),
      ),
    );
  }

  String _appBarTitle(CardCreationStage stage) {
    switch (stage) {
      case CardCreationStage.registering:
        return 'Setting Up';
      case CardCreationStage.amountEntry:
        return 'Initial Load';
      case CardCreationStage.preview:
      case CardCreationStage.creating:
        return 'Review Details';
      case CardCreationStage.success:
        return 'Card Created';
    }
  }

  Widget _buildStage(CardCreationState state, ThemeData theme) {
    switch (state.stage) {
      case CardCreationStage.registering:
        return _buildRegistering(theme, state);
      case CardCreationStage.amountEntry:
        return _buildAmountEntry(theme, state);
      case CardCreationStage.preview:
        return _buildPreview(theme, state, isProcessing: false);
      case CardCreationStage.creating:
        return _buildPreview(theme, state, isProcessing: true);
      case CardCreationStage.success:
        return _buildSuccess(theme, state);
    }
  }

  Widget _buildRegistering(ThemeData theme, CardCreationState state) {
    final controller = ref.read(cardCreationControllerProvider.notifier);
    final hasError = state.errorMessage?.isNotEmpty == true;
    final isLoading = state.isBusy && !hasError;
    final titleText = hasError ? "We couldn't start card setup" : 'Setting things up';
    final subtitleText = hasError
        ? 'Check the message below and try again.'
        : "We're preparing your card details. This usually takes a few seconds.";

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: OpeiColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isLoading
                    ? const CupertinoActivityIndicator(radius: 14)
                    : Icon(
                        hasError ? Icons.error_outline_rounded : Icons.hourglass_empty_rounded,
                        color: OpeiColors.pureBlack,
                        size: 34,
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              titleText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 19,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitleText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: OpeiColors.iosLabelSecondary,
                height: 1.38,
              ),
              textAlign: TextAlign.center,
            ),
            if (state.errorMessage?.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              _MessageBanner(message: state.errorMessage!, isError: true),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => controller.startRegistration(),
                style: FilledButton.styleFrom(
                  backgroundColor: OpeiColors.pureBlack,
                  foregroundColor: OpeiColors.pureWhite,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountEntry(ThemeData theme, CardCreationState state) {
    final controller = ref.read(cardCreationControllerProvider.notifier);

    final currency = (state.amount?.currency ?? 'USD').toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
          'Add your first funds',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
          'Enter the amount you want to move onto your virtual card. You can top up again at any time.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: OpeiColors.iosLabelSecondary,
                  height: 1.35,
                ),
              ),
        const SizedBox(height: 28),
        Form(
          key: _amountFormKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: OpeiColors.pureWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: OpeiColors.grey200, width: 1),
            ),
            child: Row(
              children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: OpeiColors.iosSurfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currency,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.iosLabelSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      enabled: !state.isBusy,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.left,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: theme.textTheme.displaySmall?.copyWith(
                          color: OpeiColors.grey300,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                        errorStyle: theme.textTheme.bodySmall?.copyWith(
                          color: OpeiColors.errorRed,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        final sanitized = value?.trim() ?? '';
                        if (sanitized.isEmpty) {
                          return 'Enter an amount to continue.';
                        }
                      final parsed =
                          double.tryParse(sanitized.replaceAll(',', ''));
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid amount above 0.00.';
                        }
                        if (parsed < 2.00) {
                          return 'Minimum deposit is \$2.00.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handlePreview(controller),
                  ),
                ),
              ],
            ),
          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Minimum deposit is \$2.00',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: OpeiColors.iosLabelSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
        if (state.errorMessage?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          _MessageBanner(message: state.errorMessage!, isError: true),
        ],
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FilledButton(
            onPressed: state.isBusy ? null : () => _handlePreview(controller),
            style: FilledButton.styleFrom(
              backgroundColor: OpeiColors.pureBlack,
              foregroundColor: OpeiColors.pureWhite,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: state.isBusy
                ? const CupertinoActivityIndicator(radius: 11, color: OpeiColors.pureWhite)
                : const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.1)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _handlePreview(CardCreationController controller) {
    if (_amountFormKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      final sanitized = _amountController.text.trim().replaceAll(',', '');
      final amount = Money.parse(sanitized.isEmpty ? '0' : sanitized);
      controller.loadPreview(amount);
    }
  }

  Future<void> _handleSuccessDone(CardCreationState state) async {
    if (_hasCompleted || _isFinishing) {
      return;
    }

    setState(() => _isFinishing = true);
    FocusScope.of(context).unfocus();

    await Future.delayed(const Duration(seconds: 15));

    final cardsController = ref.read(cardsControllerProvider.notifier);
    try {
      await cardsController.refresh();
    } catch (_) {
      // Silent catch — navigating back still returns control to cards screen which will surface errors if needed.
    }

    final creation = state.creation;
    final createdCardId = creation?.cardId.trim() ?? '';
    if (createdCardId.isNotEmpty) {
      await cardsController.preloadCardDetails(createdCardId, reveal: true);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _hasCompleted = true;
      _isFinishing = false;
    });

    if (creation != null) {
      Navigator.of(context).pop(creation);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Widget _buildPreview(ThemeData theme, CardCreationState state, {required bool isProcessing}) {
    final preview = state.preview;
    final controller = ref.read(cardCreationControllerProvider.notifier);

    if (preview == null) {
      return Center(
        child: Text(
          'Preview details unavailable. Please go back and try again.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    final hasSufficientBalance = preview.canCreate && !preview.walletBalanceAfter.isNegative;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: isProcessing ? null : controller.backToAmountEntry,
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text('Edit amount'),
              style: TextButton.styleFrom(
                foregroundColor: OpeiColors.pureBlack,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            if (state.amount != null)
              Text(
                state.amount!.format(includeCurrencySymbol: true),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 18),
              _PreviewRow(label: 'Card receives', value: preview.cardWillReceive.format(includeCurrencySymbol: true)),
              const SizedBox(height: 12),
              _PreviewRow(
                label: 'Creation fee',
                value: preview.creationFee.format(includeCurrencySymbol: true),
              ),
              const SizedBox(height: 12),
              _PreviewRow(
                label: 'Total to charge',
                value: preview.totalToCharge.format(includeCurrencySymbol: true),
                emphasize: true,
              ),
              const SizedBox(height: 12),
              _PreviewRow(
                label: 'Wallet balance after',
                value: preview.walletBalanceAfter.format(includeCurrencySymbol: true),
              ),
            ],
          ),
        ),
        if (!hasSufficientBalance) ...[
          const SizedBox(height: 20),
          const _MessageBanner(
            message: 'Wallet balance is too low to cover this card creation. Please add funds and try again.',
            isError: true,
          ),
        ],
        if (state.errorMessage?.isNotEmpty == true) ...[
          const SizedBox(height: 20),
          _MessageBanner(message: state.errorMessage!, isError: true),
        ],
        const Spacer(),
        FilledButton(
          onPressed: isProcessing || !hasSufficientBalance ? null : controller.submitCreation,
          style: FilledButton.styleFrom(
            backgroundColor: OpeiColors.pureBlack,
            foregroundColor: OpeiColors.pureWhite,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isProcessing
              ? const CupertinoActivityIndicator(radius: 11, color: OpeiColors.pureWhite)
              : Text(hasSufficientBalance ? 'Create card' : 'Add funds to continue'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSuccess(ThemeData theme, CardCreationState state) {
    final isHydrating = state.isBusy;
    final canFinish = !isHydrating && !_isFinishing;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            const SuccessHero(iconHeight: 80, gap: 8),
            const SizedBox(height: 32),
            Text(
              'Virtual card created',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Your card is ready to use',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: OpeiColors.iosLabelSecondary,
                  height: 1.4,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FilledButton(
                onPressed: canFinish
                    ? () {
                        unawaited(_handleSuccessDone(state));
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: OpeiColors.pureBlack,
                  foregroundColor: OpeiColors.pureWhite,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isFinishing
                    ? const CupertinoActivityIndicator(radius: 11, color: OpeiColors.pureWhite)
                    : const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        if (_isFinishing) ...[
          const Positioned.fill(
            child: ModalBarrier(
              color: Colors.white,
              dismissible: false,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CupertinoActivityIndicator(
                    radius: 16,
                    color: OpeiColors.pureBlack,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Setting up your card. This will take less than 30 seconds.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: OpeiColors.pureBlack,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
  final bool emphasize;

  const _PreviewRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: emphasize ? OpeiColors.pureBlack : OpeiColors.iosLabelSecondary,
      fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
    );
    final valueStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
      fontSize: emphasize ? 20 : 16,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageBanner({required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isError ? OpeiColors.errorRed : OpeiColors.pureBlack;
    final background = isError ? OpeiColors.errorRed.withValues(alpha: 0.08) : OpeiColors.grey100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isError ? Icons.error_outline : Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
