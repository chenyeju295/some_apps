class WallpaperModel {
  final String id;
  final String url; // Original URL from API
  final String? localPath; // Local file path (relative)
  final String prompt;
  final String category;
  final DateTime createdAt;
  final bool isFavorite;
  final String? style;
  final String? quality;
  final String? size;

  WallpaperModel({
    required this.id,
    required this.url,
    this.localPath,
    required this.prompt,
    required this.category,
    required this.createdAt,
    this.isFavorite = false,
    this.style,
    this.quality,
    this.size,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'localPath': localPath,
      'prompt': prompt,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
      'style': style,
      'quality': quality,
      'size': size,
    };
  }

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'] as String,
      url: json['url'] as String,
      localPath: json['localPath'] as String?,
      prompt: json['prompt'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      style: json['style'] as String?,
      quality: json['quality'] as String?,
      size: json['size'] as String?,
    );
  }

  WallpaperModel copyWith({
    String? id,
    String? url,
    String? localPath,
    String? prompt,
    String? category,
    DateTime? createdAt,
    bool? isFavorite,
    String? style,
    String? quality,
    String? size,
  }) {
    return WallpaperModel(
      id: id ?? this.id,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      prompt: prompt ?? this.prompt,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      style: style ?? this.style,
      quality: quality ?? this.quality,
      size: size ?? this.size,
    );
  }

  // Helper methods
  bool get hasLocalFile => localPath != null && localPath!.isNotEmpty;

  String get displayUrl => hasLocalFile ? localPath! : url;

  String get formattedSize => size ?? 'Unknown';
  String get formattedStyle => style ?? 'Default';
  String get formattedQuality => quality ?? 'Standard';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WallpaperModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
