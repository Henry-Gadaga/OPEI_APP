import 'package:flutter/material.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/express_order.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';

/// Shared formatting + presentation helpers for the Express P2P modules
/// (customer and agent). Keeping these in one place ensures consistent labels,
/// colours, and money formatting everywhere.

String expressUsd(int cents) =>
    Money.fromCents(cents, currency: 'USD').format();

String expressFiat(int cents, String currency) {
  final cur = currency.trim().isEmpty ? 'USD' : currency.trim().toUpperCase();
  return Money.fromCents(cents, currency: cur).format();
}

/// Fiat currencies a customer can deposit from. USD is intentionally omitted as
/// an Express deposit converts local fiat → USD.
const List<ExpressCurrencyOption> kExpressCurrencies = <ExpressCurrencyOption>[
  ExpressCurrencyOption('MZN', 'Mozambican Metical'),
  ExpressCurrencyOption('ZMW', 'Zambian Kwacha'),
  ExpressCurrencyOption('MWK', 'Malawian Kwacha'),
  ExpressCurrencyOption('ZAR', 'South African Rand'),
  ExpressCurrencyOption('KES', 'Kenyan Shilling'),
  ExpressCurrencyOption('NGN', 'Nigerian Naira'),
];

class ExpressCurrencyOption {
  final String code;
  final String name;
  const ExpressCurrencyOption(this.code, this.name);
}

/// Human-friendly method type label (e.g. MOBILE_MONEY → Mobile Money).
String expressMethodTypeLabel(String methodType) {
  switch (methodType.toUpperCase()) {
    case 'MOBILE_MONEY':
      return ErrorHelper.l10n.withdrawMobileMoneyTitle;
    case 'BANK':
    case 'BANK_TRANSFER':
      return ErrorHelper.l10n.withdrawBankTransferTitle;
    case 'CARD':
      return ErrorHelper.l10n.cardsVirtualCardLabel;
    default:
      final cleaned = methodType.replaceAll('_', ' ').toLowerCase().trim();
      if (cleaned.isEmpty) return ErrorHelper.l10n.paymentMethodLabel;
      return cleaned[0].toUpperCase() + cleaned.substring(1);
  }
}

/// Customer-facing presentation for an order status.
class ExpressStatusView {
  final String label;
  final Color color;
  final Color background;
  final IconData icon;

  const ExpressStatusView({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });
}

ExpressStatusView expressCustomerStatusView(
  ExpressOrderStatus status,
  AppLocalizations l10n,
) {
  switch (status) {
    case ExpressOrderStatus.pendingAgent:
      return ExpressStatusView(
        label: l10n.expressStatusFindingAgent,
        color: OpeiBrand.warning,
        background: Color(0xFFFFF4E0),
        icon: Icons.search_rounded,
      );
    case ExpressOrderStatus.awaitingPayment:
      return ExpressStatusView(
        label: l10n.expressStatusPayNow,
        color: OpeiBrand.primary,
        background: OpeiBrand.primaryTint,
        icon: Icons.account_balance_wallet_outlined,
      );
    case ExpressOrderStatus.paidByUser:
      return ExpressStatusView(
        label: l10n.expressStatusVerifying,
        color: OpeiBrand.warning,
        background: Color(0xFFFFF4E0),
        icon: Icons.hourglass_bottom_rounded,
      );
    case ExpressOrderStatus.disputed:
      return ExpressStatusView(
        label: l10n.expressStatusUnderReview,
        color: OpeiBrand.danger,
        background: Color(0xFFFCE8EA),
        icon: Icons.report_problem_outlined,
      );
    case ExpressOrderStatus.completed:
      return ExpressStatusView(
        label: l10n.expressStatusCompleted,
        color: OpeiBrand.success,
        background: Color(0xFFE7F6EC),
        icon: Icons.check_circle_outline_rounded,
      );
    case ExpressOrderStatus.expired:
      return ExpressStatusView(
        label: l10n.expressStatusExpired,
        color: OpeiBrand.inkTertiary,
        background: OpeiBrand.surfaceMuted,
        icon: Icons.timer_off_outlined,
      );
    case ExpressOrderStatus.cancelled:
      return ExpressStatusView(
        label: l10n.expressStatusCancelled,
        color: OpeiBrand.danger,
        background: Color(0xFFFCE8EA),
        icon: Icons.cancel_outlined,
      );
    case ExpressOrderStatus.unknown:
      return ExpressStatusView(
        label: l10n.expressStatusProcessing,
        color: OpeiBrand.inkTertiary,
        background: OpeiBrand.surfaceMuted,
        icon: Icons.sync_rounded,
      );
  }
}

/// Agent-facing presentation for an order status.
ExpressStatusView expressAgentStatusView(
  ExpressOrderStatus status,
  AppLocalizations l10n,
) {
  switch (status) {
    case ExpressOrderStatus.pendingAgent:
      return ExpressStatusView(
        label: l10n.expressStatusAvailable,
        color: OpeiBrand.warning,
        background: Color(0xFFFFF4E0),
        icon: Icons.new_releases_outlined,
      );
    case ExpressOrderStatus.awaitingPayment:
      return ExpressStatusView(
        label: l10n.expressStatusWaitingPayment,
        color: OpeiBrand.primary,
        background: OpeiBrand.primaryTint,
        icon: Icons.schedule_rounded,
      );
    case ExpressOrderStatus.paidByUser:
      return ExpressStatusView(
        label: l10n.expressStatusConfirmPayment,
        color: OpeiBrand.warning,
        background: Color(0xFFFFF4E0),
        icon: Icons.verified_user_outlined,
      );
    case ExpressOrderStatus.disputed:
      return ExpressStatusView(
        label: l10n.expressStatusUnderReview,
        color: OpeiBrand.danger,
        background: Color(0xFFFCE8EA),
        icon: Icons.report_problem_outlined,
      );
    case ExpressOrderStatus.completed:
      return ExpressStatusView(
        label: l10n.expressStatusCompleted,
        color: OpeiBrand.success,
        background: Color(0xFFE7F6EC),
        icon: Icons.check_circle_outline_rounded,
      );
    case ExpressOrderStatus.expired:
      return ExpressStatusView(
        label: l10n.expressStatusExpired,
        color: OpeiBrand.inkTertiary,
        background: OpeiBrand.surfaceMuted,
        icon: Icons.timer_off_outlined,
      );
    case ExpressOrderStatus.cancelled:
      return ExpressStatusView(
        label: l10n.expressStatusCancelled,
        color: OpeiBrand.danger,
        background: Color(0xFFFCE8EA),
        icon: Icons.cancel_outlined,
      );
    case ExpressOrderStatus.unknown:
      return ExpressStatusView(
        label: l10n.expressStatusProcessing,
        color: OpeiBrand.inkTertiary,
        background: OpeiBrand.surfaceMuted,
        icon: Icons.sync_rounded,
      );
  }
}

/// Small rounded status pill.
class ExpressStatusPill extends StatelessWidget {
  final ExpressStatusView view;
  const ExpressStatusPill({super.key, required this.view});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: view.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(view.icon, size: 13, color: view.color),
          const SizedBox(width: 5),
          Text(
            view.label,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: view.color,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
