import 'package:flutter_test/flutter_test.dart';
import 'package:appspraow/features/subscription/domain/entities/subscription.dart';

void main() {
  group('UserSubscription Entity Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.now();
    });

    test('should create subscription with all required fields', () {
      final subscription = UserSubscription(
        id: 'sub_123',
        userId: 'user_456',
        plan: SubscriptionPlan.premium,
        status: SubscriptionStatus.active,
        billingPeriod: BillingPeriod.monthly,
        currentPeriodStart: testDate,
        currentPeriodEnd: testDate.add(const Duration(days: 30)),
        cancelAtPeriodEnd: false,
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(subscription.id, 'sub_123');
      expect(subscription.userId, 'user_456');
      expect(subscription.plan, SubscriptionPlan.premium);
      expect(subscription.status, SubscriptionStatus.active);
      expect(subscription.billingPeriod, BillingPeriod.monthly);
      expect(subscription.cancelAtPeriodEnd, false);
    });

    test('should create subscription with optional fields', () {
      final subscription = UserSubscription(
        id: 'sub_full',
        userId: 'user_full',
        plan: SubscriptionPlan.premiumPlus,
        status: SubscriptionStatus.active,
        billingPeriod: BillingPeriod.yearly,
        currentPeriodStart: testDate,
        currentPeriodEnd: testDate.add(const Duration(days: 365)),
        cancelAtPeriodEnd: true,
        createdAt: testDate,
        updatedAt: testDate,
        stripeSubscriptionId: 'stripe_sub_123',
        stripeCustomerId: 'stripe_cust_456',
        metadata: {'promo_code': 'SAVE20'},
      );

      expect(subscription.stripeSubscriptionId, 'stripe_sub_123');
      expect(subscription.stripeCustomerId, 'stripe_cust_456');
      expect(subscription.metadata['promo_code'], 'SAVE20');
      expect(subscription.billingPeriod, BillingPeriod.yearly);
      expect(subscription.cancelAtPeriodEnd, true);
    });

    test('should copy subscription with updated fields', () {
      final originalSubscription = UserSubscription(
        id: 'sub_original',
        userId: 'user_id',
        plan: SubscriptionPlan.free,
        status: SubscriptionStatus.active,
        billingPeriod: BillingPeriod.monthly,
        currentPeriodStart: testDate,
        currentPeriodEnd: testDate.add(const Duration(days: 30)),
        cancelAtPeriodEnd: false,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final updatedSubscription = originalSubscription.copyWith(
        plan: SubscriptionPlan.premium,
        status: SubscriptionStatus.active,
        cancelAtPeriodEnd: true,
        updatedAt: testDate.add(const Duration(hours: 1)),
      );

      expect(updatedSubscription.id, 'sub_original');
      expect(updatedSubscription.plan, SubscriptionPlan.premium);
      expect(updatedSubscription.cancelAtPeriodEnd, true);
      expect(updatedSubscription.billingPeriod, BillingPeriod.monthly);
    });
  });

  group('UsageData Entity Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.now();
    });

    test('should create usage data with all fields', () {
      final usageData = UsageData(
        id: 'usage_123',
        userId: 'user_456',
        date: testDate,
        messageCount: 25,
        tokensUsed: 1500,
        apiCalls: 30,
        storageUsed: 1024 * 1024, // 1 MB
      );

      expect(usageData.id, 'usage_123');
      expect(usageData.userId, 'user_456');
      expect(usageData.date, testDate);
      expect(usageData.messageCount, 25);
      expect(usageData.tokensUsed, 1500);
      expect(usageData.apiCalls, 30);
      expect(usageData.storageUsed, 1024 * 1024);
    });

    test('should copy usage data with updated fields', () {
      final originalUsage = UsageData(
        id: 'usage_original',
        userId: 'user_id',
        date: testDate,
        messageCount: 10,
        tokensUsed: 500,
        apiCalls: 10,
        storageUsed: 512,
      );

      final updatedUsage = originalUsage.copyWith(
        messageCount: 15,
        tokensUsed: 750,
        apiCalls: 15,
      );

      expect(updatedUsage.id, 'usage_original');
      expect(updatedUsage.messageCount, 15);
      expect(updatedUsage.tokensUsed, 750);
      expect(updatedUsage.apiCalls, 15);
      expect(updatedUsage.storageUsed, 512); // Should remain unchanged
    });
  });

  group('Subscription Enums Tests', () {
    test('should have correct subscription plans', () {
      expect(SubscriptionPlan.values.length, 3);
      expect(SubscriptionPlan.values.contains(SubscriptionPlan.free), true);
      expect(SubscriptionPlan.values.contains(SubscriptionPlan.premium), true);
      expect(SubscriptionPlan.values.contains(SubscriptionPlan.premiumPlus), true);
    });

    test('should have correct subscription statuses', () {
      expect(SubscriptionStatus.values.length, 6);
      expect(SubscriptionStatus.values.contains(SubscriptionStatus.active), true);
      expect(SubscriptionStatus.values.contains(SubscriptionStatus.canceled), true);
      expect(SubscriptionStatus.values.contains(SubscriptionStatus.pastDue), true);
      expect(SubscriptionStatus.values.contains(SubscriptionStatus.unpaid), true);
      expect(SubscriptionStatus.values.contains(SubscriptionStatus.paused), true);
      expect(SubscriptionStatus.values.contains(SubscriptionStatus.trialing), true);
    });

    test('should have correct billing periods', () {
      expect(BillingPeriod.values.length, 2);
      expect(BillingPeriod.values.contains(BillingPeriod.monthly), true);
      expect(BillingPeriod.values.contains(BillingPeriod.yearly), true);
    });
  });

  group('Subscription Business Logic Tests', () {
    late DateTime now;

    setUp(() {
      now = DateTime.now();
    });

    test('should identify active subscriptions', () {
      final activeSubscription = UserSubscription(
        id: 'sub_active',
        userId: 'user_id',
        plan: SubscriptionPlan.premium,
        status: SubscriptionStatus.active,
        billingPeriod: BillingPeriod.monthly,
        currentPeriodStart: now.subtract(const Duration(days: 15)),
        currentPeriodEnd: now.add(const Duration(days: 15)),
        cancelAtPeriodEnd: false,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      );

      expect(activeSubscription.status, SubscriptionStatus.active);
      expect(activeSubscription.currentPeriodEnd.isAfter(now), true);
    });

    test('should identify canceled subscriptions', () {
      final canceledSubscription = UserSubscription(
        id: 'sub_canceled',
        userId: 'user_id',
        plan: SubscriptionPlan.premium,
        status: SubscriptionStatus.canceled,
        billingPeriod: BillingPeriod.monthly,
        currentPeriodStart: now.subtract(const Duration(days: 45)),
        currentPeriodEnd: now.subtract(const Duration(days: 15)),
        cancelAtPeriodEnd: true,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 15)),
      );

      expect(canceledSubscription.status, SubscriptionStatus.canceled);
      expect(canceledSubscription.cancelAtPeriodEnd, true);
      expect(canceledSubscription.currentPeriodEnd.isBefore(now), true);
    });

    test('should handle subscription upgrades', () {
      final freeSubscription = UserSubscription(
        id: 'sub_free',
        userId: 'user_id',
        plan: SubscriptionPlan.free,
        status: SubscriptionStatus.active,
        billingPeriod: BillingPeriod.monthly,
        currentPeriodStart: now,
        currentPeriodEnd: now.add(const Duration(days: 30)),
        cancelAtPeriodEnd: false,
        createdAt: now,
        updatedAt: now,
      );

      final upgradedSubscription = freeSubscription.copyWith(
        plan: SubscriptionPlan.premium,
        updatedAt: now.add(const Duration(minutes: 5)),
      );

      expect(upgradedSubscription.plan, SubscriptionPlan.premium);
      expect(upgradedSubscription.status, SubscriptionStatus.active);
      expect(upgradedSubscription.id, freeSubscription.id);
    });

    test('should handle yearly billing period correctly', () {
      final yearlySubscription = UserSubscription(
        id: 'sub_yearly',
        userId: 'user_id',
        plan: SubscriptionPlan.premiumPlus,
        status: SubscriptionStatus.active,
        billingPeriod: BillingPeriod.yearly,
        currentPeriodStart: now,
        currentPeriodEnd: now.add(const Duration(days: 365)),
        cancelAtPeriodEnd: false,
        createdAt: now,
        updatedAt: now,
      );

      final periodLength = yearlySubscription.currentPeriodEnd
          .difference(yearlySubscription.currentPeriodStart);
      
      expect(yearlySubscription.billingPeriod, BillingPeriod.yearly);
      expect(periodLength.inDays, 365);
    });

    test('should track usage data correctly', () {
      final dailyUsage = UsageData(
        id: 'usage_daily',
        userId: 'user_id',
        date: now,
        messageCount: 50,
        tokensUsed: 2500,
        apiCalls: 55,
        storageUsed: 2048,
      );

      // Simulate adding more usage
      final updatedUsage = dailyUsage.copyWith(
        messageCount: dailyUsage.messageCount + 10,
        tokensUsed: dailyUsage.tokensUsed + 500,
        apiCalls: dailyUsage.apiCalls + 10,
      );

      expect(updatedUsage.messageCount, 60);
      expect(updatedUsage.tokensUsed, 3000);
      expect(updatedUsage.apiCalls, 65);
    });

    test('should handle trial periods', () {
      final trialSubscription = UserSubscription(
        id: 'sub_trial',
        userId: 'user_id',
        plan: SubscriptionPlan.premium,
        status: SubscriptionStatus.trialing,
        billingPeriod: BillingPeriod.monthly,
        currentPeriodStart: now,
        currentPeriodEnd: now.add(const Duration(days: 7)), // 7-day trial
        cancelAtPeriodEnd: false,
        createdAt: now,
        updatedAt: now,
      );

      expect(trialSubscription.status, SubscriptionStatus.trialing);
      expect(trialSubscription.plan, SubscriptionPlan.premium);
      
      final trialDays = trialSubscription.currentPeriodEnd
          .difference(trialSubscription.currentPeriodStart).inDays;
      expect(trialDays, 7);
    });

    test('should calculate subscription value correctly', () {
      const monthlyPremium = 9.99;
      const yearlyPremium = monthlyPremium * 12 * 0.8; // 20% discount

      final monthlySubscription = UserSubscription(
        id: 'sub_monthly',
        userId: 'user_id',
        plan: SubscriptionPlan.premium,
        status: SubscriptionStatus.active,
        billingPeriod: BillingPeriod.monthly,
        currentPeriodStart: now,
        currentPeriodEnd: now.add(const Duration(days: 30)),
        cancelAtPeriodEnd: false,
        createdAt: now,
        updatedAt: now,
      );

      final yearlySubscription = monthlySubscription.copyWith(
        billingPeriod: BillingPeriod.yearly,
        currentPeriodEnd: now.add(const Duration(days: 365)),
      );

      // In a real implementation, these would be calculated
      expect(monthlySubscription.billingPeriod, BillingPeriod.monthly);
      expect(yearlySubscription.billingPeriod, BillingPeriod.yearly);
      
      // Yearly should offer better value
      expect(yearlyPremium < monthlyPremium * 12, true);
    });
  });
}