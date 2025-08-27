import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/subscription.dart';
import '../../../auth/domain/entities/user.dart';

// Subscription State
class SubscriptionState {
  final Subscription? subscription;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.subscription,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    Subscription? subscription,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Subscription Controller
class SubscriptionController extends StateNotifier<SubscriptionState> {
  final Ref _ref;

  SubscriptionController(this._ref) : super(const SubscriptionState());

  Future<void> loadSubscription(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual subscription loading
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // For now, return a mock subscription
      final subscription = Subscription(
        id: 'sub_123',
        userId: userId,
        tier: SubscriptionTier.free,
        billingPeriod: BillingPeriod.monthly,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        isActive: true,
        price: 0.0,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        subscription: subscription,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> upgradeSubscription(SubscriptionTier newTier) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual subscription upgrade
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      final updatedSubscription = state.subscription?.copyWith(
        tier: newTier,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        subscription: updatedSubscription,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> cancelSubscription() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual subscription cancellation
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      final updatedSubscription = state.subscription?.copyWith(
        isCancelled: true,
        cancelledAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        subscription: updatedSubscription,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Subscription Controller Provider
final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, SubscriptionState>(
  (ref) => SubscriptionController(ref),
);
