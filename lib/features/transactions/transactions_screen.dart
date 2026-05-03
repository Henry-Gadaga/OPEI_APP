import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/data/models/wallet_transaction.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsControllerProvider.notifier).ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsControllerProvider);
    final controller = ref.read(transactionsControllerProvider.notifier);

    final hasContent = state.transactions.isNotEmpty;
    final summary = hasContent ? _Summary.from(state.transactions) : null;

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
                if (summary != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: _SummaryCard(summary: summary),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _buildBody(context, state, controller),
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
        // thin separator between summary / header and list
        const SizedBox(height: 20),
        Container(height: 0.6, color: OpeiBrand.hairline),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: state.isRefreshing ? 0.7 : 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 32),
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
// Summary card — last 30 days inflow / outflow
// =====================================================================

class _Summary {
  final Money inflow;
  final Money outflow;
  final int inflowCount;
  final int outflowCount;
  final String currency;

  const _Summary({
    required this.inflow,
    required this.outflow,
    required this.inflowCount,
    required this.outflowCount,
    required this.currency,
  });

  factory _Summary.from(List<WalletTransaction> txs) {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final currency = txs.isNotEmpty ? txs.first.currency : 'USD';

    int inCents = 0, outCents = 0;
    int inN = 0, outN = 0;

    for (final t in txs) {
      final date = t.createdAt;
      if (date == null || date.isBefore(cutoff)) continue;
      // Only count completed / no-status to avoid pending fluff
      final s = t.status?.trim().toUpperCase() ?? '';
      final isFailed = s == 'FAILED' || s == 'CANCELLED' || s == 'CANCELED';
      if (isFailed) continue;

      if (t.isIncoming) {
        inCents += t.amountCents.abs();
        inN++;
      } else {
        outCents += t.amountCents.abs();
        outN++;
      }
    }

    return _Summary(
      inflow: Money.fromCents(inCents, currency: currency),
      outflow: Money.fromCents(outCents, currency: currency),
      inflowCount: inN,
      outflowCount: outN,
      currency: currency,
    );
  }

  bool get isEmpty => inflowCount == 0 && outflowCount == 0;
}

class _SummaryCard extends StatelessWidget {
  final _Summary summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
        boxShadow: [
          BoxShadow(
            color: OpeiBrand.ink.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
              const Text(
                'Last 30 days',
                style: TextStyle(
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
                    amount: summary.inflow.format(includeCurrencySymbol: true),
                    sub:
                        '${summary.inflowCount} ${summary.inflowCount == 1 ? 'inflow' : 'inflows'}',
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
                    amount: summary.outflow.format(includeCurrencySymbol: true),
                    sub:
                        '${summary.outflowCount} ${summary.outflowCount == 1 ? 'payment' : 'payments'}',
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
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final String amount;
  final String sub;
  final Color amountColor;

  const _StatTile({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    required this.amount,
    required this.sub,
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
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkTertiary,
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
