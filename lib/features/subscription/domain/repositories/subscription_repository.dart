import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  // Subscription Management
  Future<Either<Failure, Subscription?>> getUserSubscription(String userId);
  Future<Either<Failure, Subscription>> createSubscription({
    required String userId,
    required SubscriptionTier tier,
    required BillingPeriod billingPeriod,
    required String paymentMethodId,
    String? stripeCustomerId,
  });
  Future<Either<Failure, Subscription>> updateSubscription({
    required String subscriptionId,
    required SubscriptionTier newTier,
    required BillingPeriod newBillingPeriod,
  });
  Future<Either<Failure, void>> cancelSubscription({
    required String subscriptionId,
    bool immediately = false,
  });

  // Payment Management
  Future<Either<Failure, String>> createPaymentIntent({
    required String userId,
    required SubscriptionTier tier,
    required BillingPeriod billingPeriod,
  });
  Future<Either<Failure, String>> createStripeCustomer({
    required String email,
    required String name,
  });
  Future<Either<Failure, void>> processPayment({
    required String paymentIntentClientSecret,
  });

  // Usage Tracking
  Future<Either<Failure, UsageData>> getTodayUsage(String userId);
  Future<Either<Failure, UsageData>> updateUsage({
    required String userId,
    int? messageCount,
    int? fileUploadCount,
    int? imageUploadCount,
    double? aiTokensUsed,
  });
  Future<Either<Failure, List<UsageData>>> getUsageHistory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  // Subscription Status
  Future<Either<Failure, bool>> canSendMessage(String userId);
  Future<Either<Failure, bool>> canUploadFile(String userId);
  Future<Either<Failure, int>> getRemainingMessages(String userId);
  
  // Real-time updates
  Stream<Subscription?> watchUserSubscription(String userId);
  Stream<UsageData> watchTodayUsage(String userId);
}