import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tt1/core/config/api_config.dart';
import 'package:tt1/core/constants/app_constants.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/storage/secure_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage;
  bool _isRefreshing = false;
  int _refreshAttempts = 0;
  static const int _maxRefreshAttempts = 3;

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
        onResponse: _onResponse,
      ),
    );
    
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers[AppConstants.authHeaderKey] =
          '${AppConstants.bearerPrefix} $token';
    }
    
    // Bypass ngrok browser warning for free tunnels
    options.headers['ngrok-skip-browser-warning'] = 'true';
    
    if (!kReleaseMode) {
      debugPrint('🌐 ${options.method} ${options.path}');
      debugPrint('🔐 Auth header attached: ${options.headers.containsKey(AppConstants.authHeaderKey)}');
      if (options.data != null) {
        debugPrint('📤 Request: ${options.data}');
      }
    }
    
    handler.next(options);
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (!kReleaseMode) {
      debugPrint('✅ ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('📥 Response: ${response.data}');
    }
    handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint('❌ ${error.requestOptions.method} ${error.requestOptions.uri}');
    debugPrint('Error: ${error.response?.data ?? error.message}');

    if (error.response?.statusCode == 401) {
      final path = error.requestOptions.path;
      final isRefreshEndpoint = path.contains('/auth/refresh');
      final isPublicEndpoint = path.contains('/auth/login') || 
                                path.contains('/auth/signup') ||
                                path.contains('/auth/forgot-password') ||
                                path.contains('/auth/verify-email');
      
      if (!isRefreshEndpoint && !isPublicEndpoint && !_isRefreshing) {
        if (_refreshAttempts >= _maxRefreshAttempts) {
          debugPrint('❌ Max refresh attempts reached. Skipping further refresh attempts.');
          return handler.next(error);
        }
        
        _isRefreshing = true;
        _refreshAttempts++;
        
        try {
          final refreshToken = await _storage.getRefreshToken();
          
          if (refreshToken != null) {
            debugPrint('🔄 Attempting token refresh (attempt $_refreshAttempts/$_maxRefreshAttempts)...');
            
            final refreshResponse = await _dio.post<Map<String, dynamic>>(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );
            
            if (refreshResponse.statusCode == 200 || refreshResponse.statusCode == 201) {
              final data = refreshResponse.data!['data'] as Map<String, dynamic>;
              final newAccessToken = data['accessToken'] as String;
              final newRefreshToken = data['refreshToken'] as String;
              
              await _storage.saveToken(newAccessToken);
              await _storage.saveRefreshToken(newRefreshToken);
              
              debugPrint('✅ Token refreshed successfully');
              
              error.requestOptions.headers[AppConstants.authHeaderKey] =
                  '${AppConstants.bearerPrefix} $newAccessToken';
              
              _isRefreshing = false;
              
              try {
                final retryResponse = await _dio.fetch(error.requestOptions);
                _refreshAttempts = 0; // Reset counter on success
                return handler.resolve(retryResponse);
              } catch (retryError) {
                debugPrint('❌ Retry failed after token refresh');
                if (retryError is DioException) {
                  return handler.next(retryError);
                }
                return handler.next(error);
              }
            }
          }
        } catch (e) {
          debugPrint('❌ Token refresh failed: $e');
        }
        
        _isRefreshing = false;
      }
      
      if (!isPublicEndpoint && _refreshAttempts >= _maxRefreshAttempts) {
        debugPrint('⚠️ Session refresh limit reached. Leaving existing credentials untouched.');
      }
    } else if (error.response?.statusCode == 403) {
      await _storage.clearToken();
      await _storage.clearUser();
    }

    handler.next(error);
  }

  ApiError _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      final statusCode = error.response!.statusCode;
      
      if (data is Map<String, dynamic>) {
        final rawMessage = data['message'];
        String? message = _sanitizeServerMessage(rawMessage);
        message ??= _getStatusCodeMessage(statusCode);

        Map<String, dynamic>? fieldErrors;
        final rawErrors = data['errors'] ?? data['error'];
        if (rawErrors is Map<String, dynamic>) {
          fieldErrors = rawErrors;
        }

        return ApiError(
          message: message,
          statusCode: statusCode,
          errors: fieldErrors,
        );
      }
      
      // Handle non-JSON responses (HTML error pages, etc.)
      return ApiError(
        message: _getStatusCodeMessage(statusCode),
        statusCode: statusCode,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(message: 'Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return ApiError(message: 'No internet connection. Please check your network.');
      default:
        return ApiError(message: 'An unexpected error occurred. Please try again.');
    }
  }

  String? _sanitizeServerMessage(dynamic raw) {
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) {
        return null;
      }

      final normalized = _looksLikeHtml(trimmed) ? _stripHtmlTags(trimmed) : trimmed;
      final collapsed = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (collapsed.isEmpty) {
        return null;
      }

      final lower = collapsed.toLowerCase();
      if (lower == 'bad request' || lower == 'forbidden' || lower == 'not found') {
        return null;
      }

      return collapsed;
    }

    if (raw is List && raw.isNotEmpty) {
      for (final entry in raw) {
        final candidate = _sanitizeServerMessage(entry);
        if (candidate != null) {
          return candidate;
        }
      }
    }

    if (raw is Map<String, dynamic>) {
      for (final key in ['message', 'error', 'errorMessage', 'detail', 'title', 'description']) {
        if (raw.containsKey(key)) {
          final candidate = _sanitizeServerMessage(raw[key]);
          if (candidate != null) {
            return candidate;
          }
        }
      }
    }

    return null;
  }

  bool _looksLikeHtml(String value) {
    return value.contains('<') && value.contains('>');
  }

  String _stripHtmlTags(String value) {
    return value.replaceAll(RegExp(r'<[^>]*>'), ' ');
  }

  String _getStatusCodeMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your information.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You don\'t have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
