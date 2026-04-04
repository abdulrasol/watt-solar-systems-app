class ServiceCatalogItem {
  final int id;
  final String code;
  final String name;
  final String? description;
  final String? category;
  final bool isActive;
  final int sortOrder;
  final String? route;
  final String? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceCatalogItem({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.category,
    required this.isActive,
    required this.sortOrder,
    this.route,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceCatalogItem.fromJson(Map<String, dynamic> json) {
    return ServiceCatalogItem(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'],
      isActive: json['is_active'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      route: json['route'],
      icon: json['icon'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'category': category,
      'is_active': isActive,
      'sort_order': sortOrder,
      'route': route,
    };
  }

  ServiceCatalogItem copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    String? category,
    bool? isActive,
    int? sortOrder,
    String? route,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceCatalogItem(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      route: route ?? this.route,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
