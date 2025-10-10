class GenerationRequestModel {
  final String prompt;
  final String style;
  final String outfitType;
  final String scene;
  final String aspectRatio;
  final int width;
  final int height;

  GenerationRequestModel({
    required this.prompt,
    required this.style,
    required this.outfitType,
    required this.scene,
    this.aspectRatio = '9:16',
    this.width = 1080,
    this.height = 1920,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'style': style,
      'outfitType': outfitType,
      'scene': scene,
      'aspectRatio': aspectRatio,
      'width': width,
      'height': height,
    };
  }

  // Create from JSON
  factory GenerationRequestModel.fromJson(Map<String, dynamic> json) {
    return GenerationRequestModel(
      prompt: json['prompt'] as String,
      style: json['style'] as String,
      outfitType: json['outfitType'] as String,
      scene: json['scene'] as String,
      aspectRatio: json['aspectRatio'] as String? ?? '9:16',
      width: json['width'] as int? ?? 1080,
      height: json['height'] as int? ?? 1920,
    );
  }

  // Build full prompt for AI
  String buildFullPrompt() {
    return '$prompt, $style style, wearing $outfitType, $scene setting, '
        'fashion photography, high quality, detailed, 4k resolution, '
        'professional lighting, beautiful composition';
  }

  @override
  String toString() {
    return 'GenerationRequestModel(prompt: $prompt, style: $style, outfitType: $outfitType, scene: $scene)';
  }
}
