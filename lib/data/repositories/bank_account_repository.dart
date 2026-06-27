import 'package:opei/core/network/api_client.dart';
import 'package:opei/data/models/bank_account_deposit.dart';

class BankAccountRepository {
  final ApiClient _apiClient;

  BankAccountRepository(this._apiClient);

  Future<BankAccountPreview> previewBankAccountCreation() async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/paychangu/deposits/bank/account/preview',
      data: const <String, dynamic>{},
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return BankAccountPreview.fromJson(parsed);
  }

  Future<BankAccountCreateResult> getOrCreateBankAccount() async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/paychangu/deposits/bank/account',
      data: const <String, dynamic>{},
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return BankAccountCreateResult.fromJson(parsed);
  }

  Future<BankAccountDetails> fetchExistingBankAccount() async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/paychangu/deposits/bank/account/me',
    );
    final data = payload['data'];
    final parsed = data is Map<String, dynamic> ? data : payload;
    return BankAccountDetails.fromJson(parsed);
  }
}
