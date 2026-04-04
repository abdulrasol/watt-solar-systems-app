import 'package:solar_hub/src/features/admin/domain/models/admin_company.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';

class AdminCompanyDetails {
  final AdminCompany company;
  final List<dynamic> categories;
  final List<dynamic> deliveryOptions;
  final Map<String, dynamic> financials;
  final List<CompanyService> services;
  final List<CompanyMember> members;

  AdminCompanyDetails({
    required this.company,
    required this.categories,
    required this.deliveryOptions,
    required this.financials,
    required this.services,
    required this.members,
  });

  factory AdminCompanyDetails.fromJson(Map<String, dynamic> json) {
    final body = json;
    return AdminCompanyDetails(
      company: AdminCompany.fromJson(body['company']),
      categories: body['categories'] ?? [],
      deliveryOptions: body['delivery_options'] ?? [],
      financials: body['financials'] ?? {},
      services: (body['services'] as List? ?? []).map((e) => CompanyService.fromJson(e)).toList(),
      members: (body['members'] as List? ?? []).map((e) => CompanyMember.fromJson(e)).toList(),
    );
  }
}

class CompanyMember {
  final String id;
  final String username;
  final String email;
  final String role;

  CompanyMember({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory CompanyMember.fromJson(Map<String, dynamic> json) {
    return CompanyMember(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
