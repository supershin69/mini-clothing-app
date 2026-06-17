class OrderModel {
  final String id;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<OrderLineModel> orderLines;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.orderLines,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var list = json['order_lines'] as List? ?? [];
    List<OrderLineModel> linesList = list
        .map((i) => OrderLineModel.fromJson(i))
        .toList();

    return OrderModel(
      id: json['id'] ?? '',
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0.0') ?? 0.0,
      status: json['status'] ?? 'PENDING',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      orderLines: linesList,
    );
  }
}

class OrderLineModel {
  final String id;
  final int quantity;
  final double price;
  final String productName;
  final String selectedSize;

  OrderLineModel({
    required this.id,
    required this.quantity,
    required this.price,
    required this.productName,
    required this.selectedSize,
  });

  factory OrderLineModel.fromJson(Map<String, dynamic> json) {
    final variant = json['variant'] as Map<String, dynamic>? ?? {};
    final product = variant['product'] as Map<String, dynamic>? ?? {};

    return OrderLineModel(
      id: json['id'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      productName: product['name'] ?? 'Unknown Product',

      selectedSize: variant['size'] ?? variant['color'] ?? 'N/A',
    );
  }
}
