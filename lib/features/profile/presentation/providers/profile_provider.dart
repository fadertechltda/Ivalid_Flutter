import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../donation/domain/services/donation_gamification_service.dart';

/// Provider de Perfil — espelhando ProfileViewModel do Kotlin.
class ProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userName = 'Cliente Ivalid';
  String _userEmail = '';
  bool _isLoading = true;
  String? _error;

  // Gamificação (mock como no Kotlin)
  final int _totalDonations = 15;
  final double _availableCashback = 24.50;

  // Modal de endereço
  bool _isAddressDialogVisible = false;
  bool _isAddressLoading = false;
  bool _isSavingAddress = false;
  String _cep = '';
  String _street = '';
  String _number = '';
  String _complement = '';
  String _neighborhood = '';
  String _city = '';
  String _state = '';

  // Getters
  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalDonations => _totalDonations;
  double get availableCashback => _availableCashback;
  bool get isAddressDialogVisible => _isAddressDialogVisible;
  bool get isAddressLoading => _isAddressLoading;
  bool get isSavingAddress => _isSavingAddress;
  String get cep => _cep;
  String get street => _street;
  String get number => _number;
  String get complement => _complement;
  String get neighborhood => _neighborhood;
  String get city => _city;
  String get state => _state;

  final DonationGamificationService gamificationService =
      DonationGamificationService();

  FidelityLevel get fidelityLevel =>
      gamificationService.getLevelForDonationCount(_totalDonations);

  int? get donationsNeededForNextLevel =>
      gamificationService.getDonationsNeededForNextLevel(_totalDonations);

  ProfileProvider() {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _userName = 'Nenhum usuário logado';
      _userEmail = '';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      final data = doc.data();

      _userName = (data?['fullName'] as String?) ??
          user.displayName ??
          'Cliente Ivalid';
      _userEmail = user.email ?? 'Email indisponível';
      _applyStoredAddress(data?['address'] as Map<String, dynamic>?);
      _isLoading = false;
    } catch (e) {
      _userName = user.displayName ?? 'Cliente Ivalid';
      _userEmail = user.email ?? 'Email indisponível';
      _isLoading = false;
      _error = 'Erro ao carregar perfil: $e';
    }

    notifyListeners();
  }

  Future<void> logout(VoidCallback onSuccess) async {
    await _auth.signOut();
    onSuccess();
  }

  void setAddressDialogVisible(bool visible) {
    _isAddressDialogVisible = visible;
    notifyListeners();
  }

  void updateAddressField(String field, String value) {
    switch (field) {
      case 'cep':
        _cep = value;
        if (value.length == 8) {
          lookupCep(value);
        }
        break;
      case 'street':
        _street = value;
        break;
      case 'number':
        _number = value;
        break;
      case 'complement':
        _complement = value;
        break;
      case 'neighborhood':
        _neighborhood = value;
        break;
      case 'city':
        _city = value;
        break;
    }
    notifyListeners();
  }

  void _applyStoredAddress(Map<String, dynamic>? address) {
    if (address == null) return;
    _cep = (address['cep'] as String?) ?? _cep;
    _street = (address['street'] as String?) ?? _street;
    _number = (address['number'] as String?) ?? _number;
    _complement = (address['complement'] as String?) ?? _complement;
    _neighborhood = (address['neighborhood'] as String?) ?? _neighborhood;
    _city = (address['city'] as String?) ?? _city;
    _state = (address['state'] as String?) ?? _state;
  }

  /// Salva o endereço no documento do usuário. Retorna `true` em caso de sucesso.
  Future<bool> saveAddress() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    _isSavingAddress = true;
    notifyListeners();

    try {
      await _db.collection('users').doc(user.uid).set({
        'address': {
          'cep': _cep,
          'street': _street,
          'number': _number,
          'complement': _complement,
          'neighborhood': _neighborhood,
          'city': _city,
          'state': _state,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar endereço: $e');
      _error = 'Erro ao salvar endereço: $e';
      return false;
    } finally {
      _isSavingAddress = false;
      notifyListeners();
    }
  }

  Future<void> lookupCep(String cepValue) async {
    final cleanCep = cepValue.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length != 8) return;

    _isAddressLoading = true;
    notifyListeners();

    try {
      final client = HttpClient();
      final uri = Uri.parse('https://viacep.com.br/ws/$cleanCep/json/');
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody) as Map<String, dynamic>;

        if (data['erro'] != true) {
          _street = data['logradouro'] ?? '';
          _neighborhood = data['bairro'] ?? '';
          _city = data['localidade'] ?? '';
          _state = data['uf'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar CEP: $e');
    } finally {
      _isAddressLoading = false;
      notifyListeners();
    }
  }
}
