import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';
import '../../features/chat/presentation/pages/chat_home_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';

// Route Names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String chat = '/chat';
  static const String chatConversation = '/chat/:conversationId';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';
  static const String subscription = '/subscription';
}

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      
      // Show splash while loading
      if (isLoading) {
        return AppRoutes.splash;
      }
      
      // Redirect to login if not authenticated and trying to access protected routes
      if (!isAuthenticated && _isProtectedRoute(state.uri.toString())) {
        return AppRoutes.login;
      }
      
      // Redirect to chat if authenticated and trying to access auth routes
      if (isAuthenticated && _isAuthRoute(state.uri.toString())) {
        return AppRoutes.chat;
      }
      
      return null; // No redirect needed
    },
    routes: [
      // Splash Route
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      
      // Main App Routes (Protected)
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.chat,
            name: 'chat',
            builder: (context, state) => const ChatHomeScreen(),
            routes: [
              GoRoute(
                path: ':conversationId',
                name: 'chat-conversation',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  return ChatHomeScreen(
                    initialConversationId: conversationId,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

// Helper functions
bool _isProtectedRoute(String location) {
  const protectedRoutes = [
    AppRoutes.chat,
    AppRoutes.profile,
    AppRoutes.settings,
  ];
  
  return protectedRoutes.any((route) => location.startsWith(route));
}

bool _isAuthRoute(String location) {
  const authRoutes = [
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.splash,
  ];
  
  return authRoutes.contains(location);
}

// Main Shell Widget (for bottom navigation)
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }
}

// Bottom Navigation Widget
class AppBottomNavigation extends ConsumerWidget {
  const AppBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final theme = Theme.of(context);
    
    return NavigationBar(
      selectedIndex: _getSelectedIndex(location),
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      backgroundColor: theme.colorScheme.surface,
      elevation: 8,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith(AppRoutes.chat)) return 0;
    if (location == AppRoutes.profile) return 1;
    if (location == AppRoutes.settings) return 2;
    return 0; // Default to chat
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.chat);
        break;
      case 1:
        context.go(AppRoutes.profile);
        break;
      case 2:
        context.go(AppRoutes.settings);
        break;
    }
  }
}

// Error Screen
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'An unexpected error occurred',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.go(AppRoutes.chat);
                },
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Navigation Extensions
extension GoRouterExtension on GoRouter {
  String get location {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}