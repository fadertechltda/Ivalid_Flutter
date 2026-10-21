import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api/api_client.dart';
import '../../domain/models/impact_metrics.dart';

/// Provider do impacto social acumulado do usuário logado.
///
/// Os totais vêm da API (`GET api/app/clientes/me/impacto`). Quem soma o
/// impacto de cada pedido é a API, quando o pedido é finalizado; o app só lê.
class ImpactProvider extends ChangeNotifier {
  final ApiClient _api;
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authSub;

  ImpactMetrics _totals = ImpactMetrics.empty;
  bool _isLoading = false;

  ImpactMetrics get totals => _totals;
  bool get isLoading => _isLoading;

  ImpactProvider({ApiClient? api, FirebaseAuth? auth})
      : _api = api ?? ApiClient(),
        _auth = auth ?? FirebaseAuth.instance {
    // Recarrega sempre que a sessão mudar (login, logout, troca de conta).
    _authSub = _auth.authStateChanges().listen((_) => load());
  }

  Future<void> load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _totals = ImpactMetrics.empty;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.get('api/app/clientes/me/impacto');
      // Descarta a resposta se a conta mudou enquanto a leitura estava em voo.
      if (_auth.currentUser?.uid != uid) return;
      _totals = ImpactMetrics.fromApi(
        data is Map<String, dynamic> ? data : null,
      );
    } catch (e) {
      debugPrint('ImpactProvider: erro ao carregar impacto: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
