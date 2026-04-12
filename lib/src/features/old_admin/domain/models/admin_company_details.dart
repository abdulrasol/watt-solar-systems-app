import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';

class AdminCompanyDetails {
  final Company company;
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
      company: Company.fromJson((body['company'] as Map<String, dynamic>?) ?? <String, dynamic>{}),
      categories: body['categories'] is List ? body['categories'] : [],
      deliveryOptions: body['delivery_options'] is List ? body['delivery_options'] : [],
      financials: (body['financials'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      services: (body['services'] as List? ?? []).whereType<Map<String, dynamic>>().map((e) => CompanyService.fromJson(e)).toList(),
      members: (body['members'] as List? ?? []).whereType<Map<String, dynamic>>().map((e) => CompanyMember.fromJson(e)).toList(),
    );
  }

  AdminCompanyDetails copyWith({
    Company? company,
    List<dynamic>? categories,
    List<dynamic>? deliveryOptions,
    Map<String, dynamic>? financials,
    List<CompanyService>? services,
    List<CompanyMember>? members,
  }) {
    return AdminCompanyDetails(
      company: company ?? this.company,
      categories: categories ?? this.categories,
      deliveryOptions: deliveryOptions ?? this.deliveryOptions,
      financials: financials ?? this.financials,
      services: services ?? this.services,
      members: members ?? this.members,
    );
  }
}

class CompanyMember {
  final String id;
  final String username;
  final String email;
  final String role;

  CompanyMember({required this.id, required this.username, required this.email, required this.role});

  factory CompanyMember.fromJson(Map<String, dynamic> json) {
    return CompanyMember(id: json['id'].toString(), username: json['username'] ?? '', email: json['email'] ?? '', role: json['role'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'email': email, 'role': role};
  }

  CompanyMember copyWith({String? id, String? username, String? email, String? role}) {
    return CompanyMember(id: id ?? this.id, username: username ?? this.username, email: email ?? this.email, role: role ?? this.role);
  }
}
