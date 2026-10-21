import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';
import '../../domain/models/order_model.dart';

/// Pedidos do cliente logado, lidos da API (`GET api/app/pedidos`).
class OrdersProvider extends ChangeNotifier {
  final ApiClient _api;

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DateFormat _dateFormat = DateFormat("dd/MM/yyyy HH:mm", "pt_BR");

  OrdersProvider({ApiClient? api}) : _api = api ?? ApiClient() {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    if (FirebaseAuth.instance.currentUser == null) {
      _isLoading = false;
      _error = 'Usuário não autenticado. Faça login novamente!';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('api/app/pedidos');
      final list = data is List ? data : const [];

      _orders = list.whereType<Map<String, dynamic>>().map((map) {
        final when = DateTime.tryParse(map['dataPedido'] as String? ?? '')
                ?.toLocal() ??
            DateTime.now();
        return OrderModel.fromApi(map, date: _dateFormat.format(when));
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      debugPrint('OrdersProvider: erro ao carregar pedidos: $e');
      _error = 'Erro ao carregar pedidos.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cancela um pedido (a API devolve estoque e cashback). Devolve `null` se
  /// deu certo, ou a mensagem de erro para exibir ao usuário.
  Future<String?> cancelOrder(String orderId) async {
    try {
      await _api.post('api/app/pedidos/$orderId/cancelar');
      await fetchOrders();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Não foi possível cancelar o pedido.';
    }
  }
}
