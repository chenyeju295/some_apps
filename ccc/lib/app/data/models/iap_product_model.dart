class IAPProductModel {
  final String productId;
  final double price;
  final int tokens;
  final String title;
  final String description;
  final bool isPopular;
  final bool isBestValue;

  IAPProductModel({
    required this.productId,
    required this.price,
    required this.tokens,
    required this.title,
    required this.description,
    this.isPopular = false,
    this.isBestValue = false,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'price': price,
      'tokens': tokens,
      'title': title,
      'description': description,
      'isPopular': isPopular,
      'isBestValue': isBestValue,
    };
  }

  // Create from JSON
  factory IAPProductModel.fromJson(Map<String, dynamic> json) {
    return IAPProductModel(
      productId: json['productId'] as String,
      price: (json['price'] as num).toDouble(),
      tokens: json['tokens'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      isPopular: json['isPopular'] as bool? ?? false,
      isBestValue: json['isBestValue'] as bool? ?? false,
    );
  }

  // Get price per token
  double get pricePerToken => price / tokens;

  // Get savings percentage (compared to base product)
  double getSavingsPercentage(double basePrice) {
    if (basePrice == 0) return 0;
    return ((basePrice - pricePerToken) / basePrice * 100);
  }

  @override
  String toString() {
    return 'IAPProductModel(productId: $productId, price: \$${price.toStringAsFixed(2)}, tokens: $tokens)';
  }
}
