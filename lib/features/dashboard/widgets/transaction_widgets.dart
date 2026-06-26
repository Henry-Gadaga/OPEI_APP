import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/data/models/wallet_transaction.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';

// =====================================================================
// Public: TransactionGroupsView — sleek grouped list of tiles.
// =====================================================================

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
    final l10n = AppLocalizations.of(context)!;
    final groups = _groupTransactions(transactions, l10n);
    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var gIndex = 0; gIndex < groups.length; gIndex++) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 6),
            child: Text(
              groups[gIndex].label,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: OpeiBrand.inkTertiary,
                letterSpacing: 0.1,
              ),
            ),
          ),
          for (var i = 0; i < groups[gIndex].transactions.length; i++)
            WalletTransactionTile(
              transaction: groups[gIndex].transactions[i],
              showDivider: i != groups[gIndex].transactions.length - 1,
              onTap: onTransactionTap == null
                  ? null
                  : () => onTransactionTap!(groups[gIndex].transactions[i]),
            ),
          if (gIndex != groups.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _TransactionGroup {
  final String label;
  final List<WalletTransaction> transactions;
  const _TransactionGroup(this.label, this.transactions);
}

List<_TransactionGroup> _groupTransactions(
  List<WalletTransaction> transactions,
  AppLocalizations l10n,
) {
  if (transactions.isEmpty) return const [];

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
    final label = _buildGroupLabel(tx.createdAt, l10n);
    if (label != currentLabel) {
      currentItems = <WalletTransaction>[];
      groups.add(_TransactionGroup(label, currentItems));
      currentLabel = label;
    }
    currentItems!.add(tx);
  }
  return groups;
}

String _buildGroupLabel(DateTime? date, AppLocalizations l10n) {
  if (date == null) return l10n.transactionsEarlierGroup;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = today.difference(target).inDays;

  if (diff == 0) return l10n.transactionsTodayGroup;
  if (diff == 1) return l10n.transactionsYesterdayGroup;
  if (diff < 7) return DateFormat('EEEE').format(date); // "Wednesday"
  if (date.year == now.year) return DateFormat('EEE, d MMM').format(date);
  return DateFormat('d MMM yyyy').format(date);
}

// =====================================================================
// Type → label / icon map
// =====================================================================

class _TypeVisual {
  final IconData icon;
  const _TypeVisual({required this.icon});
}

const _typeVisuals = <String, _TypeVisual>{
  'CARD_TOPUP': _TypeVisual(icon: Icons.credit_card_rounded),
  'CARD_WITHDRAWAL': _TypeVisual(icon: Icons.credit_card_rounded),
  'CRYPTO_DEPOSIT': _TypeVisual(icon: Icons.currency_bitcoin),
  'CRYPTO_SEND': _TypeVisual(icon: Icons.currency_bitcoin),
  'P2P_RECEIVE': _TypeVisual(icon: Icons.south_rounded),
  'P2P_SEND': _TypeVisual(icon: Icons.north_rounded),
  'ADMIN_ADJUSTMENT': _TypeVisual(icon: Icons.tune_rounded),
  'FEE': _TypeVisual(icon: Icons.receipt_long_rounded),
  'REVERSAL': _TypeVisual(icon: Icons.undo_rounded),
};

// =====================================================================
// WalletTransactionTile — sleek, single-row, color-coded
// =====================================================================

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
    final vm = _TileViewModel.fromTransaction(
      transaction,
      AppLocalizations.of(context)!,
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: vm.opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: OpeiBrand.primary.withValues(alpha: 0.04),
          highlightColor: OpeiBrand.primary.withValues(alpha: 0.02),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: showDivider
                  ? const Border(
                      bottom: BorderSide(color: OpeiBrand.hairline, width: 0.6),
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _TransactionIconBadge(icon: vm.icon, isIncoming: vm.isIncoming),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              vm.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: kPrimaryFontFamily,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: OpeiBrand.ink,
                                letterSpacing: -0.2,
                                height: 1.15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                vm.amountLabel,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: kPrimaryFontFamily,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: vm.amountColor,
                                  letterSpacing: -0.3,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vm.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: kPrimaryFontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: OpeiBrand.inkSecondary,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          if (vm.statusPill != null) ...[
                            const SizedBox(width: 8),
                            vm.statusPill!,
                          ],
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

// =====================================================================
// Icon badge — rounded-square (12r) with green tint for incoming,
// neutral muted tint for outgoing.
// =====================================================================

class _TransactionIconBadge extends StatelessWidget {
  final IconData icon;
  final bool isIncoming;

  const _TransactionIconBadge({required this.icon, required this.isIncoming});

  static const _incomingBg = Color(0xFFE6F6EA);
  static const _incomingFg = Color(0xFF137A33);
  static const _outgoingBg = OpeiBrand.surfaceMuted;
  static const _outgoingFg = OpeiBrand.ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isIncoming ? _incomingBg : _outgoingBg,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 20,
        color: isIncoming ? _incomingFg : _outgoingFg,
      ),
    );
  }
}

