import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../donation/domain/services/donation_gamification_service.dart';

/// Provider de Perfil — espelhando ProfileViewModel do Kotlin.
class ProfileProvider extends ChangeNotifier {
  final ApiClient _api;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userName = 'Cliente Ivalid';
  String _phone = '';
  bool _isLoading = true;
  String? _error;

  // Gamificação - Inicia zerada por padrão no perfil do cliente
  int _totalDonations = 0;
  double _availableCashback = 0.0;

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

  ProfileProvider({ApiClient? api}) : _api = api ?? ApiClient() {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _userName = 'Nenhum usuário logado';
      _totalDonations = 0;
      _availableCashback = 0.0;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Map<String, dynamic> data;
      try {
        data = await _fetchProfile();
      } on ApiException catch (e) {
        if (e.statusCode != 404) rethrow;
        // Conta antiga ou cadastro que não chegou à API: cria o perfil agora.
        await _api.post('api/app/clientes', body: {
          'nomeCompleto': user.displayName ?? 'Cliente Ivalid',
        });
        data = await _fetchProfile();
      }

      _userName = (data['nomeCompleto'] as String?) ??
          user.displayName ??
          'Cliente Ivalid';
      _phone = (data['telefone'] as String?) ?? '';
      _totalDonations = (data['totalDoacoes'] as num?)?.toInt() ?? 0;
      _availableCashback = (data['cashbackDisponivel'] as num?)?.toDouble() ?? 0.0;

      _applyStoredAddress(data['endereco'] as Map<String, dynamic>?);
      _isLoading = false;
    } on ApiException catch (e) {
      _fallbackProfile(user);
      _error = 'Erro ao carregar perfil: ${e.message}';
    } catch (e) {
      _fallbackProfile(user);
      _error = 'Erro ao carregar perfil: $e';
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    final data = await _api.get('api/app/clientes/me');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Resposta inesperada do servidor.');
    }
    return data;
  }

  void _fallbackProfile(User user) {
    _userName = user.displayName ?? 'Cliente Ivalid';
    _totalDonations = 0;
    _availableCashback = 0.0;
    _isLoading = false;
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
    _street = (address['logradouro'] as String?) ?? _street;
    _number = (address['numero'] as String?) ?? _number;
    _complement = (address['complemento'] as String?) ?? _complement;
    _neighborhood = (address['bairro'] as String?) ?? _neighborhood;
    _city = (address['cidade'] as String?) ?? _city;
    _state = (address['estado'] as String?) ?? _state;
  }

  /// Salva o endereço pelo perfil da API. Retorna `true` em caso de sucesso.
  Future<bool> saveAddress() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    _isSavingAddress = true;
    notifyListeners();

    try {
      await _api.put('api/app/clientes/me', body: {
        'nomeCompleto': _userName,
        if (_phone.isNotEmpty) 'telefone': _phone,
        'endereco': {
          'cep': _cep,
          'logradouro': _street,
          'numero': _number,
          'complemento': _complement,
          'bairro': _neighborhood,
          'cidade': _city,
          'estado': _state,
        },
      });
      return true;
    } on ApiException catch (e) {
      _error = 'Erro ao salvar endereço: ${e.message}';
      return false;
    } catch (e) {
      debugPrint('Erro ao salvar endereço: $e');
      _error = 'Erro ao salvar endereço.';
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
