import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/features/cards/card_creation_controller.dart';
import 'package:opei/features/cards/card_creation_state.dart';
import 'package:opei/features/cards/cards_controller.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/success_hero.dart';

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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              FocusScope.of(context).unfocus();
            }
          });
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

    return PopScope(
      canPop: !_isFinishing,
      child: Scaffold(
        backgroundColor: OpeiBrand.surface,
        appBar: AppBar(
          backgroundColor: OpeiBrand.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            _appBarTitle(state.stage),
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.2,
            ),
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
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon/Spinner ───────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: hasError
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          OpeiBrand.primaryGradientStart,
                          OpeiBrand.primaryGradientEnd,
                        ],
                      ),
                color: hasError
                    ? OpeiBrand.danger.withValues(alpha: 0.12)
                    : null,
                shape: BoxShape.circle,
                boxShadow: hasError
                    ? null
                    : [
                        BoxShadow(
                          color: OpeiBrand.primary.withValues(alpha: 0.22),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Center(
                child: isLoading
                    ? const CupertinoActivityIndicator(
                        radius: 13,
                        color: Colors.white,
                      )
                    : Icon(
                        hasError
                            ? Icons.error_outline_rounded
                            : Icons.credit_card_rounded,
                        color: hasError ? OpeiBrand.danger : Colors.white,
                        size: 30,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasError ? "Setup failed" : 'Creating your card',
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.ink,
                letterSpacing: -0.4,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasError
                  ? 'Check the message below and try again.'
                  : 'Preparing your card details.\nThis only takes a moment.',
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: OpeiBrand.inkSecondary,
                letterSpacing: -0.1,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasError) ...[
              const SizedBox(height: 20),
              _MessageBanner(message: state.errorMessage!, isError: true),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => controller.startRegistration(),
                style: FilledButton.styleFrom(
                  backgroundColor: OpeiBrand.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(OpeiBrand.radiusCta),
                  ),
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
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
    final amountText = _amountController.text.trim();
    final parsedAmount =
        double.tryParse(amountText.replaceAll(',', '')) ?? 0;
    final hasAmount = parsedAmount > 0;
    final canContinue = parsedAmount >= 2.00;
    final fmtAmount = _displayAmount(amountText);

    return Form(
      key: _amountFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header label ────────────────────────────────────────────
          const SizedBox(height: 8),
          const Text(
            'Initial load',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: OpeiBrand.ink,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'How much would you like to add to your new card?',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
              height: 1.4,
            ),
          ),

          const Spacer(flex: 3),

          // ── Hero amount ─────────────────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _amountFocusNode.requestFocus(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '\$',
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: hasAmount
                              ? OpeiBrand.ink
                              : OpeiBrand.inkPlaceholder,
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          hasAmount ? fmtAmount : '0',
                          style: TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: hasAmount
                                ? OpeiBrand.ink
                                : OpeiBrand.inkPlaceholder,
                            letterSpacing: -2.0,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        currency,
                        style: const TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: OpeiBrand.inkTertiary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                // Invisible input captures keyboard
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.0,
                    child: TextFormField(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      enabled: !state.isBusy,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      showCursor: false,
                      style: const TextStyle(fontSize: 56),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isCollapsed: true,
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        final sanitized = value?.trim() ?? '';
                        if (sanitized.isEmpty) return 'Enter an amount';
                        final parsed = double.tryParse(
                            sanitized.replaceAll(',', ''));
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid amount';
                        }
                        if (parsed < 2.00) {
                          return 'Minimum deposit is \$2.00';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                      onFieldSubmitted: (_) => _handlePreview(controller),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: AnimatedDefaultTextStyle(
              duration: OpeiBrand.motionFast,
              curve: OpeiBrand.motionCurve,
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: hasAmount && !canContinue
                    ? OpeiBrand.danger
                    : OpeiBrand.inkTertiary,
                letterSpacing: -0.1,
              ),
              child: Text(
                hasAmount && !canContinue
                    ? 'Minimum deposit is \$2.00'
                    : 'Funded from your wallet  •  Min \$2.00',
              ),
            ),
          ),

          const Spacer(flex: 2),

          // ── Quick chips ─────────────────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              children: [
                for (final v in const [10, 25, 50, 100, 250]) ...[
                  _QuickAmountChip(
                    value: v,
                    isSelected: parsedAmount == v.toDouble(),
                    onTap: state.isBusy
                        ? null
                        : () {
                            final formatted = v.toString();
                            _amountController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                  offset: formatted.length),
                            );
                            setState(() {});
                          },
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),

          if (state.errorMessage?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _MessageBanner(message: state.errorMessage!, isError: true),
          ],

          const SizedBox(height: 24),

          FilledButton(
            onPressed: state.isBusy || !canContinue
                ? null
                : () => _handlePreview(controller),
            style: FilledButton.styleFrom(
              backgroundColor: OpeiBrand.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: OpeiBrand.primaryTintStrong,
              disabledForegroundColor:
                  OpeiBrand.primary.withValues(alpha: 0.6),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(OpeiBrand.radiusCta),
              ),
            ),
            child: state.isBusy
                ? const CupertinoActivityIndicator(
                    radius: 11, color: Colors.white)
                : const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  /// Format the amount string with thousands separators while preserving the
  /// trailing decimal as the user types it (e.g. `1234.5` -> `1,234.5`,
  /// `1234.` -> `1,234.`, `1234` -> `1,234`).
  String _displayAmount(String raw) {
    if (raw.isEmpty) return '';
    final trimmed = raw.replaceAll(',', '');
    final parts = trimmed.split('.');
    final intPart = parts.first;
    final decimalPart = parts.length > 1 ? parts.sublist(1).join('') : null;
    final intNumber = int.tryParse(intPart) ?? 0;
    final formattedInt = intNumber.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    if (parts.length == 1) return formattedInt;
    return '$formattedInt.${decimalPart ?? ''}';
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

  Widget _buildPreview(ThemeData theme, CardCreationState state,
      {required bool isProcessing}) {
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

    final hasSufficientBalance =
        preview.canCreate && !preview.walletBalanceAfter.isNegative;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Hero — what the card will receive ──────────────────────────
        Container(
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CARD WILL RECEIVE",
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
                        preview.cardWillReceive
                            .format(includeCurrencySymbol: true),
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
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.credit_card_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── Section: Breakdown ──────────────────────────────────────────
        const _SectionLabel('PAYMENT BREAKDOWN'),
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
                label: 'Initial load',
                value: preview.cardWillReceive
                    .format(includeCurrencySymbol: true),
              ),
              const _PreviewDivider(),
              _PreviewRow(
                label: 'Creation fee',
                value:
                    preview.creationFee.format(includeCurrencySymbol: true),
              ),
              const _PreviewDivider(),
              _PreviewRow(
                label: 'Total to charge',
                value: preview.totalToCharge
                    .format(includeCurrencySymbol: true),
                emphasize: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── Section: Wallet impact ──────────────────────────────────────
        const _SectionLabel('AFTER THIS PAYMENT'),
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
                preview.walletBalanceAfter
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

        if (!hasSufficientBalance) ...[
          const SizedBox(height: 14),
          const _MessageBanner(
            message:
                'Wallet balance is too low to cover this card creation. Top up to continue.',
            isError: true,
          ),
        ],
        if (state.errorMessage?.isNotEmpty == true) ...[
          const SizedBox(height: 14),
          _MessageBanner(message: state.errorMessage!, isError: true),
        ],

        const Spacer(),

        FilledButton(
          onPressed: isProcessing || !hasSufficientBalance
              ? null
              : controller.submitCreation,
          style: FilledButton.styleFrom(
            backgroundColor: OpeiBrand.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: OpeiBrand.primaryTintStrong,
            disabledForegroundColor:
                OpeiBrand.primary.withValues(alpha: 0.6),
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(OpeiBrand.radiusCta),
            ),
          ),
          child: isProcessing
              ? const CupertinoActivityIndicator(
                  radius: 11, color: Colors.white)
              : Text(
                  hasSufficientBalance ? 'Create card' : 'Add funds to continue',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isProcessing ? null : controller.backToAmountEntry,
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
        const SizedBox(height: 4),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              color: emphasize ? OpeiBrand.ink : OpeiBrand.inkSecondary,
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
                  fontSize: emphasize ? 15 : 13.5,
                  fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
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

class _PreviewDivider extends StatelessWidget {
  const _PreviewDivider();
  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        thickness: 0.5,
        color: OpeiBrand.hairline,
        indent: 14,
        endIndent: 14,
      );
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

class _QuickAmountChip extends StatelessWidget {
  final int value;
  final bool isSelected;
  final VoidCallback? onTap;

  const _QuickAmountChip({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: AnimatedContainer(
          duration: OpeiBrand.motionFast,
          curve: OpeiBrand.motionCurve,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected ? OpeiBrand.primary : OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: isSelected
                  ? OpeiBrand.primary
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            '\$$value',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : OpeiBrand.ink,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
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
