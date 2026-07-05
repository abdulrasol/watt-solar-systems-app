class AdminCountry {
  final int id;
  final String name;
  final String code;

  const AdminCountry({
    required this.id,
    required this.name,
    required this.code,
  });

  factory AdminCountry.fromJson(Map<String, dynamic> json) {
    return AdminCountry(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  AdminCountry copyWith({
    int? id,
    String? name,
    String? code,
  }) {
    return AdminCountry(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }
}
