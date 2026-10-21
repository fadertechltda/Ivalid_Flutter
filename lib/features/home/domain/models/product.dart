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

  /// Loja dona do produto. Um pedido só pode ter itens de uma loja.
  final String supermercadoId;

  /// Estoque informado pela API (a validação final é feita no pedido).
  final int quantidadeDisponivel;

  /// Desconto e preço vigentes, sempre calculados pela API.
  final int percentualDesconto;
  final double precoAtual;

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
    this.supermercadoId = '',
    this.quantidadeDisponivel = 0,
    this.percentualDesconto = 0,
    double? precoAtual,
  }) : precoAtual = precoAtual ?? newPrice;

  double get priceOriginal => oldPrice;

  /// Desconto vigente (calculado pela API).
  int get discountPercent => percentualDesconto;

  /// Preço vigente (calculado pela API).
  double get priceNow => precoAtual;

  int get expiresInDays => daysValidity;

  /// Distância formatada (`1,5 km`) ou `null` quando a loja ainda não informou.
  String? get distanceLabel => distanceKm > 0
      ? '${distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km'
      : null;

  /// `Marca • 1,5 km`, omitindo as partes que não foram informadas.
  String get brandAndDistance =>
      [brand, distanceLabel].whereType<String>().where((p) => p.isNotEmpty).join(' • ');

  /// `Marca • Loja`, omitindo as partes que não foram informadas.
  String get brandAndStore =>
      [brand, storeName].where((p) => p.isNotEmpty).join(' • ');

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
      supermercadoId: supermercadoId,
      quantidadeDisponivel: quantidadeDisponivel,
      percentualDesconto: percentualDesconto,
      precoAtual: precoAtual,
    );
  }

  /// Lê um `ProdutoVitrineModel` da API (`api/app/produtos`).
  factory Product.fromApi(Map<String, dynamic> map, {bool isFavorite = false}) {
    final original = (map['precoOriginal'] as num?)?.toDouble() ?? 0.0;
    final atual = (map['precoAtual'] as num?)?.toDouble() ?? original;
    return Product(
      id: map['id'] as String? ?? '',
      name: map['nome'] as String? ?? '',
      brand: map['marca'] as String? ?? '',
      urlImagem: map['urlImagem'] as String? ?? '',
      storeName: map['nomeSupermercado'] as String? ?? '',
      distanceKm: 0.0,
      oldPrice: original,
      newPrice: atual,
      daysValidity: (map['diasParaVencer'] as num?)?.toInt() ?? 0,
      categoryId: map['categoriaId'] as String? ?? '',
      isFavorite: isFavorite,
      supermercadoId: map['supermercadoId'] as String? ?? '',
      quantidadeDisponivel: (map['quantidadeDisponivel'] as num?)?.toInt() ?? 0,
      percentualDesconto: (map['percentualDesconto'] as num?)?.toInt() ?? 0,
      precoAtual: atual,
    );
  }
}
