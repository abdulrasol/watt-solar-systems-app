class CompanyType {
  final int id;
  final String code;
  final String name;

  const CompanyType({required this.id, required this.code, required this.name});

  factory CompanyType.fromJson(Map<String, dynamic> json) {
    return CompanyType(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }

  CompanyType copyWith({int? id, String? code, String? name}) {
    return CompanyType(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  bool get isPlaceholder {
    final normalizedCode = code.trim().toLowerCase();
    final normalizedName = name.trim().toLowerCase();
    return id == 0 || normalizedCode == 'dummy' || normalizedName == 'dummy';
  }
}
