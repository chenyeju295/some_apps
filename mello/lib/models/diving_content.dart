import 'package:json_annotation/json_annotation.dart';

part 'diving_content.g.dart';

@JsonSerializable()
class DivingContent {
  final String id;
  final String title;
  final String content;
  final String category;
  final String difficulty;
  final List<String> tags;
  final String? imageUrl;
  final int readTimeMinutes;
  final DateTime createdAt;

  const DivingContent({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.difficulty,
    required this.tags,
    this.imageUrl,
    required this.readTimeMinutes,
    required this.createdAt,
  });

  factory DivingContent.fromJson(Map<String, dynamic> json) =>
      _$DivingContentFromJson(json);

  Map<String, dynamic> toJson() => _$DivingContentToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DivingContent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum DivingCategory {
  safety('Safety'),
  equipment('Equipment'),
  marineLife('Marine Life'),
  techniques('Techniques'),
  certification('Certification'),
  destinations('Destinations');

  const DivingCategory(this.displayName);
  final String displayName;
}

enum DifficultyLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced'),
  expert('Expert');

  const DifficultyLevel(this.displayName);
  final String displayName;
}
