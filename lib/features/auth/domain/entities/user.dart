class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime lastSignIn;
  final SubscriptionPlan subscriptionPlan;
  final int dailyMessageCount;
  final DateTime lastMessageDate;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.isEmailVerified,
    required this.createdAt,
    required this.lastSignIn,
    required this.subscriptionPlan,
    this.dailyMessageCount = 0,
    required this.lastMessageDate,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignIn,
    SubscriptionPlan? subscriptionPlan,
    int? dailyMessageCount,
    DateTime? lastMessageDate,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      dailyMessageCount: dailyMessageCount ?? this.dailyMessageCount,
      lastMessageDate: lastMessageDate ?? this.lastMessageDate,
    );
  }
}

enum SubscriptionPlan {
  free,
  premium,
  premiumPlus,
}

extension SubscriptionPlanX on SubscriptionPlan {
  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.premiumPlus:
        return 'Premium Plus';
    }
  }
  
  int get messageLimit {
    switch (this) {
      case SubscriptionPlan.free:
        return 10;
      case SubscriptionPlan.premium:
      case SubscriptionPlan.premiumPlus:
        return -1; // Unlimited
    }
  }
  
  double get monthlyPrice {
    switch (this) {
      case SubscriptionPlan.free:
        return 0.0;
      case SubscriptionPlan.premium:
        return 9.99;
      case SubscriptionPlan.premiumPlus:
        return 19.99;
    }
  }
}