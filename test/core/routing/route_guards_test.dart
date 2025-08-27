import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:appspraow/core/routing/route_guards.dart';
import 'package:appspraow/core/routing/app_router.dart';
import 'package:appspraow/features/auth/domain/entities/user.dart';
import 'package:appspraow/features/auth/presentation/providers/auth_controller.dart';

// Generate mocks
@GenerateMocks([WidgetRef])
class MockWidgetRef extends Mock implements WidgetRef {}

void main() {
  group('RouteGuards Tests', () {
    late MockWidgetRef mockRef;
    late User testUser;

    setUp(() {
      mockRef = MockWidgetRef();
      testUser = User(
        id: 'test_user',
        email: 'test@example.com',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastSignIn: DateTime.now(),
        subscriptionPlan: SubscriptionPlan.free,
        dailyMessageCount: 5,
        lastMessageDate: DateTime.now(),
      );
    });

    group('Authentication Checks', () {
      test('should return false for unauthenticated user', () {
        // Mock unauthenticated state
        when(mockRef.read(authControllerProvider)).thenReturn(
          const AuthState(isAuthenticated: false, user: null),
        );

        final isAuthenticated = RouteGuards.isAuthenticated(mockRef);
        expect(isAuthenticated, false);
      });

      test('should return true for authenticated user', () {
        // Mock authenticated state
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: testUser),
        );

        final isAuthenticated = RouteGuards.isAuthenticated(mockRef);
        expect(isAuthenticated, true);
      });

      test('should return false for authenticated state without user', () {
        // Mock invalid state
        when(mockRef.read(authControllerProvider)).thenReturn(
          const AuthState(isAuthenticated: true, user: null),
        );

        final isAuthenticated = RouteGuards.isAuthenticated(mockRef);
        expect(isAuthenticated, false);
      });
    });

    group('Subscription Checks', () {
      test('should return false for unauthenticated user checking subscription', () {
        when(mockRef.read(authControllerProvider)).thenReturn(
          const AuthState(isAuthenticated: false, user: null),
        );

        final hasSubscription = RouteGuards.hasSubscription(mockRef, SubscriptionPlan.premium);
        expect(hasSubscription, false);
      });

      test('should return true for user with sufficient subscription', () {
        final premiumUser = testUser.copyWith(subscriptionPlan: SubscriptionPlan.premium);
        
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: premiumUser),
        );

        final hasSubscription = RouteGuards.hasSubscription(mockRef, SubscriptionPlan.premium);
        expect(hasSubscription, true);
      });

      test('should return false for user with insufficient subscription', () {
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: testUser), // Free plan user
        );

        final hasSubscription = RouteGuards.hasSubscription(mockRef, SubscriptionPlan.premium);
        expect(hasSubscription, false);
      });

      test('should handle subscription hierarchy correctly', () {
        final premiumPlusUser = testUser.copyWith(subscriptionPlan: SubscriptionPlan.premiumPlus);
        
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: premiumPlusUser),
        );

        // Premium Plus should have access to Premium features
        final hasPremiumAccess = RouteGuards.hasSubscription(mockRef, SubscriptionPlan.premium);
        expect(hasPremiumAccess, true);

        // Premium Plus should have access to Free features
        final hasFreeAccess = RouteGuards.hasSubscription(mockRef, SubscriptionPlan.free);
        expect(hasFreeAccess, true);
      });
    });

    group('Email Verification Checks', () {
      test('should return false for unauthenticated user', () {
        when(mockRef.read(authControllerProvider)).thenReturn(
          const AuthState(isAuthenticated: false, user: null),
        );

        final isVerified = RouteGuards.isEmailVerified(mockRef);
        expect(isVerified, false);
      });

      test('should return true for verified user', () {
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: testUser),
        );

        final isVerified = RouteGuards.isEmailVerified(mockRef);
        expect(isVerified, true);
      });

      test('should return false for unverified user', () {
        final unverifiedUser = testUser.copyWith(isEmailVerified: false);
        
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: unverifiedUser),
        );

        final isVerified = RouteGuards.isEmailVerified(mockRef);
        expect(isVerified, false);
      });
    });

    group('Daily Limit Checks', () {
      test('should return true for unauthenticated user (blocked)', () {
        when(mockRef.read(authControllerProvider)).thenReturn(
          const AuthState(isAuthenticated: false, user: null),
        );

        final hasReachedLimit = RouteGuards.hasReachedDailyLimit(mockRef);
        expect(hasReachedLimit, true);
      });

      test('should return false for premium user (unlimited)', () {
        final premiumUser = testUser.copyWith(
          subscriptionPlan: SubscriptionPlan.premium,
          dailyMessageCount: 100, // High count but unlimited plan
        );
        
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: premiumUser),
        );

        final hasReachedLimit = RouteGuards.hasReachedDailyLimit(mockRef);
        expect(hasReachedLimit, false);
      });

      test('should return true for free user who reached limit', () {
        final limitedUser = testUser.copyWith(
          subscriptionPlan: SubscriptionPlan.free,
          dailyMessageCount: 10, // Free plan limit
        );
        
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: limitedUser),
        );

        final hasReachedLimit = RouteGuards.hasReachedDailyLimit(mockRef);
        expect(hasReachedLimit, true);
      });

      test('should return false for free user under limit', () {
        final underLimitUser = testUser.copyWith(
          subscriptionPlan: SubscriptionPlan.free,
          dailyMessageCount: 5, // Under the 10 message limit
        );
        
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: underLimitUser),
        );

        final hasReachedLimit = RouteGuards.hasReachedDailyLimit(mockRef);
        expect(hasReachedLimit, false);
      });
    });

    group('Redirect Logic', () {
      test('should redirect to login for unauthenticated user', () {
        when(mockRef.read(authControllerProvider)).thenReturn(
          const AuthState(isAuthenticated: false, user: null),
        );

        final redirectRoute = RouteGuards.getRedirectRoute(mockRef, AppRoutes.chat);
        expect(redirectRoute, AppRoutes.login);
      });

      test('should redirect to chat for authenticated user accessing auth routes', () {
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: testUser),
        );

        final redirectRoute = RouteGuards.getRedirectRoute(mockRef, AppRoutes.login);
        expect(redirectRoute, AppRoutes.chat);
      });
    });

    group('Access Results', () {
      test('should create access result with all fields', () {
        const result = RouteAccessResult(
          allowed: false,
          redirectRoute: AppRoutes.login,
          message: 'Please log in',
        );

        expect(result.allowed, false);
        expect(result.redirectRoute, AppRoutes.login);
        expect(result.message, 'Please log in');
      });

      test('should create allowed access result', () {
        const result = RouteAccessResult(allowed: true);

        expect(result.allowed, true);
        expect(result.redirectRoute, null);
        expect(result.message, null);
      });

      test('should have meaningful toString', () {
        const result = RouteAccessResult(
          allowed: false,
          redirectRoute: AppRoutes.profile,
          message: 'Upgrade required',
        );

        final stringResult = result.toString();
        expect(stringResult.contains('allowed: false'), true);
        expect(stringResult.contains('redirectRoute: ${AppRoutes.profile}'), true);
        expect(stringResult.contains('message: Upgrade required'), true);
      });
    });

    group('Check Access Integration', () {
      test('should allow access for authenticated user to allowed route', () {
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: testUser),
        );

        final result = RouteGuards.checkAccess(mockRef, AppRoutes.chat);
        expect(result.allowed, true);
        expect(result.message, null);
      });

      test('should deny access for unauthenticated user', () {
        when(mockRef.read(authControllerProvider)).thenReturn(
          const AuthState(isAuthenticated: false, user: null),
        );

        final result = RouteGuards.checkAccess(mockRef, AppRoutes.chat);
        expect(result.allowed, false);
        expect(result.redirectRoute, AppRoutes.login);
        expect(result.message, 'Please log in to continue');
      });

      test('should deny access for unverified user to protected route', () {
        final unverifiedUser = testUser.copyWith(isEmailVerified: false);
        
        when(mockRef.read(authControllerProvider)).thenReturn(
          AuthState(isAuthenticated: true, user: unverifiedUser),
        );

        final result = RouteGuards.checkAccess(mockRef, AppRoutes.chat);
        expect(result.allowed, false);
        expect(result.redirectRoute, AppRoutes.profile);
        expect(result.message?.contains('verify'), true);
      });
    });
  });

  group('RouteDebugger Tests', () {
    test('should format navigation logs correctly', () {
      // Test that the debug functions don't throw errors
      expect(() => RouteDebugger.logNavigation('/from', '/to'), returnsNormally);
      expect(() => RouteDebugger.logAccessDenied('/route', 'reason'), returnsNormally);
      expect(() => RouteDebugger.logRedirect('/from', '/to', 'reason'), returnsNormally);
    });
  });

  group('Edge Cases', () {
    test('should handle null user gracefully', () {
      when(mockRef.read(authControllerProvider)).thenReturn(
        const AuthState(isAuthenticated: true, user: null),
      );

      expect(() => RouteGuards.isAuthenticated(mockRef), returnsNormally);
      expect(RouteGuards.isAuthenticated(mockRef), false);
    });

    test('should handle invalid subscription plan', () {
      when(mockRef.read(authControllerProvider)).thenReturn(
        AuthState(isAuthenticated: true, user: testUser),
      );

      // Should not throw even with edge case plans
      expect(() => RouteGuards.hasSubscription(mockRef, SubscriptionPlan.premiumPlus), returnsNormally);
    });

    test('should handle route with special characters', () {
      const specialRoute = '/chat/conversation-with-special_characters.123';
      
      when(mockRef.read(authControllerProvider)).thenReturn(
        AuthState(isAuthenticated: true, user: testUser),
      );

      expect(() => RouteGuards.checkAccess(mockRef, specialRoute), returnsNormally);
    });
  });
}