import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/subscription.dart';

part 'subscription_model.g.dart';

@JsonSerializable()
class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.id,
    required super.userId,
    required super.tier,
    required super.billingPeriod,
    required super.startDate,
    required super.endDate,
    required super.isActive,
    super.isCancelled = false,
    super.cancelledAt,
    super.stripeSubscriptionId,
    super.stripeCustomerId,
    required super.price,
    super.currency = 'USD',
    required super.createdAt,
    required super.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);

  factory SubscriptionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return SubscriptionModel(
      id: snapshot.id,
      userId: data['userId'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (tier) => tier.name == data['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      billingPeriod: BillingPeriod.values.firstWhere(
        (period) => period.name == data['billingPeriod'],
        orElse: () => BillingPeriod.monthly,
      ),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool,
      isCancelled: data['isCancelled'] as bool? ?? false,
      cancelledAt: data['cancelledAt'] != null
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
      stripeSubscriptionId: data['stripeSubscriptionId'] as String?,
      stripeCustomerId: data['stripeCustomerId'] as String?,
      price: (data['price'] as num).toDouble(),
      currency: data['currency'] as String? ?? 'USD',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'tier': tier.name,
      'billingPeriod': billingPeriod.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'isCancelled': isCancelled,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'stripeSubscriptionId': stripeSubscriptionId,
      'stripeCustomerId': stripeCustomerId,
      'price': price,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SubscriptionModel.fromEntity(Subscription subscription) {
    return SubscriptionModel(
      id: subscription.id,
      userId: subscription.userId,
      tier: subscription.tier,
      billingPeriod: subscription.billingPeriod,
      startDate: subscription.startDate,
      endDate: subscription.endDate,
      isActive: subscription.isActive,
      isCancelled: subscription.isCancelled,
      cancelledAt: subscription.cancelledAt,
      stripeSubscriptionId: subscription.stripeSubscriptionId,
      stripeCustomerId: subscription.stripeCustomerId,
      price: subscription.price,
      currency: subscription.currency,
      createdAt: subscription.createdAt,
      updatedAt: subscription.updatedAt,
    );
  }

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    SubscriptionTier? tier,
    BillingPeriod? billingPeriod,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isCancelled,
    DateTime? cancelledAt,
    String? stripeSubscriptionId,
    String? stripeCustomerId,
    double? price,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isCancelled: isCancelled ?? this.isCancelled,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class UsageDataModel extends UsageData {
  const UsageDataModel({
    required super.userId,
    required super.date,
    super.messageCount = 0,
    super.fileUploadCount = 0,
    super.imageUploadCount = 0,
    super.aiTokensUsed = 0.0,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UsageDataModel.fromJson(Map<String, dynamic> json) =>
      _$UsageDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$UsageDataModelToJson(this);

  factory UsageDataModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return UsageDataModel(
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      messageCount: data['messageCount'] as int? ?? 0,
      fileUploadCount: data['fileUploadCount'] as int? ?? 0,
      imageUploadCount: data['imageUploadCount'] as int? ?? 0,
      aiTokensUsed: (data['aiTokensUsed'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'messageCount': messageCount,
      'fileUploadCount': fileUploadCount,
      'imageUploadCount': imageUploadCount,
      'aiTokensUsed': aiTokensUsed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UsageDataModel.fromEntity(UsageData usage) {
    return UsageDataModel(
      userId: usage.userId,
      date: usage.date,
      messageCount: usage.messageCount,
      fileUploadCount: usage.fileUploadCount,
      imageUploadCount: usage.imageUploadCount,
      aiTokensUsed: usage.aiTokensUsed,
      createdAt: usage.createdAt,
      updatedAt: usage.updatedAt,
    );
  }
}