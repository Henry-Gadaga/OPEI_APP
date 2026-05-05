import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/data/models/transaction_summary.dart';
import 'package:opei/features/dashboard/widgets/transaction_widgets.dart';
import 'package:opei/features/transactions/transactions_controller.dart';
import 'package:opei/features/transactions/transactions_state.dart';
import 'package:opei/features/transactions/widgets/transaction_detail_sheet.dart';
import 'package:opei/theme.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _kLoadMoreThreshold = 360;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsControllerProvider.notifier).ensureLoaded();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final remaining = position.maxScrollExtent - position.pixels;
    if (remaining > _kLoadMoreThreshold) return;

    final state = ref.read(transactionsControllerProvider);
    if (!state.hasMore) return;
    if (state.isLoadingMore) return;
    if (state.isLoading || state.isRefreshing) return;
    if (state.loadMoreError != null) return;

    ref.read(transactionsControllerProvider.notifier).loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsControllerProvider);
    final controller = ref.read(transactionsControllerProvider.notifier);

    final summary = state.summary;
    final hasList = state.transactions.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: OpeiBrand.surface,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: OpeiBrand.primary,
            backgroundColor: OpeiBrand.surface,
            displacement: 28,
            onRefresh: () => controller.refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    txCount: state.transactions.length,
                    isRefreshing: state.isRefreshing,
                  ),
                ),
                if (summary != null && !summary.isEmpty)
                  SliverToBoxAdapter(
                    child: _SummaryCard(summary: summary),
                  ),
                SliverToBoxAdapter(
                  child: _buildBody(context, state, controller),
                ),
                if (hasList)
                  SliverToBoxAdapter(
                    child: _ListFooter(
                      state: state,
                      onRetry: () => controller.loadMore(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TransactionsState state,
    TransactionsController controller,
  ) {
    if (state.showSkeleton) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: TransactionsListSkeleton(itemCount: 7),
      );
    }

    if (state.error != null && state.transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: _StatusSlot(
          icon: Icons.wifi_off_rounded,
          iconColor: OpeiBrand.danger,
          iconBg: const Color(0xFFFDECEC),
          title: 'Couldn\'t load activity',
          subtitle: state.error!,
          actionLabel: 'Try again',
          onAction: () => controller.refresh(),
        ),
      );
    }

    if (state.transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: _StatusSlot(
          icon: Icons.receipt_long_rounded,
          iconColor: OpeiBrand.primary,
          iconBg: OpeiBrand.primaryTint,
          title: 'No activity yet',
          subtitle:
              'You haven\'t made any moves yet.\nNew activity will appear here instantly.',
        ),
      );
    }

    // Full-width transaction list — no horizontal card wrapper
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(height: 0.6, color: OpeiBrand.hairline),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: state.isRefreshing ? 0.7 : 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TransactionGroupsView(
              transactions: state.transactions,
              onTransactionTap: (tx) =>
                  showTransactionDetailSheet(context, tx),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// Pagination footer — spinner, retry, or end-of-list marker
// =====================================================================

class _ListFooter extends StatelessWidget {
  final TransactionsState state;
  final VoidCallback onRetry;

  const _ListFooter({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 24;

    if (state.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(OpeiBrand.primary),
            ),
          ),
        ),
      );
    }

    if (state.loadMoreError != null) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
        child: Column(
          children: [
            Text(
              state.loadMoreError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.inkSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: OpeiBrand.primaryTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Try again',
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.primary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!state.hasMore) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad),
        child: const Center(
          child: Text(
            "You're all caught up",
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: OpeiBrand.inkTertiary,
              letterSpacing: 0.1,
            ),
          ),
        ),
      );
    }

    // Has more but not loading yet — reserve a bit of space for the trigger.
    return SizedBox(height: bottomPad + 16);
  }
}

// =====================================================================
// Header
// =====================================================================

class _Header extends StatelessWidget {
  final int txCount;
  final bool isRefreshing;

  const _Header({required this.txCount, required this.isRefreshing});

  @override
  Widget build(BuildContext context) {
    final countLabel =
        txCount == 0 ? '' : '$txCount ${txCount == 1 ? 'transaction' : 'transactions'}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Activity',
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: OpeiBrand.ink,
                    letterSpacing: -0.9,
                  ),
                ),
              ),
              if (isRefreshing)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(OpeiBrand.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            countLabel.isEmpty
                ? 'Every move on your account, in one place.'
                : '$countLabel · all on one timeline',
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Summary card — backend-computed inflow / outflow (last 30 days)
// =====================================================================

class _SummaryCard extends StatelessWidget {
  final TransactionSummary summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OpeiBrand.surface,
        border: const Border(
          top: BorderSide(color: OpeiBrand.hairline, width: 0.6),
          bottom: BorderSide(color: OpeiBrand.hairline, width: 0.6),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: OpeiBrand.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _rangeLabel(summary),
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.inkSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.south_rounded,
                    iconBg: const Color(0xFFE6F6EA),
                    iconFg: const Color(0xFF137A33),
                    label: 'Money in',
                    amount: summary.totalIn.format(includeCurrencySymbol: true),
                    amountColor: const Color(0xFF137A33),
                  ),
                ),
                Container(width: 1, color: OpeiBrand.hairline),
                Expanded(
                  child: _StatTile(
                    icon: Icons.north_rounded,
                    iconBg: OpeiBrand.surfaceMuted,
                    iconFg: OpeiBrand.ink,
                    label: 'Money out',
                    amount:
                        summary.totalOut.format(includeCurrencySymbol: true),
                    amountColor: OpeiBrand.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _rangeLabel(TransactionSummary summary) {
    final from = summary.from;
    final to = summary.to;
    if (from == null || to == null) {
      return 'Last 30 days';
    }
    final days = to.difference(from).inDays;
    if (days >= 28 && days <= 31) return 'Last 30 days';
    if (days >= 6 && days <= 8) return 'Last 7 days';
    if (days >= 89 && days <= 92) return 'Last 90 days';
    return 'Last $days days';
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final String amount;
  final Color amountColor;

  const _StatTile({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconFg, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: OpeiBrand.inkSecondary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: amountColor,
                letterSpacing: -0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Empty / error slot
// =====================================================================

class _StatusSlot extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatusSlot({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              height: 1.45,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 22),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(
                    color: OpeiBrand.primaryTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.primary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
