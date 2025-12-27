import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/features/dashboard/widgets/transaction_widgets.dart';
import 'package:tt1/features/transactions/transactions_controller.dart';
import 'package:tt1/features/transactions/transactions_state.dart';
import 'package:tt1/features/transactions/widgets/transaction_detail_sheet.dart';
import 'package:tt1/theme.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: OpeiColors.pureBlack,
          backgroundColor: OpeiColors.pureWhite,
          displacement: 72,
          onRefresh: () => controller.refresh(),
          child: _buildContent(context, state, controller),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransactionsState state,
      TransactionsController controller) {
    if (state.showSkeleton) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: OpeiColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: OpeiColors.iosSeparator, width: 0.7),
            ),
            clipBehavior: Clip.antiAlias,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: TransactionsListSkeleton(itemCount: 5),
            ),
          ),
        ],
      );
    }

    if (state.error != null && state.transactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        children: [
          Column(
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: OpeiColors.errorRed.withValues(alpha: 0.85)),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 15, color: OpeiColors.errorRed),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () {
                  controller.refresh();
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ],
      );
    }

    if (state.transactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        children: [
          Column(
            children: [
              Icon(Icons.receipt_long,
                  size: 48, color: OpeiColors.iosLabelTertiary),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'You haven\'t made any moves yet. New activity will show up instantly.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: OpeiColors.iosLabelSecondary,
                    ),
              ),
            ],
          ),
        ],
      );
    }

    final transactions = state.transactions;

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      children: [
        Container(
          decoration: BoxDecoration(
            color: OpeiColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: OpeiColors.iosSeparator, width: 0.7),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: TransactionGroupsView(
            transactions: transactions,
            onTransactionTap: (tx) => showTransactionDetailSheet(context, tx),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
