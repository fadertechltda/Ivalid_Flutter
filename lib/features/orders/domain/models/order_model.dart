/// Item de um pedido, como devolvido pela API (`ItemPedidoModel`).
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

  factory OrderItemModel.fromApi(Map<String, dynamic> map) {
    return OrderItemModel(
      name: map['nomeProduto'] as String? ?? 'Item Desconhecido',
      quantity: (map['quantidade'] as num?)?.toInt() ?? 0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      isDonation: (map['ehDoacao'] as bool?) ?? (map['origem'] == 'doacao'),
    );
  }
}

/// Pedido do cliente, como devolvido pela API (`PedidoModel`).
class OrderModel {
  final String id;
  final String date;
  final double total;

  /// Status normalizado pela API: PENDENTE, CONFIRMADO, SEPARADO, EM_ROTA,
  /// FINALIZADO ou CANCELADO.
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

  /// O cliente só pode cancelar antes de o pedido ser separado.
  bool get canCancel => status == 'PENDENTE' || status == 'CONFIRMADO';

  factory OrderModel.fromApi(Map<String, dynamic> map, {required String date}) {
    final rawItems = (map['itens'] as List<dynamic>?) ?? const [];
    final timestamp =
        DateTime.tryParse(map['dataPedido'] as String? ?? '')?.toLocal() ??
            DateTime.now();
    return OrderModel(
      id: map['id'] as String? ?? '',
      date: date,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: (map['statusNormalizado'] as String?) ??
          (map['status'] as String?) ??
          '',
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItemModel.fromApi)
          .toList(),
      timestamp: timestamp,
      hasDonations: map['possuiDoacoes'] as bool? ?? false,
      donationItemsCount: (map['quantidadeItensDoacao'] as num?)?.toInt() ?? 0,
    );
  }
}
