import 'package:opei/core/network/api_client.dart';
import 'package:opei/data/models/mobile_money_deposit.dart';
import 'package:opei/data/models/mobile_money_withdrawal.dart';

/// All routes proxy through the gateway `/paychangu` module.
/// The gateway resolves the caller's user-id from the JWT — the client
/// never embeds `userId` in paths or request bodies.
class MobileMoneyDepositRepository {
  final ApiClient _apiClient;

  MobileMoneyDepositRepository(this._apiClient);

  Future<List<SavedMobileNumber>> listSavedNumbers({
    bool active = true,
    String? channel,
  }) async {
    final query = <String, String>{'active': active.toString()};
    if (channel != null && channel.trim().isNotEmpty) {
      query['channel'] = channel.trim().toUpperCase();
    }
    final payload = await _apiClient.get<dynamic>(
      '/paychangu/users/me/mobile-numbers',
      queryParameters: query,
    );
    final list = payload is List
        ? payload
        : (payload is Map<String, dynamic> ? payload['data'] : null);
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(SavedMobileNumber.fromJson)
        .toList(growable: false);
  }

  Future<SavedMobileNumber> addNumber({
    required String name,
    required String channel,
    required String mobile,
    bool isPrimary = false,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/paychangu/users/me/mobile-numbers',
      data: {
        'name': name.trim(),
        'channel': channel.toUpperCase(),
        'mobile': mobile.trim(),
        'isPrimary': isPrimary,
      },
    );
    final data = payload['data'];
    if (data is Map<String, dynamic>) return SavedMobileNumber.fromJson(data);
    return SavedMobileNumber.fromJson(payload);
  }

  Future<SavedMobileNumber> updateNumber({
    required String numberId,
    String? name,
    String? mobile,
    String? channel,
    bool? isPrimary,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name.trim();
    if (mobile != null) body['mobile'] = mobile.trim();
    if (channel != null) body['channel'] = channel.toUpperCase();
    if (isPrimary != null) body['isPrimary'] = isPrimary;
    final payload = await _apiClient.patch<Map<String, dynamic>>(
      '/paychangu/users/me/mobile-numbers/$numberId',
      data: body,
    );
    final data = payload['data'];
    if (data is Map<String, dynamic>) return SavedMobileNumber.fromJson(data);
    return SavedMobileNumber.fromJson(payload);
  }

  Future<void> deleteNumber({required String numberId}) async {
    await _apiClient.delete<dynamic>(
      '/paychangu/users/me/mobile-numbers/$numberId',
    );
  }

  Future<MobileMoneyDepositPreview> previewDeposit({
    required int amountUsdCents,
    required String channel,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/paychangu/deposits/mobile-money/preview',
      data: {
        'amountUsdCents': amountUsdCents.toString(),
        'channel': channel.toUpperCase(),
      },
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return MobileMoneyDepositPreview.fromJson(
      parsed,
      fallbackAmountUsdCents: amountUsdCents,
      fallbackChannel: channel,
    );
  }

  Future<MobileMoneyDepositInitiation> initiateDeposit({
    required String savedMobileNumberId,
    required int amountUsdCents,
    required String channel,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/paychangu/deposits/mobile-money/initiate',
      data: {
        'savedMobileNumberId': savedMobileNumberId,
        'amountUsdCents': amountUsdCents.toString(),
        'channel': channel.toUpperCase(),
      },
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return MobileMoneyDepositInitiation.fromJson(parsed);
  }

  Future<MobileMoneyDepositStatus> fetchDepositStatus({
    required String transactionId,
  }) async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/paychangu/deposits/mobile-money/$transactionId/status',
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return MobileMoneyDepositStatus.fromJson(parsed);
  }

  Future<MobileMoneyWithdrawalPreview> previewWithdrawal({
    required int amountUsdCents,
    required String channel,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/paychangu/withdrawals/mobile-money/preview',
      data: {
        'amountUsdCents': amountUsdCents.toString(),
        'channel': channel.toUpperCase(),
      },
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return MobileMoneyWithdrawalPreview.fromJson(
      parsed,
      fallbackAmountUsdCents: amountUsdCents,
      fallbackChannel: channel,
    );
  }

  Future<MobileMoneyWithdrawalInitiation> initiateWithdrawal({
    required int amountUsdCents,
    required String channel,
    String? savedMobileNumberId,
    String? mobile,
  }) async {
    final body = <String, dynamic>{
      'amountUsdCents': amountUsdCents.toString(),
      'channel': channel.toUpperCase(),
    };
    if (savedMobileNumberId != null && savedMobileNumberId.trim().isNotEmpty) {
      body['savedMobileNumberId'] = savedMobileNumberId.trim();
    }
    if (mobile != null && mobile.trim().isNotEmpty) {
      body['mobile'] = mobile.trim();
    }
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/paychangu/withdrawals/mobile-money/initiate',
      data: body,
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return MobileMoneyWithdrawalInitiation.fromJson(parsed);
  }

  Future<MobileMoneyWithdrawalStatus> fetchWithdrawalStatus({
    required String payoutId,
  }) async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/paychangu/withdrawals/mobile-money/$payoutId/status',
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return MobileMoneyWithdrawalStatus.fromJson(parsed);
  }
}
