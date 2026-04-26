import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../domain/models/order_model.dart';

/// Provider de Pedidos — espelhando OrdersViewModel do Kotlin.
/// Busca apenas pedidos do usuário logado (filtro por userId).
class OrdersProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Formato de data pt-BR igual ao Kotlin: "dd/MM/yyyy HH:mm"
  final DateFormat _dateFormat = DateFormat("dd/MM/yyyy HH:mm", "pt_BR");

  OrdersProvider() {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      _isLoading = false;
      _error = 'Usuário não autenticado. Faça login novamente!';
      notifyListeners();
      return;
    }

    debugPrint('OrdersProvider: Buscando pedidos para userId=$userId');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Busca SOMENTE os pedidos do usuário logado.
      // Evita orderBy composto para não depender de índice Firestore.
      // A ordenação é feita no cliente após a filtragem.
      final snapshot = await _db
          .collection('pedidos')
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint('OrdersProvider: Firestore retornou ${snapshot.docs.length} doc(s) para userId=$userId');

      _orders = snapshot.docs.map((doc) {
        try {
          final data = doc.data();

          // Validação extra: garante que o campo userId do documento
          // é realmente do usuário logado (proteção contra bug de cache)
          final docUserId = data['userId'] as String?;
          if (docUserId != userId) {
            debugPrint('OrdersProvider: DESCARTANDO pedido ${doc.id} (userId=$docUserId ≠ $userId)');
            return null;
          }

          final Timestamp? timestamp = data['timestamp'] as Timestamp?;
          final DateTime dateTime = timestamp?.toDate() ?? DateTime.now();

          final List<dynamic> rawItems =
              (data['itens'] as List<dynamic>?) ?? [];

          return OrderModel(
            id: doc.id,
            date: _dateFormat.format(dateTime),
            total: (data['total'] as num?)?.toDouble() ?? 0.0,
            status: data['status'] as String? ?? 'Status desconhecido',
            items: rawItems
                .map((item) =>
                    OrderItemModel.fromMap(item as Map<String, dynamic>))
                .toList(),
            timestamp: dateTime,
          );
        } catch (e) {
          debugPrint('OrdersProvider: Erro ao mapear pedido ${doc.id}: $e');
          return null;
        }
      }).whereType<OrderModel>().toList();

      // Ordenação local por timestamp descrescente (mais recentes primeiro)
      _orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('OrdersProvider: ${_orders.length} pedido(s) do usuário logado');

      _isLoading = false;
      _error = null;
    } catch (e) {
      debugPrint('OrdersProvider: ERRO ao carregar pedidos: $e');
      _isLoading = false;
      _error = 'Erro ao carregar pedidos: $e';
    }

    notifyListeners();
  }
}
