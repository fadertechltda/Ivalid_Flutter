import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/api/api_client.dart';
import '../../domain/models/product.dart';
import '../../domain/models/category.dart';

enum ProductSortOption {
  defaultSort,
  priceAsc,
  priceDesc,
  discountAsc,
  discountDesc,
  distanceAsc,
  distanceDesc,
}

class HomeProvider extends ChangeNotifier {
  final ApiClient _api;

  String _query = '';
  String? _selectedCategoryId;
  List<Category> _categories = [];
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  ProductSortOption _currentSort = ProductSortOption.defaultSort;

  String? get selectedCategoryId => _selectedCategoryId;
  List<Category> get categories => _categories;
  List<Product> get filteredProducts => _filteredProducts;

  /// Catálogo completo, sem busca/categoria aplicadas (ex.: médias de preço).
  List<Product> get allProducts => _allProducts;
  List<Product> get favoriteProducts =>
      _allProducts.where((p) => p.isFavorite).toList();
  bool get isLoading => _isLoading;

  /// Mensagem de falha ao carregar o catálogo (`null` quando deu certo).
  String? get error => _error;
  ProductSortOption get currentSort => _currentSort;

  HomeProvider({ApiClient? api}) : _api = api ?? ApiClient() {
    load();
  }

  /// Carrega catálogo, categorias e favoritos pela API.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _fetchCategories(),
        _fetchProducts(),
        _fetchFavoriteIds(),
      ]);

      _categories = [
        Category(id: 'all', name: 'Todos'),
        ...results[0] as List<Category>,
      ];
      final favorites = results[2] as Set<String>;
      _allProducts = (results[1] as List<Product>)
          .map((p) => favorites.contains(p.id) ? p.copyWith(isFavorite: true) : p)
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
      _allProducts = [];
    } catch (e) {
      debugPrint('HomeProvider: erro ao carregar catálogo: $e');
      _error = 'Não foi possível carregar os produtos.';
      _allProducts = [];
    } finally {
      _isLoading = false;
      applyFilters();
    }
  }

  Future<List<Category>> _fetchCategories() async {
    try {
      final data = await _api.get('api/app/categorias');
      if (data is! List) return [];
      return data.whereType<Map<String, dynamic>>().map(Category.fromApi).toList();
    } on ApiException {
      // Sem categorias o catálogo continua utilizável (só o filtro some).
      return [];
    }
  }

  Future<List<Product>> _fetchProducts() async {
    const pageSize = 100;
    final products = <Product>[];
    var page = 1;
    while (true) {
      final data = await _api.get('api/app/produtos', query: {
        'pagina': '$page',
        'tamanhoPagina': '$pageSize',
      });
      if (data is! Map<String, dynamic>) break;
      final items = data['itens'];
      if (items is List) {
        products.addAll(
            items.whereType<Map<String, dynamic>>().map(Product.fromApi));
      }
      if (data['temProxima'] != true) break;
      page++;
    }
    return products;
  }

  Future<Set<String>> _fetchFavoriteIds() async {
    if (FirebaseAuth.instance.currentUser == null) return {};
    try {
      final data = await _api.get('api/app/clientes/me/favoritos');
      if (data is! List) return {};
      return data
          .map((e) => e is Map<String, dynamic> ? e['id'] as String? : e as String?)
          .whereType<String>()
          .toSet();
    } on ApiException {
      return {};
    }
  }

  void onQueryChange(String newQuery) {
    _query = newQuery;
    applyFilters();
  }

  void onSelectCategory(String? id) {
    _selectedCategoryId = id;
    applyFilters();
  }

  /// Alterna o favorito na tela na hora e confirma na API; se falhar, desfaz.
  Future<void> toggleFavorite(String productId) async {
    final index = _allProducts.indexWhere((p) => p.id == productId);
    if (index == -1) return;
    final wasFavorite = _allProducts[index].isFavorite;

    _setFavorite(productId, !wasFavorite);
    try {
      final path = 'api/app/clientes/me/favoritos/$productId';
      if (wasFavorite) {
        await _api.delete(path);
      } else {
        await _api.put(path);
      }
    } catch (e) {
      debugPrint('HomeProvider: erro ao atualizar favorito: $e');
      _setFavorite(productId, wasFavorite);
    }
  }

  void _setFavorite(String productId, bool value) {
    _allProducts = _allProducts
        .map((p) => p.id == productId ? p.copyWith(isFavorite: value) : p)
        .toList();
    applyFilters();
  }

  void sortProducts(ProductSortOption sortOption) {
    _currentSort = sortOption;
    applyFilters();
  }

  void applyFilters() {
    final q = _query.trim().toLowerCase();
    final cat = _selectedCategoryId;

    var filtered = _allProducts.where((p) {
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.storeName.toLowerCase().contains(q);
      final matchesCat = (cat == null || cat == 'all') || p.categoryId == cat;
      return matchesQuery && matchesCat;
    }).toList();

    switch (_currentSort) {
      case ProductSortOption.priceAsc:
        filtered.sort((a, b) => a.priceNow.compareTo(b.priceNow));
        break;
      case ProductSortOption.priceDesc:
        filtered.sort((a, b) => b.priceNow.compareTo(a.priceNow));
        break;
      case ProductSortOption.discountAsc:
        filtered.sort((a, b) => a.discountPercent.compareTo(b.discountPercent));
        break;
      case ProductSortOption.discountDesc:
        filtered.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        break;
      case ProductSortOption.distanceAsc:
        filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case ProductSortOption.distanceDesc:
        filtered.sort((a, b) => b.distanceKm.compareTo(a.distanceKm));
        break;
      case ProductSortOption.defaultSort:
        filtered.sort((a, b) {
          int cmp = a.expiresInDays.compareTo(b.expiresInDays);
          if (cmp == 0) {
            return b.discountPercent.compareTo(a.discountPercent);
          }
          return cmp;
        });
        break;
    }

    _filteredProducts = filtered;
    notifyListeners();
  }
}
