class Category {
  final String id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromApi(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String? ?? '',
      name: (map['nome'] ?? map['name']) as String? ?? '',
    );
  }
}
