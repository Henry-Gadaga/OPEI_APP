import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opei/data/models/card_transaction.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';

Future<void> showCardTransactionDetailSheet(
  BuildContext context,
  CardTransaction transaction,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    useSafeArea: false,
    builder: (context) => CardTransactionDetailSheet(transaction: transaction),
  );
}

class CardTransactionDetailSheet extends StatelessWidget {
  final CardTransaction transaction;

  const CardTransactionDetailSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCredit = transaction.isCredit;
    final amountColor =
        isCredit ? const Color(0xFF137A33) : OpeiBrand.ink;
    final iconBg =
        isCredit ? const Color(0xFFE6F6EA) : OpeiBrand.surfaceMuted;
    final iconFg =
        isCredit ? const Color(0xFF137A33) : OpeiBrand.ink;
    final iconData =
        isCredit ? Icons.south_rounded : Icons.north_rounded;

    // Strip sign characters — we convey direction via colour and icon
    final amountDisplay = transaction.formattedAmount
        .replaceAll('+', '')
        .replaceAll('−', '')
        .replaceAll('-', '')
        .trim();

    final status = transaction.normalizedStatus.toUpperCase();

    final entries = <_Entry>[
      if (transaction.normalizedType.isNotEmpty)
        _Entry(l10n.transactionTypeLabel, transaction.normalizedType),
      if (transaction.normalizedTransactionType.isNotEmpty)
        _Entry(l10n.transactionTransactionTypeLabel, transaction.normalizedTransactionType),
      _Entry(
        l10n.transactionDirectionLabel,
        isCredit ? l10n.transactionIncomingValue : l10n.transactionOutgoingValue,
      ),
      _Entry(l10n.currencyLabel, transaction.currencyLabel),
      if (transaction.balanceAfterDetail.isNotEmpty)
        _Entry(l10n.cardBalanceAfterRow, transaction.balanceAfterDetail),
      if (transaction.normalizedMethod.isNotEmpty)
        _Entry(l10n.transactionMethodLabel, transaction.normalizedMethod),
      if ((transaction.reference ?? '').trim().isNotEmpty)
        _Entry(l10n.referenceLabel, transaction.reference!.trim(), isCopy: true),
    ];

    final narrative = (transaction.narrative ?? '').trim();
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Handle + close ─────────────────────────────────────────
            _Handle(onClose: () => Navigator.of(context).maybePop()),

            // ── Header: icon · title + date · status ───────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(iconData, color: iconFg, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          transaction.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: OpeiBrand.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (transaction.formattedDate.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            transaction.formattedDate,
                            style: const TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: OpeiBrand.inkSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusChip(status: status),
                ],
              ),
            ),

            // ── Amount ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amountDisplay,
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ),
              ),
            ),

            // ── Divider ────────────────────────────────────────────────
            const Divider(height: 1, thickness: 0.6, color: OpeiBrand.hairline),

            // ── Detail rows ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++)
                    _DetailRow(
                      entry: entries[i],
                      showDivider: i != entries.length - 1 ||
                          narrative.isNotEmpty,
                    ),
                ],
              ),
            ),

            // ── Narrative / note ───────────────────────────────────────
            if (narrative.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.transactionNoteLabel,
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: OpeiBrand.inkTertiary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SelectableText(
                      narrative,
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: OpeiBrand.ink,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20 + bottomPad),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Handle + close
// ─────────────────────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  final VoidCallback onClose;
  const _Handle({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Stack(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 34,
              height: 4,
              decoration: BoxDecoration(
                color: OpeiBrand.hairlineStrong,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 6,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: OpeiBrand.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: OpeiBrand.inkSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status chip
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status.isEmpty) return const SizedBox.shrink();

    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'COMPLETED':
      case 'SUCCESS':
        bg = const Color(0xFFE6F6EA);
        fg = const Color(0xFF137A33);
        label = AppLocalizations.of(context)!.transactionStatusCompleted;
        break;
      case 'PENDING':
      case 'PROCESSING':
        bg = const Color(0xFFFFF6E0);
        fg = const Color(0xFF8A5A00);
        label = AppLocalizations.of(context)!.pendingStatus;
        break;
      case 'FAILED':
      case 'DECLINED':
        bg = const Color(0xFFFDECEC);
        fg = OpeiBrand.danger;
        label = status == 'FAILED'
            ? AppLocalizations.of(context)!.transactionStatusFailed
            : AppLocalizations.of(context)!.transactionStatusDeclined;
        break;
      default:
        bg = OpeiBrand.surfaceMuted;
        fg = OpeiBrand.inkSecondary;
        label = status.isNotEmpty
            ? status[0] + status.substring(1).toLowerCase()
            : '';
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail row
// ─────────────────────────────────────────────────────────────────────────────

class _Entry {
  final String label;
  final String value;
  final bool isCopy;
  const _Entry(this.label, this.value, {this.isCopy = false});
}

class _DetailRow extends StatelessWidget {
  final _Entry entry;
  final bool showDivider;
  const _DetailRow({required this.entry, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final val = entry.value.trim().isEmpty ? '—' : entry.value.trim();

    return Container(
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: OpeiBrand.hairline, width: 0.5),
              ),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              entry.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.inkSecondary,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: entry.isCopy
                ? _CopyValue(value: val)
                : Text(
                    val,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: OpeiBrand.ink,
                      letterSpacing: -0.1,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tap-to-copy reference
// ─────────────────────────────────────────────────────────────────────────────

class _CopyValue extends StatefulWidget {
  final String value;
  const _CopyValue({required this.value});

  @override
  State<_CopyValue> createState() => _CopyValueState();
}

class _CopyValueState extends State<_CopyValue> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copy,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              widget.value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: OpeiBrand.ink,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(width: 5),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              key: ValueKey(_copied),
              size: 13,
              color: _copied
                  ? const Color(0xFF137A33)
                  : OpeiBrand.inkTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
