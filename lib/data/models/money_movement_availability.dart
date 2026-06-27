class MoneyMovementAvailability {
  final int version;
  final DateTime? updatedAt;
  final DepositAvailability deposit;
  final WithdrawalAvailability withdrawal;
  final CardsAvailability cards;

  const MoneyMovementAvailability({
    required this.version,
    required this.updatedAt,
    required this.deposit,
    required this.withdrawal,
    required this.cards,
  });

  factory MoneyMovementAvailability.fromJson(Map<String, dynamic> json) {
    return MoneyMovementAvailability(
      version: _asInt(json['version']) ?? 0,
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
      deposit: DepositAvailability.fromJson(_asMap(json['deposit'])),
      withdrawal: WithdrawalAvailability.fromJson(_asMap(json['withdrawal'])),
      cards: CardsAvailability.fromJson(_asMap(json['cards'])),
    );
  }

  factory MoneyMovementAvailability.defaults() {
    return const MoneyMovementAvailability(
      version: 0,
      updatedAt: null,
      deposit: DepositAvailability(
        expressP2P: ExpressP2PAvailability(
          enabled: true,
          currencies: [
            RailToggle(code: 'MZN', enabled: true),
            RailToggle(code: 'ZMW', enabled: true),
            RailToggle(code: 'MWK', enabled: true),
            RailToggle(code: 'ZAR', enabled: true),
            RailToggle(code: 'KES', enabled: true),
            RailToggle(code: 'NGN', enabled: true),
          ],
        ),
        classicP2P: SimpleRailAvailability(enabled: true),
        crypto: CryptoRailAvailability(
          enabled: true,
          assets: [
            CryptoAssetAvailability(
              code: 'USDT',
              enabled: true,
              networks: [
                RailToggle(code: 'polygon', enabled: true),
                RailToggle(code: 'ethereum', enabled: true),
                RailToggle(code: 'bsc', enabled: true),
                RailToggle(code: 'tron', enabled: true),
              ],
            ),
            CryptoAssetAvailability(
              code: 'USDC',
              enabled: true,
              networks: [
                RailToggle(code: 'polygon', enabled: true),
                RailToggle(code: 'ethereum', enabled: true),
                RailToggle(code: 'bsc', enabled: true),
              ],
            ),
          ],
        ),
      ),
      withdrawal: WithdrawalAvailability(
        mobileMoney: MobileMoneyAvailability(
          enabled: true,
          countries: [
            MobileMoneyCountryAvailability(
              country: 'GH',
              currency: 'GHS',
              enabled: true,
              networks: [RailToggle(code: 'MTN', name: 'MTN', enabled: true)],
            ),
            MobileMoneyCountryAvailability(
              country: 'KE',
              currency: 'KES',
              enabled: true,
              networks: [
                RailToggle(code: 'MPESA', name: 'M-Pesa', enabled: true),
              ],
            ),
            MobileMoneyCountryAvailability(
              country: 'UG',
              currency: 'UGX',
              enabled: true,
              networks: [
                RailToggle(code: 'MTN', name: 'MTN', enabled: true),
                RailToggle(code: 'AIRTEL', name: 'Airtel Money', enabled: true),
              ],
            ),
            MobileMoneyCountryAvailability(
              country: 'RW',
              currency: 'RWF',
              enabled: true,
              networks: [
                RailToggle(code: 'MTN', name: 'MTN', enabled: true),
                RailToggle(code: 'AIRTEL', name: 'Airtel Money', enabled: true),
              ],
            ),
            MobileMoneyCountryAvailability(
              country: 'SN',
              currency: 'XOF',
              enabled: true,
              networks: [
                RailToggle(code: 'FREE', enabled: true),
                RailToggle(code: 'FREEMONEY', enabled: true),
                RailToggle(code: 'EXPRESSO', enabled: true),
                RailToggle(code: 'WAVE', enabled: true),
                RailToggle(code: 'ORANGE', enabled: true),
              ],
            ),
            MobileMoneyCountryAvailability(
              country: 'CI',
              currency: 'XOF',
              enabled: true,
              networks: [
                RailToggle(code: 'ORANGE', enabled: true),
                RailToggle(code: 'MTN', enabled: true),
                RailToggle(code: 'MOOV', enabled: true),
              ],
            ),
            MobileMoneyCountryAvailability(
              country: 'CM',
              currency: 'XAF',
              enabled: true,
              networks: [RailToggle(code: 'MTN', enabled: true)],
            ),
            MobileMoneyCountryAvailability(
              country: 'CD',
              currency: 'CDF',
              enabled: true,
              networks: [
                RailToggle(code: 'AIRTEL', enabled: true),
                RailToggle(code: 'ORANGE', enabled: true),
                RailToggle(code: 'VODAFONE', enabled: true),
                RailToggle(code: 'MPESA', enabled: true),
                RailToggle(code: 'AFRICEL', enabled: true),
              ],
            ),
            MobileMoneyCountryAvailability(
              country: 'GA',
              currency: 'XAF',
              enabled: true,
              networks: [
                RailToggle(code: 'AIRTEL', enabled: true),
                RailToggle(code: 'MOOV', enabled: true),
              ],
            ),
            MobileMoneyCountryAvailability(
              country: 'GM',
              currency: 'GMD',
              enabled: true,
              networks: [
                RailToggle(code: 'AFRIMONEY', enabled: true),
                RailToggle(code: 'QMONEY', enabled: true),
              ],
            ),
            MobileMoneyCountryAvailability(
              country: 'ZM',
              currency: 'ZMW',
              enabled: true,
              networks: [
                RailToggle(code: 'MTN', enabled: true),
                RailToggle(code: 'AIRTEL', name: 'Airtel Money', enabled: true),
                RailToggle(code: 'ZAMTEL', name: 'Zamtel', enabled: true),
              ],
            ),
          ],
        ),
        bankTransfer: BankTransferAvailability(
          enabled: true,
          countries: [
            BankTransferCountryAvailability(
              country: 'US',
              currency: 'USD',
              enabled: true,
              transferTypes: ['WIRE', 'ACH'],
              accountTypes: ['CHECKING', 'SAVINGS'],
              beneficiaryTypes: ['INDIVIDUAL', 'BUSINESS'],
            ),
          ],
        ),
        classicP2P: SimpleRailAvailability(enabled: true),
        crypto: CryptoRailAvailability(
          enabled: true,
          assets: [
            CryptoAssetAvailability(
              code: 'USDT',
              enabled: true,
              networks: [
                RailToggle(code: 'tron', enabled: true),
                RailToggle(code: 'polygon', enabled: true),
                RailToggle(code: 'ethereum', enabled: true),
                RailToggle(code: 'bsc', enabled: true),
              ],
            ),
            CryptoAssetAvailability(
              code: 'USDC',
              enabled: true,
              networks: [
                RailToggle(code: 'polygon', enabled: true),
                RailToggle(code: 'ethereum', enabled: true),
                RailToggle(code: 'bsc', enabled: true),
              ],
            ),
          ],
        ),
      ),
      cards: CardsAvailability(
        creation: SimpleRailAvailability(enabled: true),
        topUp: SimpleRailAvailability(enabled: true),
        withdrawal: SimpleRailAvailability(enabled: true),
      ),
    );
  }

  bool get isFallback => version == 0 && updatedAt == null;
}

