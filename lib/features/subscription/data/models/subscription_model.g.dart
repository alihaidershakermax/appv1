// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tier: $enumDecode(_$SubscriptionTierEnumMap, json['tier']),
      status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
      billingPeriod:
          $enumDecode(_$BillingPeriodEnumMap, json['billingPeriod']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      renewalDate: json['renewalDate'] == null
          ? null
          : DateTime.parse(json['renewalDate'] as String),
      canceledAt: json['canceledAt'] == null
          ? null
          : DateTime.parse(json['canceledAt'] as String),
      stripeSubscriptionId: json['stripeSubscriptionId'] as String?,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      stripePriceId: json['stripePriceId'] as String?,
      usageData: json['usageData'] == null
          ? null
          : UsageDataModel.fromJson(
              json['usageData'] as Map<String, dynamic>),
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      limits: json['limits'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SubscriptionModelToJson(SubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tier': _$SubscriptionTierEnumMap[instance.tier]!,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'billingPeriod': _$BillingPeriodEnumMap[instance.billingPeriod]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'renewalDate': instance.renewalDate?.toIso8601String(),
      'canceledAt': instance.canceledAt?.toIso8601String(),
      'stripeSubscriptionId': instance.stripeSubscriptionId,
      'stripeCustomerId': instance.stripeCustomerId,
      'stripePriceId': instance.stripePriceId,
      'usageData': instance.usageData?.toJson(),
      'features': instance.features,
      'limits': instance.limits,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.free: 'free',
  SubscriptionTier.premium: 'premium',
  SubscriptionTier.premiumPlus: 'premiumPlus',
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.canceled: 'canceled',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.pendingCancelation: 'pendingCancelation',
  SubscriptionStatus.pastDue: 'pastDue',
  SubscriptionStatus.trialing: 'trialing',
};

const _$BillingPeriodEnumMap = {
  BillingPeriod.monthly: 'monthly',
  BillingPeriod.yearly: 'yearly',
};

UsageDataModel _$UsageDataModelFromJson(Map<String, dynamic> json) =>
    UsageDataModel(
      messagesThisMonth: json['messagesThisMonth'] as int? ?? 0,
      messagesLimit: json['messagesLimit'] as int? ?? 100,
      imagesThisMonth: json['imagesThisMonth'] as int? ?? 0,
      imagesLimit: json['imagesLimit'] as int? ?? 10,
      documentsThisMonth: json['documentsThisMonth'] as int? ?? 0,
      documentsLimit: json['documentsLimit'] as int? ?? 5,
      lastResetDate: json['lastResetDate'] == null
          ? null
          : DateTime.parse(json['lastResetDate'] as String),
      totalTokensUsed: json['totalTokensUsed'] as int? ?? 0,
      totalTokensLimit: json['totalTokensLimit'] as int? ?? 10000,
    );

Map<String, dynamic> _$UsageDataModelToJson(UsageDataModel instance) =>
    <String, dynamic>{
      'messagesThisMonth': instance.messagesThisMonth,
      'messagesLimit': instance.messagesLimit,
      'imagesThisMonth': instance.imagesThisMonth,
      'imagesLimit': instance.imagesLimit,
      'documentsThisMonth': instance.documentsThisMonth,
      'documentsLimit': instance.documentsLimit,
      'lastResetDate': instance.lastResetDate?.toIso8601String(),
      'totalTokensUsed': instance.totalTokensUsed,
      'totalTokensLimit': instance.totalTokensLimit,
    };