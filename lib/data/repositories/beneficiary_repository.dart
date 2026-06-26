import 'package:flutter/foundation.dart';
import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/beneficiary.dart';

/// Talks to the gateway's `/beneficiaries` endpoints.
///
/// All endpoints require a user JWT (handled by [ApiClient] interceptor) and
/// expect `userId` either in the query string or in the JSON body.
class BeneficiaryRepository {
  final ApiClient _apiClient;

  BeneficiaryRepository(this._apiClient);

  // ── Reads ────────────────────────────────────────────────────────────────

  /// Lists beneficiaries for [userId], optionally filtered by [country] and
  /// [type]. The backend uses Prisma's `BeneficiaryType` enum and will reject
  /// anything outside `MOBILEMONEY | BANK | ALIPAY | WECHATPAY` with a 400.
  /// For US bank receivers pass `type: 'BANK'` and `country: 'US'`.
  Future<List<Beneficiary>> listBeneficiaries({
    required String userId,
    String? country,
    String? currency,
    String type = 'MOBILEMONEY',
    int page = 1,
    int limit = 50,
  }) async {
    try {
      debugPrint(
          '👥 Fetching $type beneficiaries for $userId (country=$country)');

      final params = <String, dynamic>{
        'userId': userId,
        'type': type,
        'page': page,
        'limit': limit,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
      };
      if (country != null && country.isNotEmpty) params['country'] = country;
      if (currency != null && currency.isNotEmpty) params['currency'] = currency;

      final payload = await _apiClient.get<Map<String, dynamic>>(
        '/beneficiaries',
        queryParameters: params,
      );

      final raw = payload['data'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(Beneficiary.fromJson)
          .toList();
    } on ApiError catch (error) {
      if (error.statusCode == 404) {
        return const [];
      }
      final message = ErrorHelper.getErrorMessage(error);
      debugPrint('❌ Beneficiary list failed: $message');
      rethrow;
    }
  }

  // ── Writes (create per-corridor) ─────────────────────────────────────────

  /// Mobile-money corridors mapped from ISO country code to their gateway path
  /// segment. Used by [createMobileMoneyBeneficiary].
  static const Map<String, String> mobileMoneyCorridors = {
    'SN': 'senegal-mobile-money',
    'RW': 'rwanda-mobile-money',
    'UG': 'uganda-mobile-money',
    'CM': 'cameroon-mobile-money',
    'CI': 'ivory-coast-mobile-money',
    'CD': 'drc-mobile-money',
    'GM': 'gambia-mobile-money',
    'GA': 'gabon-mobile-money',
    'GH': 'ghana-mobile-money',
    'ZM': 'zambia-mobile-money',
    'KE': 'kenya-mobile-money',
  };

  /// Networks supported by each mobile-money corridor.
  static const Map<String, List<String>> mobileMoneyNetworks = {
    'SN': ['FREE', 'FREEMONEY', 'EXPRESSO', 'WAVE', 'ORANGE'],
    'RW': ['MTN', 'AIRTEL'],
    'UG': ['MTN', 'AIRTEL'],
    'CM': ['MTN'],
    'CI': ['ORANGE', 'MTN', 'MOOV'],
    'CD': ['AIRTEL', 'ORANGE', 'VODAFONE', 'MPESA', 'AFRICEL'],
    'GM': ['AFRIMONEY', 'QMONEY'],
    'GA': ['AIRTEL', 'MOOV'],
    'GH': ['MTN'],
    'ZM': ['MTN', 'AIRTEL', 'ZAMTEL'],
    'KE': ['MPESA'],
  };

  /// Whether the corridor requires `accountName` in the create payload.
  /// Ghana is the only corridor where the provider returns the name itself.
  static bool requiresAccountName(String country) =>
      country.toUpperCase() != 'GH';

  /// Local payout currency metadata per country.
  ///
  /// - [code]      ISO currency code expected by the remittance service
  ///               (e.g. `KES`, `UGX`).
  /// - [symbol]    Short prefix shown in the UI (e.g. `KSh`, `USh`).
  /// - [decimals]  How many fractional digits the currency uses in the UI.
  ///               Most East/West African mobile-money currencies are integer
  ///               only (UGX, RWF, XOF, XAF), so the user can't type a
  ///               decimal at all.
  /// - [quickAmounts] Suggested quick-pick values in MAJOR units (what the
  ///               user sees / types).
  static const Map<String,
      ({String code, String symbol, int decimals, List<int> quickAmounts})>
      mobileMoneyCurrencyMeta = {
    'SN': (code: 'XOF', symbol: 'CFA', decimals: 0,
        quickAmounts: [5000, 10000, 25000, 50000]),
    'RW': (code: 'RWF', symbol: 'RF', decimals: 0,
        quickAmounts: [10000, 25000, 50000, 100000]),
    'UG': (code: 'UGX', symbol: 'USh', decimals: 0,
        quickAmounts: [50000, 100000, 200000, 500000]),
    'CM': (code: 'XAF', symbol: 'FCFA', decimals: 0,
        quickAmounts: [5000, 10000, 25000, 50000]),
    'CI': (code: 'XOF', symbol: 'CFA', decimals: 0,
        quickAmounts: [5000, 10000, 25000, 50000]),
    'CD': (code: 'CDF', symbol: 'FC', decimals: 0,
        quickAmounts: [25000, 50000, 100000, 250000]),
    'GM': (code: 'GMD', symbol: 'D', decimals: 2,
        quickAmounts: [500, 1000, 2500, 5000]),
    'GA': (code: 'XAF', symbol: 'FCFA', decimals: 0,
        quickAmounts: [5000, 10000, 25000, 50000]),
    'GH': (code: 'GHS', symbol: 'GH₵', decimals: 2,
        quickAmounts: [100, 250, 500, 1000]),
    'ZM': (code: 'ZMW', symbol: 'ZK', decimals: 2,
        quickAmounts: [250, 500, 1000, 2500]),
    'KE': (code: 'KES', symbol: 'KSh', decimals: 2,
        quickAmounts: [1000, 2500, 5000, 10000]),
    // US bank — receiver currency is USD with 2 decimals.
    'US': (code: 'USD', symbol: '\$', decimals: 2,
        quickAmounts: [100, 500, 1000, 5000]),
  };

  /// Convenience: meta for [country] or a safe default.
  static ({String code, String symbol, int decimals, List<int> quickAmounts})
      currencyMetaFor(String country) {
    return mobileMoneyCurrencyMeta[country.toUpperCase()] ??
        (code: 'USD', symbol: '\$', decimals: 2, quickAmounts: [10, 25, 50, 100]);
  }

  /// Phone-number metadata per country, used by the UI to render a fixed
  /// dial-code prefix and validate the national number length exactly.
  ///
  /// `nationalLength` is the number of digits the user types AFTER the dial
  /// code (no leading zero).
  static const Map<String, ({String dialCode, int nationalLength})>
      mobileMoneyPhoneMeta = {
    'SN': (dialCode: '+221', nationalLength: 9),
    'RW': (dialCode: '+250', nationalLength: 9),
    'UG': (dialCode: '+256', nationalLength: 9),
    'CM': (dialCode: '+237', nationalLength: 9),
    'CI': (dialCode: '+225', nationalLength: 10),
    'CD': (dialCode: '+243', nationalLength: 9),
    'GM': (dialCode: '+220', nationalLength: 7),
    'GA': (dialCode: '+241', nationalLength: 8),
    'GH': (dialCode: '+233', nationalLength: 9),
    'ZM': (dialCode: '+260', nationalLength: 9),
    'KE': (dialCode: '+254', nationalLength: 9),
  };

  /// Creates a mobile-money beneficiary for [country].
  ///
  /// Returns the freshly created [Beneficiary]. The caller can refresh the
  /// list after this resolves successfully.
  Future<Beneficiary> createMobileMoneyBeneficiary({
    required String userId,
    required String country,
    required String network,
    required String accountNumber,
    String? accountName,
  }) async {
    final corridor = mobileMoneyCorridors[country.toUpperCase()];
    if (corridor == null) {
      throw ApiError(message: 'E-2601', statusCode: 400);
    }

    final body = <String, dynamic>{
      'userId': userId,
      'network': network,
      'accountNumber': accountNumber.trim(),
    };
    if (accountName != null && accountName.trim().isNotEmpty) {
      body['accountName'] = accountName.trim();
    }

    try {
      debugPrint('➕ Creating $corridor beneficiary for $userId');
      final payload = await _apiClient.post<Map<String, dynamic>>(
        '/beneficiaries/$corridor',
        data: body,
      );

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return Beneficiary.fromJson(data);
      }
      // Fallback: some endpoints may return the body directly.
      return Beneficiary.fromJson(payload);
    } on ApiError catch (error) {
      final message = ErrorHelper.getErrorMessage(error);
      debugPrint('❌ Beneficiary create failed: $message');
      rethrow;
    }
  }