class RailToggle {
  final String code;
  final String? name;
  final bool enabled;
  final String? reason;

  const RailToggle({
    required this.code,
    this.name,
    required this.enabled,
    this.reason,
  });

  factory RailToggle.fromJson(Map<String, dynamic> json) {
    return RailToggle(
      code: (json['code'] ?? '').toString(),
      name: _nullableString(json['name']),
      enabled: _asBool(json['enabled']) ?? true,
      reason: _nullableString(json['reason']),
    );
  }
}

class SimpleRailAvailability {
  final bool enabled;
  final String? reason;

  const SimpleRailAvailability({required this.enabled, this.reason});

  factory SimpleRailAvailability.fromJson(Map<String, dynamic> json) {
    return SimpleRailAvailability(
      enabled: _asBool(json['enabled']) ?? true,
      reason: _nullableString(json['reason']),
    );
  }
}

class DepositAvailability {
  final ExpressP2PAvailability expressP2P;
  final SimpleRailAvailability classicP2P;
  final CryptoRailAvailability crypto;

  const DepositAvailability({
    required this.expressP2P,
    required this.classicP2P,
    required this.crypto,
  });

  factory DepositAvailability.fromJson(Map<String, dynamic> json) {
    return DepositAvailability(
      expressP2P: ExpressP2PAvailability.fromJson(_asMap(json['expressP2P'])),
      classicP2P: SimpleRailAvailability.fromJson(_asMap(json['classicP2P'])),
      crypto: CryptoRailAvailability.fromJson(_asMap(json['crypto'])),
    );
  }
}

class WithdrawalAvailability {
  final MobileMoneyAvailability mobileMoney;
  final BankTransferAvailability bankTransfer;
  final SimpleRailAvailability classicP2P;
  final CryptoRailAvailability crypto;

