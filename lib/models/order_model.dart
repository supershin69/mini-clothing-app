class OrderModel {
  final String id;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      // Safely parse the PostgreSQL Decimal type which might arrive as a String or num
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
