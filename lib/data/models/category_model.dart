class CategoryModel {
  final String id;
  final String name;

  /// Key string untuk icon (mis. "rice_bowl"), dipetakan ke IconData
  /// lewat `AppIcons.categoryIcon()` - JSON tidak bisa simpan IconData
  /// langsung.
  final String icon;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}
