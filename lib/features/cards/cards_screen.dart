import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/card_details.dart';
import 'package:opei/data/models/promo_card_create_result.dart';
import 'package:opei/data/models/virtual_card.dart';
import 'package:opei/features/cards/card_colors.dart';
import 'package:opei/features/cards/card_transactions_screen.dart';
import 'package:opei/features/cards/cards_controller.dart';
import 'package:opei/features/cards/create_virtual_card_flow.dart';
import 'package:opei/features/cards/card_topup_sheet.dart';
import 'package:opei/features/cards/card_withdraw_sheet.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/money_movement/availability_controller.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/responsive/responsive_tokens.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';

Route<PromoCardCreateResult?> _buildCreateCardFlowRoute() {
  return PageRouteBuilder<PromoCardCreateResult?>(
    pageBuilder: (_, animation, secondaryAnimation) =>
        const CreateVirtualCardFlow(),
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    fullscreenDialog: true,
    transitionsBuilder: (_, animation, secondaryAnimation, child) => child,
  );
}

class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardsControllerProvider.notifier).ensureLoaded();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cardsState = ref.watch(cardsControllerProvider);
    final availability = availabilityFromAsync(
      ref.watch(moneyMovementAvailabilityProvider),
    );
    final cardAvailability = availability.cards;
    final isInitialLoading = cardsState.isLoading && !cardsState.hasLoaded;
    final rawError = cardsState.error;
    final normalizedError = rawError?.trim() ?? '';
    final hasError = rawError != null;
    final resolvedErrorMessage = hasError
        ? (normalizedError.isNotEmpty
              ? normalizedError
              : l10n.cardsLoadFailedMessage)
        : null;
    final showErrorBanner = hasError && cardsState.cards.isNotEmpty;
    final showErrorState =
        hasError &&
        cardsState.cards.isEmpty &&
        cardsState.hasLoaded &&
        !cardsState.isLoading;
    final showEmptyState =
        cardsState.hasLoaded &&
        cardsState.cards.isEmpty &&
        !hasError &&
        !cardsState.isLoading;
    final showCardList = cardsState.cards.isNotEmpty;
    final showBlockingLoader =
        cardsState.isLoading && cardsState.cards.isEmpty && !showErrorState;
    final showHeaderCreateButton =
        cardsState.hasLoaded &&
        !cardsState.isLoading &&
        cardAvailability.creation.enabled;

    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final scrollPhysics = AlwaysScrollableScrollPhysics(
      parent: isCupertino
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
    );

    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;

    return ResponsiveScaffold(
      useSafeArea: false,
      padding: EdgeInsets.zero,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          displacement: 25,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          color: OpeiColors.pureBlack,
          backgroundColor: OpeiColors.pureWhite,
          child: SingleChildScrollView(
            physics: scrollPhysics,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: spacing),
                  SizedBox(
                    height: 28,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            l10n.dashboardNavCards,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: showHeaderCreateButton
                              ? GestureDetector(
                                  onTap: () async {
                                    await _startCardCreationFlow();
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: OpeiBrand.primary,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: OpeiBrand.primary.withValues(
                                            alpha: 0.25,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                )
                              : const SizedBox(width: 32, height: 32),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (showErrorBanner && resolvedErrorMessage != null) ...[
                    _CardsMessageBanner(
                      message: resolvedErrorMessage,
                      onRetry: () =>
                          ref.read(cardsControllerProvider.notifier).refresh(),
                    ),
                    SizedBox(height: spacing * 2.5),
                  ],
                  if (isInitialLoading) ...[
                    const _CardsLoadingPlaceholder(),
                    SizedBox(height: spacing * 3),
                  ] else if (showCardList) ...[
                    _UserCardsCarousel(
                      cards: cardsState.cards,
                      pageController: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      detailsById: cardsState.detailsById,
                      revealedCardIds: cardsState.revealedCardIds,
                      loadingCardIds: cardsState.detailLoadingIds,
                      onToggleDetails: _handleToggleCardDetails,
                      onCopyValue: _copyToClipboard,
                    ),
                    SizedBox(height: spacing * 1.5),
                    if (cardsState.cards.length > 1)
                      _CarouselPageIndicator(
                        itemCount: cardsState.cards.length,
                        currentIndex: _currentPage,
                      ),
                    if (cardsState.cards.length > 1)
                      SizedBox(height: spacing * 2),
                    if (cardsState.cards.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          final cappedIndex = math.min(
                            _currentPage,
                            cardsState.cards.length - 1,
                          );
                          final selectedCard = cardsState.cards[cappedIndex];
                          final isBusy = cardsState.actionInFlightIds.contains(
                            selectedCard.id.trim(),
                          );

                          return _CardActionsRow(
                            card: selectedCard,
                            onTransactionsTap: () => _openTransactions(
                              cardsState.cards,
                              cappedIndex,
                            ),
                            onFreezeTap: () => _handleFreezeCard(selectedCard),
                            onUnfreezeTap: () =>
                                _handleUnfreezeCard(selectedCard),
                            onTopUpTap: () => _handleTopUp(selectedCard),
                            onWithdrawTap: () => _handleWithdraw(selectedCard),
                            onTerminateTap: () =>
                                _handleTerminateCard(selectedCard),
                            isBusy: isBusy,
                            topUpEnabled: cardAvailability.topUp.enabled,
                            withdrawEnabled:
                                cardAvailability.withdrawal.enabled,
                          );
                        },
                      ),
                    ],
                    SizedBox(height: spacing * 2.25),
                  ] else if (showErrorState &&
                      resolvedErrorMessage != null) ...[
                    _CardsErrorPlaceholder(
                      message: resolvedErrorMessage,
                      onRetry: () =>
                          ref.read(cardsControllerProvider.notifier).refresh(),
                    ),
                    SizedBox(height: spacing * 3),
                  ] else if (showBlockingLoader) ...[
                    const _CardsLoadingPlaceholder(),
                    SizedBox(height: spacing * 3),
                  ] else if (showEmptyState) ...[
                    _CardsEmptyState(
                      onCreateCard: _startCardCreationFlow,
                      creationEnabled: cardAvailability.creation.enabled,
                    ),
                    SizedBox(height: spacing * 2),
                  ] else ...[
                    SizedBox(height: spacing * 1.5),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      ref.read(cardsControllerProvider.notifier).refresh(),
      ref
          .read(dashboardControllerProvider.notifier)
          .refreshBalance(showSpinner: false),
    ]);
  }

  Future<void> _startCardCreationFlow() async {
    final l10n = AppLocalizations.of(context)!;
    final availability = availabilityFromWidgetRef(ref);
    if (!availability.cards.creation.enabled) {
      showError(context, l10n.errServiceUnavailable);
      return;
    }

    final creation = await Navigator.of(
      context,
    ).push<PromoCardCreateResult?>(_buildCreateCardFlowRoute());

    if (!mounted || creation == null) {
      return;
    }

    await ref.read(cardsControllerProvider.notifier).refresh();

    if (!mounted) {
      return;
    }

    final updatedState = ref.read(cardsControllerProvider);
    final cards = updatedState.cards;

    if (cards.isEmpty) {
      showSuccess(context, l10n.cardsVirtualReadyMessage);
      return;
    }

    final createdCardId = creation.cardId.trim();
    var targetIndex = createdCardId.isEmpty
        ? cards.length - 1
        : cards.indexWhere((card) => card.id.trim() == createdCardId);

    if (targetIndex < 0) {
      targetIndex = cards.length - 1;
    }

    if (targetIndex < 0) {
      targetIndex = 0;
    }

    setState(() {
      _currentPage = targetIndex;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final maxIndex = cards.length - 1;
      if (targetIndex < 0 || targetIndex > maxIndex) {
        return;
      }

      _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });

    showSuccess(context, l10n.cardsVirtualReadyMessage);
  }

  void _openTransactions(List<VirtualCard> cards, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            CardTransactionsScreen(cards: cards, initialIndex: initialIndex),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
      ),
    );
  }

  Future<void> _copyToClipboard(String label, String value) async {
    final l10n = AppLocalizations.of(context)!;
    final sanitized = value.replaceAll(' ', '').trim();
    if (sanitized.isEmpty ||
        sanitized.contains('•') ||
        sanitized == '—' ||
        sanitized == '***') {
      return;
    }

    await Clipboard.setData(ClipboardData(text: value));
    await HapticFeedback.selectionClick();

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.cardsValueCopied(label)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleFreezeCard(VirtualCard card) async {
    final result = await ref
        .read(cardsControllerProvider.notifier)
        .freezeCard(card);

    if (!mounted) {
      return;
    }

    if (result.hasError) {
      showError(context, result.error!);
      return;
    }

    if (result.hasMessage) {
      showSuccess(context, result.message!);
    }
  }

  Future<void> _handleUnfreezeCard(VirtualCard card) async {
    final result = await ref
        .read(cardsControllerProvider.notifier)
        .unfreezeCard(card);

    if (!mounted) {
      return;
    }

    if (result.hasError) {
      showError(context, result.error!);
      return;
    }

    if (result.hasMessage) {
      showSuccess(context, result.message!);
    }
  }

  Future<void> _handleTopUp(VirtualCard card) async {
    final l10n = AppLocalizations.of(context)!;
    final availability = availabilityFromWidgetRef(ref);
    if (!availability.cards.topUp.enabled) {
      showError(context, l10n.errServiceUnavailable);
      return;
    }

    final cardId = card.id.trim();
    if (cardId.isEmpty) {
      showError(context, l10n.cardsNotFoundError);
      return;
    }

    await showResponsiveBottomSheet<void>(
      context: context,
      dismissOnBarrierTap: true,
      builder: (_) => CardTopUpSheet(card: card),
    );
  }

  Future<void> _handleWithdraw(VirtualCard card) async {
    final l10n = AppLocalizations.of(context)!;
    final availability = availabilityFromWidgetRef(ref);
    if (!availability.cards.withdrawal.enabled) {
      showError(context, l10n.errServiceUnavailable);
      return;
    }

    final cardId = card.id.trim();
    if (cardId.isEmpty) {
      showError(context, l10n.cardsNotFoundError);
      return;
    }

    await showResponsiveBottomSheet<void>(
      context: context,
      dismissOnBarrierTap: true,
      builder: (_) => CardWithdrawSheet(card: card),
    );
  }

  Future<void> _handleTerminateCard(VirtualCard card) async {
    final confirmed = await _confirmTerminateDialog(card);
    if (!confirmed) {
      return;
    }

    final result = await ref
        .read(cardsControllerProvider.notifier)
        .terminateCard(card);

    if (!mounted) {
      return;
    }

    if (result.hasError) {
      showError(context, result.error!);
      return;
    }

    if (result.hasMessage) {
      showSuccess(context, result.message!);
    }
  }

  Future<bool> _confirmTerminateDialog(VirtualCard card) async {
    final result = await showResponsiveBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => _TerminateConfirmationSheet(
        cardName: card.cardName.isNotEmpty
            ? card.cardName
            : AppLocalizations.of(context)!.cardsVirtualCardLabel,
        lastFour: card.last4,
      ),
    );

    return result ?? false;
  }

  Future<void> _handleToggleCardDetails(VirtualCard card) async {
    final message = await ref
        .read(cardsControllerProvider.notifier)
        .toggleCardDetails(card);
    if (!mounted || message == null || message.trim().isEmpty) {
      return;
    }
    showError(context, message);
  }
}

