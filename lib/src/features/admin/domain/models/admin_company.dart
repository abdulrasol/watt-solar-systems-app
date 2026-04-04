import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';

class AdminCompany {
  final int id;
  final String name;
  final String? type;
  final String? description;
  final String? address;
  final bool allowsB2b;
  final bool allowsB2c;
  final String status;
  final String? tier;
  final String? logo;
  final String? cityName;
  final String? expireDate;
  final String? createdAt;
  final String? updatedAt;
  final List<CompanyService> services;

  AdminCompany({
    required this.id,
    required this.name,
    this.type,
    this.description,
    this.address,
    required this.allowsB2b,
    required this.allowsB2c,
    required this.status,
    this.tier,
    this.logo,
    this.cityName,
    this.expireDate,
    this.createdAt,
    this.updatedAt,
    this.services = const [],
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

  factory AdminCompany.fromJson(Map<String, dynamic> json) {
    return AdminCompany(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? json['company_type'],
      description: json['description'],
      address: json['address'],
      allowsB2b: json['allows_b2b'] ?? false,
      allowsB2c: json['allows_b2c'] ?? false,
      status: json['status'] ?? 'pending',
      tier: json['tier'] ?? json['company_tier'],
      logo: json['logo'],
      cityName: json['city']?['name'],
      expireDate: json['expire_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      services: (json['services'] as List? ?? []).map((e) => CompanyService.fromJson(e)).toList(),
    );
  }
}
