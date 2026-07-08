import 'package:watt/src/features/admin/domain/models/admin_country.dart';

class AdminCity {
  final int id;
  final String name;
  final String code;
  final AdminCountry country;

  const AdminCity({
    required this.id,
    required this.name,
    required this.code,
    required this.country,
  });

  factory AdminCity.fromJson(Map<String, dynamic> json) {
    return AdminCity(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      country: AdminCountry.fromJson(
        json['country'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'country': country.toJson(),
    };
  }

  AdminCity copyWith({
    int? id,
    String? name,
    String? code,
    AdminCountry? country,
  }) {
    return AdminCity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      country: country ?? this.country,
    );
  }
}
