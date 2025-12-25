class ApiConfig {
  static const String baseUrl = 'https://vortically-grippelike-viki.ngrok-free.dev';
  static const String apiVersion = 'v1';
  
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
