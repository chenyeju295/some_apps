import 'package:json_annotation/json_annotation.dart';

part 'user_progress.g.dart';

@JsonSerializable()
class UserProgress {
  final String userId;
  final int tokenBalance;
  final int totalTokensUsed;
  final int totalImagesGenerated;
  final List<String> completedContentIds;
  final List<String> bookmarkedContentIds;
  final Map<String, int> categoryProgress;
  final DateTime lastActiveDate;
  final DateTime joinDate;
  final UserPreferences preferences;

  const UserProgress({
    required this.userId,
    required this.tokenBalance,
    this.totalTokensUsed = 0,
    this.totalImagesGenerated = 0,
    this.completedContentIds = const [],
    this.bookmarkedContentIds = const [],
    this.categoryProgress = const {},
    required this.lastActiveDate,
    required this.joinDate,
    required this.preferences,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);

  Map<String, dynamic> toJson() => _$UserProgressToJson(this);

  UserProgress copyWith({
    String? userId,
    int? tokenBalance,
    int? totalTokensUsed,
    int? totalImagesGenerated,
    List<String>? completedContentIds,
    List<String>? bookmarkedContentIds,
    Map<String, int>? categoryProgress,
    DateTime? lastActiveDate,
    DateTime? joinDate,
    UserPreferences? preferences,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      totalTokensUsed: totalTokensUsed ?? this.totalTokensUsed,
      totalImagesGenerated: totalImagesGenerated ?? this.totalImagesGenerated,
      completedContentIds: completedContentIds ?? this.completedContentIds,
      bookmarkedContentIds: bookmarkedContentIds ?? this.bookmarkedContentIds,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      joinDate: joinDate ?? this.joinDate,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgress &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

@JsonSerializable()
class UserPreferences {
  final bool darkMode;
  final bool notificationsEnabled;
  final bool soundEffectsEnabled;
  final String preferredImageStyle;
  final bool trackingConsent;

  const UserPreferences({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.soundEffectsEnabled = true,
    this.preferredImageStyle = 'realistic',
    this.trackingConsent = false,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    bool? soundEffectsEnabled,
    String? preferredImageStyle,
    bool? trackingConsent,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      preferredImageStyle: preferredImageStyle ?? this.preferredImageStyle,
      trackingConsent: trackingConsent ?? this.trackingConsent,
    );
  }
}
