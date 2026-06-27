import 'package:opei/core/network/api_client.dart';
import 'package:opei/data/models/money_movement_availability.dart';

class MoneyMovementAvailabilityRepository {
  final ApiClient _apiClient;

  MoneyMovementAvailabilityRepository(this._apiClient);

  Future<MoneyMovementAvailability> fetchAvailability() async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/money-movement/availability',
    );
    final rawData = payload['data'];
    final data = rawData is Map<String, dynamic>
        ? rawData
        : <String, dynamic>{};
    return MoneyMovementAvailability.fromJson(data);
  }
}
