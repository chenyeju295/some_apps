class ShowcaseModel {
  final String title;
  final String subtitle;
  final String description;
  final String imageAsset;
  final String category;
  final List<String> tags;
  final int likes;
  final int downloads;

  const ShowcaseModel({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageAsset,
    required this.category,
    required this.tags,
    required this.likes,
    required this.downloads,
  });

  static List<ShowcaseModel> get featuredWallpapers => [
        ShowcaseModel(
          title: 'Cosmic Beauty',
          subtitle: 'Space Nebula Collection',
          description:
              'Discover the beauty of deep space with our cosmic wallpaper collection featuring stunning nebulas and galaxies.',
          imageAsset: 'assets/images/space_showcase.png',
          category: 'Space',
          tags: ['Cosmic', 'Nebula', 'Stars', 'Galaxy'],
          likes: 2847,
          downloads: 15623,
        ),
        ShowcaseModel(
          title: 'Portrait Elegance',
          subtitle: 'Professional Beauty',
          description:
              'Stunning portrait photography with professional lighting and elegant composition for your device.',
          imageAsset: 'assets/images/portrait_showcase.png',
          category: 'Portrait',
          tags: ['Beauty', 'Portrait', 'Professional', 'Elegant'],
          likes: 3521,
          downloads: 18945,
        ),
        ShowcaseModel(
          title: 'Anime Dreams',
          subtitle: 'Kawaii Collection',
          description:
              'Adorable anime-style wallpapers featuring beautiful characters with expressive eyes and magical themes.',
          imageAsset: 'assets/images/anime_showcase.png',
          category: 'Anime',
          tags: ['Anime', 'Kawaii', 'Manga', 'Cute'],
          likes: 4125,
          downloads: 22356,
        ),
        ShowcaseModel(
          title: 'Cyberpunk City',
          subtitle: 'Neon Nights',
          description:
              'Futuristic cityscape with neon lights and holographic displays in a cyberpunk aesthetic.',
          imageAsset: 'assets/images/city_showcase.png',
          category: 'City',
          tags: ['Cyberpunk', 'Neon', 'Futuristic', 'Night'],
          likes: 2963,
          downloads: 16784,
        ),
        ShowcaseModel(
          title: 'Mountain Serenity',
          subtitle: 'Nature\'s Peace',
          description:
              'Peaceful mountain landscapes with crystal clear lakes and golden hour lighting for tranquil moments.',
          imageAsset: 'assets/images/nature_showcase.png',
          category: 'Nature',
          tags: ['Mountains', 'Lake', 'Peaceful', 'Golden Hour'],
          likes: 3856,
          downloads: 20147,
        ),
      ];

  static List<ShowcaseModel> get trendingCategories => [
        ShowcaseModel(
          title: 'Portrait & Beauty',
          subtitle: 'Professional Photography',
          description:
              'Elegant portraits with professional lighting and stunning compositions.',
          imageAsset: 'assets/images/portrait_showcase.png',
          category: 'Portrait',
          tags: ['New', 'Trending', 'Popular'],
          likes: 5247,
          downloads: 28945,
        ),
        ShowcaseModel(
          title: 'Anime Style',
          subtitle: 'Kawaii & Manga',
          description:
              'Beautiful anime artwork with expressive characters and magical themes.',
          imageAsset: 'assets/images/anime_showcase.png',
          category: 'Anime',
          tags: ['Hot', 'Trending', 'Creative'],
          likes: 6128,
          downloads: 34567,
        ),
        ShowcaseModel(
          title: 'Cyberpunk City',
          subtitle: 'Futuristic Urban',
          description:
              'Neon-lit cityscapes with holographic displays and sci-fi atmosphere.',
          imageAsset: 'assets/images/city_showcase.png',
          category: 'City',
          tags: ['Futuristic', 'Popular', 'Modern'],
          likes: 4521,
          downloads: 25896,
        ),
      ];

  static List<String> get inspirationalQuotes => [
        "Create something beautiful today",
        "Your next wallpaper awaits",
        "AI-powered creativity at your fingertips",
        "Transform your screen, transform your mood",
        "Where imagination meets technology",
        "Every pixel tells a story",
      ];
}
