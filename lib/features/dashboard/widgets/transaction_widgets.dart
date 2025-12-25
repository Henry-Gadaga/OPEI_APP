import 'package:flutter/material.dart';
import 'package:tt1/data/models/wallet_transaction.dart';
import 'package:tt1/theme.dart';

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
    final isCredit = transaction.isCredit;
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        );
    final amountStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isCredit ? OpeiColors.successGreen : OpeiColors.errorRed,
          letterSpacing: -0.15,
        );

    final secondaryStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 10.5,
          color: OpeiColors.iosLabelSecondary,
          letterSpacing: -0.05,
        );

    final primaryLabel = transaction.listTitle;
    final dateLabel = transaction.formattedDate;
    final statusLabel = transaction.normalizedStatus;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: showDivider ? Border(bottom: BorderSide(color: OpeiColors.iosSeparator, width: 0.5)) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                              primaryLabel,
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
                        [
                          if (dateLabel.isNotEmpty) dateLabel,
                          if (statusLabel.isNotEmpty) statusLabel,
                        ].join(' • '),
                        style: secondaryStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            border: showDivider ? Border(bottom: BorderSide(color: OpeiColors.iosSeparator, width: 0.5)) : null,
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
                      _SkeletonLine(width: 124, height: 12),
                      SizedBox(height: 5),
                      _SkeletonLine(width: 96, height: 10),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                _SkeletonLine(width: 56, height: 13),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: OpeiColors.iosSurfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: OpeiColors.iosSurfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}