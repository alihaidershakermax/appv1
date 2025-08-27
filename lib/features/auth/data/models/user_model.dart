import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.isEmailVerified,
    required super.createdAt,
    required super.lastSignIn,
    required super.subscriptionPlan,
    super.dailyMessageCount = 0,
    required super.lastMessageDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return UserModel(
      id: snapshot.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      isEmailVerified: data['isEmailVerified'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastSignIn: (data['lastSignIn'] as Timestamp).toDate(),
      subscriptionPlan: SubscriptionPlan.values.firstWhere(
        (plan) => plan.name == data['subscriptionPlan'],
        orElse: () => SubscriptionPlan.free,
      ),
      dailyMessageCount: data['dailyMessageCount'] as int? ?? 0,
      lastMessageDate: (data['lastMessageDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSignIn': Timestamp.fromDate(lastSignIn),
      'subscriptionPlan': subscriptionPlan.name,
      'dailyMessageCount': dailyMessageCount,
      'lastMessageDate': Timestamp.fromDate(lastMessageDate),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      isEmailVerified: user.isEmailVerified,
      createdAt: user.createdAt,
      lastSignIn: user.lastSignIn,
      subscriptionPlan: user.subscriptionPlan,
      dailyMessageCount: user.dailyMessageCount,
      lastMessageDate: user.lastMessageDate,
    );
  }

  UserModel copyWith({
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
    return UserModel(
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