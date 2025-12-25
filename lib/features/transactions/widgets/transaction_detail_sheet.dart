import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tt1/data/models/wallet_transaction.dart';
import 'package:tt1/theme.dart';
import 'package:tt1/widgets/reference_copy_value.dart';

Future<void> showTransactionDetailSheet(
  BuildContext context,
  WalletTransaction transaction,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TransactionDetailSheet(transaction: transaction),
  );
}

class TransactionDetailSheet extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final metadataText = _stringifyMetadata(transaction.metadata);

    final entries = <_DetailEntry>[
      _DetailEntry('Amount', transaction.formattedAmount),
      if (transaction.normalizedStatus.isNotEmpty)
        _DetailEntry('Status', transaction.displayStatus),
      _DetailEntry('Reference', transaction.displayReference),
      _DetailEntry('Transaction Type', transaction.humanizedTransactionType),
      _DetailEntry('Currency', transaction.currency.toUpperCase()),
      _DetailEntry('Created At', transaction.formattedCreatedDateTime),
      if (transaction.updatedAt != null)
        _DetailEntry('Updated At', transaction.formattedUpdatedDateTime),
      if ((transaction.description ?? '').trim().isNotEmpty)
        _DetailEntry('Description', transaction.description!.trim(), multiline: true),
      if (metadataText != null && metadataText.trim().isNotEmpty)
        _DetailEntry('Metadata', metadataText.trim(), multiline: true),
    ];

    return FractionallySizedBox(
      heightFactor: 0.85,
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
                      transaction.listTitle,
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
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: transaction.isCredit
                                    ? OpeiColors.successGreen
                                    : OpeiColors.errorRed,
                              ),
                        ),
                        const SizedBox(width: 12),
                        if (transaction.normalizedStatus.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: OpeiColors.iosSurfaceMuted,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              transaction.normalizedStatus,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transaction.formattedCreatedDateTime,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: OpeiColors.iosLabelSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ...entries.map((entry) => _DetailRow(entry: entry)).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _stringifyMetadata(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return value.trim().isEmpty ? null : value;
    }

    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
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
    final valueText = entry.value.trim().isEmpty ? '—' : entry.value.trim();

    if (entry.label.toLowerCase() == 'reference') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
          pillPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                )
              : Text(
                  valueText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                ),
        ],
      ),
    );
  }
}