import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: OpeiBrand.surfaceMuted,
        body: SafeArea(
          child: RefreshIndicator(
            color: OpeiBrand.primary,
            backgroundColor: OpeiBrand.surface,
            displacement: 28,
            onRefresh: () => controller.refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Activity',
                          style: TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: OpeiBrand.ink,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All your transactions in one place.',
                          style: TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: OpeiBrand.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: _buildBody(context, state, controller),
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
      return Container(
        decoration: BoxDecoration(
          color: OpeiBrand.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: OpeiBrand.hairline, width: 1),
          boxShadow: [
            BoxShadow(
              color: OpeiBrand.ink.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: const TransactionsListSkeleton(itemCount: 6),
      );
    }

    if (state.error != null && state.transactions.isEmpty) {
      return _StatusSlot(
        icon: Icons.wifi_off_rounded,
        iconColor: OpeiBrand.danger,
        iconBg: const Color(0xFFFFF0F0),
        title: 'Couldn\'t load activity',
        subtitle: state.error!,
        actionLabel: 'Try again',
        onAction: () => controller.refresh(),
      );
    }

    if (state.transactions.isEmpty) {
      return const _StatusSlot(
        icon: Icons.receipt_long_rounded,
        iconColor: OpeiBrand.primary,
        iconBg: OpeiBrand.primaryTint,
        title: 'No activity yet',
        subtitle:
            'You haven\'t made any moves yet.\nNew activity will appear instantly.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
        boxShadow: [
          BoxShadow(
            color: OpeiBrand.ink.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: state.isRefreshing ? 0.65 : 1,
        child: TransactionGroupsView(
          transactions: state.transactions,
          onTransactionTap: (tx) =>
              showTransactionDetailSheet(context, tx),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
        boxShadow: [
          BoxShadow(
            color: OpeiBrand.ink.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
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
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onAction,
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
          ],
        ],
      ),
    );
  }
}
