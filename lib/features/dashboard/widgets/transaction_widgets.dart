import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tt1/core/money/money.dart';
import 'package:tt1/data/models/wallet_transaction.dart';
import 'package:tt1/theme.dart';

class TransactionGroupsView extends StatelessWidget {
  final List<WalletTransaction> transactions;
  final ValueChanged<WalletTransaction>? onTransactionTap;

  const TransactionGroupsView({
    super.key,
    required this.transactions,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    final groups = _groupTransactions(transactions);
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var gIndex = 0; gIndex < groups.length; gIndex++) ...[
          if (!_shouldSuppressLabel(groups[gIndex].label))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                groups[gIndex].label.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: OpeiColors.iosLabelSecondary,
                    ),
              ),
            ),
          Column(
            children: [
              for (var i = 0; i < groups[gIndex].transactions.length; i++)
                WalletTransactionTile(
                  transaction: groups[gIndex].transactions[i],
                  showDivider: i != groups[gIndex].transactions.length - 1,
                  onTap: onTransactionTap == null
                      ? null
                      : () => onTransactionTap!(groups[gIndex].transactions[i]),
                ),
            ],
          ),
          if (gIndex != groups.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

bool _shouldSuppressLabel(String label) =>
    label.trim().toLowerCase() == 'today';

class _TransactionGroup {
  final String label;
  final List<WalletTransaction> transactions;

  const _TransactionGroup(this.label, this.transactions);
}

List<_TransactionGroup> _groupTransactions(
    List<WalletTransaction> transactions) {
  if (transactions.isEmpty) {
    return const [];
  }

  final sorted = List<WalletTransaction>.from(transactions)
    ..sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

  final groups = <_TransactionGroup>[];
  String? currentLabel;
  List<WalletTransaction>? currentItems;

  for (final tx in sorted) {
    final label = _buildGroupLabel(tx.createdAt);
    if (label != currentLabel) {
      currentItems = <WalletTransaction>[];
      groups.add(_TransactionGroup(label, currentItems));
      currentLabel = label;
    }
    currentItems!.add(tx);
  }

  return groups;
}

String _buildGroupLabel(DateTime? date) {
  if (date == null) return 'Earlier';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = today.difference(target).inDays;

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';

  return DateFormat('MMM d, yyyy').format(date);
}

class _TransactionTypeVisual {
  final String label;
  final IconData icon;

  const _TransactionTypeVisual({
    required this.label,
    required this.icon,
  });
}

const _transactionTypeVisuals = <String, _TransactionTypeVisual>{
  'CARD_TOPUP': _TransactionTypeVisual(
    label: 'Card Top-up',
    icon: Icons.credit_card,
  ),
  'CRYPTO_DEPOSIT': _TransactionTypeVisual(
    label: 'Crypto Deposit',
    icon: Icons.currency_bitcoin,
  ),
  'P2P_RECEIVE': _TransactionTypeVisual(
    label: 'Received from',
    icon: Icons.person_add_alt_1,
  ),
  'ADMIN_ADJUSTMENT': _TransactionTypeVisual(
    label: 'Account Adjustment',
    icon: Icons.tune,
  ),
  'CARD_WITHDRAWAL': _TransactionTypeVisual(
    label: 'Card Withdrawal',
    icon: Icons.credit_card,
  ),
  'CRYPTO_SEND': _TransactionTypeVisual(
    label: 'Crypto Sent',
    icon: Icons.currency_bitcoin,
  ),
  'P2P_SEND': _TransactionTypeVisual(
    label: 'Sent to',
    icon: Icons.person_remove_alt_1,
  ),
  'FEE': _TransactionTypeVisual(
    label: 'Transaction Fee',
    icon: Icons.receipt_long,
  ),
  'REVERSAL': _TransactionTypeVisual(
    label: 'Reversal',
    icon: Icons.undo,
  ),
};

class WalletTransactionTile extends StatelessWidget {
  final WalletTransaction transaction;
  final bool showDivider;
  final VoidCallback? onTap;

  const WalletTransactionTile({
    super.key,
    required this.transaction,
    this.showDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = _TransactionTileViewModel.fromTransaction(transaction);
    final border = showDivider
        ? Border(
            bottom: BorderSide(color: OpeiColors.iosSeparator, width: 0.5),
          )
        : null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: viewModel.opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: viewModel.isPending ? null : onTap,
          child: Container(
            decoration: BoxDecoration(border: border),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _TransactionIconCircle(
                  icon: viewModel.icon,
                  filled: viewModel.iconFilled,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              viewModel.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            viewModel.amountLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                  color: viewModel.amountColor,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              viewModel.subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 11,
                                    color: OpeiColors.iosLabelSecondary,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(data: viewModel.badge),
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

class _TransactionIconCircle extends StatelessWidget {
  final IconData icon;
  final bool filled;

  const _TransactionIconCircle({required this.icon, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: filled ? OpeiColors.pureBlack : OpeiColors.pureWhite,
        shape: BoxShape.circle,
        border: Border.all(color: OpeiColors.pureBlack, width: 1),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: filled ? OpeiColors.pureWhite : OpeiColors.pureBlack,
        size: 16,
      ),
    );
  }
}

class _StatusBadgeData {
  final String label;
  final String icon;
  final Color background;
  final Color textColor;
  final bool showSpinner;

  const _StatusBadgeData({
    required this.label,
    required this.icon,
    required this.background,
    required this.textColor,
    required this.showSpinner,
  });

  bool get isPending => showSpinner;
}

class _StatusBadge extends StatelessWidget {
  final _StatusBadgeData data;

  const _StatusBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    return Text(
      data.label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: data.textColor,
            letterSpacing: 0.1,
          ),
    );
  }
}

class _TransactionTileViewModel {
  final IconData icon;
  final bool iconFilled;
  final String title;
  final String subtitle;
  final String amountLabel;
  final Color amountColor;
  final _StatusBadgeData badge;
  final double opacity;

  bool get isPending => badge.isPending;

  const _TransactionTileViewModel({
    required this.icon,
    required this.iconFilled,
    required this.title,
    required this.subtitle,
    required this.amountLabel,
    required this.amountColor,
    required this.badge,
    required this.opacity,
  });

  factory _TransactionTileViewModel.fromTransaction(
      WalletTransaction transaction) {
    final rawType = transaction.rawType?.toUpperCase() ?? '';
    final typeVisual = _transactionTypeVisuals[rawType];
    final isIncoming = transaction.isIncoming;
    final icon = typeVisual?.icon ??
        (isIncoming ? Icons.call_received : Icons.call_made);
    final resolvedTitle =
        transaction.isPeerToPeer && transaction.listTitle.isNotEmpty
            ? transaction.listTitle
            : (typeVisual?.label ?? transaction.listTitle);
    final amount = Money.fromCents(transaction.amountCents.abs(),
        currency: transaction.currency);
    final amountLabel =
        '${isIncoming ? '+' : '-'}${amount.format(includeCurrencySymbol: true)}';
    final amountColor =
        isIncoming ? OpeiColors.successGreen : OpeiColors.errorRed;
    final subtitle = _formatListDateTime(transaction.createdAt);
    final badge = _buildStatusBadge(transaction);
    final opacity = badge.isPending ? 0.7 : 1.0;

    return _TransactionTileViewModel(
      icon: icon,
      iconFilled: !isIncoming,
      title: resolvedTitle,
      subtitle: subtitle,
      amountLabel: amountLabel,
      amountColor: amountColor,
      badge: badge,
      opacity: opacity,
    );
  }
}

_StatusBadgeData _buildStatusBadge(WalletTransaction transaction) {
  final normalized = transaction.status?.trim().toUpperCase() ?? '';
  const badgeBackground = OpeiColors.iosSurfaceMuted;
  const badgeText = OpeiColors.iosLabelSecondary;

  if (normalized == 'PENDING') {
    return _StatusBadgeData(
      label: 'Processing',
      icon: '',
      background: badgeBackground,
      textColor: badgeText,
      showSpinner: false,
    );
  }

  return _StatusBadgeData(
    label: 'Completed',
    icon: '',
    background: badgeBackground,
    textColor: badgeText,
    showSpinner: false,
  );
}

String _formatListDateTime(DateTime? date) {
  if (date == null) return 'Date unavailable';
  final formatter = DateFormat('MMM d, yyyy • h:mm a');
  return formatter.format(date);
}

class TransactionsListSkeleton extends StatelessWidget {
  final int itemCount;

  const TransactionsListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        final showDivider = index != itemCount - 1;
        return Container(
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom:
                        BorderSide(color: OpeiColors.iosSeparator, width: 0.5))
                : null,
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _SkeletonCircle(),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonLine(width: 120, height: 11),
                      SizedBox(height: 5),
                      _SkeletonLine(width: 90, height: 9),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                _SkeletonLine(width: 60, height: 12),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SkeletonCircle extends StatefulWidget {
  const _SkeletonCircle();

  @override
  State<_SkeletonCircle> createState() => _SkeletonCircleState();
}

class _SkeletonCircleState extends State<_SkeletonCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const baseColor = OpeiColors.iosSurfaceMuted;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final opacity = 0.35 + (0.25 * _pulse.value);
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: baseColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}

class _SkeletonLine extends StatefulWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  State<_SkeletonLine> createState() => _SkeletonLineState();
}

class _SkeletonLineState extends State<_SkeletonLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const baseColor = OpeiColors.iosSurfaceMuted;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final opacity = 0.35 + (0.25 * _pulse.value);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