class _CardsMessageBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CardsMessageBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: OpeiColors.errorRed,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: OpeiBrand.primary,
                backgroundColor: OpeiBrand.primaryTint,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              child: Text(l10n.retryCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _TerminateConfirmationSheet extends StatelessWidget {
  final String cardName;
  final String? lastFour;

  const _TerminateConfirmationSheet({required this.cardName, this.lastFour});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cardLabel = (lastFour == null || lastFour!.isEmpty)
        ? cardName
        : '$cardName ·•••• ${lastFour!}';

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: OpeiColors.iosSeparator.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: OpeiColors.errorRed.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline,
              size: 28,
              color: OpeiColors.errorRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.cardsTerminateConfirmTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.cardsTerminateConfirmSubtitle(cardLabel),
            style: textTheme.bodyMedium?.copyWith(
              color: OpeiColors.iosLabelSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: OpeiColors.errorRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.cardsTerminateMoveFundsWarning,
                    style: textTheme.bodySmall?.copyWith(
                      color: OpeiColors.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    backgroundColor: OpeiColors.grey100,
                    foregroundColor: OpeiColors.pureBlack,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n.cardsKeepCardCta),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: OpeiColors.errorRed,
                    foregroundColor: OpeiColors.pureWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n.cardsTerminateCta),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardsLoadingPlaceholder extends StatelessWidget {
  const _CardsLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: OpeiColors.grey100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const CupertinoActivityIndicator(radius: 14),
      ),
    );
  }
}

