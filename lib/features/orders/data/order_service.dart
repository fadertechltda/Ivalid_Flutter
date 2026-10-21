import 'dart:async';

import '../../../core/api/api_client.dart';
import '../../payment/domain/models/payment_models.dart';

/// Linha do carrinho como a API espera: só id, quantidade e origem.
/// O preço nunca é enviado; a API sempre calcula.
class OrderLineRequest {
  final String productId;
  final int quantity;
  final bool isDonation;

  const OrderLineRequest({
    required this.productId,
    required this.quantity,
    required this.isDonation,
  });

  Map<String, dynamic> toJson() => {
        'produtoId': productId,
        'quantidade': quantity,
        'origem': isDonation ? 'doacao' : 'compra',
      };
}

/// Resultado de `pedidos/validar` (simulação, sem gravar nada).
class OrderSummary {
  final double subtotal;
  final double cashbackApplied;
  final double total;
  final List<String> problems;

  const OrderSummary({
    required this.subtotal,
    required this.cashbackApplied,
    required this.total,
    required this.problems,
  });

  bool get isValid => problems.isEmpty;

  factory OrderSummary.fromApi(Map<String, dynamic> map) => OrderSummary(
        subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
        cashbackApplied: (map['cashbackAplicado'] as num?)?.toDouble() ?? 0.0,
        total: (map['total'] as num?)?.toDouble() ?? 0.0,
        problems: problemMessages(map['problemas']),
      );

  /// Texto amigável para cada item que a API recusou.
  static List<String> problemMessages(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map((p) {
      final name = p['nome'] as String? ?? 'Produto';
      final available = (p['disponivel'] as num?)?.toInt() ?? 0;
      return available > 0
          ? '$name: só restam $available unidade(s).'
          : '$name: indisponível no momento.';
    }).toList();
  }
}

/// Pedido recém-criado.
class CreatedOrder {
  final String id;
  final double total;
  final String status;

  const CreatedOrder({
    required this.id,
    required this.total,
    required this.status,
  });

  factory CreatedOrder.fromApi(Map<String, dynamic> map) => CreatedOrder(
        id: map['id'] as String? ?? '',
        total: (map['total'] as num?)?.toDouble() ?? 0.0,
        status: (map['statusNormalizado'] as String?) ??
            (map['status'] as String?) ??
            '',
      );
}

/// Operações de pedido e pagamento na API (`api/app/pedidos`).
class OrderService {
  OrderService({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  Map<String, dynamic> _body({
    required String paymentMethod,
    required double cashback,
    required List<OrderLineRequest> lines,
    String? address,
  }) =>
      {
        'formaPagamento': paymentMethod,
        'cashbackUsado': cashback,
        if (address != null && address.isNotEmpty) 'endereco': address,
        'itens': lines.map((l) => l.toJson()).toList(),
      };

  Future<OrderSummary> validate({
    required String paymentMethod,
    required double cashback,
    required List<OrderLineRequest> lines,
  }) async {
    final data = await _api.post(
      'api/app/pedidos/validar',
      body: _body(paymentMethod: paymentMethod, cashback: cashback, lines: lines),
    );
    return OrderSummary.fromApi(data as Map<String, dynamic>);
  }

  Future<CreatedOrder> create({
    required String paymentMethod,
    required double cashback,
    required List<OrderLineRequest> lines,
  }) async {
    final data = await _api.post(
      'api/app/pedidos',
      body: _body(paymentMethod: paymentMethod, cashback: cashback, lines: lines),
    );
    return CreatedOrder.fromApi(data as Map<String, dynamic>);
  }

  Future<void> cancel(String orderId) =>
      _api.post('api/app/pedidos/$orderId/cancelar');

  /// URL do checkout do InfinitePay para um pedido `Online` pendente.
  Future<String> paymentLink(String orderId) async {
    final data = await _api.post('api/app/pedidos/$orderId/pagamento/link');
    final url = data is Map<String, dynamic> ? data['url'] as String? : null;
    if (url == null || url.isEmpty) {
      throw const PaymentException('A API não devolveu o link de pagamento.');
    }
    return url;
  }

  /// Pede à API que confirme o pagamento (ela consulta o InfinitePay). Tenta
  /// de novo enquanto a aprovação ainda não aparece (código 7).
  Future<void> confirmPayment(
    String orderId,
    CheckoutRedirect redirect, {
    int attempts = 4,
    Duration wait = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < attempts; i++) {
      try {
        await _api.post('api/app/pedidos/$orderId/pagamento/confirmar', body: {
          'transactionNsu': redirect.transactionNsu,
          'slug': redirect.slug,
          if (redirect.captureMethod.isNotEmpty)
            'captureMethod': redirect.captureMethod,
          if (redirect.receiptUrl != null) 'receiptUrl': redirect.receiptUrl,
        });
        return;
      } on ApiException catch (e) {
        final notYet = e.codigo == 7;
        if (!notYet || i == attempts - 1) rethrow;
        await Future<void>.delayed(wait);
      }
    }
  }
}
