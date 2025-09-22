class WallpaperModel {
  final String id;
  final String url;
  final String prompt;
  final String category;
  final DateTime createdAt;
  final bool isFavorite;

  WallpaperModel({
    required this.id,
    required this.url,
    required this.prompt,
    required this.category,
    required this.createdAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'prompt': prompt,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'] as String,
      url: json['url'] as String,
      prompt: json['prompt'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  WallpaperModel copyWith({
    String? id,
    String? url,
    String? prompt,
    String? category,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return WallpaperModel(
      id: id ?? this.id,
      url: url ?? this.url,
      prompt: prompt ?? this.prompt,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WallpaperModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
