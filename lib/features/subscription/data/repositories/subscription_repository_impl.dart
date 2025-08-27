import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';
import '../datasources/stripe_payment_service.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;
  final StripePaymentService stripeService;
  final NetworkInfo networkInfo;

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
    required this.stripeService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Subscription?>> getUserSubscription(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final subscription = await remoteDataSource.getUserSubscription(userId);
        return Right(subscription);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Subscription>> createSubscription({
    required String userId,
    required SubscriptionTier tier,
    required BillingPeriod billingPeriod,
    required String paymentMethodId,
    String? stripeCustomerId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Create Stripe subscription
        final stripeSubData = await stripeService.createSubscription(
          customerId: stripeCustomerId!,
          paymentMethodId: paymentMethodId,
          tier: tier,
          billingPeriod: billingPeriod,
        );

        // Calculate end date
        final now = DateTime.now();
        final endDate = billingPeriod == BillingPeriod.monthly
            ? DateTime(now.year, now.month + 1, now.day)
            : DateTime(now.year + 1, now.month, now.day);

        // Create subscription model
        final subscription = SubscriptionModel(
          id: '', // Will be set by Firestore
          userId: userId,
          tier: tier,
          billingPeriod: billingPeriod,
          startDate: now,
          endDate: endDate,
          isActive: true,
          stripeSubscriptionId: stripeSubData['id'] as String,
          stripeCustomerId: stripeCustomerId,
          price: tier.monthlyPrice,
          createdAt: now,
          updatedAt: now,
        );

        final createdSubscription = await remoteDataSource.createSubscription(subscription);
        return Right(createdSubscription);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on PaymentException catch (e) {
        return Left(PaymentFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Subscription>> updateSubscription({
    required String subscriptionId,
    required SubscriptionTier newTier,
    required BillingPeriod newBillingPeriod,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Get current subscription
        final currentSub = await remoteDataSource.getUserSubscription(subscriptionId);
        if (currentSub == null) {
          return const Left(ServerFailure('Subscription not found'));
        }

        // Update Stripe subscription
        await stripeService.updateSubscription(
          subscriptionId: currentSub.stripeSubscriptionId!,
          newTier: newTier,
          newBillingPeriod: newBillingPeriod,
        );

        // Update local subscription
        final updatedSubscription = currentSub.copyWith(
          tier: newTier,
          billingPeriod: newBillingPeriod,
          price: newBillingPeriod == BillingPeriod.monthly 
              ? newTier.monthlyPrice 
              : newTier.yearlyPrice,
          updatedAt: DateTime.now(),
        );

        final result = await remoteDataSource.updateSubscription(updatedSubscription);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on PaymentException catch (e) {
        return Left(PaymentFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription({
    required String subscriptionId,
    bool immediately = false,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Cancel Stripe subscription
        await stripeService.cancelSubscription(
          subscriptionId: subscriptionId,
          immediately: immediately,
        );

        // Update local subscription
        await remoteDataSource.cancelSubscription(subscriptionId);
        
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on PaymentException catch (e) {
        return Left(PaymentFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> createPaymentIntent({
    required String userId,
    required SubscriptionTier tier,
    required BillingPeriod billingPeriod,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Get or create Stripe customer
        final customerData = await stripeService.createPaymentIntent(
          customerId: 'temp', // This should be the actual customer ID
          tier: tier,
          billingPeriod: billingPeriod,
        );

        return Right(customerData['client_secret'] as String);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on PaymentException catch (e) {
        return Left(PaymentFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> createStripeCustomer({
    required String email,
    required String name,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final customerId = await stripeService.createCustomer(
          email: email,
          name: name,
        );
        return Right(customerId);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> processPayment({
    required String paymentIntentClientSecret,
  }) async {
    try {
      await stripeService.processPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
      );
      return const Right(null);
    } on PaymentException catch (e) {
      return Left(PaymentFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UsageData>> getTodayUsage(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final usage = await remoteDataSource.getTodayUsage(userId);
        return Right(usage);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UsageData>> updateUsage({
    required String userId,
    int? messageCount,
    int? fileUploadCount,
    int? imageUploadCount,
    double? aiTokensUsed,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Get current usage
        final currentUsage = await remoteDataSource.getTodayUsage(userId);
        
        // Update with new values
        final updatedUsage = UsageDataModel.fromEntity(currentUsage).copyWith(
          messageCount: messageCount != null 
              ? currentUsage.messageCount + messageCount 
              : currentUsage.messageCount,
          fileUploadCount: fileUploadCount != null 
              ? currentUsage.fileUploadCount + fileUploadCount 
              : currentUsage.fileUploadCount,
          imageUploadCount: imageUploadCount != null 
              ? currentUsage.imageUploadCount + imageUploadCount 
              : currentUsage.imageUploadCount,
          aiTokensUsed: aiTokensUsed != null 
              ? currentUsage.aiTokensUsed + aiTokensUsed 
              : currentUsage.aiTokensUsed,
          updatedAt: DateTime.now(),
        );

        final result = await remoteDataSource.updateUsage(updatedUsage);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<UsageData>>> getUsageHistory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final usage = await remoteDataSource.getUsageHistory(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        );
        return Right(usage);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> canSendMessage(String userId) async {
    final subscriptionResult = await getUserSubscription(userId);
    final usageResult = await getTodayUsage(userId);

    return subscriptionResult.fold(
      (failure) => Left(failure),
      (subscription) {
        return usageResult.fold(
          (failure) => Left(failure),
          (usage) {
            // Check if user has premium subscription
            if (subscription != null && subscription.isPremium) {
              return const Right(true);
            }
            
            // Check free tier limits
            final freeLimit = SubscriptionTier.free.messageLimit;
            return Right(usage.messageCount < freeLimit);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, bool>> canUploadFile(String userId) async {
    final subscriptionResult = await getUserSubscription(userId);
    
    return subscriptionResult.fold(
      (failure) => Left(failure),
      (subscription) {
        // File upload only available for premium users
        if (subscription != null && subscription.isPremium) {
          return const Right(true);
        }
        return const Right(false);
      },
    );
  }

  @override
  Future<Either<Failure, int>> getRemainingMessages(String userId) async {
    final subscriptionResult = await getUserSubscription(userId);
    final usageResult = await getTodayUsage(userId);

    return subscriptionResult.fold(
      (failure) => Left(failure),
      (subscription) {
        return usageResult.fold(
          (failure) => Left(failure),
          (usage) {
            // Premium users have unlimited messages
            if (subscription != null && subscription.isPremium) {
              return const Right(-1); // Unlimited
            }
            
            // Free tier limits
            final freeLimit = SubscriptionTier.free.messageLimit;
            final remaining = freeLimit - usage.messageCount;
            return Right(remaining.clamp(0, freeLimit));
          },
        );
      },
    );
  }

  @override
  Stream<Subscription?> watchUserSubscription(String userId) {
    return remoteDataSource.watchUserSubscription(userId);
  }

  @override
  Stream<UsageData> watchTodayUsage(String userId) {
    return remoteDataSource.watchTodayUsage(userId);
  }
}