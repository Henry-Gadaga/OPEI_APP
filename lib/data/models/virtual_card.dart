import 'package:tt1/core/money/money.dart';

class VirtualCard {
  final String id;
  final String? last4;
  final String cardName;
  final String? expiry;
  final String status;
  final VirtualCardAddress? address;
  final Money? balance;
  final String? cvv;

  const VirtualCard({
    required this.id,
    required this.cardName,
    required this.status,
    this.last4,
    this.expiry,
    this.address,
    this.balance,
    this.cvv,
  });

  factory VirtualCard.fromJson(Map<String, dynamic> json) {
    final rawCurrency = json['currency']?.toString();
    final dynamic rawBalance = json['availableBalance'] ??
        json['cardBalance'] ??
        json['balance'];
    final Money? parsedBalance = rawBalance != null
        ? Money.fromJson(
            rawBalance,
            currency: (rawCurrency?.isNotEmpty ?? false)
                ? rawCurrency!
                : 'USD',
          )
        : null;
    final dynamic rawCvv = json['cvv'] ??
        json['cardCvv'] ??
        json['cardCVV'] ??
        json['cardSecurityCode'] ??
        json['securityCode'];

    String _readCardId() {
      for (final key in const ['crid', 'cardId', 'cardID', 'id']) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
      return '';
    }

    String _readCardName() {
      for (final key in const ['cardName', 'name', 'card_name']) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
      return '';
    }

    String? _readExpiry() {
      for (final key in const ['valid', 'expiry', 'expires', 'expiration', 'expiryDate', 'expiry_date']) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
      return null;
    }

    String? _readStatus() {
      for (final key in const ['status', 'cardStatus']) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
      return null;
    }

    return VirtualCard(
      id: _readCardId(),
      last4: json['last4']?.toString().trim().isEmpty == true
          ? null
          : json['last4']?.toString(),
      cardName: _readCardName(),
      expiry: _readExpiry(),
      status: _readStatus() ?? 'unknown',
      address: json['address'] is Map<String, dynamic>
          ? VirtualCardAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      balance: parsedBalance,
      cvv: rawCvv?.toString(),
    );
  }

  VirtualCard copyWith({
    String? id,
    String? last4,
    String? cardName,
    String? expiry,
    String? status,
    VirtualCardAddress? address,
    Money? balance,
    String? cvv,
  }) {
    return VirtualCard(
      id: id ?? this.id,
      last4: last4 ?? this.last4,
      cardName: cardName ?? this.cardName,
      expiry: expiry ?? this.expiry,
      status: status ?? this.status,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      cvv: cvv ?? this.cvv,
    );
  }
}

class VirtualCardAddress {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;
  final String? countryCode;

  const VirtualCardAddress({
    this.street,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.countryCode,
  });

  factory VirtualCardAddress.fromJson(Map<String, dynamic> json) {
    return VirtualCardAddress(
      street: json['street']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      zipCode: json['zipCode']?.toString(),
      countryCode: json['countryCode']?.toString(),
    );
  }
}