class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiError({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;

  String getFieldError(String field) {
    if (errors != null && errors!.containsKey(field)) {
      final error = errors![field];
      if (error is String) return error;
      if (error is List && error.isNotEmpty) return error.first.toString();
    }
    return '';
  }

  bool hasFieldError(String field) => getFieldError(field).isNotEmpty;
}
