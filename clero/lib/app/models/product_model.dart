class ProductModel {
  final String productId;
  final String title;
  final String description;
  final double price;
  final int crystals;
  final String currency;
  final String iconPath;
  final bool isPopular;
  final String? badge;

  const ProductModel({
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.crystals,
    this.currency = 'USD',
    required this.iconPath,
    this.isPopular = false,
    this.badge,
  });

  static const List<ProductModel> products = [
    ProductModel(
      productId: 'com.joinclero.ios4.99',
      title: 'Crystal Pack',
      description: '',
      price: 4.99,
      crystals: 2600,
      iconPath: 'assets/icons/crystal_small.png',
      isPopular: false,
    ),
    ProductModel(
      productId: 'com.joinclero.ios9.99',
      title: 'Crystal Pack',
      description: '',
      price: 9.99,
      crystals: 5200,
      iconPath: 'assets/icons/crystal_medium.png',
      isPopular: true,
      badge: 'POPULAR',
    ),
    ProductModel(
      productId: 'com.joinclero.ios19.99',
      title: 'Crystal Pack',
      description: '',
      price: 19.99,
      crystals: 10400,
      iconPath: 'assets/icons/crystal_large.png',
      isPopular: false,
    ),
    ProductModel(
      productId: 'com.joinclero.ios49.99',
      title: 'Crystal Pack',
      description: '',
      price: 49.99,
      crystals: 26000,
      iconPath: 'assets/icons/crystal_large.png',
      isPopular: false,
      badge: 'BEST VALUE',
    ),
  ];

  // Helper methods
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedCrystals {
    if (crystals >= 1000) {
      return '${(crystals / 1000).toStringAsFixed(1)}K';
    }
    return crystals.toString();
  }

  double get crystalsPerDollar => crystals / price;

  String get valueRating {
    final avgValue =
        products.map((p) => p.crystalsPerDollar).reduce((a, b) => a + b) /
            products.length;
    if (crystalsPerDollar > avgValue * 1.1) {
      return 'BEST VALUE';
    } else if (crystalsPerDollar > avgValue * 0.9) {
      return 'GOOD VALUE';
    }
    return 'STANDARD';
  }

  @override
  String toString() {
    return 'ProductModel(id: $productId, title: $title, price: $formattedPrice, crystals: $crystals)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}

// Crystal consumption rates for different operations
class CrystalCosts {
  static const int basicGeneration = 100; // Standard wallpaper generation
  static const int hdGeneration = 150; // HD quality generation
  static const int premiumGeneration = 200; // Premium with advanced features
  static const int batchGeneration = 80; // Per image in batch (discount)

  static const Map<String, int> generationCosts = {
    'standard': basicGeneration,
    'hd': hdGeneration,
    'premium': premiumGeneration,
    'batch': batchGeneration,
  };

  static const Map<String, int> styleCosts = {
    'realistic': 0, // Base cost
    'artistic': 50, // Additional cost
    'anime': 30, // Additional cost
    'fantasy': 70, // Additional cost
    'vintage': 20, // Additional cost
    'modern': 40, // Additional cost
  };

  static int calculateGenerationCost({
    required String quality,
    required String style,
    bool isBatch = false,
  }) {
    int baseCost = isBatch
        ? batchGeneration
        : (generationCosts[quality] ?? basicGeneration);
    int styleCost = styleCosts[style] ?? 0;
    return baseCost + styleCost;
  }
}
