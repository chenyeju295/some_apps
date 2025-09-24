// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diving_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DivingContent _$DivingContentFromJson(Map<String, dynamic> json) =>
    DivingContent(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      imageUrl: json['imageUrl'] as String?,
      readTimeMinutes: (json['readTimeMinutes'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DivingContentToJson(DivingContent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'tags': instance.tags,
      'imageUrl': instance.imageUrl,
      'readTimeMinutes': instance.readTimeMinutes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