  // ── US Bank ──────────────────────────────────────────────────────────────

  /// Allowed values for `destination.type`.
  ///
  /// Business rules enforced by the backend:
  ///  * `WIRE`  → allowed for both `INDIVIDUAL` and `BUSINESS`
  ///  * `ACH`   → allowed for `INDIVIDUAL` only (`ACH` + `BUSINESS` returns 400)
  static const List<String> usBankTransferTypes = ['WIRE', 'ACH'];

  /// Allowed values for `destination.accountType`.
  static const List<String> usBankAccountTypes = ['CHECKING', 'SAVINGS'];

  /// Allowed values for `beneficiary.type`.
  static const List<String> usBankBeneficiaryTypes = ['INDIVIDUAL', 'BUSINESS'];

  /// Common remittance purposes accepted by the provider.
  ///
  /// Stored as the wire-format enum the backend expects, paired with a
  /// human-readable label for the UI.
  static const List<({String value, String label})> usBankRemittancePurposes = [
    (value: 'FAMILY_SUPPORT', label: ''),
    (value: 'EDUCATION', label: ''),
    (value: 'GIFT_AND_DONATION', label: ''),
    (value: 'MEDICAL_TREATMENT', label: ''),
    (value: 'MAINTENANCE_EXPENSES', label: ''),
    (value: 'TRAVEL', label: ''),
    (value: 'SMALL_VALUE_REMITTANCE', label: ''),
    (value: 'LIBERALIZED_REMITTANCE', label: ''),
    (value: 'PERSONAL_TRANSFER', label: ''),
    (value: 'SALARY_PAYMENT', label: ''),
    (value: 'LOAN_PAYMENT', label: ''),
    (value: 'TAX_PAYMENT', label: ''),
    (value: 'UTILITY_BILLS', label: ''),
    (value: 'PROPERTY_PURCHASE', label: ''),
    (value: 'PROPERTY_RENTAL', label: ''),
    (value: 'CONSTRUCTION_EXPENSES', label: ''),
    (value: 'HOTEL_ACCOMMODATION', label: ''),
    (value: 'TRANSPORTATION_FEES', label: ''),
    (value: 'DELIVERY_FEES', label: ''),
    (value: 'OFFICE_EXPENSES', label: ''),
    (value: 'ADVERTISING_EXPENSES', label: ''),
    (value: 'ADVISORY_FEES', label: ''),
    (value: 'SERVICE_CHARGES', label: ''),
    (value: 'BUSINESS_INSURANCE', label: ''),
    (value: 'INSURANCE_CLAIMS', label: ''),
    (value: 'EXPORTED_GOODS', label: ''),
    (value: 'SHARES_INVESTMENT', label: ''),
    (value: 'FUND_INVESTMENT', label: ''),
    (value: 'ROYALTY_FEES', label: ''),
    (value: 'COMPUTER_SERVICES', label: ''),
    (value: 'REWARD_PAYMENT', label: ''),
    (value: 'INFLUENCER_PAYMENT', label: ''),
    (value: 'OTHER_FEES', label: ''),
    (value: 'OTHER', label: ''),
  ];

