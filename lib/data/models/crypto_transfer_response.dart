import 'package:opei/core/money/money.dart';

class CryptoTransferResponse {
  final String status;
  final String reference;
  final Money amount;
  final String chain;
  final String asset;

  CryptoTransferResponse({
    required this.status,
    required this.reference,
    required this.amount,
    required this.chain,
    required this.asset,
  });

  factory CryptoTransferResponse.fromJson(Map<String, dynamic> json) {
    final asset = (json['asset'] ?? json['currency'] ?? '').toString().toUpperCase();
    final currency = asset.isEmpty ? 'USD' : asset;

    return CryptoTransferResponse(
      status: (json['status'] ?? '').toString(),
      reference: (json['reference'] ?? json['ref'] ?? '').toString(),
      amount: Money.fromJson(json['amountCents'] ?? json['amount'] ?? json['value'], currency: currency),
      chain: (json['chain'] ?? json['network'] ?? '').toString(),
      asset: currency,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'reference': reference,
        'amountCents': amount.cents,
        'chain': chain,
        'asset': asset,
      };
}