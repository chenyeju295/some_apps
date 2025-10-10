class UserModel {
  final String id;
  int tokenBalance;
  final DateTime createdAt;
  int totalGenerations;
  List<String> favoriteStyles;
  bool privacyAccepted;
  bool attPermissionAsked;

  UserModel({
    required this.id,
    required this.tokenBalance,
    required this.createdAt,
    this.totalGenerations = 0,
    List<String>? favoriteStyles,
    this.privacyAccepted = false,
    this.attPermissionAsked = false,
  }) : favoriteStyles = favoriteStyles ?? [];

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tokenBalance': tokenBalance,
      'createdAt': createdAt.toIso8601String(),
      'totalGenerations': totalGenerations,
      'favoriteStyles': favoriteStyles,
      'privacyAccepted': privacyAccepted,
      'attPermissionAsked': attPermissionAsked,
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      tokenBalance: json['tokenBalance'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      totalGenerations: json['totalGenerations'] as int? ?? 0,
      favoriteStyles:
          (json['favoriteStyles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      privacyAccepted: json['privacyAccepted'] as bool? ?? false,
      attPermissionAsked: json['attPermissionAsked'] as bool? ?? false,
    );
  }

  // Copy with
  UserModel copyWith({
    String? id,
    int? tokenBalance,
    DateTime? createdAt,
    int? totalGenerations,
    List<String>? favoriteStyles,
    bool? privacyAccepted,
    bool? attPermissionAsked,
  }) {
    return UserModel(
      id: id ?? this.id,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      createdAt: createdAt ?? this.createdAt,
      totalGenerations: totalGenerations ?? this.totalGenerations,
      favoriteStyles: favoriteStyles ?? this.favoriteStyles,
      privacyAccepted: privacyAccepted ?? this.privacyAccepted,
      attPermissionAsked: attPermissionAsked ?? this.attPermissionAsked,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, tokenBalance: $tokenBalance, totalGenerations: $totalGenerations)';
  }
}
