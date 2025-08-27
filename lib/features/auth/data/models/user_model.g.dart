// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      subscription: json['subscription'] == null
          ? null
          : SubscriptionModel.fromJson(
              json['subscription'] as Map<String, dynamic>),
      preferences: json['preferences'] == null
          ? null
          : UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'phoneNumber': instance.phoneNumber,
      'isEmailVerified': instance.isEmailVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'subscription': instance.subscription?.toJson(),
      'preferences': instance.preferences?.toJson(),
    };

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      language: json['language'] as String? ?? 'en',
      theme: $enumDecodeNullable(_$ThemeModeEnumMap, json['theme']) ??
          ThemeMode.system,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      aiModel: json['aiModel'] as String? ?? 'gpt-4',
      streamingEnabled: json['streamingEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'language': instance.language,
      'theme': _$ThemeModeEnumMap[instance.theme]!,
      'notificationsEnabled': instance.notificationsEnabled,
      'soundEnabled': instance.soundEnabled,
      'aiModel': instance.aiModel,
      'streamingEnabled': instance.streamingEnabled,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};