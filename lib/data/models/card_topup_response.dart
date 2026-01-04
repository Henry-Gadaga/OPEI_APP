import 'package:opei/core/money/money.dart';

/// Response returned after confirming a card top-up.
class CardTopUpResponse {
  final String reference;
  final String status;
  final Money amount;
  final Money fee;
  final Money totalDebit;

  CardTopUpResponse({
    required this.reference,
    required this.status,
    required this.amount,
    required this.fee,
    required this.totalDebit,
  });

  factory CardTopUpResponse.fromJson(
    Map<String, dynamic> json, {
    String currency = 'USD',
    int? fallbackAmountCents,
    int? fallbackFeeCents,
    int? fallbackTotalCents,
  }) {
    Money parseMoney(dynamic value, {int? fallback}) => Money.fromJson(
          value,
          currency: currency,
          fallbackCents: fallback,
        );

    final parsedAmount = parseMoney(json['amountCents'] ?? json['amount'], fallback: fallbackAmountCents);
    final parsedFee = parseMoney(json['feeCents'] ?? json['fee'], fallback: fallbackFeeCents);
    final parsedTotal = parseMoney(
      json['totalDebitCents'] ?? json['totalDebit'] ?? json['total'],
      fallback: fallbackTotalCents ?? (parsedAmount.cents + parsedFee.cents),
    );

    return CardTopUpResponse(
      reference: json['reference']?.toString().trim() ?? '',
      status: json['status']?.toString().trim() ?? '',
      amount: parsedAmount,
      fee: parsedFee,
      totalDebit: parsedTotal,
    );
  }

  Money get amountMoney => amount;
  Money get feeMoney => fee;
  Money get totalDebitMoney => totalDebit;
}