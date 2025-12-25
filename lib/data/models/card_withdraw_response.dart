import 'package:tt1/core/money/money.dart';

/// Response returned after confirming a card withdrawal.
class CardWithdrawResponse {
  final String reference;
  final String status;
  final Money amount;
  final Money fee;
  final Money netAmount;

  CardWithdrawResponse({
    required this.reference,
    required this.status,
    required this.amount,
    required this.fee,
    required this.netAmount,
  });

  factory CardWithdrawResponse.fromJson(
    Map<String, dynamic> json, {
    String currency = 'USD',
    int? fallbackAmountCents,
    int? fallbackFeeCents,
    int? fallbackNetCents,
  }) {
    Money parseMoney(dynamic value, {int? fallback}) => Money.fromJson(
          value,
          currency: currency,
          fallbackCents: fallback,
        );

    final parsedAmount = parseMoney(json['amountCents'] ?? json['amount'], fallback: fallbackAmountCents);
    final parsedFee = parseMoney(json['feeCents'] ?? json['fee'], fallback: fallbackFeeCents);
    final parsedNet = parseMoney(json['netAmountCents'] ?? json['netAmount'] ?? json['net'], fallback: fallbackNetCents);

    return CardWithdrawResponse(
      reference: json['reference']?.toString().trim() ?? '',
      status: json['status']?.toString().trim() ?? '',
      amount: parsedAmount,
      fee: parsedFee,
      netAmount: parsedNet,
    );
  }

  Money get amountMoney => amount;
  Money get feeMoney => fee;
  Money get netMoney => netAmount;
}