  const WithdrawalAvailability({
    required this.mobileMoney,
    required this.bankTransfer,
    required this.classicP2P,
    required this.crypto,
  });

  factory WithdrawalAvailability.fromJson(Map<String, dynamic> json) {
    return WithdrawalAvailability(
      mobileMoney: MobileMoneyAvailability.fromJson(
        _asMap(json['mobileMoney']),
      ),
      bankTransfer: BankTransferAvailability.fromJson(
        _asMap(json['bankTransfer']),
      ),
      classicP2P: SimpleRailAvailability.fromJson(_asMap(json['classicP2P'])),
      crypto: CryptoRailAvailability.fromJson(_asMap(json['crypto'])),
    );
  }
}

class CardsAvailability {
  final SimpleRailAvailability creation;
  final SimpleRailAvailability topUp;
  final SimpleRailAvailability withdrawal;

  const CardsAvailability({
    required this.creation,
    required this.topUp,
    required this.withdrawal,
  });

  factory CardsAvailability.fromJson(Map<String, dynamic> json) {
    return CardsAvailability(
      creation: SimpleRailAvailability.fromJson(_asMap(json['creation'])),
      topUp: SimpleRailAvailability.fromJson(_asMap(json['topUp'])),
      withdrawal: SimpleRailAvailability.fromJson(_asMap(json['withdrawal'])),
    );
  }
}

class ExpressP2PAvailability {
  final bool enabled;
  final String? reason;
  final List<RailToggle> currencies;

  const ExpressP2PAvailability({
    required this.enabled,
    this.reason,
    required this.currencies,
  });

  factory ExpressP2PAvailability.fromJson(Map<String, dynamic> json) {
    return ExpressP2PAvailability(
      enabled: _asBool(json['enabled']) ?? true,
      reason: _nullableString(json['reason']),
      currencies: _asList(json['currencies'])
          .map((item) => RailToggle.fromJson(_asMap(item)))
          .where((item) => item.code.isNotEmpty)
          .toList(growable: false),
    );
  }

  bool isCurrencyEnabled(String code) {
    if (!enabled) return false;
    final upper = code.toUpperCase();
    for (final currency in currencies) {
      if (currency.code.toUpperCase() == upper) return currency.enabled;
    }
    return true;
  }
}

class CryptoRailAvailability {
  final bool enabled;
  final String? reason;
  final List<CryptoAssetAvailability> assets;

  const CryptoRailAvailability({
    required this.enabled,
    this.reason,
    required this.assets,
  });

  factory CryptoRailAvailability.fromJson(Map<String, dynamic> json) {
    return CryptoRailAvailability(
      enabled: _asBool(json['enabled']) ?? true,
      reason: _nullableString(json['reason']),
      assets: _asList(json['assets'])
          .map((item) => CryptoAssetAvailability.fromJson(_asMap(item)))
          .where((item) => item.code.isNotEmpty)
          .toList(growable: false),
    );
  }

  CryptoAssetAvailability? asset(String code) {
    final upper = code.toUpperCase();
    for (final asset in assets) {
      if (asset.code.toUpperCase() == upper) return asset;
    }
    return null;
  }

  bool isAssetEnabled(String code) {
    if (!enabled) return false;
    final found = asset(code);
    return found == null ? true : found.enabled;
  }

  bool isNetworkEnabled(String assetCode, String networkCode) {
    if (!enabled) return false;
    final found = asset(assetCode);
    if (found == null) return true;
    return found.isNetworkEnabled(networkCode);
  }
}

class CryptoAssetAvailability {
  final String code;
  final bool enabled;
  final String? reason;
  final List<RailToggle> networks;

  const CryptoAssetAvailability({
    required this.code,
    required this.enabled,
    this.reason,
    required this.networks,
  });

  factory CryptoAssetAvailability.fromJson(Map<String, dynamic> json) {
    return CryptoAssetAvailability(
      code: (json['code'] ?? '').toString(),
      enabled: _asBool(json['enabled']) ?? true,
      reason: _nullableString(json['reason']),
      networks: _asList(json['networks'])
          .map((item) => RailToggle.fromJson(_asMap(item)))
          .where((item) => item.code.isNotEmpty)
          .toList(growable: false),
    );
  }

  bool isNetworkEnabled(String networkCode) {
    if (!enabled) return false;
    final normalized = networkCode.toLowerCase();
    for (final network in networks) {
      if (network.code.toLowerCase() == normalized) return network.enabled;
    }
    return true;
  }
}

class MobileMoneyAvailability {
  final bool enabled;
  final String? reason;
  final List<MobileMoneyCountryAvailability> countries;