  /// Creates a US bank beneficiary.
  ///
  /// Performs a small amount of client-side enforcement (transfer-type vs.
  /// beneficiary-type rules, routing-number length) so we surface a clean
  /// inline message instead of waiting for the gateway to round-trip a 400.
  Future<Beneficiary> createUsBankBeneficiary({
    required String userId,
    // Destination
    required String transferType, // WIRE | ACH
    required String accountType, // CHECKING | SAVINGS
    required String accountNumber,
    required String routingNumber,
    required String bankName,
    required String bankAddress,
    required String postCode,
    required String city,
    required String state,
    required String remittancePurpose,
    // Beneficiary
    required String beneficiaryType, // INDIVIDUAL | BUSINESS
    required String beneficiaryAccountName,
    required String beneficiaryState,
    required String beneficiaryCity,
    required String beneficiaryAddress,
    required String beneficiaryPostCode,
  }) async {
    final t = transferType.toUpperCase();
    final at = accountType.toUpperCase();
    final bt = beneficiaryType.toUpperCase();

    if (!usBankTransferTypes.contains(t)) {
      throw ApiError(message: 'E-2602', statusCode: 400);
    }
    if (!usBankAccountTypes.contains(at)) {
      throw ApiError(message: 'E-2603', statusCode: 400);
    }
    if (!usBankBeneficiaryTypes.contains(bt)) {
      throw ApiError(message: 'E-2604', statusCode: 400);
    }
    if (t == 'ACH' && bt == 'BUSINESS') {
      throw ApiError(message: 'E-2605', statusCode: 400);
    }

    final routing = routingNumber.replaceAll(RegExp(r'\D'), '');
    if (routing.length != 9) {
      throw ApiError(message: 'E-2606', statusCode: 400);
    }
    final account = accountNumber.replaceAll(RegExp(r'\D'), '');
    if (account.length < 4 || account.length > 17) {
      throw ApiError(message: 'E-2607', statusCode: 400);
    }

    final body = <String, dynamic>{
      'userId': userId,
      'destination': {
        'type': t,
        'accountType': at,
        'accountNumber': account,
        'routingNumber': routing,
        'bankName': bankName.trim(),
        'bankAddress': bankAddress.trim(),
        'postCode': postCode.trim(),
        'city': city.trim(),
        'state': state.trim(),
        'remittancePurpose': remittancePurpose,
        'beneficiary': {
          'type': bt,
          'accountName': beneficiaryAccountName.trim(),
          'country': 'US',
          'state': beneficiaryState.trim(),
          'city': beneficiaryCity.trim(),
          'address': beneficiaryAddress.trim(),
          'postCode': beneficiaryPostCode.trim(),
        },
      },
    };

    try {
      debugPrint('➕ Creating us-bank beneficiary for $userId');
      final payload = await _apiClient.post<Map<String, dynamic>>(
        '/beneficiaries/us-bank',
        data: body,
      );

      // Provider can mark the beneficiary as failed even when the HTTP call
      // succeeded — surface that as a typed error so the UI shows a clear
      // message instead of silently celebrating.
      final ok = payload['success'];
      final data = payload['data'];
      final dataMap = data is Map<String, dynamic> ? data : null;
      final providerStatus =
          (dataMap?['status']?.toString() ?? '').toUpperCase();
      if (ok == false || providerStatus == 'FAILED') {
        final msg = (payload['message']?.toString().isNotEmpty ?? false)
            ? payload['message'].toString()
            : 'Provider marked beneficiary as failed';
        throw ApiError(message: msg, statusCode: 502);
      }

      if (dataMap != null) return Beneficiary.fromJson(dataMap);
      return Beneficiary.fromJson(payload);
    } on ApiError catch (error) {
      final message = ErrorHelper.getErrorMessage(error, context: 'us_bank');
      debugPrint('❌ US bank beneficiary create failed: $message');
      rethrow;
    }
  }
}
