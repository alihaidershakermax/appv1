import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class GetUserSubscription {
  final SubscriptionRepository repository;

  GetUserSubscription(this.repository);

  Future<Either<Failure, Subscription?>> call(String userId) async {
    return await repository.getUserSubscription(userId);
  }

  Stream<Subscription?> watch(String userId) {
    return repository.watchUserSubscription(userId);
  }
}

class CreateSubscription {
  final SubscriptionRepository repository;

  CreateSubscription(this.repository);

  Future<Either<Failure, Subscription>> call({
    required String userId,
    required SubscriptionTier tier,
    required BillingPeriod billingPeriod,
    required String paymentMethodId,
    String? stripeCustomerId,
  }) async {
    return await repository.createSubscription(
      userId: userId,
      tier: tier,
      billingPeriod: billingPeriod,
      paymentMethodId: paymentMethodId,
      stripeCustomerId: stripeCustomerId,
    );
  }
}

class CancelSubscription {
  final SubscriptionRepository repository;

  CancelSubscription(this.repository);

  Future<Either<Failure, void>> call({
    required String subscriptionId,
    bool immediately = false,
  }) async {
    return await repository.cancelSubscription(
      subscriptionId: subscriptionId,
      immediately: immediately,
    );
  }
}

class CheckMessageLimit {
  final SubscriptionRepository repository;

  CheckMessageLimit(this.repository);

  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.canSendMessage(userId);
  }
}

class GetRemainingMessages {
  final SubscriptionRepository repository;

  GetRemainingMessages(this.repository);

  Future<Either<Failure, int>> call(String userId) async {
    return await repository.getRemainingMessages(userId);
  }
}

class UpdateUsage {
  final SubscriptionRepository repository;

  UpdateUsage(this.repository);

  Future<Either<Failure, UsageData>> call({
    required String userId,
    int? messageCount,
    int? fileUploadCount,
    int? imageUploadCount,
    double? aiTokensUsed,
  }) async {
    return await repository.updateUsage(
      userId: userId,
      messageCount: messageCount,
      fileUploadCount: fileUploadCount,
      imageUploadCount: imageUploadCount,
      aiTokensUsed: aiTokensUsed,
    );
  }
}

class GetTodayUsage {
  final SubscriptionRepository repository;

  GetTodayUsage(this.repository);

  Future<Either<Failure, UsageData>> call(String userId) async {
    return await repository.getTodayUsage(userId);
  }

  Stream<UsageData> watch(String userId) {
    return repository.watchTodayUsage(userId);
  }
}