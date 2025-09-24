// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) => UserProgress(
      userId: json['userId'] as String,
      tokenBalance: (json['tokenBalance'] as num).toInt(),
      totalTokensUsed: (json['totalTokensUsed'] as num?)?.toInt() ?? 0,
      totalImagesGenerated:
          (json['totalImagesGenerated'] as num?)?.toInt() ?? 0,
      completedContentIds: (json['completedContentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      bookmarkedContentIds: (json['bookmarkedContentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      categoryProgress:
          (json['categoryProgress'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      lastActiveDate: DateTime.parse(json['lastActiveDate'] as String),
      joinDate: DateTime.parse(json['joinDate'] as String),
      preferences:
          UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserProgressToJson(UserProgress instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'tokenBalance': instance.tokenBalance,
      'totalTokensUsed': instance.totalTokensUsed,
      'totalImagesGenerated': instance.totalImagesGenerated,
      'completedContentIds': instance.completedContentIds,
      'bookmarkedContentIds': instance.bookmarkedContentIds,
      'categoryProgress': instance.categoryProgress,
      'lastActiveDate': instance.lastActiveDate.toIso8601String(),
      'joinDate': instance.joinDate.toIso8601String(),
      'preferences': instance.preferences,
    };

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      darkMode: json['darkMode'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEffectsEnabled: json['soundEffectsEnabled'] as bool? ?? true,
      preferredImageStyle:
          json['preferredImageStyle'] as String? ?? 'realistic',
      trackingConsent: json['trackingConsent'] as bool? ?? false,
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'darkMode': instance.darkMode,
      'notificationsEnabled': instance.notificationsEnabled,
      'soundEffectsEnabled': instance.soundEffectsEnabled,
      'preferredImageStyle': instance.preferredImageStyle,
      'trackingConsent': instance.trackingConsent,
    };
