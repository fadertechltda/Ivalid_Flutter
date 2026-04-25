import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _query = '';
  String? _selectedCategoryId;
  List<Category> _categories = [];
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  ProductSortOption _currentSort = ProductSortOption.defaultSort;

  String get query => _query;
  String? get selectedCategoryId => _selectedCategoryId;
  List<Category> get categories => _categories;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  ProductSortOption get currentSort => _currentSort;

  HomeProvider() {
    loadFromFirestore();
  }

  Future<void> loadFromFirestore() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Dummy categories
      List<Category> cats = [
        Category(id: 'all', name: 'Todos'),
        Category(id: 'hortifruti', name: 'Hortifruti'),
        Category(id: 'laticinios', name: 'Laticínios'),
        Category(id: 'padaria', name: 'Padaria'),
      ];
      
      try {
        final catSnap = await _db.collection('categories').get();
        if (catSnap.docs.isNotEmpty) {
          cats = catSnap.docs.map((d) => Category.fromMap(d.data(), d.id)).toList();
        }
      } catch (_) {}

      _categories = cats;

      // Products — collection name matches Kotlin original: "produtos"
      try {
        final prodSnap = await _db.collection('produtos').get();
        _allProducts = prodSnap.docs.map((d) {
          try {
            return Product.fromMap(d.data(), d.id);
          } catch (e) {
            debugPrint('Erro ao mapear produto ${d.id}: $e');
            return null;
          }
        }).whereType<Product>().toList();
        debugPrint('Produtos carregados: ${_allProducts.length}');
      } catch (e) {
        debugPrint('Erro geral produtos: $e');
        _allProducts = [];
      }
    } finally {
      _isLoading = false;
      applyFilters();
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

  void toggleFavorite(String productId) {
    _allProducts = _allProducts.map((p) {
      if (p.id == productId) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();
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
      default:
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