class _CardsErrorPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CardsErrorPlaceholder({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: OpeiColors.errorRed.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off_outlined,
              size: 34,
              color: OpeiColors.errorRed,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.genericIssueTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: OpeiColors.pureBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                height: 1.35,
                color: OpeiColors.pureBlack,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  backgroundColor: OpeiBrand.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                child: Text(l10n.retryCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCardsCarousel extends StatelessWidget {
  final List<VirtualCard> cards;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final Map<String, CardDetails> detailsById;
  final Set<String> revealedCardIds;
  final Set<String> loadingCardIds;
  final Future<void> Function(VirtualCard card) onToggleDetails;
  final Future<void> Function(String label, String value) onCopyValue;

  const _UserCardsCarousel({
    required this.cards,
    required this.pageController,
    required this.onPageChanged,
    required this.detailsById,
    required this.revealedCardIds,
    required this.loadingCardIds,
    required this.onToggleDetails,
    required this.onCopyValue,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScale = mediaQuery.textScaler.scale(1.0).clamp(1.0, 1.35);
    const baseHeight = 228.0;
    final maxResponsiveHeight = math.max(
      baseHeight,
      mediaQuery.size.height * 0.45,
    );
    final cardHeight = (baseHeight * textScale).clamp(
      baseHeight,
      maxResponsiveHeight,
    );

    return SizedBox(
      height: cardHeight,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemCount: cards.length,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final card = cards[index];
          final cardId = card.id.trim();
          final details = cardId.isEmpty ? null : detailsById[cardId];
          final isRevealed =
              cardId.isNotEmpty && revealedCardIds.contains(cardId);
          final isLoading =
              cardId.isNotEmpty && loadingCardIds.contains(cardId);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _UserCardView(
              card: card,
              index: index,
              details: details,
              isRevealed: isRevealed,
              isLoading: isLoading,
              onToggleDetails: onToggleDetails,
              onCopyValue: onCopyValue,
            ),
          );
        },
      ),
    );
  }
}

class _UserCardView extends StatelessWidget {
  final VirtualCard card;
  final int index;
  final CardDetails? details;
  final bool isRevealed;
  final bool isLoading;
  final Future<void> Function(VirtualCard card)? onToggleDetails;
  final Future<void> Function(String label, String value) onCopyValue;

  const _UserCardView({
    required this.card,
    required this.index,
    required this.details,
    required this.isRevealed,
    required this.isLoading,
    required this.onToggleDetails,
    required this.onCopyValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusLabel = _formatStatus(card.status);
    final statusColor = _statusColor(statusLabel);
    final showDetails = isRevealed && details != null;

    final normalizedPan = _normalizeDigitsWithFallback(
      details?.cardNumber ?? '',
      fallback: card.last4,
    );
    final panGroups = _splitIntoGroups(normalizedPan);
    final cvvRevealed = _formatRevealedCvv(
      details?.cvv ?? '',
      fallback: card.cvv,
    );
    final cvvMasked = _maskCvv(card.cvv);
    final balanceRevealed = _formatRevealedBalance(
      details?.balance ?? card.balance,
    );
    final balanceMasked = _maskBalance(card.balance);

    final copyableCardNumber = showDetails
        ? _normalizeCardNumberForCopy(details!.cardNumber, fallback: card.last4)
        : '';
    final copyableCvv = showDetails ? _normalizeCvvForCopy(details!.cvv) : '';
    final rawExpiry = card.expiry?.trim() ?? '';
    final expiryLabel = rawExpiry.isEmpty ? '—' : rawExpiry;
    final copyableExpiry = showDetails && rawExpiry.isNotEmpty ? rawExpiry : '';
    final addressData = _buildAddressData(card);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _gradientColors(card, index),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          card.cardName.isNotEmpty
                              ? card.cardName
                              : l10n.cardsVirtualCardLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: OpeiColors.pureWhite,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (addressData != null) ...[
                          const SizedBox(height: 10),
                          _CardAddressPreview(
                            label: l10n.addressLabel,
                            preview: addressData.preview,
                            isPlaceholder: addressData.isPlaceholder,
                            onTap: () =>
                                _showAddressSheet(context, addressData),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CardStatusPill(label: statusLabel, color: statusColor),
                      const SizedBox(height: 12),
                      _CardRevealButton(
                        isLoading: isLoading,
                        isRevealed: isRevealed,
                        onPressed: onToggleDetails == null
                            ? null
                            : () => onToggleDetails!(card),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _CardPanDisplay(
                      groups: panGroups,
                      isRevealed: showDetails,
                      textStyle:
                          theme.textTheme.titleLarge?.copyWith(
                            color: OpeiColors.pureWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 3.0,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ) ??
                          const TextStyle(
                            color: OpeiColors.pureWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 3.0,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: copyableCardNumber.isNotEmpty
                        ? _CopyIconButton(
                            label: l10n.cardsCardNumberLabel,
                            onPressed: () => onCopyValue(
                              l10n.cardsCardNumberLabel,
                              copyableCardNumber,
                            ),
                          )
                        : const _CopyIconPlaceholder(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: _CardInfoColumn(
                            label: l10n.cardsExpiresLabel,
                            value: expiryLabel,
                            animateValue: true,
                            onCopy: copyableExpiry.isNotEmpty
                                ? () => onCopyValue(
                                    l10n.cardsExpiryDateLabel,
                                    copyableExpiry,
                                  )
                                : null,
                            copyLabel: l10n.cardsExpiryDateLabel,
                            reserveCopySlot: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: _CardInfoColumn(
                            label: l10n.cardsCvvLabel,
                            value: cvvRevealed,
                            maskedValue: cvvMasked,
                            isMasked: !showDetails,
                            animateValue: true,
                            onCopy: copyableCvv.isNotEmpty
                                ? () => onCopyValue(
                                    l10n.cardsCvvLabel,
                                    copyableCvv,
                                  )
                                : null,
                            copyLabel: l10n.cardsCvvLabel,
                            reserveCopySlot: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: _CardInfoColumn(
                            label: l10n.walletBalanceRow,
                            value: balanceRevealed,
                            maskedValue: balanceMasked,
                            isMasked: !showDetails,
                            animateValue: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            'VISA',
                            style: TextStyle(
                              color: OpeiColors.pureWhite.withValues(
                                alpha: 0.92,
                              ),
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.4,
                              fontStyle: FontStyle.italic,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isLoading,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              opacity: isLoading ? 1 : 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: OpeiColors.pureBlack.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: OpeiColors.pureWhite.withValues(alpha: 0.18),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CupertinoActivityIndicator(radius: 12),
                        const SizedBox(height: 12),
                        Text(
                          l10n.loadingSecurelyLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: OpeiColors.pureWhite.withValues(alpha: 0.85),
                            fontSize: 12,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _extractDigits(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String _normalizeCardNumberForCopy(String input, {String? fallback}) {
    final digits = _normalizeDigitsWithFallback(input, fallback: fallback);
    return digits.length >= 12 ? digits : '';
  }

  static String _normalizeCvvForCopy(String input) {
    final sanitized = input.replaceAll(RegExp(r'\s'), '').trim();
    return RegExp(r'^[0-9]{3,4}$').hasMatch(sanitized) ? sanitized : '';
  }

  List<Color> _gradientColors(VirtualCard card, int index) {
    final option = CardColorPalette.defaultOption;
    if (option != null) {
      return option.gradient;
    }

    return _fallbackGradients[index % _fallbackGradients.length];
  }

  static const List<List<Color>> _fallbackGradients = [
    [Color(0xFF1A1A1A), Color(0xFF2D2D2D), Color(0xFF000000)],
    [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
    [Color(0xFF2D1B69), Color(0xFF3E2C7F), Color(0xFF221344)],
  ];

  String _formatStatus(String raw) {
    final sanitized = raw.replaceAll('_', ' ').trim();
    if (sanitized.isEmpty) {
      return '—';
    }

    return sanitized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF34D399);
      case 'review':
      case 'pending':
        return const Color(0xFFFBBF24);
      case 'blocked':
      case 'inactive':
        return const Color(0xFFF87171);
      default:
        return OpeiColors.pureWhite.withValues(alpha: 0.75);
    }
  }

  static String _formatRevealedCvv(String rawCvv, {String? fallback}) {
    final sanitized = rawCvv.trim();
    if (sanitized.isEmpty) {
      final fallbackTrimmed = fallback?.trim();
      if (fallbackTrimmed != null && fallbackTrimmed.isNotEmpty) {
        return fallbackTrimmed;
      }
      return '***';
    }
    return sanitized;
  }

  static String _formatRevealedBalance(Money? balance) {
    if (balance == null) {
      return '—';
    }
    return balance.format(includeCurrencySymbol: true);
  }

  static String _maskCvv(String? rawCvv) {
    final sanitized = rawCvv?.trim();
    if (sanitized == null || sanitized.isEmpty) {
      return '***';
    }

    return List.generate(sanitized.length, (_) => '•').join();
  }

  static String _maskBalance(Money? balance) {
    if (balance == null) {
      return '****';
    }

    final formatted = balance.format(includeCurrencySymbol: true);
    return formatted.replaceAll(RegExp(r'[0-9]'), '•');
  }

  static String _normalizeDigitsWithFallback(String input, {String? fallback}) {
    var digits = _extractDigits(input);
    final fallbackDigits = fallback == null ? '' : _extractDigits(fallback);

    if (fallbackDigits.length == 4) {
      if (digits.length >= 4) {
        digits = digits.substring(0, digits.length - 4) + fallbackDigits;
      } else {
        digits = fallbackDigits;
      }
    }

    return digits;
  }

  static List<String> _splitIntoGroups(String digits, [int groupSize = 4]) {
    final sanitized = digits.trim();
    if (sanitized.isEmpty) {
      return [];
    }

    final groups = <String>[];
    for (var i = 0; i < sanitized.length; i += groupSize) {
      final end = math.min(i + groupSize, sanitized.length);
      groups.add(sanitized.substring(i, end));
    }

    return groups;
  }

  static _CardAddressData? _buildAddressData(VirtualCard card) {
    final address = card.address;

    if (address == null) {
      return null;
    }

    String? trimValue(String? value) {
      final trimmed = value?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    }

    final previewParts = <String>[];
    final street = trimValue(address.street);
    final city = trimValue(address.city);
    final state = trimValue(address.state);
    final country = trimValue(address.country);
    final zipCode = trimValue(address.zipCode);
    final countryCode = trimValue(address.countryCode);

    if (street != null) previewParts.add(street);
    if (city != null) previewParts.add(city);
    if (state != null) previewParts.add(state);
    if (country != null) previewParts.add(country);
    if (zipCode != null) previewParts.add(zipCode);

    final preview = previewParts.take(2).join(', ');

    final fullLines = <String>[];
    if (street != null) {
      fullLines.add(street);
    }

    final localityParts = <String>[];
    if (city != null) localityParts.add(city);
    if (state != null) localityParts.add(state);
    if (zipCode != null) localityParts.add(zipCode);
    if (localityParts.isNotEmpty) {
      fullLines.add(localityParts.join(', '));
    }

    if (country != null) {
      if (countryCode != null &&
          !country.toUpperCase().contains(countryCode.toUpperCase())) {
        fullLines.add('$country (${countryCode.toUpperCase()})');
      } else {
        fullLines.add(country);
      }
    }

    final effectivePreview = preview.trim().isNotEmpty
        ? preview.trim()
        : fullLines.join(', ').trim();
    final joinedFull = fullLines.join('\n').trim();
    final effectiveFull = joinedFull.isNotEmpty ? joinedFull : effectivePreview;

    if (effectivePreview.isEmpty && effectiveFull.isEmpty) {
      return null;
    }

    final hasMeaningfulData = [
      street,
      city,
      state,
      country,
      zipCode,
      countryCode,
    ].any((value) => value != null && value.trim().isNotEmpty);

    if (!hasMeaningfulData) {
      return null;
    }

    return _CardAddressData(
      preview: effectivePreview.trim(),
      full: effectiveFull.trim(),
      isPlaceholder: false,
    );
  }

  void _showAddressSheet(BuildContext context, _CardAddressData data) {
    showResponsiveBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final l10n = AppLocalizations.of(sheetContext)!;
        final copyLabel = data.isPlaceholder
            ? l10n.cardsCopySampleAddressCta
            : l10n.cardsCopyAddressCta;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: OpeiColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.cardsAddressTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.pureBlack,
                  ),
                ),
                if (data.isPlaceholder) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.cardsSampleAddressHelper,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: OpeiColors.grey600,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  data.full,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: OpeiColors.pureBlack,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final normalizedCopy = data.full
                            .replaceAll(RegExp(r'\s+'), ' ')
                            .trim();
                        if (normalizedCopy.isEmpty) {
                          return;
                        }
                        Navigator.of(sheetContext).pop();
                        await onCopyValue(
                          l10n.cardsAddressTitle,
                          normalizedCopy,
                        );
                      },
                      icon: const Icon(CupertinoIcons.doc_on_doc),
                      label: Text(copyLabel),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(AppLocalizations.of(context)!.closeCta),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardPanDisplay extends StatelessWidget {
  final List<String> groups;
  final bool isRevealed;
  final TextStyle textStyle;

  const _CardPanDisplay({
    required this.groups,
    required this.isRevealed,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGroups = groups.isEmpty ? ['0000'] : groups;
    final displayGroups = (!isRevealed && effectiveGroups.length < 4)
        ? [
            ...List.filled(4 - effectiveGroups.length, '0000'),
            ...effectiveGroups,
          ]
        : effectiveGroups;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < displayGroups.length; i++) ...[
            _CardPanGroup(
              digits: displayGroups[i],
              isLast: i == displayGroups.length - 1,
              isRevealed: isRevealed,
              textStyle: textStyle,
            ),
            if (i != displayGroups.length - 1) const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }
}

class _CardAddressData {
  final String preview;
  final String full;
  final bool isPlaceholder;

  const _CardAddressData({
    required this.preview,
    required this.full,
    required this.isPlaceholder,
  });
}

class _CardAddressPreview extends StatelessWidget {
  final String label;
  final String preview;
  final VoidCallback? onTap;
  final bool isPlaceholder;

  const _CardAddressPreview({
    required this.label,
    required this.preview,
    this.onTap,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = isPlaceholder
        ? OpeiColors.pureWhite.withValues(alpha: 0.7)
        : OpeiColors.pureWhite.withValues(alpha: 0.92);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, size: 16, color: baseColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label • $preview',
              style:
                  theme.textTheme.bodySmall?.copyWith(
                    color: baseColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ) ??
                  TextStyle(
                    color: baseColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 16, color: baseColor),
        ],
      ),
    );
  }
}

class _CardPanGroup extends StatelessWidget {
  final String digits;
  final bool isLast;
  final bool isRevealed;
  final TextStyle textStyle;

  const _CardPanGroup({
    required this.digits,
    required this.isLast,
    required this.isRevealed,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDigits = digits.isNotEmpty ? digits : '0000';
    final maskLength = effectiveDigits.length;
    final maskText = List.generate(maskLength, (_) => '•').join();

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: SizedBox(
        height: textStyle.fontSize != null ? textStyle.fontSize! * 1.4 : null,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              opacity: (isRevealed || isLast) ? 1 : 0,
              child: Text(effectiveDigits, style: textStyle),
            ),
            if (!isLast)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                opacity: isRevealed ? 0 : 1,
                child: Text(maskText, style: textStyle),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardInfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final String? maskedValue;
  final bool isMasked;
  final bool animateValue;
  final VoidCallback? onCopy;
  final String? copyLabel;
  final bool reserveCopySlot;

  const _CardInfoColumn({
    required this.label,
    required this.value,
    this.maskedValue,
    this.isMasked = false,
    this.animateValue = false,
    this.onCopy,
    this.copyLabel,
    this.reserveCopySlot = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpeiColors.pureWhite.withValues(alpha: 0.55),
              letterSpacing: 0.8,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
          ),
        ),
        const SizedBox(height: 5),
        animateValue
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: _CardInfoValue(
                  key: ValueKey(
                    '$label-$value-${maskedValue ?? ''}-${isMasked ? 'masked' : 'revealed'}',
                  ),
                  value: value,
                  maskedValue: maskedValue,
                  isMasked: isMasked,
                  onCopy: onCopy,
                  copyLabel: copyLabel ?? label,
                  reserveCopySlot: reserveCopySlot,
                ),
              )
            : _CardInfoValue(
                value: value,
                maskedValue: maskedValue,
                isMasked: isMasked,
                onCopy: onCopy,
                copyLabel: copyLabel ?? label,
                reserveCopySlot: reserveCopySlot,
              ),
      ],
    );
  }
}

class _CardInfoValue extends StatelessWidget {
  final String value;
  final String? maskedValue;
  final bool isMasked;
  final VoidCallback? onCopy;
  final String copyLabel;
  final bool reserveCopySlot;

  const _CardInfoValue({
    super.key,
    required this.value,
    this.maskedValue,
    this.isMasked = false,
    this.onCopy,
    required this.copyLabel,
    this.reserveCopySlot = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double valueHeight = 26;
    final hasMasking = maskedValue != null;
    final canCopy = onCopy != null && !isMasked && value.trim().isNotEmpty;
    final needsTrailingSpace = canCopy || reserveCopySlot;

    final baseStyle =
        theme.textTheme.titleSmall?.copyWith(
          color: OpeiColors.pureWhite,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ) ??
        const TextStyle(
          color: OpeiColors.pureWhite,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        );

    Widget buildValueContent() {
      if (!hasMasking) {
        return Text(
          value,
          style: baseStyle,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
        );
      }

      return _MaskedValueText(
        revealedText: value,
        maskedText: maskedValue!,
        isMasked: isMasked,
        style: baseStyle,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const double minWidthForTrailing = 90;
        final hasRoomForTrailing = constraints.maxWidth >= minWidthForTrailing;

        if (!needsTrailingSpace || !hasRoomForTrailing) {
          return SizedBox(
            height: valueHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: buildValueContent(),
              ),
            ),
          );
        }

        return SizedBox(
          height: valueHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: buildValueContent(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              canCopy
                  ? _CopyIconButton(
                      label: AppLocalizations.of(
                        context,
                      )!.copyLabelWithValue(copyLabel),
                      onPressed: onCopy!,
                      size: 24,
                    )
                  : const _CopyIconPlaceholder(size: 24),
            ],
          ),
        );
      },
    );
  }
}

class _MaskedValueText extends StatelessWidget {
  final String revealedText;
  final String maskedText;
  final bool isMasked;
  final TextStyle style;

  const _MaskedValueText({
    required this.revealedText,
    required this.maskedText,
    required this.isMasked,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          opacity: isMasked ? 0 : 1,
          child: Text(
            revealedText,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          opacity: isMasked ? 1 : 0,
          child: Text(
            maskedText,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

class _CopyIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final double size;

  const _CopyIconButton({
    required this.onPressed,
    required this.label,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final dimension = size;
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          color: OpeiColors.pureWhite.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(dimension / 2),
          border: Border.all(
            color: OpeiColors.pureWhite.withValues(alpha: 0.24),
            width: 0.8,
          ),
        ),
        child: Icon(
          CupertinoIcons.doc_on_doc,
          size: dimension * 0.55,
          color: OpeiColors.pureWhite.withValues(alpha: 0.9),
          semanticLabel: label,
        ),
      ),
    );
  }
}

class _CopyIconPlaceholder extends StatelessWidget {
  final double size;

  const _CopyIconPlaceholder({this.size = 26});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size);
  }
}

class _CardRevealButton extends StatelessWidget {
  final bool isLoading;
  final bool isRevealed;
  final Future<void> Function()? onPressed;

  const _CardRevealButton({
    required this.isLoading,
    required this.isRevealed,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final baseColor = OpeiColors.pureWhite.withValues(
      alpha: isRevealed ? 0.24 : 0.16,
    );
    final borderColor = OpeiColors.pureWhite.withValues(alpha: 0.25);

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () async {
              await onPressed!.call();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isRevealed ? 1.1 : 0.8),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('spinner'),
                    width: 14,
                    height: 14,
                    child: CupertinoActivityIndicator(radius: 7),
                  )
                : Icon(
                    isRevealed
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    key: ValueKey(isRevealed ? 'hide' : 'show'),
                    color: OpeiColors.pureWhite.withValues(alpha: 0.92),
                    size: 18,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CardStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _CardStatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = label.trim().isEmpty ? 'Unknown' : label.trim();
    final isUnknown = normalized.toLowerCase() == 'unknown';
    final backgroundColor = isUnknown
        ? OpeiColors.pureWhite.withValues(alpha: 0.18)
        : color.withValues(alpha: 0.18);
    final foregroundColor = isUnknown ? OpeiColors.pureWhite : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ── Cards empty state ────────────────────────────────────────────────────────

class _CardsEmptyState extends StatelessWidget {
  final VoidCallback onCreateCard;
  final bool creationEnabled;

  const _CardsEmptyState({
    required this.onCreateCard,
    required this.creationEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      (
        Icons.subscriptions_outlined,
        l10n.cardsUseCaseSubscriptionsTitle,
        l10n.cardsUseCaseSubscriptionsSubtitle,
      ),
      (
        Icons.shopping_bag_outlined,
        l10n.cardsUseCaseOnlineShoppingTitle,
        l10n.cardsUseCaseOnlineShoppingSubtitle,
      ),
      (
        Icons.flight_outlined,
        l10n.cardsUseCaseTravelTitle,
        l10n.cardsUseCaseTravelSubtitle,
      ),
      (
        Icons.public,
        l10n.cardsUseCaseInternationalTitle,
        l10n.cardsUseCaseInternationalSubtitle,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Card preview ──────────────────────────────────────────
        const SizedBox(height: 8),
        const VirtualCardHero(),
        const SizedBox(height: 24),

        // ── Headline + subtitle ───────────────────────────────────
        Text(
          l10n.cardsEmptyStateTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: OpeiBrand.ink,
            letterSpacing: -0.6,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.cardsEmptyStateSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: OpeiBrand.inkSecondary,
            height: 1.45,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 22),

        // ── CTA button ────────────────────────────────────────────
        // Faded brand-blue background with bright brand-blue label,
        // matching the feature-tile icon style (tint bg + primary fg).
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: creationEnabled ? onCreateCard : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: OpeiBrand.primaryTint,
              foregroundColor: OpeiBrand.primary,
              disabledBackgroundColor: OpeiBrand.surfaceMuted,
              disabledForegroundColor: OpeiBrand.inkTertiary,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: creationEnabled
                      ? OpeiBrand.primary
                      : OpeiBrand.inkTertiary,
                ),
                SizedBox(width: 7),
                Text(
                  l10n.cardsCreateCardCta,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: creationEnabled
                        ? OpeiBrand.primary
                        : OpeiBrand.inkTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── Feature grid (2 × 2) ──────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _FeatureTile(
                icon: features[0].$1,
                title: features[0].$2,
                subtitle: features[0].$3,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FeatureTile(
                icon: features[1].$1,
                title: features[1].$2,
                subtitle: features[1].$3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FeatureTile(
                icon: features[2].$1,
                title: features[2].$2,
                subtitle: features[2].$3,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FeatureTile(
                icon: features[3].$1,
                title: features[3].$2,
                subtitle: features[3].$3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: OpeiBrand.primaryTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: OpeiBrand.primary),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.2,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class VirtualCardHero extends StatelessWidget {
  const VirtualCardHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        child: AspectRatio(
          aspectRatio: 1.586,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Soft brand glow under the card
              Positioned(
                left: 14,
                right: 14,
                bottom: -6,
                top: 14,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F4DA2).withValues(alpha: 0.24),
                        blurRadius: 26,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                ),
              ),
              // Card body — mirrors the default branded gradient
              // used after a card is created (CardColorPalette.defaultOption)
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF5AA9F5), // sky highlight
                      Color(0xFF1F7BDF), // mid brand blue
                      Color(0xFF0F4DA2), // deep navy base
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Decorative diagonal sheen
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      left: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Top row: Opei logo + chip + VISA
                    Positioned(
                      top: 22,
                      left: 22,
                      right: 22,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Opei',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 30,
                            height: 22,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFEED88A), Color(0xFFB6892E)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'VISA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Card number
                    Positioned(
                      bottom: 56,
                      left: 22,
                      right: 22,
                      child: Text(
                        '••••  ••••  ••••  ••••',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.95),
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    // Bottom row: holder + expiry placeholders
                    Positioned(
                      bottom: 18,
                      left: 22,
                      right: 22,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.cardsHolderLabel.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.cardsYourNamePlaceholder,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.cardsExpiresLabel.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                '••/••',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardUseCasesList extends StatelessWidget {
  const CardUseCasesList({super.key});

  @override
  Widget build(BuildContext context) {
    final useCases = [
      CardUseCase(
        icon: Icons.subscriptions_outlined,
        title: AppLocalizations.of(context)!.cardsUseCaseSubscriptionsTitle,
        subtitle: AppLocalizations.of(
          context,
        )!.cardsUseCaseSubscriptionsSubtitle,
      ),
      CardUseCase(
        icon: Icons.shopping_bag_outlined,
        title: AppLocalizations.of(context)!.cardsUseCaseOnlineShoppingTitle,
        subtitle: AppLocalizations.of(
          context,
        )!.cardsUseCaseOnlineShoppingSubtitle,
      ),
      CardUseCase(
        icon: Icons.flight_outlined,
        title: AppLocalizations.of(context)!.cardsUseCaseTravelTitle,
        subtitle: AppLocalizations.of(context)!.cardsUseCaseTravelSubtitle,
      ),
      CardUseCase(
        icon: Icons.games_outlined,
        title: AppLocalizations.of(context)!.cardsUseCaseGamingTitle,
        subtitle: AppLocalizations.of(context)!.cardsUseCaseGamingSubtitle,
      ),
      CardUseCase(
        icon: Icons.public,
        title: AppLocalizations.of(context)!.cardsUseCaseInternationalTitle,
        subtitle: AppLocalizations.of(
          context,
        )!.cardsUseCaseInternationalSubtitle,
      ),
      CardUseCase(
        icon: Icons.shield_outlined,
        title: AppLocalizations.of(context)!.cardsUseCaseSecureTitle,
        subtitle: AppLocalizations.of(context)!.cardsUseCaseSecureSubtitle,
      ),
    ];

    return Column(
      children: useCases.asMap().entries.map((entry) {
        final index = entry.key;
        final useCase = entry.value;
        final isLast = index == useCases.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
          child: UseCaseTile(useCase: useCase),
        );
      }).toList(),
    );
  }
}

class CardUseCase {
  final IconData icon;
  final String title;
  final String subtitle;

  CardUseCase({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class UseCaseTile extends StatelessWidget {
  final CardUseCase useCase;

  const UseCaseTile({super.key, required this.useCase});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: OpeiBrand.primaryTint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(useCase.icon, size: 19, color: OpeiBrand.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    useCase.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    useCase.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: OpeiBrand.inkSecondary,
                      letterSpacing: -0.1,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarouselPageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const _CarouselPageIndicator({
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isActive ? 20 : 8,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? OpeiColors.pureBlack : OpeiColors.grey300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _CardActionsRow extends StatelessWidget {
  final VirtualCard card;
  final VoidCallback? onTransactionsTap;
  final VoidCallback? onFreezeTap;
  final VoidCallback? onUnfreezeTap;
  final VoidCallback? onTopUpTap;
  final VoidCallback? onWithdrawTap;
  final VoidCallback? onTerminateTap;
  final bool isBusy;
  final bool topUpEnabled;
  final bool withdrawEnabled;

  const _CardActionsRow({
    required this.card,
    this.onTransactionsTap,
    this.onFreezeTap,
    this.onUnfreezeTap,
    this.onTerminateTap,
    this.onTopUpTap,
    this.onWithdrawTap,
    this.isBusy = false,
    this.topUpEnabled = true,
    this.withdrawEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = card.status.trim();
    final normalizedStatus = status.toLowerCase();
    final isLocked = _statusIndicatesLocked(normalizedStatus);
    final isTerminated = _statusIndicatesTerminated(normalizedStatus);
    final showFreezeAction = !isLocked && !isTerminated;
    final showUnfreezeAction = isLocked && !isTerminated;

    final actions = <_CardActionConfig>[
      _CardActionConfig(
        icon: Icons.add_circle_outline,
        label: l10n.cardsTopUpAction,
        onTap: (isTerminated || isBusy || !topUpEnabled) ? null : onTopUpTap,
      ),
      _CardActionConfig(
        icon: Icons.arrow_circle_up_outlined,
        label: l10n.cardsWithdrawAction,
        onTap: (isTerminated || !withdrawEnabled) ? null : onWithdrawTap,
      ),
      _CardActionConfig(
        icon: Icons.receipt_long_outlined,
        label: l10n.cardsTransactionsAction,
        onTap:
            onTransactionsTap ??
            () {
              debugPrint('View transactions for card: ${card.id}');
            },
      ),
    ];

    if (showFreezeAction) {
      actions.add(
        _CardActionConfig(
          icon: Icons.lock_outline,
          label: l10n.cardsFreezeAction,
          onTap: isBusy ? null : onFreezeTap,
          isLoading: isBusy,
        ),
      );
    }

    if (showUnfreezeAction) {
      actions.add(
        _CardActionConfig(
          icon: Icons.lock_open_outlined,
          label: l10n.cardsUnfreezeAction,
          onTap: isBusy ? null : onUnfreezeTap,
          isLoading: isBusy,
        ),
      );
    }

    actions.add(
      _CardActionConfig(
        icon: Icons.cancel_outlined,
        label: l10n.cardsTerminateCta,
        onTap: (isBusy || isTerminated) ? null : onTerminateTap,
        isLoading: isBusy,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++)
          _CardActionTile(
            icon: actions[i].icon,
            label: actions[i].label,
            onTap: actions[i].onTap,
            isLoading: actions[i].isLoading,
            showDivider: i != actions.length - 1,
          ),
      ],
    );
  }
}

bool _statusIndicatesLocked(String normalizedStatus) {
  if (normalizedStatus.isEmpty) {
    return false;
  }

  if (normalizedStatus.contains('unlock') ||
      normalizedStatus.contains('unfreeze') ||
      normalizedStatus.contains('unfroze') ||
      normalizedStatus.contains('unfrozen')) {
    return false;
  }

  final tokens = normalizedStatus
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.isNotEmpty)
      .toSet();

  const lockedKeywords = <String>{
    'lock',
    'locked',
    'freeze',
    'frozen',
    'froze',
    'block',
    'blocked',
    'inactive',
    'suspend',
    'suspended',
    'hold',
    'held',
  };

  if (tokens.any(lockedKeywords.contains)) {
    return true;
  }

  return lockedKeywords.any(normalizedStatus.contains);
}

bool _statusIndicatesTerminated(String normalizedStatus) {
  if (normalizedStatus.isEmpty) {
    return false;
  }

  final tokens = normalizedStatus
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.isNotEmpty)
      .toSet();

  const terminatedKeywords = <String>{
    'terminate',
    'terminated',
    'close',
    'closed',
    'closing',
    'cancel',
    'cancelled',
    'canceled',
    'deactivate',
    'deactivated',
  };

  if (tokens.any(terminatedKeywords.contains)) {
    return true;
  }

  return terminatedKeywords.any(normalizedStatus.contains);
}

class _CardActionConfig {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _CardActionConfig({
    required this.icon,
    required this.label,
    this.onTap,
    this.isLoading = false,
  });
}

class _CardActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool showDivider;

  const _CardActionTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null || isLoading;
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: OpeiColors.pureBlack,
      letterSpacing: -0.2,
    );

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(color: OpeiColors.grey200, width: 0.5),
                )
              : null,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isDisabled ? 0.6 : 1,
          child: Row(
            children: [
              Icon(icon, color: OpeiColors.pureBlack, size: 22),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: labelStyle)),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(radius: 8),
                )
              else
                Icon(Icons.chevron_right, color: OpeiColors.grey400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateCardButton extends ConsumerStatefulWidget {
  const CreateCardButton({super.key});

  @override
  ConsumerState<CreateCardButton> createState() => _CreateCardButtonState();
}

class _CreateCardButtonState extends ConsumerState<CreateCardButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final parentState = context.findAncestorStateOfType<_CardsScreenState>();
    final availability = availabilityFromAsync(
      ref.watch(moneyMovementAvailabilityProvider),
    );
    final creationEnabled = availability.cards.creation.enabled;

    return GestureDetector(
      onTapDown: creationEnabled ? (_) => _controller.forward() : null,
      onTapUp: (_) async {
        final unavailableMessage = AppLocalizations.of(
          context,
        )!.errServiceUnavailable;
        if (!creationEnabled) {
          showError(context, unavailableMessage);
          return;
        }

        await _controller.reverse();
        if (!mounted) return;

        if (parentState != null) {
          await parentState._startCardCreationFlow();
          return;
        }

        await navigator.push(_buildCreateCardFlowRoute());
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: creationEnabled
                ? OpeiColors.pureBlack
                : OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: OpeiColors.pureBlack.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.cardsCreateVirtualCardCta,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: creationEnabled
                    ? OpeiColors.pureWhite
                    : OpeiBrand.inkTertiary,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
