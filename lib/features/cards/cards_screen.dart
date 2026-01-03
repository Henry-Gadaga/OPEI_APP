import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/money/money.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/data/models/card_creation_response.dart';
import 'package:tt1/data/models/card_details.dart';
import 'package:tt1/data/models/virtual_card.dart';
import 'package:tt1/features/cards/card_colors.dart';
import 'package:tt1/features/cards/card_transactions_screen.dart';
import 'package:tt1/features/cards/cards_controller.dart';
import 'package:tt1/features/cards/create_virtual_card_flow.dart';
import 'package:tt1/features/cards/card_topup_sheet.dart';
import 'package:tt1/features/cards/card_withdraw_sheet.dart';
import 'package:tt1/features/dashboard/dashboard_controller.dart';
import 'package:tt1/responsive/responsive_tokens.dart';
import 'package:tt1/responsive/responsive_widgets.dart';
import 'package:tt1/theme.dart';

Route<CardCreationResponse?> _buildCreateCardFlowRoute() {
  return PageRouteBuilder<CardCreationResponse?>(
    pageBuilder: (_, __, ___) => const CreateVirtualCardFlow(),
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    fullscreenDialog: true,
    transitionsBuilder: (_, __, ___, child) => child,
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
    final cardsState = ref.watch(cardsControllerProvider);
    final isInitialLoading = cardsState.isLoading && !cardsState.hasLoaded;
    final rawError = cardsState.error;
    final normalizedError = rawError?.trim() ?? '';
    final hasError = rawError != null;
    final resolvedErrorMessage = hasError
        ? (normalizedError.isNotEmpty
            ? normalizedError
            : "We couldn't load your cards. Please try again.")
        : null;
    final showErrorBanner = hasError && cardsState.cards.isNotEmpty;
    final showErrorState = hasError && cardsState.cards.isEmpty && cardsState.hasLoaded && !cardsState.isLoading;
    final showEmptyState = cardsState.hasLoaded && cardsState.cards.isEmpty && !hasError && !cardsState.isLoading;
    final showCardList = cardsState.cards.isNotEmpty;
    final showBlockingLoader = cardsState.isLoading && cardsState.cards.isEmpty && !showErrorState;
    final showHeaderCreateButton = cardsState.hasLoaded && cardsState.cards.isEmpty;

    final platform = Theme.of(context).platform;
    final isCupertino = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final scrollPhysics = AlwaysScrollableScrollPhysics(
      parent: isCupertino ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
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
              padding: EdgeInsets.symmetric(horizontal: tokens.horizontalPadding),
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
                            'Cards',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                                color: OpeiColors.pureBlack,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: OpeiColors.pureWhite,
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
                      onRetry: () => ref.read(cardsControllerProvider.notifier).refresh(),
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
                      onPageChanged: (index) => setState(() => _currentPage = index),
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
                    if (cardsState.cards.length > 1) SizedBox(height: spacing * 2),
                    if (cardsState.cards.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          final cappedIndex = math.min(_currentPage, cardsState.cards.length - 1);
                          final selectedCard = cardsState.cards[cappedIndex];
                          final isBusy = cardsState.actionInFlightIds.contains(selectedCard.id.trim());

                          return _CardActionsRow(
                            card: selectedCard,
                            onTransactionsTap: () => _openTransactions(cardsState.cards, cappedIndex),
                            onFreezeTap: () => _handleFreezeCard(selectedCard),
                            onUnfreezeTap: () => _handleUnfreezeCard(selectedCard),
                            onTopUpTap: () => _handleTopUp(selectedCard),
                             onWithdrawTap: () => _handleWithdraw(selectedCard),
                            onTerminateTap: () => _handleTerminateCard(selectedCard),
                            isBusy: isBusy,
                          );
                        },
                      ),
                    ],
                    SizedBox(height: spacing * 2.25),
                   ] else if (showErrorState && resolvedErrorMessage != null) ...[
                    _CardsErrorPlaceholder(
                      message: resolvedErrorMessage,
                      onRetry: () => ref.read(cardsControllerProvider.notifier).refresh(),
                    ),
                    SizedBox(height: spacing * 3),
                   ] else if (showBlockingLoader) ...[
                     const _CardsLoadingPlaceholder(),
                     SizedBox(height: spacing * 3),
                  ] else if (showEmptyState) ...[
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
                        child: SizedBox(
                          height: 220,
                          child: const VirtualCardHero(),
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 2.25),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use Your Visa Card For',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: spacing * 1.25),
                            const CardUseCasesList(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 2),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.horizontalPadding,
                            vertical: spacing * 1.6,
                          ),
                          color: OpeiColors.pureBlack,
                          borderRadius: BorderRadius.circular(14),
                          onPressed: _startCardCreationFlow,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Icon(Icons.add, color: OpeiColors.pureWhite, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Create Card',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: OpeiColors.pureWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 2.5),
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
      ref.read(dashboardControllerProvider.notifier).refreshBalance(showSpinner: false),
    ]);
  }

  Future<void> _startCardCreationFlow() async {
    final creation = await Navigator.of(context).push<CardCreationResponse?>(
      _buildCreateCardFlowRoute(),
    );

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
      showSuccess(context, 'Your virtual card is ready!');
      return;
    }

    final createdCardId = creation.cardId.trim();
    var targetIndex = createdCardId.isEmpty ? cards.length - 1 : cards.indexWhere((card) => card.id.trim() == createdCardId);

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

    showSuccess(context, 'Your virtual card is ready!');
  }

  void _openTransactions(List<VirtualCard> cards, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) => CardTransactionsScreen(
          cards: cards,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      ),
    );
  }

  Future<void> _copyToClipboard(String label, String value) async {
    final sanitized = value.replaceAll(' ', '').trim();
    if (sanitized.isEmpty || sanitized.contains('•') || sanitized == '—' || sanitized == '***') {
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
        content: Text('$label copied'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleFreezeCard(VirtualCard card) async {
    final result = await ref.read(cardsControllerProvider.notifier).freezeCard(card);

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
    final result = await ref.read(cardsControllerProvider.notifier).unfreezeCard(card);

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
    final cardId = card.id.trim();
    if (cardId.isEmpty) {
      showError(context, "We couldn't find this card.");
      return;
    }

    await showResponsiveBottomSheet<void>(
      context: context,
      builder: (_) => CardTopUpSheet(card: card),
    );
  }

  Future<void> _handleWithdraw(VirtualCard card) async {
    final cardId = card.id.trim();
    if (cardId.isEmpty) {
      showError(context, "We couldn't find this card.");
      return;
    }

    await showResponsiveBottomSheet<void>(
      context: context,
      builder: (_) => CardWithdrawSheet(card: card),
    );
  }

  Future<void> _handleTerminateCard(VirtualCard card) async {
    final confirmed = await _confirmTerminateDialog(card);
    if (!confirmed) {
      return;
    }

    final result = await ref.read(cardsControllerProvider.notifier).terminateCard(card);

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
        cardName: card.cardName.isNotEmpty ? card.cardName : 'Virtual Card',
        lastFour: card.last4,
      ),
    );

    return result ?? false;
  }

  Future<void> _handleToggleCardDetails(VirtualCard card) async {
    final message = await ref.read(cardsControllerProvider.notifier).toggleCardDetails(card);
    if (!mounted || message == null || message.trim().isEmpty) {
      return;
    }
    showError(context, message);
  }
}

