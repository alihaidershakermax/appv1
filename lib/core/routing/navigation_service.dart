import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

/// Navigation service for programmatic navigation
/// Provides type-safe navigation methods for all app routes
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  /// Navigate to login screen
  static void toLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  /// Navigate to signup screen
  static void toSignup(BuildContext context) {
    context.go(AppRoutes.signup);
  }

  /// Navigate to chat screen
  static void toChat(BuildContext context) {
    context.go(AppRoutes.chat);
  }

  /// Navigate to specific conversation
  static void toChatConversation(BuildContext context, String conversationId) {
    context.go('${AppRoutes.chat}/$conversationId');
  }

  /// Navigate to profile screen
  static void toProfile(BuildContext context) {
    context.go(AppRoutes.profile);
  }

  /// Navigate to settings screen
  static void toSettings(BuildContext context) {
    context.go(AppRoutes.settings);
  }

  /// Push a route and wait for result
  static Future<T?> push<T>(BuildContext context, String route) {
    return context.push<T>(route);
  }

  /// Pop current route
  static void pop<T>(BuildContext context, [T? result]) {
    context.pop(result);
  }

  /// Check if can pop
  static bool canPop(BuildContext context) {
    return context.canPop();
  }

  /// Replace current route
  static void replace(BuildContext context, String route) {
    context.go(route);
  }

  /// Clear stack and navigate to route
  static void clearAndNavigateTo(BuildContext context, String route) {
    context.go(route);
  }

  /// Show dialog with navigation context
  static Future<T?> showDialogRoute<T>(
    BuildContext context,
    Widget dialog, {
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => dialog,
    );
  }

  /// Show bottom sheet with navigation context
  static Future<T?> showBottomSheetRoute<T>(
    BuildContext context,
    Widget content, {
    bool isScrollControlled = false,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => content,
    );
  }

  /// Get current route name
  static String getCurrentRoute(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    return router.location;
  }

  /// Navigate with parameters
  static void toRouteWithParams(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) {
    String finalRoute = route;
    params.forEach((key, value) {
      finalRoute = finalRoute.replaceAll(':$key', value);
    });
    context.go(finalRoute);
  }

  /// Navigate with query parameters
  static void toRouteWithQuery(
    BuildContext context,
    String route,
    Map<String, String> queryParams,
  ) {
    final uri = Uri.parse(route);
    final newUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParams,
      },
    );
    context.go(newUri.toString());
  }
}

/// Extension methods for easier navigation
extension NavigationExtension on BuildContext {
  void toLogin() => NavigationService.toLogin(this);
  void toSignup() => NavigationService.toSignup(this);
  void toChat() => NavigationService.toChat(this);
  void toChatConversation(String conversationId) => 
      NavigationService.toChatConversation(this, conversationId);
  void toProfile() => NavigationService.toProfile(this);
  void toSettings() => NavigationService.toSettings(this);
  
  String get currentRoute => NavigationService.getCurrentRoute(this);
}