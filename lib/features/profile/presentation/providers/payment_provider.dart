import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditCardModel {
  final String id;
  final String number;
  final String holderName;
  final String expiryDate;
  final String cvv;
  final String brand; // VISA, MASTERCARD, ELO, AMERICANEXPRESS, HIPERCARD, UNKNOWN
  final String type; // Crédito, Débito, Voucher, Vale Refeição, Vale Alimentação

  CreditCardModel({
    required this.id,
    required this.number,
    required this.holderName,
    required this.expiryDate,
    required this.cvv,
    required this.brand,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'holderName': holderName,
        'expiryDate': expiryDate,
        'cvv': cvv,
        'brand': brand,
        'type': type,
      };

  factory CreditCardModel.fromJson(Map<String, dynamic> json) => CreditCardModel(
        id: json['id'] as String,
        number: json['number'] as String,
        holderName: json['holderName'] as String,
        expiryDate: json['expiryDate'] as String,
        cvv: json['cvv'] as String,
        brand: json['brand'] as String,
        type: json['type'] as String,
      );

  String get maskedNumber {
    final clean = number.replaceAll(' ', '');
    if (clean.length < 4) return '****';
    return '•••• ${clean.substring(clean.length - 4)}';
  }
}

class PaymentProvider extends ChangeNotifier {
  static const String _storageKey = 'ivalid_saved_cards';
  
  List<CreditCardModel> _cards = [];
  double _balance = 0.00;
  bool _isLoading = true;

  List<CreditCardModel> get cards => _cards;
  double get balance => _balance;
  bool get isLoading => _isLoading;

  // Transações simuladas para enriquecer a experiência visual
  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Cashback Recebido',
      'subtitle': 'Doação de Alimentos Hortifruti',
      'value': 4.50,
      'isPositive': true,
      'date': 'Hoje, 14:32',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'title': 'Compra Ivalid',
      'subtitle': 'Supermercado Nova Era',
      'value': -45.90,
      'isPositive': false,
      'date': 'Ontem, 19:15',
      'icon': Icons.shopping_bag_rounded,
    },
    {
      'title': 'Doação Aprovada',
      'subtitle': 'Associação Amigos do Bem',
      'value': -15.00,
      'isPositive': false,
      'date': '16 Mai, 10:00',
      'icon': Icons.favorite_rounded,
    },
    {
      'title': 'Recarga Ivalid Card',
      'subtitle': 'Via Cartão Elo',
      'value': 50.00,
      'isPositive': true,
      'date': '12 Mai, 15:45',
      'icon': Icons.add_circle_outline_rounded,
    }
  ];

  List<Map<String, dynamic>> get transactions => _transactions;

  PaymentProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cardsString = prefs.getString(_storageKey);
      
      if (cardsString != null) {
        final List<dynamic> decoded = jsonDecode(cardsString);
        _cards = decoded.map((item) => CreditCardModel.fromJson(item)).toList();
      } else {
        // Se for a primeira inicialização, vamos prender os cartões mockados da imagem do usuário
        // para dar o visual premium imediato!
        _cards = [
          CreditCardModel(
            id: 'mock_elo',
            number: '5067450612344749',
            holderName: 'ALEXANDRE FREITAS',
            expiryDate: '08/30',
            cvv: '123',
            brand: 'ELO',
            type: 'Crédito',
          ),
          CreditCardModel(
            id: 'mock_master',
            number: '5123450612344506',
            holderName: 'ALEXANDRE FREITAS',
            expiryDate: '12/29',
            cvv: '456',
            brand: 'MASTERCARD',
            type: 'Crédito',
          ),
        ];
        await _saveCardsToStorage();
      }

      // Carregar saldo simulado
      _balance = prefs.getDouble('ivalid_pago_balance') ?? 0.00;
    } catch (e) {
      debugPrint('Erro ao carregar dados de pagamento: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveCardsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardsJson = jsonEncode(_cards.map((c) => c.toJson()).toList());
      await prefs.setString(_storageKey, cardsJson);
    } catch (e) {
      debugPrint('Erro ao salvar cartões: $e');
    }
  }

  Future<void> addCard(CreditCardModel card) async {
    _cards.add(card);
    await _saveCardsToStorage();
    notifyListeners();
  }

  Future<void> deleteCard(String id) async {
    _cards.removeWhere((c) => c.id == id);
    await _saveCardsToStorage();
    notifyListeners();
  }

  Future<void> updateBalance(double value) async {
    _balance = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ivalid_pago_balance', _balance);
    notifyListeners();
  }

  // Detecta bandeira com base no prefixo
  static String detectCardBrand(String number) {
    final cleanNumber = number.replaceAll(RegExp(r'\s+'), '');
    if (cleanNumber.isEmpty) return 'UNKNOWN';
    
    if (cleanNumber.startsWith('4')) {
      return 'VISA';
    }
    
    if (RegExp(r'^5[1-5]').hasMatch(cleanNumber) || RegExp(r'^2[2-7]').hasMatch(cleanNumber)) {
      return 'MASTERCARD';
    }
    
    if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) {
      return 'AMERICANEXPRESS';
    }
    
    // Elo
    final eloRegex = RegExp(r'^(401178|401179|431274|438935|451416|457393|457631|457632|504175|506699|5067|509|627892|636297|636368|650485|65072|65090|65165)');
    if (eloRegex.hasMatch(cleanNumber)) {
      return 'ELO';
    }
    
    // Hipercard
    if (cleanNumber.startsWith('3841') || 
        cleanNumber.startsWith('606282') || 
        cleanNumber.startsWith('637095') || 
        cleanNumber.startsWith('637568') || 
        cleanNumber.startsWith('637612')) {
      return 'HIPERCARD';
    }
    
    return 'UNKNOWN';
  }
}
