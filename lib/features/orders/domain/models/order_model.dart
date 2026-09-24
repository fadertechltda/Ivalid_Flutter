/// Modelo de item de um pedido — espelhando OrderItem do Kotlin
class OrderItemModel {
  final String name;
  final int quantity;
  final double subtotal;
  final bool isDonation;

  OrderItemModel({
    required this.name,
    required this.quantity,
    required this.subtotal,
    this.isDonation = false,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      name: map['name'] as String? ?? 'Item Desconhecido',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      isDonation: (map['isDonation'] as bool?) ?? (map['origin'] == 'doacao'),
    );
  }
}

/// Modelo de pedido — espelhando Order do Kotlin
class OrderModel {
  final String id;
  final String date;
  final double total;
  final String status;
  final List<OrderItemModel> items;
  final DateTime timestamp;
  final bool hasDonations;
  final int donationItemsCount;

  OrderModel({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
    required this.timestamp,
    this.hasDonations = false,
    this.donationItemsCount = 0,
  });
}
