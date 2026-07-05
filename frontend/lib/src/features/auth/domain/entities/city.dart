import 'package:solar_hub/src/features/auth/domain/entities/country.dart';

class City {
  final int id;
  final String name;
  final Country country;
  final String? code;

  City({
    required this.id,
    required this.name,
    required this.country,
    this.code,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      country: Country.fromJson(json['country']),
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'country': country.toJson(), 'code': code};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
