import 'package:dio/dio.dart';

class CompanyRegistrationModel {
  final String name;
  final String description;
  final String? address;
  final int? city;
  final String? logo;
  final int? tire;
  final int? type;
  final bool b2b;
  final bool b2c;

  CompanyRegistrationModel({
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.b2b,
    required this.b2c,
    this.logo,
    this.tire,
    this.type,
  });

  Future<Map<String, dynamic>> toJson() async {
    return {
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'b2b': b2b,
      'b2c': b2c,
      'logo': logo != null && logo!.isNotEmpty ? await MultipartFile.fromFile(logo!) : null,
      'tire': tire,
      'type': type,
    };
  }
}
