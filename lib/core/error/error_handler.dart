import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

/// Global error handler for the application
class AppErrorHandler {
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack, 'Flutter Framework Error');
    };

    // Handle errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack, 'Platform Error');
      return true;
    };
  }

  static void _logError(Object error, StackTrace? stack, String context) {
    if (kDebugMode) {
      developer.log(
        'Error occurred: $error',
        name: 'AppErrorHandler',
        error: error,
        stackTrace: stack,
      );
    }

    // TODO: In production, send to crash reporting service
    // FirebaseCrashlytics.instance.recordError(error, stack);
  }

  /// Report error manually
  static void reportError(Object error, StackTrace? stack, [String? context]) {
    _logError(error, stack, context ?? 'Manual Report');
  }

  /// Handle network errors
  static String getNetworkErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorString.contains('certificate') || errorString.contains('ssl')) {
      return 'Security certificate error. Please check your connection.';
    } else if (errorString.contains('format') || errorString.contains('parse')) {
      return 'Data format error. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handle authentication errors
  static String getAuthErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('user-not-found')) {
      return 'No account found with this email address.';
    } else if (errorString.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorString.contains('email-already-in-use')) {
      return 'An account already exists with this email address.';
    } else if (errorString.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (errorString.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (errorString.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    } else if (errorString.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else {
      return 'Authentication failed. Please try again.';
    }
  }

  /// Handle payment errors
  static String getPaymentErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('card_declined')) {
      return 'Your card was declined. Please try a different payment method.';
    } else if (errorString.contains('insufficient_funds')) {
      return 'Insufficient funds. Please check your account balance.';
    } else if (errorString.contains('expired_card')) {
      return 'Your card has expired. Please use a different card.';
    } else if (errorString.contains('invalid_cvc')) {
      return 'Invalid security code. Please check your card details.';
    } else if (errorString.contains('processing_error')) {
      return 'Payment processing error. Please try again.';
    } else {
      return 'Payment failed. Please try again or contact support.';
    }
  }
}

/// Error display widget
class ErrorDisplayWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final bool showDetails;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (showDetails) ...[
            const SizedBox(height: 12),
            Text(
              'If this problem persists, please contact support.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Snackbar error display
class ErrorSnackBar {
  static void show(BuildContext context, String error, {VoidCallback? onRetry}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Theme.of(context).colorScheme.onError,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}

/// Network error handler with retry logic
class NetworkErrorHandler {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  static Future<T> withRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        // Check if error is retryable
        if (_isRetryableError(error)) {
          await Future.delayed(retryDelay * attempts);
        } else {
          rethrow;
        }
      }
    }
    
    throw Exception('Max retries exceeded');
  }

  static bool _isRetryableError(Object error) {
    final errorString = error.toString().toLowerCase();
    
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('socket');
  }
}

/// Error boundary widget
class ErrorBoundary extends ConsumerWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stack)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }
}

/// App-level error state provider
final appErrorProvider = StateNotifierProvider<AppErrorNotifier, AppErrorState>(
  (ref) => AppErrorNotifier(),
);

class AppErrorState {
  final String? currentError;
  final List<String> errorHistory;
  final bool hasUnhandledError;

  const AppErrorState({
    this.currentError,
    this.errorHistory = const [],
    this.hasUnhandledError = false,
  });

  AppErrorState copyWith({
    String? currentError,
    List<String>? errorHistory,
    bool? hasUnhandledError,
  }) {
    return AppErrorState(
      currentError: currentError,
      errorHistory: errorHistory ?? this.errorHistory,
      hasUnhandledError: hasUnhandledError ?? this.hasUnhandledError,
    );
  }
}

class AppErrorNotifier extends StateNotifier<AppErrorState> {
  AppErrorNotifier() : super(const AppErrorState());

  void reportError(String error) {
    state = state.copyWith(
      currentError: error,
      errorHistory: [...state.errorHistory, error],
      hasUnhandledError: true,
    );
  }

  void clearCurrentError() {
    state = state.copyWith(
      currentError: null,
      hasUnhandledError: false,
    );
  }

  void clearAllErrors() {
    state = const AppErrorState();
  }
}