// =====================================================================
// Status pill (only for non-completed states, e.g. Pending/Failed)
// =====================================================================

class _StatusPill extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;

  const _StatusPill({
    required this.label,
    required this.background,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: kPrimaryFontFamily,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// =====================================================================
// View model
// =====================================================================

class _TileViewModel {
  final IconData icon;
  final bool isIncoming;
  final String title;
  final String subtitle;
  final String amountLabel;
  final Color amountColor;
  final Widget? statusPill;
  final double opacity;
  final bool isPending;

  const _TileViewModel({
    required this.icon,
    required this.isIncoming,
    required this.title,
    required this.subtitle,
    required this.amountLabel,
    required this.amountColor,
    required this.statusPill,
    required this.opacity,
    required this.isPending,
  });

  factory _TileViewModel.fromTransaction(
    WalletTransaction tx,
    AppLocalizations l10n,
  ) {
    final rawType = tx.rawType?.toUpperCase() ?? '';
    final visual = _typeVisuals[rawType];
    final isIncoming = tx.isIncoming;
    final isCrypto = tx.isCryptoTransfer;
    final icon = isCrypto
        ? Icons.currency_bitcoin_rounded
        : (visual?.icon ??
              (isIncoming ? Icons.south_rounded : Icons.north_rounded));

    final amount = Money.fromCents(tx.amountCents.abs(), currency: tx.currency);
    final amountLabel =
        '${isIncoming ? '+' : '−'}${amount.format(includeCurrencySymbol: true)}';

    // Modern fintech: incoming = green; outgoing = ink (not alarming red).
    final amountColor = isIncoming ? const Color(0xFF137A33) : OpeiBrand.ink;

    // Subtitle shows time only ("12:45 PM") — group header already shows the day.
    final subtitle = _formatTimeOnly(tx.createdAt);

    final pill = _buildStatusPill(tx, l10n);
    final isPending = tx.isPending;

    return _TileViewModel(
      icon: icon,
      isIncoming: isIncoming,
      title: tx.listTitle,
      subtitle: subtitle,
      amountLabel: amountLabel,
      amountColor: amountColor,
      statusPill: pill,
      opacity: isPending ? 0.78 : 1.0,
      isPending: isPending,
    );
  }
}

Widget? _buildStatusPill(WalletTransaction tx, AppLocalizations l10n) {
  final s = tx.status?.trim().toUpperCase() ?? '';

  if (s == 'PENDING' || s == 'PROCESSING') {
    return _StatusPill(
      label: l10n.pendingStatus,
      background: Color(0xFFFFF6E0),
      textColor: Color(0xFF8A5A00),
    );
  }
  if (s == 'FAILED' || s == 'DECLINED' || s == 'CANCELLED' || s == 'CANCELED') {
    return _StatusPill(
      label: s == 'FAILED'
          ? l10n.transactionsFailedStatus
          : l10n.transactionsCancelledStatus,
      background: const Color(0xFFFDECEC),
      textColor: OpeiBrand.danger,
    );
  }
  if (s == 'REVERSED' || s == 'REFUNDED') {
    return _StatusPill(
      label: s == 'REVERSED'
          ? l10n.transactionsReversedStatus
          : l10n.transactionsRefundedStatus,
      background: OpeiBrand.surfaceMuted,
      textColor: OpeiBrand.inkSecondary,
    );
  }
  // Completed → no pill (cleaner look). Time alone in the subtitle.
  return null;
}

String _formatTimeOnly(DateTime? date) {
  if (date == null) return '—';
  return DateFormat('h:mm a').format(date);
}

// =====================================================================
// Skeleton — mirrors new tile shape
// =====================================================================

class TransactionsListSkeleton extends StatelessWidget {
  final int itemCount;
  const TransactionsListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        final showDivider = index != itemCount - 1;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(
                    bottom: BorderSide(color: OpeiBrand.hairline, width: 0.6),
                  )
                : null,
          ),
          child: Row(
            children: const [
              _SkRect(w: 40, h: 40, r: 12),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkRect(w: 130, h: 12, r: 6),
                    SizedBox(height: 6),
                    _SkRect(w: 80, h: 10, r: 6),
                  ],
                ),
              ),
              SizedBox(width: 12),
              _SkRect(w: 70, h: 12, r: 6),
            ],
          ),
        );
      }),
    );
  }
}

class _SkRect extends StatefulWidget {
  final double w;
  final double h;
  final double r;
  const _SkRect({required this.w, required this.h, required this.r});

  @override
  State<_SkRect> createState() => _SkRectState();
}

class _SkRectState extends State<_SkRect> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (context, child) {
        final opacity = 0.55 + 0.30 * _a.value;
        return Container(
          width: widget.w,
          height: widget.h,
          decoration: BoxDecoration(
            color: OpeiBrand.surfaceMuted.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(widget.r),
          ),
        );
      },
    );
  }
}
