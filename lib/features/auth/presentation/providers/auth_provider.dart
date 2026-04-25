import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        _setError('E-mail ou senha incorretos.');
      } else {
        _setError(e.message ?? 'Erro desconhecido ao entrar.');
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Ocorreu um erro. Tente novamente.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.reload();

      // Save user data to Firestore (matching Kotlin SignUpViewModel)
      final uid = cred.user!.uid;
      await _db.collection('users').doc(uid).set({
        'fullName': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _setError('Este e-mail já está em uso.');
      } else if (e.code == 'weak-password') {
        _setError('A senha deve ter no mínimo 6 caracteres.');
      } else {
        _setError(e.message ?? 'Erro desconhecido ao cadastrar.');
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Ocorreu um erro. Tente novamente.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
