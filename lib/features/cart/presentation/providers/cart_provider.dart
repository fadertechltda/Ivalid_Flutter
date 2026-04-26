import 'package:flutter/foundation.dart';
import '../../../home/domain/models/product.dart';
import '../../../donation/domain/services/donation_gamification_service.dart';

enum OriginType { vendaDireta, doacao }

class CartItem {
  final Product product;
  final int quantity;
  final OriginType origin;

  CartItem({
    required this.product,
    required this.quantity,
    this.origin = OriginType.vendaDireta,
  });

  double get subtotal => product.priceNow * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    OriginType? origin,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      origin: origin ?? this.origin,
    );
  }
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  int _userTotalDonationsMock = 15;

  final DonationGamificationService gamificationService = DonationGamificationService();

  List<CartItem> get items => _items;
  int get userTotalDonationsMock => _userTotalDonationsMock;

  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);
  int get count => _items.fold(0, (sum, item) => sum + item.quantity);
  double get donationSubtotal => _items
      .where((item) => item.origin == OriginType.doacao)
      .fold(0, (sum, item) => sum + item.subtotal);

  void add(Product product, int quantity, {bool isDonationContext = false}) {
    if (quantity <= 0) return;

    final originType = isDonationContext ? OriginType.doacao : OriginType.vendaDireta;

    final existingIndex = _items.indexWhere(
        (item) => item.product.id == product.id && item.origin == originType);

    if (existingIndex == -1) {
      _items.add(CartItem(product: product, quantity: quantity, origin: originType));
    } else {
      final existingItem = _items[existingIndex];
      _items[existingIndex] =
          existingItem.copyWith(quantity: existingItem.quantity + quantity);
    }
    notifyListeners();
  }

  void setQuantity(String productId, int quantity, {OriginType originType = OriginType.vendaDireta}) {
    if (quantity <= 0) {
      _items.removeWhere((item) => item.product.id == productId && item.origin == originType);
    } else {
      final index = _items.indexWhere(
          (item) => item.product.id == productId && item.origin == originType);
      if (index != -1) {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
    }
    notifyListeners();
  }

  void remove(String productId, {OriginType originType = OriginType.vendaDireta}) {
    _items.removeWhere((item) => item.product.id == productId && item.origin == originType);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
