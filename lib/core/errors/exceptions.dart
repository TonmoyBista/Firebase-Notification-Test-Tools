class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  ServerException({required this.message, this.statusCode, this.responseBody});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class AuthException implements Exception {
  final String message;
  AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException({required this.message});

  @override
  String toString() => 'ValidationException: $message';
}

class StorageException implements Exception {
  final String message;
  StorageException({required this.message});

  @override
  String toString() => 'StorageException: $message';
}
