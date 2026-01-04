import 'package:flutter/material.dart';
import 'package:opei/data/models/card_transaction.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/reference_copy_value.dart';

Future<void> showCardTransactionDetailSheet(
  BuildContext context,
  CardTransaction transaction,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CardTransactionDetailSheet(transaction: transaction),
  );
}

class CardTransactionDetailSheet extends StatelessWidget {
  final CardTransaction transaction;

  const CardTransactionDetailSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();
    final methodLabel = transaction.normalizedMethod;

    return FractionallySizedBox(
      heightFactor: 0.82,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: Material(
          color: OpeiColors.pureWhite,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiColors.iosSurfaceMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  children: [
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          transaction.formattedAmount,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: transaction.isCredit
                                    ? OpeiColors.successGreen
                                    : OpeiColors.errorRed,
                              ),
                        ),
                        const SizedBox(width: 12),
                        if (transaction.normalizedStatus.isNotEmpty)
                          _StatusPill(label: transaction.normalizedStatus),
                        if (transaction.normalizedType.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _StatusPill(label: transaction.normalizedType, inverted: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (transaction.formattedDate.isNotEmpty)
                      Text(
                        transaction.formattedDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: OpeiColors.iosLabelSecondary,
                            ),
                      ),
                    if (methodLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Method • $methodLabel',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: OpeiColors.iosLabelSecondary,
                            ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ...entries.map((entry) => _DetailRow(entry: entry)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_DetailEntry> _buildEntries() {
    final entries = <_DetailEntry>[
      _DetailEntry('Card Balance After', transaction.balanceAfterDetail),
      _DetailEntry('Type', transaction.normalizedType),
      _DetailEntry('Transaction Type', transaction.normalizedTransactionType),
      _DetailEntry('Narrative', transaction.narrative?.trim() ?? '', multiline: true),
      _DetailEntry('Status', transaction.normalizedStatus),
      _DetailEntry('Currency', transaction.currencyLabel),
      _DetailEntry('Reference', transaction.reference?.trim() ?? ''),
    ];

    return entries.where((entry) => entry.value.trim().isNotEmpty).toList(growable: false);
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool inverted;

  const _StatusPill({required this.label, this.inverted = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = label.trim();
    final background = inverted
        ? OpeiColors.pureBlack
        : OpeiColors.iosSurfaceMuted;
    final foreground = inverted
        ? OpeiColors.pureWhite
        : OpeiColors.pureBlack;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized,
        style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: foreground,
            ),
      ),
    );
  }
}

class _DetailEntry {
  final String label;
  final String value;
  final bool multiline;

  const _DetailEntry(this.label, this.value, {this.multiline = false});
}

class _DetailRow extends StatelessWidget {
  final _DetailEntry entry;

  const _DetailRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final valueText = entry.value.trim();

    if (entry.label.toLowerCase() == 'reference') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: ReferenceCopyValue(
          label: entry.label,
          reference: valueText,
          labelOnTop: true,
          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 13,
                color: OpeiColors.iosLabelSecondary,
                letterSpacing: 0.2,
              ),
          valueStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                  color: OpeiColors.iosLabelSecondary,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 6),
          entry.multiline
              ? SelectableText(
                  valueText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                )
              : Text(
                  valueText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                ),
        ],
      ),
    );
  }
}