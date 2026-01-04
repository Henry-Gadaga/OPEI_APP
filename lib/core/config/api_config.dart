import 'package:opei/core/config/environment.dart';

class ApiConfig {
  static String get baseUrl => Environment.apiBaseUrl;
  static String get apiVersion => Environment.apiVersion;
  static const String kycCallbackUrl = 'https://opei.app/kyc/result';

  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
