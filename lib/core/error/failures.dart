// Base Failure class
abstract class Failure {
  final String message;
  
  const Failure(this.message);
}

// Server Failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Authentication Failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// Payment Failure
class PaymentFailure extends Failure {
  const PaymentFailure(super.message);
}

// Permission Failure
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}