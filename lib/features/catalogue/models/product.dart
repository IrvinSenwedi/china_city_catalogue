class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final String storeName;
  final String categoryName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.storeName,
    required this.categoryName,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] ?? 0,
      imageUrl: json['image_url'],
      storeName: json['stores']?['name'] ?? '',
      categoryName: json['categories']?['name'] ?? '',
    );
  }

  String get stockLabel {
    if (stockQuantity == 0) return 'Out of Stock';
    if (stockQuantity <= 5) return 'Low Stock';
    return 'In Stock';
  }

  bool get isAvailable => stockQuantity > 0;
}
