import 'package:tt1/core/money/money.dart';

class CardCreationPreview {
  final bool canCreate;
  final Money creationFee;
  final Money cardWillReceive;
  final Money totalToCharge;
  final Money walletBalance;
  final Money walletBalanceAfter;
  final int? feeVersion;

  const CardCreationPreview({
    required this.canCreate,
    required this.creationFee,
    required this.cardWillReceive,
    required this.totalToCharge,
    required this.walletBalance,
    required this.walletBalanceAfter,
    this.feeVersion,
  });

  factory CardCreationPreview.fromJson(
    Map<String, dynamic> json, {
    String currency = 'USD',
  }) {
    return CardCreationPreview(
      canCreate: json['canCreate'] as bool? ?? false,
      creationFee: Money.fromJson(json['creationFee'], currency: currency),
      cardWillReceive: Money.fromJson(json['cardWillReceive'], currency: currency),
      totalToCharge: Money.fromJson(json['totalToCharge'], currency: currency),
      walletBalance: Money.fromJson(json['walletBalance'], currency: currency),
      walletBalanceAfter: Money.fromJson(json['walletBalanceAfter'], currency: currency),
      feeVersion: json['feeVersion'] is int
          ? json['feeVersion'] as int
          : int.tryParse(json['feeVersion']?.toString() ?? ''),
    );
  }
}