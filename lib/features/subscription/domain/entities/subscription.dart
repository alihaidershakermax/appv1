enum SubscriptionStatus {
  active,
  inactive,
  expired,
  cancelled,
}

enum SubscriptionTier {
  free,
  premium,
  premiumPlus,
}

extension SubscriptionTierX on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.premiumPlus:
        return 'Premium Plus';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionTier.free:
        return '10 messages per day';
      case SubscriptionTier.premium:
        return 'Unlimited messages';
      case SubscriptionTier.premiumPlus:
        return 'Unlimited + Priority support';
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0.0;
      case SubscriptionTier.premium:
        return 9.99;
      case SubscriptionTier.premiumPlus:
        return 19.99;
    }
  }

  double get yearlyPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0.0;
      case SubscriptionTier.premium:
        return 99.99; // 2 months free
      case SubscriptionTier.premiumPlus:
        return 199.99; // 2 months free
    }
  }

  int get messageLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 10;
      case SubscriptionTier.premium:
      case SubscriptionTier.premiumPlus:
        return -1; // Unlimited
    }
  }

  List<String> get features {
    switch (this) {
      case SubscriptionTier.free:
        return [
          '10 messages per day',
          'Basic AI responses',
          'Text only support',
        ];
      case SubscriptionTier.premium:
        return [
          'Unlimited messages',
          'Advanced AI responses',
          'Image & file support',
          'Chat history backup',
          'Custom AI personalities',
        ];
      case SubscriptionTier.premiumPlus:
        return [
          'Everything in Premium',
          'Priority AI responses',
          'Advanced file processing',
          'Priority customer support',
          'Early feature access',
          'Multiple AI models',
        ];
    }
  }

  String get stripeProductId {
    switch (this) {
      case SubscriptionTier.free:
        return '';
      case SubscriptionTier.premium:
        return 'prod_premium_monthly'; // Replace with actual Stripe product ID
      case SubscriptionTier.premiumPlus:
        return 'prod_premium_plus_monthly'; // Replace with actual Stripe product ID
    }
  }

  String get stripePriceId {
    switch (this) {
      case SubscriptionTier.free:
        return '';
      case SubscriptionTier.premium:
        return 'price_premium_monthly'; // Replace with actual Stripe price ID
      case SubscriptionTier.premiumPlus:
        return 'price_premium_plus_monthly'; // Replace with actual Stripe price ID
    }
  }
}

enum BillingPeriod {
  monthly,
  yearly,
}

extension BillingPeriodX on BillingPeriod {
  String get displayName {
    switch (this) {
      case BillingPeriod.monthly:
        return 'Monthly';
      case BillingPeriod.yearly:
        return 'Yearly';
    }
  }

  String get description {
    switch (this) {
      case BillingPeriod.monthly:
        return 'Billed monthly';
      case BillingPeriod.yearly:
        return 'Billed annually (2 months free)';
    }
  }
}

class Subscription {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final BillingPeriod billingPeriod;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isCancelled;
  final DateTime? cancelledAt;
  final String? stripeSubscriptionId;
  final String? stripeCustomerId;
  final double price;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.billingPeriod,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.isCancelled = false,
    this.cancelledAt,
    this.stripeSubscriptionId,
    this.stripeCustomerId,
    required this.price,
    this.currency = 'USD',
    required this.createdAt,
    required this.updatedAt,
  });

  Subscription copyWith({
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
    return Subscription(
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

  bool get isExpired => DateTime.now().isAfter(endDate);
  
  bool get isPremium => tier != SubscriptionTier.free && isActive && !isExpired;
  
  int get daysUntilExpiry => endDate.difference(DateTime.now()).inDays;
  
  double get savingsPercent {
    if (billingPeriod == BillingPeriod.yearly) {
      final monthlyTotal = tier.monthlyPrice * 12;
      final yearlySavings = monthlyTotal - price;
      return (yearlySavings / monthlyTotal) * 100;
    }
    return 0.0;
  }
}

class UsageData {
  final String userId;
  final DateTime date;
  final int messageCount;
  final int fileUploadCount;
  final int imageUploadCount;
  final double aiTokensUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UsageData({
    required this.userId,
    required this.date,
    this.messageCount = 0,
    this.fileUploadCount = 0,
    this.imageUploadCount = 0,
    this.aiTokensUsed = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  UsageData copyWith({
    String? userId,
    DateTime? date,
    int? messageCount,
    int? fileUploadCount,
    int? imageUploadCount,
    double? aiTokensUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UsageData(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      messageCount: messageCount ?? this.messageCount,
      fileUploadCount: fileUploadCount ?? this.fileUploadCount,
      imageUploadCount: imageUploadCount ?? this.imageUploadCount,
      aiTokensUsed: aiTokensUsed ?? this.aiTokensUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  UsageData incrementMessageCount() {
    return copyWith(
      messageCount: messageCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  UsageData incrementFileUpload() {
    return copyWith(
      fileUploadCount: fileUploadCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  UsageData incrementImageUpload() {
    return copyWith(
      imageUploadCount: imageUploadCount + 1,
      updatedAt: DateTime.now(),
    );
  }
}