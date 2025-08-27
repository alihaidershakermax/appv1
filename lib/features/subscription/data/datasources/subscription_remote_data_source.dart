import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/subscription_model.dart';
import '../../domain/entities/subscription.dart';

abstract class SubscriptionRemoteDataSource {
  Future<SubscriptionModel?> getUserSubscription(String userId);
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription);
  Future<SubscriptionModel> updateSubscription(SubscriptionModel subscription);
  Future<void> cancelSubscription(String subscriptionId);
  
  Future<UsageDataModel> getTodayUsage(String userId);
  Future<UsageDataModel> updateUsage(UsageDataModel usage);
  Future<List<UsageDataModel>> getUsageHistory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Stream<SubscriptionModel?> watchUserSubscription(String userId);
  Stream<UsageDataModel> watchTodayUsage(String userId);
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final FirebaseFirestore _firestore;

  SubscriptionRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<SubscriptionModel?> getUserSubscription(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return SubscriptionModel.fromFirestore(querySnapshot.docs.first, null);
    } catch (e) {
      throw ServerException('Failed to get user subscription: $e');
    }
  }

  @override
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription) async {
    try {
      final docRef = _firestore.collection('subscriptions').doc();
      final subscriptionWithId = subscription.copyWith(id: docRef.id);
      
      await docRef.set(subscriptionWithId.toFirestore());
      return subscriptionWithId;
    } catch (e) {
      throw ServerException('Failed to create subscription: $e');
    }
  }

  @override
  Future<SubscriptionModel> updateSubscription(SubscriptionModel subscription) async {
    try {
      await _firestore
          .collection('subscriptions')
          .doc(subscription.id)
          .update(subscription.toFirestore());
      
      return subscription;
    } catch (e) {
      throw ServerException('Failed to update subscription: $e');
    }
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _firestore
          .collection('subscriptions')
          .doc(subscriptionId)
          .update({
        'isActive': false,
        'isCancelled': true,
        'cancelledAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw ServerException('Failed to cancel subscription: $e');
    }
  }

  @override
  Future<UsageDataModel> getTodayUsage(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final docId = '${userId}_${startOfDay.millisecondsSinceEpoch}';

      final docSnapshot = await _firestore
          .collection('usage_data')
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        return UsageDataModel.fromFirestore(docSnapshot, null);
      } else {
        // Create new usage data for today
        final newUsage = UsageDataModel(
          userId: userId,
          date: startOfDay,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _firestore
            .collection('usage_data')
            .doc(docId)
            .set(newUsage.toFirestore());
        
        return newUsage;
      }
    } catch (e) {
      throw ServerException('Failed to get today usage: $e');
    }
  }

  @override
  Future<UsageDataModel> updateUsage(UsageDataModel usage) async {
    try {
      final docId = '${usage.userId}_${usage.date.millisecondsSinceEpoch}';
      
      await _firestore
          .collection('usage_data')
          .doc(docId)
          .set(usage.toFirestore(), SetOptions(merge: true));
      
      return usage;
    } catch (e) {
      throw ServerException('Failed to update usage: $e');
    }
  }

  @override
  Future<List<UsageDataModel>> getUsageHistory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('usage_data')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UsageDataModel.fromFirestore(doc, null))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get usage history: $e');
    }
  }

  @override
  Stream<SubscriptionModel?> watchUserSubscription(String userId) {
    return _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return SubscriptionModel.fromFirestore(snapshot.docs.first, null);
    });
  }

  @override
  Stream<UsageDataModel> watchTodayUsage(String userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final docId = '${userId}_${startOfDay.millisecondsSinceEpoch}';

    return _firestore
        .collection('usage_data')
        .doc(docId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UsageDataModel.fromFirestore(snapshot, null);
      } else {
        return UsageDataModel(
          userId: userId,
          date: startOfDay,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    });
  }
}