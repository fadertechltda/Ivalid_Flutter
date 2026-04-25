class Category {
  final String id;
  final String name;
  final int? icon;

  Category({
    required this.id,
    required this.name,
    this.icon,
  });

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'] as String? ?? '',
      icon: map['icon'] as int?,
    );
  }
}
