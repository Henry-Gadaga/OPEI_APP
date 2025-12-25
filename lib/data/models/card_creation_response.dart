import 'package:tt1/core/money/money.dart';

class CardCreationResponse {
  final String cardId;
  final String? providerCardId;
  final String? providerCardUserId;
  final String? reference;
  final String status;
  final String? cardBrand;
  final String? cardType;
  final Money creationFee;
  final Money cardWillReceive;
  final Money totalCharged;

  const CardCreationResponse({
    required this.cardId,
    required this.status,
    required this.creationFee,
    required this.cardWillReceive,
    required this.totalCharged,
    this.providerCardId,
    this.providerCardUserId,
    this.reference,
    this.cardBrand,
    this.cardType,
  });

  factory CardCreationResponse.fromJson(
    Map<String, dynamic> json, {
    String currency = 'USD',
  }) {
    return CardCreationResponse(
      cardId: json['cardId']?.toString() ?? '',
      providerCardId: json['providerCardId']?.toString(),
      providerCardUserId: json['providerCardUserId']?.toString(),
      reference: json['reference']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      cardBrand: json['cardBrand']?.toString(),
      cardType: json['cardType']?.toString(),
      creationFee: Money.fromJson(json['creationFee'], currency: currency),
      cardWillReceive: Money.fromJson(json['cardWillReceive'], currency: currency),
      totalCharged: Money.fromJson(json['totalCharged'], currency: currency),
    );
  }
}