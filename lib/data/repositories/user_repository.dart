import 'package:tt1/core/network/api_client.dart';
import 'package:tt1/core/network/api_response.dart';
import 'package:tt1/data/models/user_model.dart';
import 'package:tt1/data/models/full_profile_response.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/user/me');

    final apiResponse = ApiResponse<UserModel>.fromJson(
      response,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return apiResponse.data!;
  }

  Future<FullProfileResponse> getFullProfile(String userId) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/users/$userId/profile');

    final apiResponse = ApiResponse<FullProfileResponse>.fromJson(
      response,
      (json) => FullProfileResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return apiResponse.data!;
  }
}
