import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/network/api_response.dart';
import 'package:opei/data/models/user_model.dart';
import 'package:opei/data/models/full_profile_response.dart';

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
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/users/$userId/profile',
    );

    final apiResponse = ApiResponse<FullProfileResponse>.fromJson(
      response,
      (json) => FullProfileResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return apiResponse.data!;
  }

  Future<String> getLanguage() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/user/me/language',
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response,
      (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    final language = apiResponse.data!['language'];
    return (language ?? 'en').toString();
  }

  Future<String> setLanguage(String languageCode) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/user/me/language',
      data: {'language': languageCode},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response,
      (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    final language = apiResponse.data!['language'];
    return (language ?? languageCode).toString();
  }
}