  const MobileMoneyAvailability({
    required this.enabled,
    this.reason,
    required this.countries,
  });

  factory MobileMoneyAvailability.fromJson(Map<String, dynamic> json) {
    return MobileMoneyAvailability(
      enabled: _asBool(json['enabled']) ?? true,
      reason: _nullableString(json['reason']),
      countries: _asList(json['countries'])
          .map((item) => MobileMoneyCountryAvailability.fromJson(_asMap(item)))
          .where((item) => item.country.isNotEmpty)
          .toList(growable: false),
    );
  }

  MobileMoneyCountryAvailability? country(String code) {
    final upper = code.toUpperCase();
    for (final country in countries) {
      if (country.country.toUpperCase() == upper) return country;
    }
    return null;
  }

  bool isCountryEnabled(String code) {
    if (!enabled) return false;
    final found = country(code);
    return found == null ? true : found.enabled;
  }

  bool isNetworkEnabled(String countryCode, String networkCode) {
    if (!enabled) return false;
    final found = country(countryCode);
    if (found == null) return true;
    return found.isNetworkEnabled(networkCode);
  }
}

class MobileMoneyCountryAvailability {
  final String country;
  final String currency;
  final bool enabled;
  final String? reason;
  final List<RailToggle> networks;

  const MobileMoneyCountryAvailability({
    required this.country,
    required this.currency,
    required this.enabled,
    this.reason,
    required this.networks,
  });

  factory MobileMoneyCountryAvailability.fromJson(Map<String, dynamic> json) {
    return MobileMoneyCountryAvailability(
      country: (json['country'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      enabled: _asBool(json['enabled']) ?? true,
      reason: _nullableString(json['reason']),
      networks: _asList(json['networks'])
          .map((item) => RailToggle.fromJson(_asMap(item)))
          .where((item) => item.code.isNotEmpty)
          .toList(growable: false),
    );
  }

  bool isNetworkEnabled(String networkCode) {
    if (!enabled) return false;
    final upper = networkCode.toUpperCase();
    for (final network in networks) {
      if (network.code.toUpperCase() == upper) return network.enabled;
    }
    return true;
  }
}

class BankTransferAvailability {
  final bool enabled;
  final String? reason;
  final List<BankTransferCountryAvailability> countries;

  const BankTransferAvailability({
    required this.enabled,
    this.reason,
    required this.countries,
  });

  factory BankTransferAvailability.fromJson(Map<String, dynamic> json) {
    return BankTransferAvailability(
      enabled: _asBool(json['enabled']) ?? true,
      reason: _nullableString(json['reason']),
      countries: _asList(json['countries'])
          .map((item) => BankTransferCountryAvailability.fromJson(_asMap(item)))
          .where((item) => item.country.isNotEmpty)
          .toList(growable: false),
    );
  }

  BankTransferCountryAvailability? country(String code) {
    final upper = code.toUpperCase();
    for (final country in countries) {
      if (country.country.toUpperCase() == upper) return country;
    }
    return null;
  }

  bool isCountryEnabled(String code) {
    if (!enabled) return false;
    final found = country(code);
    return found == null ? true : found.enabled;
  }
}

class BankTransferCountryAvailability {
  final String country;
  final String currency;
  final bool enabled;
  final String? reason;
  final List<String> transferTypes;
  final List<String> accountTypes;
  final List<String> beneficiaryTypes;
  final List<String> requiredFields;
  final List<String> optionalFields;

  const BankTransferCountryAvailability({
    required this.country,
    required this.currency,
    required this.enabled,
    this.reason,
    this.transferTypes = const [],
    this.accountTypes = const [],
    this.beneficiaryTypes = const [],
    this.requiredFields = const [],
    this.optionalFields = const [],
  });

  factory BankTransferCountryAvailability.fromJson(Map<String, dynamic> json) {
    return BankTransferCountryAvailability(
      country: (json['country'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      enabled: _asBool(json['enabled']) ?? true,
      reason: _nullableString(json['reason']),
      transferTypes: _asStringList(json['transferTypes']),
      accountTypes: _asStringList(json['accountTypes']),
      beneficiaryTypes: _asStringList(json['beneficiaryTypes']),
      requiredFields: _asStringList(json['requiredFields']),
      optionalFields: _asStringList(json['optionalFields']),
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return const <String, dynamic>{};
}

List<Object?> _asList(Object? value) {
  if (value is List) return value;
  return const <Object?>[];
}

List<String> _asStringList(Object? value) {
  return _asList(value)
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

bool? _asBool(Object? value) {
  if (value is bool) return value;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
  }
  return null;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _nullableString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}
