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
    };

const _$ImageStyleEnumMap = {
  ImageStyle.realistic: 'realistic',
  ImageStyle.artistic: 'artistic',
  ImageStyle.vintage: 'vintage',
  ImageStyle.cartoon: 'cartoon',
  ImageStyle.cinematic: 'cinematic',
};
