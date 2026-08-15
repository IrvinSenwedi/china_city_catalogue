class Reservation {
  final String id;
  final String productName;
  final double productPrice;
  final int quantity;
  final String status;
  final DateTime createdAt;
  final DateTime? collectionAt;
  final DateTime? expiresAt;

  Reservation({
    required this.id,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.status,
    required this.createdAt,
    this.collectionAt,
    this.expiresAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      productName: json['products']?['name'] ?? '',
      productPrice: (json['products']?['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] ?? 1,
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(json['created_at']),
      collectionAt: json['collection_at'] == null
          ? null
          : DateTime.parse(json['collection_at']).toLocal(),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at']).toLocal(),
    );
  }
}
