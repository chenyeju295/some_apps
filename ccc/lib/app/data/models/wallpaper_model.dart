class WallpaperModel {
  final String id;
  final String imageUrl;
  String? localPath;
  final String prompt;
  final List<String> tags;
  final DateTime createdAt;
  bool isFavorite;
  final String style;
  final String outfitType;
  final String scene;
  final bool isSample; // 标识是否为样例数据

  WallpaperModel({
    required this.id,
    required this.imageUrl,
    this.localPath,
    required this.prompt,
    required this.tags,
    required this.createdAt,
    this.isFavorite = false,
    required this.style,
    required this.outfitType,
    required this.scene,
    this.isSample = false, // 默认不是样例数据
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'localPath': localPath,
      'prompt': prompt,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
      'style': style,
      'outfitType': outfitType,
      'scene': scene,
      'isSample': isSample,
    };
  }

  // Create from JSON
  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      localPath: json['localPath'] as String?,
      prompt: json['prompt'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      style: json['style'] as String,
      outfitType: json['outfitType'] as String,
      scene: json['scene'] as String,
      isSample: json['isSample'] as bool? ?? false,
    );
  }

  // Copy with
  WallpaperModel copyWith({
    String? id,
    String? imageUrl,
    String? localPath,
    String? prompt,
    List<String>? tags,
    DateTime? createdAt,
    bool? isFavorite,
    String? style,
    String? outfitType,
    String? scene,
    bool? isSample,
  }) {
    return WallpaperModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      localPath: localPath ?? this.localPath,
      prompt: prompt ?? this.prompt,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      style: style ?? this.style,
      outfitType: outfitType ?? this.outfitType,
      scene: scene ?? this.scene,
      isSample: isSample ?? this.isSample,
    );
  }

  @override
  String toString() {
    return 'WallpaperModel(id: $id, prompt: $prompt, isFavorite: $isFavorite)';
  }
}
