import 'package:json_annotation/json_annotation.dart';

part 'generated_image.g.dart';

@JsonSerializable()
class GeneratedImage {
  final String id;
  final String prompt;
  final String imageUrl;
  final DateTime createdAt;
  final ImageStyle style;
  final bool isFavorite;
  final int tokensUsed;
  final String? title;
  final String? description;
  final String? knowledgeContent;
  final List<String>? tags;

  const GeneratedImage({
    required this.id,
    required this.prompt,
    required this.imageUrl,
    required this.createdAt,
    required this.style,
    this.isFavorite = false,
    this.tokensUsed = 1,
    this.title,
    this.description,
    this.knowledgeContent,
    this.tags,
  });

  factory GeneratedImage.fromJson(Map<String, dynamic> json) =>
      _$GeneratedImageFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedImageToJson(this);

  GeneratedImage copyWith({
    String? id,
    String? prompt,
    String? imageUrl,
    DateTime? createdAt,
    ImageStyle? style,
    bool? isFavorite,
    int? tokensUsed,
    String? title,
    String? description,
    String? knowledgeContent,
    List<String>? tags,
  }) {
    return GeneratedImage(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      style: style ?? this.style,
      isFavorite: isFavorite ?? this.isFavorite,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      title: title ?? this.title,
      description: description ?? this.description,
      knowledgeContent: knowledgeContent ?? this.knowledgeContent,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneratedImage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum ImageStyle {
  realistic('Realistic'),
  artistic('Artistic'),
  vintage('Vintage'),
  cartoon('Cartoon'),
  cinematic('Cinematic');

  const ImageStyle(this.displayName);
  final String displayName;
}
