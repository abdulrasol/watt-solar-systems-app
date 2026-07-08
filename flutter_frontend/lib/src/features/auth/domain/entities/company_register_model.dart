import 'package:dio/dio.dart';

class CompanyRegistrationModel {
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final int? city;
  final String? image;
  final int companyType;
  final bool allowsB2B;
  final bool allowsB2C;
  final int? currency;
  final List<int>? categories;

  CompanyRegistrationModel({
    required this.name,
    required this.companyType,
    required this.allowsB2B,
    required this.allowsB2C,
    this.description,
    this.address,
    this.phone,
    this.city,
    this.image,
    this.currency,
    this.categories,
  });

  Future<Map<String, dynamic>> toJson() async {
    final data = <String, dynamic>{
      'name': name,
      'company_type': companyType,
      'allows_b2b': allowsB2B,
      'allows_b2c': allowsB2C,
    };

    if (description != null) data['description'] = description;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (city != null) data['city'] = city;
    if (currency != null) data['currency'] = currency;
    if (categories != null) data['categories'] = categories;
    if (image != null && image!.isNotEmpty) {
      data['image'] = await MultipartFile.fromFile(image!);
    }

    return data;
  }
}