class _CardsMessageBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CardsMessageBanner({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
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
                foregroundColor: OpeiColors.pureBlack,
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
              ),
              child: const Text('Retry'),
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

  const _TerminateConfirmationSheet({
    required this.cardName,
    this.lastFour,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cardLabel =
        (lastFour == null || lastFour!.isEmpty) ? cardName : '$cardName ·•••• ${lastFour!}';

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
            'Terminate this card?',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This card will be permanently removed. You won’t be able to use or view $cardLabel again.',
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
                    'Make sure you’ve moved any remaining funds before confirming.',
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
                  child: const Text('Keep card'),
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
                  child: const Text('Terminate'),
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

  const _CardsErrorPlaceholder({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
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
              'We ran into an issue',
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
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  backgroundColor: OpeiColors.pureBlack,
                  foregroundColor: OpeiColors.pureWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                child: const Text('Retry'),
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
    return SizedBox(
      height: 228,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemCount: cards.length,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final card = cards[index];
          final cardId = card.id.trim();
          final details = cardId.isEmpty ? null : detailsById[cardId];
          final isRevealed = cardId.isNotEmpty && revealedCardIds.contains(cardId);
          final isLoading = cardId.isNotEmpty && loadingCardIds.contains(cardId);

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
    final statusLabel = _formatStatus(card.status);
    final statusColor = _statusColor(statusLabel);
    final showDetails = isRevealed && details != null;

    final normalizedPan = _normalizeDigitsWithFallback(
      details?.cardNumber ?? '',
      fallback: card.last4,
    );
    final panGroups = _splitIntoGroups(normalizedPan);
    final cvvRevealed = _formatRevealedCvv(details?.cvv ?? '', fallback: card.cvv);
    final cvvMasked = _maskCvv(card.cvv);
    final balanceRevealed = _formatRevealedBalance(details?.balance ?? card.balance);
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
                          card.cardName.isNotEmpty ? card.cardName : 'Virtual Card',
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
                            label: 'Address',
                            preview: addressData.preview,
                            isPlaceholder: addressData.isPlaceholder,
                            onTap: () => _showAddressSheet(context, addressData),
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
                        onPressed: onToggleDetails == null ? null : () => onToggleDetails!(card),
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
                      textStyle: theme.textTheme.titleLarge?.copyWith(
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
                            label: 'Card number',
                            onPressed: () => onCopyValue('Card number', copyableCardNumber),
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
                        _CardInfoColumn(
                          label: 'Expires',
                          value: expiryLabel,
                          animateValue: true,
                          onCopy: copyableExpiry.isNotEmpty
                              ? () => onCopyValue('Expiry date', copyableExpiry)
                              : null,
                          copyLabel: 'Expiry date',
                          reserveCopySlot: true,
                        ),
                        const SizedBox(width: 18),
                        _CardInfoColumn(
                          label: 'CVV',
                          value: cvvRevealed,
                          maskedValue: cvvMasked,
                          isMasked: !showDetails,
                          animateValue: true,
                          onCopy: copyableCvv.isNotEmpty
                              ? () => onCopyValue('CVV', copyableCvv)
                              : null,
                          copyLabel: 'CVV',
                          reserveCopySlot: true,
                        ),
                        const SizedBox(width: 18),
                        _CardInfoColumn(
                          label: 'Balance',
                          value: balanceRevealed,
                          maskedValue: balanceMasked,
                          isMasked: !showDetails,
                          animateValue: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    height: 26,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        'VISA',
                        style: TextStyle(
                          color: OpeiColors.pureWhite.withValues(alpha: 0.92),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.4,
                          fontStyle: FontStyle.italic,
                          height: 1.0,
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
                          'Loading securely...',
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
      return 'Unknown';
    }

    return sanitized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
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
    const fallbackPreview = '742 Evergreen Terrace, Springfield';
    const fallbackFull = '742 Evergreen Terrace\nSpringfield, IL 62704\nUnited States';

    final address = card.address;

    if (address == null) {
      return const _CardAddressData(
        preview: fallbackPreview,
        full: fallbackFull,
        isPlaceholder: true,
      );
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
      if (countryCode != null && !country.toUpperCase().contains(countryCode.toUpperCase())) {
        fullLines.add('$country (${countryCode.toUpperCase()})');
      } else {
        fullLines.add(country);
      }
    }

    final effectivePreview = preview.isNotEmpty ? preview : fullLines.join(', ');
    final effectiveFull = fullLines.isNotEmpty ? fullLines.join('\n') : effectivePreview;

    if (effectivePreview.trim().isEmpty && effectiveFull.trim().isEmpty) {
      return const _CardAddressData(
        preview: fallbackPreview,
        full: fallbackFull,
        isPlaceholder: true,
      );
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
        final copyLabel = data.isPlaceholder ? 'Copy sample address' : 'Copy address';

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
                  'Card Address',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: OpeiColors.pureBlack,
                      ),
                ),
                if (data.isPlaceholder) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Sample data shown for layout. Real card addresses will appear here once provided by the gateway.',
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
                        final normalizedCopy = data.full.replaceAll(RegExp(r'\s+'), ' ').trim();
                        if (normalizedCopy.isEmpty) {
                          return;
                        }
                        Navigator.of(sheetContext).pop();
                        await onCopyValue('Card address', normalizedCopy);
                      },
                      icon: const Icon(CupertinoIcons.doc_on_doc),
                      label: Text(copyLabel),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Close'),
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
          Icon(
            Icons.location_on_outlined,
            size: 16,
            color: baseColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label • $preview',
              style: theme.textTheme.bodySmall?.copyWith(
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
          Icon(
            Icons.chevron_right,
            size: 16,
            color: baseColor,
          ),
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
              child: Text(
                effectiveDigits,
                style: textStyle,
              ),
            ),
            if (!isLast)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                opacity: isRevealed ? 0 : 1,
                child: Text(
                  maskText,
                  style: textStyle,
                ),
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
        Text(
          label.toUpperCase(),
          style: theme.textTheme.bodySmall?.copyWith(
                color: OpeiColors.pureWhite.withValues(alpha: 0.55),
                letterSpacing: 0.8,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 5),
        animateValue
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _CardInfoValue(
                  key: ValueKey('$label-$value-${maskedValue ?? ''}-${isMasked ? 'masked' : 'revealed'}'),
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

    final baseStyle = theme.textTheme.titleSmall?.copyWith(
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
        return Text(value, style: baseStyle);
      }

      return _MaskedValueText(
        revealedText: value,
        maskedText: maskedValue!,
        isMasked: isMasked,
        style: baseStyle,
      );
    }

    if (!needsTrailingSpace) {
      return SizedBox(
        height: valueHeight,
        child: Align(
          alignment: Alignment.centerLeft,
          child: buildValueContent(),
        ),
      );
    }

    return SizedBox(
      height: valueHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: buildValueContent(),
          ),
          const SizedBox(width: 6),
          canCopy
              ? _CopyIconButton(
                  label: 'Copy $copyLabel',
                  onPressed: onCopy!,
                  size: 24,
                )
              : const _CopyIconPlaceholder(size: 24),
        ],
      ),
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

  const _CopyIconButton({required this.onPressed, required this.label, this.size = 26});

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
    return SizedBox(
      width: size,
      height: size,
    );
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
    final baseColor = OpeiColors.pureWhite.withValues(alpha: isRevealed ? 0.24 : 0.16);
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
          border: Border.all(
            color: borderColor,
            width: isRevealed ? 1.1 : 0.8,
          ),
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
                    isRevealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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

  const _CardStatusPill({
    required this.label,
    required this.color,
  });

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
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF2D2D2D),
                  Color(0xFF1A1A1A),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: OpeiColors.pureBlack.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 24,
                  left: 24,
                  right: 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Opei',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: OpeiColors.pureWhite.withValues(alpha: 0.9),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'VISA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: OpeiColors.pureWhite.withValues(alpha: 0.9),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '••••    ••••    ••••    ••••',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: OpeiColors.pureWhite.withValues(alpha: 0.9),
                          letterSpacing: 3.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Virtual Visa Card',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: OpeiColors.pureWhite.withValues(alpha: 0.7),
                              letterSpacing: 0.5,
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
      CardUseCase(icon: Icons.subscriptions_outlined, title: 'Subscriptions', subtitle: 'Netflix, Spotify, and more'),
      CardUseCase(icon: Icons.shopping_bag_outlined, title: 'Online Shopping', subtitle: 'Purchase from any store'),
      CardUseCase(icon: Icons.flight_outlined, title: 'Travel & Tickets', subtitle: 'Book flights and hotels'),
      CardUseCase(icon: Icons.games_outlined, title: 'Gaming', subtitle: 'In-app purchases and games'),
      CardUseCase(icon: Icons.public, title: 'International Store Payments', subtitle: 'Shop from anywhere'),
      CardUseCase(icon: Icons.shield_outlined, title: 'Secure Online Purchases', subtitle: 'Protected transactions'),
    ];

    return Column(
      children: useCases.asMap().entries.map((entry) {
        final index = entry.key;
        final useCase = entry.value;
        final isLast = index == useCases.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
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

  CardUseCase({required this.icon, required this.title, required this.subtitle});
}

class UseCaseTile extends StatelessWidget {
  final CardUseCase useCase;

  const UseCaseTile({super.key, required this.useCase});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: OpeiColors.pureBlack.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: OpeiColors.iosSurfaceMuted,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                useCase.icon,
                size: 20,
                color: OpeiColors.pureBlack,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    useCase.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    useCase.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: OpeiColors.iosLabelSecondary,
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
      children: List.generate(
        itemCount,
        (index) {
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
        },
      ),
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

  const _CardActionsRow({
    required this.card,
    this.onTransactionsTap,
    this.onFreezeTap,
    this.onUnfreezeTap,
    this.onTerminateTap,
    this.onTopUpTap,
    this.onWithdrawTap,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = card.status.trim();
    final normalizedStatus = status.toLowerCase();
    final isLocked = _statusIndicatesLocked(normalizedStatus);
    final isTerminated = _statusIndicatesTerminated(normalizedStatus);
    final showFreezeAction = !isLocked && !isTerminated;
    final showUnfreezeAction = isLocked && !isTerminated;

    final actions = <_CardActionConfig>[
      _CardActionConfig(
        icon: Icons.add_circle_outline,
        label: 'Top Up',
        onTap: (isTerminated || isBusy) ? null : onTopUpTap,
      ),
      _CardActionConfig(
        icon: Icons.arrow_circle_up_outlined,
        label: 'Withdraw',
        onTap: isTerminated ? null : onWithdrawTap,
      ),
      _CardActionConfig(
        icon: Icons.receipt_long_outlined,
        label: 'Transactions',
        onTap: onTransactionsTap ?? () {
          debugPrint('View transactions for card: ${card.id}');
        },
      ),
    ];

    if (showFreezeAction) {
      actions.add(
        _CardActionConfig(
          icon: Icons.lock_outline,
          label: 'Freeze Card',
          onTap: isBusy ? null : onFreezeTap,
          isLoading: isBusy,
        ),
      );
    }

    if (showUnfreezeAction) {
      actions.add(
        _CardActionConfig(
          icon: Icons.lock_open_outlined,
          label: 'Unfreeze Card',
          onTap: isBusy ? null : onUnfreezeTap,
          isLoading: isBusy,
        ),
      );
    }

    actions.add(
      _CardActionConfig(
        icon: Icons.cancel_outlined,
        label: 'Terminate',
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
                  bottom: BorderSide(
                    color: OpeiColors.grey200,
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isDisabled ? 0.6 : 1,
          child: Row(
            children: [
              Icon(
                icon,
                color: OpeiColors.pureBlack,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: labelStyle,
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(radius: 8),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: OpeiColors.grey400,
                  size: 20,
                ),
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

class _CreateCardButtonState extends ConsumerState<CreateCardButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final parentState =
        context.findAncestorStateOfType<_CardsScreenState>();

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) async {
        await _controller.reverse();
        if (!mounted) return;

        if (parentState != null) {
          await parentState._startCardCreationFlow();
          return;
        }

        await navigator.push(
          _buildCreateCardFlowRoute(),
        );
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: OpeiColors.pureBlack,
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
              'Create Virtual Card',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.pureWhite,
                    letterSpacing: -0.2,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}