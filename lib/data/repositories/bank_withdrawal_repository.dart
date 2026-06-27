import 'package:opei/core/network/api_client.dart';
import 'package:opei/data/models/bank_withdrawal.dart';

class BankWithdrawalRepository {
  final ApiClient _apiClient;

  BankWithdrawalRepository(this._apiClient);

  Future<List<SupportedBank>> listSupportedBanks() async {
    final payload = await _apiClient.get<dynamic>(
      '/paychangu/withdrawals/bank/banks',
    );
    final list = payload is List
        ? payload
        : (payload is Map<String, dynamic> ? payload['data'] : null);
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(SupportedBank.fromJson)
        .where((item) => item.uuid.isNotEmpty && item.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<BankWithdrawalPreview> previewWithdrawal({
    required int amountUsdCents,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/paychangu/withdrawals/bank/preview',
      data: {'amountUsdCents': amountUsdCents.toString()},
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return BankWithdrawalPreview.fromJson(
      parsed,
      fallbackAmountUsdCents: amountUsdCents,
    );
  }

  Future<BankWithdrawalInitiation> initiateWithdrawal({
    required String bankUuid,
    required String bankAccountName,
    required String bankAccountNumber,
    required int amountUsdCents,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/paychangu/withdrawals/bank/initiate',
      data: {
        'bankUuid': bankUuid.trim(),
        'bankAccountName': bankAccountName.trim(),
        'bankAccountNumber': bankAccountNumber.trim(),
        'amountUsdCents': amountUsdCents.toString(),
      },
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return BankWithdrawalInitiation.fromJson(parsed);
  }

  Future<BankWithdrawalStatus> fetchWithdrawalStatus({
    required String payoutId,
  }) async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/paychangu/withdrawals/bank/$payoutId/status',
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return BankWithdrawalStatus.fromJson(parsed);
  }
}
