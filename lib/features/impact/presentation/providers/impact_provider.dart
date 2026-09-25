import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/impact_metrics.dart';
import '../../domain/services/impact_calculator.dart';

/// Provider do impacto social acumulado do usuário logado.
///
/// Os totais ficam em `users/{uid}.impact` e são atualizados com
/// `FieldValue.increment`, que é atômico: duas compras simultâneas não perdem
/// uma à outra (diferente de ler-somar-gravar no cliente).
///
/// Importante: registrar o impacto **nunca** pode impedir um pedido. Por isso
/// [registerOrder] captura e apenas loga qualquer erro.
class ImpactProvider extends ChangeNotifier {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authSub;

  ImpactMetrics _totals = ImpactMetrics.empty;
  bool _isLoading = false;

  ImpactMetrics get totals => _totals;
  bool get isLoading => _isLoading;

  ImpactProvider({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
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
      final doc = await _db.collection('users').doc(uid).get();
      // Descarta a resposta se a conta mudou enquanto a leitura estava em voo.
      if (_auth.currentUser?.uid != uid) return;

      final raw = doc.data()?['impact'];
      _totals = ImpactMetrics.fromMap(
        raw is Map ? Map<String, dynamic>.from(raw) : null,
      );
    } catch (e) {
      debugPrint('ImpactProvider: erro ao carregar impacto: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Soma o impacto de um pedido recém-criado aos totais do usuário e grava um
  /// retrato desse impacto no próprio pedido (auditoria/backfill futuro).
  Future<void> registerOrder({
    required DocumentReference<Map<String, dynamic>> orderRef,
    required ImpactMetrics metrics,
  }) async {
    if (metrics.isEmpty) return;

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // 1) Totais do usuário (o que a UI lê).
    try {
      await _db.collection('users').doc(uid).set({
        'impact': {
          'itemsRescued': FieldValue.increment(metrics.itemsRescued),
          'itemsDonated': FieldValue.increment(metrics.itemsDonated),
          'savedReais': FieldValue.increment(metrics.savedReais),
          'donatedReais': FieldValue.increment(metrics.donatedReais),
          'methodologyVersion': ImpactCalculator.methodologyVersion,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _totals = _totals + metrics;
      notifyListeners();
    } catch (e) {
      debugPrint('ImpactProvider: erro ao atualizar totais do usuário: $e');
    }

    // 2) Retrato do impacto no pedido — passo separado para que uma regra de
    // segurança que bloqueie update em `pedidos` não afete o passo anterior.
    try {
      await orderRef.update({
        'impact': {
          ...metrics.toMap(),
          'methodologyVersion': ImpactCalculator.methodologyVersion,
        },
      });
    } catch (e) {
      debugPrint('ImpactProvider: erro ao gravar impacto no pedido: $e');
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
