import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/domain/entities/user.dart';
import 'app_router.dart';

/// Route guards for access control
class RouteGuards {
  /// Check if user is authenticated
  static bool isAuthenticated(WidgetRef ref) {
    final authState = ref.read(authControllerProvider);
    return authState.isAuthenticated && authState.user != null;
  }

  /// Check if user has required subscription
  static bool hasSubscription(WidgetRef ref, SubscriptionPlan requiredPlan) {
    if (!isAuthenticated(ref)) return false;
    
    final user = ref.read(authControllerProvider).user!;
    return _subscriptionHasAccess(user.subscriptionPlan, requiredPlan);
  }

  /// Check if user is email verified
  static bool isEmailVerified(WidgetRef ref) {
    if (!isAuthenticated(ref)) return false;
    
    final user = ref.read(authControllerProvider).user!;
    return user.isEmailVerified;
  }

  /// Check if user has exceeded daily limits
  static bool hasReachedDailyLimit(WidgetRef ref) {
    if (!isAuthenticated(ref)) return true;
    
    final user = ref.read(authControllerProvider).user!;
    if (user.subscriptionPlan.messageLimit == -1) return false; // Unlimited
    
    return user.dailyMessageCount >= user.subscriptionPlan.messageLimit;
  }

  /// Get redirect route for unauthorized access
  static String getRedirectRoute(WidgetRef ref, String attemptedRoute) {
    if (!isAuthenticated(ref)) {
      return AppRoutes.login;
    }
    
    // If trying to access premium features without subscription
    if (_isPremiumRoute(attemptedRoute) && 
        !hasSubscription(ref, SubscriptionPlan.premium)) {
      return AppRoutes.profile; // Redirect to profile for upgrade
    }
    
    // If email not verified and trying to access protected features
    if (_requiresEmailVerification(attemptedRoute) && 
        !isEmailVerified(ref)) {
      return AppRoutes.profile; // Redirect to profile for verification
    }
    
    return AppRoutes.chat; // Default redirect
  }

  /// Check access and return allowed status with message
  static RouteAccessResult checkAccess(WidgetRef ref, String route) {
    if (!isAuthenticated(ref)) {
      return RouteAccessResult(
        allowed: false,
        redirectRoute: AppRoutes.login,
        message: 'Please log in to continue',
      );
    }
    
    final user = ref.read(authControllerProvider).user!;
    
    // Check subscription requirements
    if (_isPremiumRoute(route) && 
        !hasSubscription(ref, SubscriptionPlan.premium)) {
      return RouteAccessResult(
        allowed: false,
        redirectRoute: AppRoutes.profile,
        message: 'Upgrade to Premium to access this feature',
      );
    }
    
    // Check email verification
    if (_requiresEmailVerification(route) && !user.isEmailVerified) {
      return RouteAccessResult(
        allowed: false,
        redirectRoute: AppRoutes.profile,
        message: 'Please verify your email to continue',
      );
    }
    
    // Check daily limits
    if (_hasMessageLimits(route) && hasReachedDailyLimit(ref)) {
      return RouteAccessResult(
        allowed: false,
        redirectRoute: AppRoutes.profile,
        message: 'Daily message limit reached. Upgrade for unlimited messages.',
      );
    }
    
    return RouteAccessResult(allowed: true);
  }

  /// Private helper methods
  static bool _subscriptionHasAccess(SubscriptionPlan userPlan, SubscriptionPlan requiredPlan) {
    const hierarchy = {
      SubscriptionPlan.free: 0,
      SubscriptionPlan.premium: 1,
      SubscriptionPlan.premiumPlus: 2,
    };
    
    return hierarchy[userPlan]! >= hierarchy[requiredPlan]!;
  }

  static bool _isPremiumRoute(String route) {
    const premiumRoutes = [
      // Add routes that require premium subscription
      '/advanced-features',
      '/premium-ai-models',
    ];
    
    return premiumRoutes.any((premiumRoute) => route.startsWith(premiumRoute));
  }

  static bool _requiresEmailVerification(String route) {
    const verificationRequiredRoutes = [
      AppRoutes.chat,
      AppRoutes.profile,
      // Add other routes that require email verification
    ];
    
    return verificationRequiredRoutes.any((protectedRoute) => 
        route.startsWith(protectedRoute));
  }

  static bool _hasMessageLimits(String route) {
    // Routes where message limits apply
    return route.startsWith(AppRoutes.chat);
  }
}

/// Result of route access check
class RouteAccessResult {
  final bool allowed;
  final String? redirectRoute;
  final String? message;

  RouteAccessResult({
    required this.allowed,
    this.redirectRoute,
    this.message,
  });

  @override
  String toString() {
    return 'RouteAccessResult(allowed: $allowed, redirectRoute: $redirectRoute, message: $message)';
  }
}

/// Debug helpers
class RouteDebugger {
  static void logNavigation(String from, String to, {String? reason}) {
    if (kDebugMode) {
      print('🧭 Navigation: $from → $to${reason != null ? ' ($reason)' : ''}');
    }
  }

  static void logAccessDenied(String route, String reason) {
    if (kDebugMode) {
      print('🚫 Access denied to $route: $reason');
    }
  }

  static void logRedirect(String from, String to, String reason) {
    if (kDebugMode) {
      print('↩️ Redirect: $from → $to ($reason)');
    }
  }
}