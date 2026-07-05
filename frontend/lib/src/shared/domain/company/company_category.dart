class CompanyCategory {
  final int id;
  final String name;

  const CompanyCategory({required this.id, required this.name});

  factory CompanyCategory.fromJson(Map<String, dynamic> json) {
    return CompanyCategory(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  CompanyCategory copyWith({int? id, String? name}) {
    return CompanyCategory(id: id ?? this.id, name: name ?? this.name);
  }
}
