class AdminGlobalCategory {
  final int id;
  final String name;
  final String? icon;

  const AdminGlobalCategory({
    required this.id,
    required this.name,
    this.icon,
  });

  factory AdminGlobalCategory.fromJson(Map<String, dynamic> json) {
    return AdminGlobalCategory(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  AdminGlobalCategory copyWith({
    int? id,
    String? name,
    String? icon,
  }) {
    return AdminGlobalCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }
}
