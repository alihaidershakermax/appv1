import 'package:flutter_test/flutter_test.dart';
import 'package:appspraow/features/auth/domain/entities/user.dart';

void main() {
  group('User Entity Tests', () {
    late User testUser;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.now();
      testUser = User(
        id: 'test_user_id',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        isEmailVerified: true,
        createdAt: testDate,
        lastSignIn: testDate,
        subscriptionPlan: SubscriptionPlan.free,
        dailyMessageCount: 5,
        lastMessageDate: testDate,
      );
    });

    test('should create user with all required fields', () {
      expect(testUser.id, 'test_user_id');
      expect(testUser.email, 'test@example.com');
      expect(testUser.displayName, 'Test User');
      expect(testUser.photoUrl, 'https://example.com/photo.jpg');
      expect(testUser.isEmailVerified, true);
      expect(testUser.createdAt, testDate);
      expect(testUser.lastSignIn, testDate);
      expect(testUser.subscriptionPlan, SubscriptionPlan.free);
      expect(testUser.dailyMessageCount, 5);
      expect(testUser.lastMessageDate, testDate);
    });

    test('should create user with minimal required fields', () {
      final minimalUser = User(
        id: 'minimal_id',
        email: 'minimal@example.com',
        isEmailVerified: false,
        createdAt: testDate,
        lastSignIn: testDate,
        subscriptionPlan: SubscriptionPlan.free,
        lastMessageDate: testDate,
      );

      expect(minimalUser.id, 'minimal_id');
      expect(minimalUser.email, 'minimal@example.com');
      expect(minimalUser.displayName, null);
      expect(minimalUser.photoUrl, null);
      expect(minimalUser.isEmailVerified, false);
      expect(minimalUser.dailyMessageCount, 0);
    });

    test('should create copy with updated fields using copyWith', () {
      final updatedUser = testUser.copyWith(
        displayName: 'Updated Name',
        dailyMessageCount: 10,
        subscriptionPlan: SubscriptionPlan.premium,
      );

      expect(updatedUser.id, testUser.id);
      expect(updatedUser.email, testUser.email);
      expect(updatedUser.displayName, 'Updated Name');
      expect(updatedUser.dailyMessageCount, 10);
      expect(updatedUser.subscriptionPlan, SubscriptionPlan.premium);
      expect(updatedUser.photoUrl, testUser.photoUrl);
      expect(updatedUser.isEmailVerified, testUser.isEmailVerified);
    });

    test('should keep original values when copyWith called with null', () {
      final copiedUser = testUser.copyWith();

      expect(copiedUser.id, testUser.id);
      expect(copiedUser.email, testUser.email);
      expect(copiedUser.displayName, testUser.displayName);
      expect(copiedUser.photoUrl, testUser.photoUrl);
      expect(copiedUser.isEmailVerified, testUser.isEmailVerified);
      expect(copiedUser.createdAt, testUser.createdAt);
      expect(copiedUser.lastSignIn, testUser.lastSignIn);
      expect(copiedUser.subscriptionPlan, testUser.subscriptionPlan);
      expect(copiedUser.dailyMessageCount, testUser.dailyMessageCount);
      expect(copiedUser.lastMessageDate, testUser.lastMessageDate);
    });
  });

  group('SubscriptionPlan Extension Tests', () {
    test('should return correct display names', () {
      expect(SubscriptionPlan.free.displayName, 'Free');
      expect(SubscriptionPlan.premium.displayName, 'Premium');
      expect(SubscriptionPlan.premiumPlus.displayName, 'Premium Plus');
    });

    test('should return correct message limits', () {
      expect(SubscriptionPlan.free.messageLimit, 10);
      expect(SubscriptionPlan.premium.messageLimit, -1);
      expect(SubscriptionPlan.premiumPlus.messageLimit, -1);
    });

    test('should return correct monthly prices', () {
      expect(SubscriptionPlan.free.monthlyPrice, 0.0);
      expect(SubscriptionPlan.premium.monthlyPrice, 9.99);
      expect(SubscriptionPlan.premiumPlus.monthlyPrice, 19.99);
    });
  });

  group('User Business Logic Tests', () {
    test('should identify free plan users correctly', () {
      final freeUser = User(
        id: 'free_user',
        email: 'free@example.com',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastSignIn: DateTime.now(),
        subscriptionPlan: SubscriptionPlan.free,
        dailyMessageCount: 8,
        lastMessageDate: DateTime.now(),
      );

      expect(freeUser.subscriptionPlan, SubscriptionPlan.free);
      expect(freeUser.subscriptionPlan.messageLimit, 10);
      expect(freeUser.subscriptionPlan.monthlyPrice, 0.0);
    });

    test('should identify premium users correctly', () {
      final premiumUser = User(
        id: 'premium_user',
        email: 'premium@example.com',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastSignIn: DateTime.now(),
        subscriptionPlan: SubscriptionPlan.premium,
        dailyMessageCount: 50,
        lastMessageDate: DateTime.now(),
      );

      expect(premiumUser.subscriptionPlan, SubscriptionPlan.premium);
      expect(premiumUser.subscriptionPlan.messageLimit, -1);
      expect(premiumUser.subscriptionPlan.monthlyPrice, 9.99);
    });

    test('should handle user upgrade scenarios', () {
      final user = User(
        id: 'upgrade_user',
        email: 'upgrade@example.com',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastSignIn: DateTime.now(),
        subscriptionPlan: SubscriptionPlan.free,
        dailyMessageCount: 10,
        lastMessageDate: DateTime.now(),
      );

      final upgradedUser = user.copyWith(
        subscriptionPlan: SubscriptionPlan.premium,
        dailyMessageCount: 0, // Reset count after upgrade
      );

      expect(upgradedUser.subscriptionPlan, SubscriptionPlan.premium);
      expect(upgradedUser.subscriptionPlan.messageLimit, -1);
      expect(upgradedUser.dailyMessageCount, 0);
    });

    test('should calculate remaining messages for free users', () {
      final freeUser = User(
        id: 'free_user',
        email: 'free@example.com',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastSignIn: DateTime.now(),
        subscriptionPlan: SubscriptionPlan.free,
        dailyMessageCount: 7,
        lastMessageDate: DateTime.now(),
      );

      final remaining = freeUser.subscriptionPlan.messageLimit - freeUser.dailyMessageCount;
      expect(remaining, 3);
    });

    test('should handle unlimited messages for premium users', () {
      final premiumUser = User(
        id: 'premium_user',
        email: 'premium@example.com',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastSignIn: DateTime.now(),
        subscriptionPlan: SubscriptionPlan.premium,
        dailyMessageCount: 100,
        lastMessageDate: DateTime.now(),
      );

      expect(premiumUser.subscriptionPlan.messageLimit, -1);
      // For unlimited plans, there's no limit to check
    });
  });
}