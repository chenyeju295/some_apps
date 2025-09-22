// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneratedImage _$GeneratedImageFromJson(Map<String, dynamic> json) =>
    GeneratedImage(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      style: $enumDecode(_$ImageStyleEnumMap, json['style']),
      isFavorite: json['isFavorite'] as bool? ?? false,
      tokensUsed: (json['tokensUsed'] as num?)?.toInt() ?? 1,
      title: json['title'] as String?,
      description: json['description'] as String?,
      knowledgeContent: json['knowledgeContent'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$GeneratedImageToJson(GeneratedImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prompt': instance.prompt,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'style': _$ImageStyleEnumMap[instance.style]!,
      'isFavorite': instance.isFavorite,
      'tokensUsed': instance.tokensUsed,
      'title': instance.title,
      'description': instance.description,
      'knowledgeContent': instance.knowledgeContent,
      'tags': instance.tags,
    };

const _$ImageStyleEnumMap = {
  ImageStyle.realistic: 'realistic',
  ImageStyle.artistic: 'artistic',
  ImageStyle.vintage: 'vintage',
  ImageStyle.cartoon: 'cartoon',
  ImageStyle.cinematic: 'cinematic',
};
