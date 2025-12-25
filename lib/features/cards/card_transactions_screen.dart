import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/money/money.dart';
import 'package:tt1/data/models/card_transaction.dart';
import 'package:tt1/data/models/virtual_card.dart';
import 'package:tt1/features/cards/card_colors.dart';
import 'package:tt1/features/cards/card_transaction_detail_sheet.dart';
import 'package:tt1/features/cards/card_transactions_controller.dart';
import 'package:tt1/features/cards/card_transactions_state.dart';
import 'package:tt1/theme.dart';

class CardTransactionsScreen extends ConsumerStatefulWidget {
  final List<VirtualCard> cards;
  final int initialIndex;

  CardTransactionsScreen({
    super.key,
    required this.cards,
    this.initialIndex = 0,
  }) : assert(cards.isNotEmpty, 'CardTransactionsScreen requires at least one card.');

  @override
  ConsumerState<CardTransactionsScreen> createState() => _CardTransactionsScreenState();
}

class _CardTransactionsScreenState extends ConsumerState<CardTransactionsScreen> {
  late final PageController _pageController;
  late final ScrollController _scrollController;
  late int _currentIndex;

  VirtualCard get _activeCard => widget.cards[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.cards.length - 1);
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.95,
    );
    _scrollController = ScrollController()
      ..addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureTransactionsLoaded(force: true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(cardTransactionsControllerProvider);
    final feed = transactionsState.feedFor(_activeCard.id);

    return Scaffold(
      backgroundColor: OpeiColors.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _CloseButton(onPressed: () => Navigator.of(context).pop()),
                  Expanded(
                    child: Text(
                      'Card Transactions',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  _ensureTransactionsLoaded(force: true);
                },
                physics: const ClampingScrollPhysics(),
                itemCount: widget.cards.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _TransactionCardPreview(card: widget.cards[index]),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (widget.cards.length > 1)
              _CarouselPageIndicator(
                itemCount: widget.cards.length,
                currentIndex: _currentIndex,
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _TransactionsBody(
                scrollController: _scrollController,
                feed: feed,
                card: _activeCard,
                onRetry: () => _ensureTransactionsLoaded(force: true),
                onRefresh: () => ref.read(cardTransactionsControllerProvider.notifier).refresh(_activeCard.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ensureTransactionsLoaded({required bool force}) {
    ref.read(cardTransactionsControllerProvider.notifier).loadInitial(
          _activeCard.id,
          force: force,
        );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent == 0 || position.pixels < position.maxScrollExtent - 120) {
      return;
    }

    final controller = ref.read(cardTransactionsControllerProvider.notifier);
    final feed = ref.read(cardTransactionsControllerProvider).feedFor(_activeCard.id);

    if (feed.hasMore && !feed.isLoadingMore && !feed.isLoading && !feed.isRefreshing) {
      controller.loadMore(_activeCard.id);
    }
  }
}

class _TransactionsBody extends StatelessWidget {
  final ScrollController scrollController;
  final CardTransactionsFeed feed;
  final VirtualCard card;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  const _TransactionsBody({
    required this.scrollController,
    required this.feed,
    required this.card,
    required this.onRefresh,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (feed.showSkeleton) {
      return const _TransactionsSkeleton();
    }

    if (feed.errorMessage != null && feed.transactions.isEmpty) {
      return _TransactionsErrorState(
        message: feed.errorMessage!,
        onRetry: onRetry,
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      color: OpeiColors.pureBlack,
      child: feed.transactions.isEmpty
          ? ListView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              children: const [
                SizedBox(height: 40),
                _EmptyTransactionsState(),
              ],
            )
          : ListView.builder(
              controller: scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: feed.transactions.length + (feed.hasMore || feed.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= feed.transactions.length) {
                  if (feed.loadMoreError != null) {
                    return _LoadMoreErrorBanner(
                      message: feed.loadMoreError!,
                    );
                  }
                  return const _LoadMoreSpinner();
                }

                final transaction = feed.transactions[index];
                final showDivider = index != feed.transactions.length - 1 || feed.isLoadingMore;
                return _CardTransactionTile(
                  transaction: transaction,
                  showDivider: showDivider,
                );
              },
            ),
    );
  }
}

class _CardTransactionTile extends StatelessWidget {
  final CardTransaction transaction;
  final bool showDivider;

  const _CardTransactionTile({
    required this.transaction,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit == true;
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        );
    final secondaryStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 10.5,
          color: OpeiColors.iosLabelSecondary,
          letterSpacing: -0.05,
        );
    final amountStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isCredit ? OpeiColors.successGreen : OpeiColors.errorRed,
          letterSpacing: -0.15,
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showCardTransactionDetailSheet(context, transaction),
      child: Container(
        decoration: BoxDecoration(
          border: showDivider ? Border(bottom: BorderSide(color: OpeiColors.iosSeparator, width: 0.5)) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: OpeiColors.iosSurfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: OpeiColors.pureBlack,
                size: 12,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          transaction.title,
                          style: titleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        transaction.formattedAmount,
                        style: amountStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    transaction.subtitle,
                    style: secondaryStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (transaction.balanceAfterLabel.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Balance: ${transaction.balanceAfterLabel}',
                      style: secondaryStyle?.copyWith(
                        color: OpeiColors.iosLabelTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCardPreview extends StatelessWidget {
  final VirtualCard card;

  const _TransactionCardPreview({required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = _formatStatus(card.status);
    final statusColor = _statusColor(statusLabel);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors(card),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: OpeiColors.pureBlack.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 8),
                    _CardStatusPill(label: statusLabel, color: statusColor),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _formatCardNumber(card.last4),
            style: theme.textTheme.titleLarge?.copyWith(
                  color: OpeiColors.pureWhite,
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 3.2,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _CardInfoColumn(
                      label: 'Expires',
                      value: card.expiry == null || card.expiry!.trim().isEmpty ? '—' : card.expiry!,
                    ),
                    const SizedBox(width: 28),
                    _CardInfoColumn(
                      label: 'CVV',
                      value: _maskCvv(card.cvv),
                    ),
                    const SizedBox(width: 28),
                    _CardInfoColumn(
                      label: 'Balance',
                      value: _maskBalance(card.balance),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'VISA',
                style: TextStyle(
                  color: OpeiColors.pureWhite.withValues(alpha: 0.92),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.0,
                  fontStyle: FontStyle.italic,
                  height: 0.9,
                  fontFamily: '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _gradientColors(VirtualCard card) {
    final palette = CardColorPalette.defaultOption;
    if (palette != null) {
      return palette.gradient;
    }
    return const [
      Color(0xFF1A1A1A),
      Color(0xFF2D2D2D),
      Color(0xFF000000),
    ];
  }

  static String _formatCardNumber(String? last4) {
    final trimmed = last4?.trim();
    final suffix = (trimmed == null || trimmed.isEmpty) ? '••••' : trimmed;
    return '••••    ••••    ••••    $suffix';
  }

  static String _maskCvv(String? cvv) {
    final trimmed = cvv?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return '***';
    }
    return List.generate(trimmed.length, (_) => '•').join();
  }

  static String _maskBalance(Money? balance) {
    if (balance == null) {
      return '****';
    }
    final formatted = balance.format(includeCurrencySymbol: true);
    return formatted.replaceAll(RegExp(r'[0-9]'), '•');
  }

  static String _formatStatus(String raw) {
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

  static Color _statusColor(String status) {
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

class _CardInfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _CardInfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.bodySmall?.copyWith(
                color: OpeiColors.pureWhite.withValues(alpha: 0.55),
                letterSpacing: 1.0,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
                color: OpeiColors.pureWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
        ),
      ],
    );
  }
}

class _TransactionsSkeleton extends StatelessWidget {
  const _TransactionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: OpeiColors.iosSeparator, width: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: OpeiColors.iosSurfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 144,
                      decoration: BoxDecoration(
                        color: OpeiColors.iosSurfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 112,
                      decoration: BoxDecoration(
                        color: OpeiColors.iosSurfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TransactionsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TransactionsErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: OpeiColors.pureBlack,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: CupertinoButton.filled(
              onPressed: onRetry,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 48,
          color: OpeiColors.iosLabelTertiary,
        ),
        const SizedBox(height: 12),
        Text(
          'No card transactions yet',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'When you start using this card, your transaction history will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: OpeiColors.iosLabelSecondary,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }
}

class _LoadMoreSpinner extends StatelessWidget {
  const _LoadMoreSpinner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CupertinoActivityIndicator(color: OpeiColors.pureBlack.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _LoadMoreErrorBanner extends StatelessWidget {
  final String message;

  const _LoadMoreErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, color: OpeiColors.errorRed.withValues(alpha: 0.9), size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: OpeiColors.errorRed,
                    fontSize: 12,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: OpeiColors.iosSurfaceMuted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.close,
          size: 18,
          color: OpeiColors.pureBlack,
        ),
      ),
    );
  }
}

class _CarouselPageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const _CarouselPageIndicator({required this.itemCount, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isActive ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? OpeiColors.pureBlack : OpeiColors.grey300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}