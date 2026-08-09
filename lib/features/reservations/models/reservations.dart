class Reservation {
  final String id;
  final String productName;
  final double productPrice;
  final int quantity;
  final String status;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.status,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      productName: json['products']?['name'] ?? '',
      productPrice: (json['products']?['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] ?? 1,
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
