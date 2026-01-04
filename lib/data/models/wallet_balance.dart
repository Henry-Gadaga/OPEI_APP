import 'package:opei/core/money/money.dart';

class WalletBalance {
  final String walletId;
  final String userId;
  final Money balance;
  final Money reservedBalance;
  final DateTime? updatedAt;

  WalletBalance({
    required this.walletId,
    required this.userId,
    required this.balance,
    required this.reservedBalance,
    this.updatedAt,
  });

  Money get availableBalance => balance - reservedBalance;

  int get balanceCents => balance.cents;
  int get reservedBalanceCents => reservedBalance.cents;
  int get availableBalanceCents => availableBalance.cents;

  double get balanceMajor => balance.inMajorUnits;
  double get reservedBalanceMajor => reservedBalance.inMajorUnits;
  double get availableBalanceMajor => availableBalance.inMajorUnits;

  Money get balanceMoney => balance;
  Money get reservedBalanceMoney => reservedBalance;
  Money get availableBalanceMoney => availableBalance;

  String get formattedAvailableBalance =>
      availableBalance.format(includeCurrencySymbol: true);
  String get formattedBalance =>
      balance.format(includeCurrencySymbol: true);

  WalletBalance copyWith({
    String? walletId,
    String? userId,
    Money? balance,
    Money? reservedBalance,
    DateTime? updatedAt,
  }) {
    return WalletBalance(
      walletId: walletId ?? this.walletId,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      reservedBalance: reservedBalance ?? this.reservedBalance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    String parseString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          return json[key].toString();
        }
      }
      return fallback;
    }

    DateTime? parseDate(List<String> keys) {
      for (final key in keys) {
        if (!json.containsKey(key) || json[key] == null) continue;
        final value = json[key];
        if (value is DateTime) return value;
        if (value is String && value.isNotEmpty) {
          final parsed = DateTime.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    dynamic readFirst(List<String> keys) {
      for (final key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          return json[key];
        }
      }
      return null;
    }

    final walletId = parseString([
      'walletId',
      'wallet_id',
      'id',
    ]);

    final userId = parseString([
      'userId',
      'user_id',
      'ownerId',
      'owner_id',
    ]);

    final currency = parseString([
      'currency',
      'currencyCode',
      'currency_code',
    ], fallback: 'USD').toUpperCase();

    final balanceMoney = Money.fromJson(
      readFirst([
        'balanceInCents',
        'balance_in_cents',
        'availableBalance',
        'available_balance',
        'balance',
        'ledgerBalance',
        'ledger_balance',
      ]),
      currency: currency,
    );

    final reservedMoney = Money.fromJson(
      readFirst([
        'reservedBalanceInCents',
        'reserved_balance_in_cents',
        'reservedBalance',
        'reserved_balance',
        'holdBalance',
        'hold_balance',
      ]),
      currency: currency,
    );

    final updatedAt = parseDate([
      'updatedAt',
      'updated_at',
      'syncedAt',
      'synced_at',
    ]);

    return WalletBalance(
      walletId: walletId,
      userId: userId,
      balance: balanceMoney,
      reservedBalance: reservedMoney,
      updatedAt: updatedAt,
    );
  }
}