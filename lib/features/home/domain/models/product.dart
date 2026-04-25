class Product {
  final String id;
  final String name;
  final String brand;
  final String urlImagem;
  final String storeName;
  final double distanceKm;
  final double oldPrice;
  final double newPrice;
  final int daysValidity;
  final String categoryId;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.urlImagem,
    required this.storeName,
    required this.distanceKm,
    required this.oldPrice,
    required this.newPrice,
    required this.daysValidity,
    required this.categoryId,
    this.isFavorite = false,
  });

  double get priceOriginal => oldPrice;

  int get discountPercent {
    int val = (30 - daysValidity) * 2;
    if (val < 0) val = 0;
    if (val > 90) val = 90;
    return val;
  }

  double get priceNow {
    if (oldPrice > 0) {
      return oldPrice * (1.0 - (discountPercent / 100.0));
    }
    return newPrice;
  }

  int get expiresInDays => daysValidity;

  Product copyWith({bool? isFavorite}) {
    return Product(
      id: id,
      name: name,
      brand: brand,
      urlImagem: urlImagem,
      storeName: storeName,
      distanceKm: distanceKm,
      oldPrice: oldPrice,
      newPrice: newPrice,
      daysValidity: daysValidity,
      categoryId: categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      urlImagem: map['urlImagem'] as String? ?? '',
      storeName: map['storeName'] as String? ?? '',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (map['oldPrice'] as num?)?.toDouble() ?? 0.0,
      newPrice: (map['newPrice'] as num?)?.toDouble() ?? 0.0,
      daysValidity: (map['daysValidity'] as num?)?.toInt() ?? 0,
      categoryId: map['categoryId'] as String? ?? '',
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }
}
