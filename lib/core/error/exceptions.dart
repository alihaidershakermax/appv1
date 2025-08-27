// Base Exception class
abstract class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
}

// Server Exception
class ServerException extends AppException {
  const ServerException(super.message);
}

// Cache Exception
class CacheException extends AppException {
  const CacheException(super.message);
}

// Network Exception
class NetworkException extends AppException {
  const NetworkException(super.message);
}

// Authentication Exception
class AuthException extends AppException {
  const AuthException(super.message);
}

// Payment Exception
class PaymentException extends AppException {
  const PaymentException(super.message);
}

// Permission Exception
class PermissionException extends AppException {
  const PermissionException(super.message);
}