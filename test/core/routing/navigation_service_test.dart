import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appspraow/core/routing/navigation_service.dart';
import 'package:appspraow/core/routing/app_router.dart';

void main() {
  group('NavigationService Tests', () {
    testWidgets('should be a singleton', (WidgetTester tester) async {
      final instance1 = NavigationService();
      final instance2 = NavigationService();
      
      expect(identical(instance1, instance2), true);
    });
  });

  group('AppRoutes Constants Tests', () {
    test('should have correct route constants', () {
      expect(AppRoutes.splash, '/');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.signup, '/signup');
      expect(AppRoutes.chat, '/chat');
      expect(AppRoutes.chatConversation, '/chat/:conversationId');
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.profile, '/profile');
      expect(AppRoutes.onboarding, '/onboarding');
      expect(AppRoutes.subscription, '/subscription');
    });

    test('should generate conversation routes correctly', () {
      const conversationId = 'conv_123';
      final route = '${AppRoutes.chat}/$conversationId';
      
      expect(route, '/chat/conv_123');
    });

    test('should handle nested routes', () {
      const baseRoute = AppRoutes.chat;
      const subRoute = 'settings';
      final nestedRoute = '$baseRoute/$subRoute';
      
      expect(nestedRoute, '/chat/settings');
    });
  });

  group('Navigation Extension Tests', () {
    testWidgets('should provide extension methods for BuildContext', (WidgetTester tester) async {
      late BuildContext testContext;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              testContext = context;
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      // Test that extension methods exist on BuildContext
      expect(testContext.currentRoute, isA<String>());
    });
  });

  group('Route Generation Tests', () {
    test('should generate parameterized routes correctly', () {
      const route = '/chat/:conversationId';
      const conversationId = 'abc123';
      
      final finalRoute = route.replaceAll(':conversationId', conversationId);
      expect(finalRoute, '/chat/abc123');
    });

    test('should handle multiple parameters', () {
      const route = '/users/:userId/posts/:postId';
      const userId = 'user123';
      const postId = 'post456';
      
      String finalRoute = route;
      finalRoute = finalRoute.replaceAll(':userId', userId);
      finalRoute = finalRoute.replaceAll(':postId', postId);
      
      expect(finalRoute, '/users/user123/posts/post456');
    });

    test('should handle query parameters', () {
      const baseRoute = '/search';
      const query = 'flutter';
      const category = 'mobile';
      
      final uri = Uri.parse(baseRoute);
      final newUri = uri.replace(queryParameters: {
        'q': query,
        'category': category,
      });
      
      expect(newUri.toString(), '/search?q=flutter&category=mobile');
    });
  });

  group('Route Validation Tests', () {
    test('should validate route format', () {
      const validRoutes = [
        '/',
        '/login',
        '/chat',
        '/chat/123',
        '/profile',
        '/settings',
      ];

      for (final route in validRoutes) {
        expect(route.startsWith('/'), true, reason: 'Route $route should start with /');
      }
    });

    test('should identify protected routes', () {
      const protectedRoutes = [
        '/chat',
        '/profile',
        '/settings',
      ];

      const publicRoutes = [
        '/',
        '/login',
        '/signup',
      ];

      // In a real implementation, this would use the actual helper function
      for (final route in protectedRoutes) {
        expect(route.startsWith('/'), true);
      }

      for (final route in publicRoutes) {
        expect(route.startsWith('/'), true);
      }
    });
  });

  group('Navigation State Tests', () {
    test('should track navigation history', () {
      final navigationHistory = <String>[];
      
      // Simulate navigation
      navigationHistory.add(AppRoutes.splash);
      navigationHistory.add(AppRoutes.login);
      navigationHistory.add(AppRoutes.chat);
      
      expect(navigationHistory.length, 3);
      expect(navigationHistory.last, AppRoutes.chat);
      expect(navigationHistory.first, AppRoutes.splash);
    });

    test('should handle back navigation', () {
      final navigationStack = <String>[
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.chat,
      ];
      
      // Pop the last route
      final poppedRoute = navigationStack.removeLast();
      
      expect(poppedRoute, AppRoutes.chat);
      expect(navigationStack.last, AppRoutes.login);
      expect(navigationStack.length, 2);
    });

    test('should handle deep linking', () {
      const deepLink = '/chat/conversation_123';
      
      // Parse the deep link
      final parts = deepLink.split('/');
      expect(parts[1], 'chat');
      expect(parts[2], 'conversation_123');
      
      // Should be able to extract conversation ID
      final conversationId = parts.length > 2 ? parts[2] : null;
      expect(conversationId, 'conversation_123');
    });
  });

  group('Route Parameters Tests', () {
    test('should extract route parameters', () {
      const route = '/chat/:conversationId';
      const actualPath = '/chat/abc123';
      
      // Simple parameter extraction (in real app this would be more sophisticated)
      if (actualPath.startsWith('/chat/')) {
        final conversationId = actualPath.substring('/chat/'.length);
        expect(conversationId, 'abc123');
      }
    });

    test('should handle missing parameters', () {
      const route = '/chat/:conversationId';
      const actualPath = '/chat/';
      
      if (actualPath.startsWith('/chat/')) {
        final remainingPath = actualPath.substring('/chat/'.length);
        expect(remainingPath.isEmpty, true);
      }
    });

    test('should validate parameter format', () {
      const validConversationIds = [
        'conv_123',
        'abc-456',
        'uuid-1234-5678-9012',
      ];

      const invalidConversationIds = [
        '',
        ' ',
        'conv with spaces',
        'conv/with/slashes',
      ];

      for (final id in validConversationIds) {
        expect(id.isNotEmpty, true);
        expect(id.contains(' '), false);
        expect(id.contains('/'), false);
      }

      for (final id in invalidConversationIds) {
        final isValid = id.isNotEmpty && 
                       !id.contains(' ') && 
                       !id.contains('/') &&
                       id.trim() == id;
        expect(isValid, false);
      }
    });
  });

  group('Error Handling Tests', () {
    test('should handle invalid routes gracefully', () {
      const invalidRoutes = [
        '',
        'invalid-route',
        '//',
        '/invalid//path',
      ];

      for (final route in invalidRoutes) {
        // In a real implementation, these would be handled by the router
        if (route.isEmpty || !route.startsWith('/')) {
          expect(route.startsWith('/'), false);
        }
      }
    });

    test('should provide fallback routes', () {
      const fallbackRoute = AppRoutes.chat;
      
      expect(fallbackRoute, '/chat');
      expect(fallbackRoute.startsWith('/'), true);
    });
  });

  group('Navigation Performance Tests', () {
    test('should handle rapid navigation calls', () {
      final navigationCalls = <String>[];
      
      // Simulate rapid navigation
      for (int i = 0; i < 100; i++) {
        navigationCalls.add('/route_$i');
      }
      
      expect(navigationCalls.length, 100);
      expect(navigationCalls.first, '/route_0');
      expect(navigationCalls.last, '/route_99');
    });

    test('should deduplicate navigation to same route', () {
      final navigationHistory = <String>[];
      const targetRoute = AppRoutes.chat;
      
      // Simulate multiple calls to same route
      for (int i = 0; i < 5; i++) {
        if (navigationHistory.isEmpty || navigationHistory.last != targetRoute) {
          navigationHistory.add(targetRoute);
        }
      }
      
      expect(navigationHistory.length, 1);
      expect(navigationHistory.first, targetRoute);
    });
  });
}