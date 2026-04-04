import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/service.dart';

class Company {
  final int id;
  final String name;
  final String? type;
  final String? description;
  final String? address;
  final bool allowsB2B;
  final bool allowsB2C;
  final String status;
  final String? tier;
  final String? logo;
  final City? city;
  final String? currency;
  final List<dynamic> categories;
  final String? subscriptionPlan;
  final String? expireDate;
  final String? createdAt;
  final String? updatedAt;
  final dynamic userPermission;
  final List<CompanyService> services;
  final String? memberRole;

  Company({
    required this.id,
    required this.name,
    this.type,
    this.description,
    this.address,
    required this.allowsB2B,
    required this.allowsB2C,
    required this.status,
    this.tier,
    this.logo,
    this.city,
    this.currency,
    required this.categories,
    this.subscriptionPlan,
    this.expireDate,
    this.createdAt,
    this.updatedAt,
    this.userPermission,
    this.services = const [],
    this.memberRole,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'],
      description: json['description'],
      address: json['address'],
      allowsB2B: json['allows_b2b'] ?? false,
      allowsB2C: json['allows_b2c'] ?? false,
      status: json['status'] ?? 'active',
      tier: json['tier'],
      logo: json['logo'],
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      currency: json['currency'],
      categories: json['categories'] != null ? List<dynamic>.from(json['categories']) : [],
      subscriptionPlan: json['subscription_plan'],
      expireDate: json['expire_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      userPermission: json['user_permission'],
      services: (json['services'] as List? ?? const [])
          .map(
            (e) => CompanyService(
              serviceCode: e['service_code'] ?? '',
              serviceName: e['service_name'] ?? e['name'] ?? '',
              status: e['status'] ?? 'inactive',
              isAutoEnabled: e['is_auto_enabled'] ?? false,
              autoEnabledBy: (e['auto_enabled_by'] as List?)?.map((item) => '$item').toList() ?? const [],
              subscriptionId: e['subscription_id'],
              requestedAt: e['requested_at'],
              approvedAt: e['approved_at'],
              activatedAt: e['activated_at'],
              startsAt: e['starts_at'],
              endsAt: e['ends_at'],
              notes: e['notes'],
              meta: e['meta'] != null ? Map<String, dynamic>.from(e['meta']) : const {},
            ),
          )
          .toList(),
      memberRole: json['member_role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'address': address,
      'allows_b2b': allowsB2B,
      'allows_b2c': allowsB2C,
      'status': status,
      'tier': tier,
      'logo': logo,
      'city': city?.toJson(),
      'currency': currency,
      'categories': categories,
      'subscription_plan': subscriptionPlan,
      'expire_date': expireDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_permission': userPermission,
      'services': services
          .map(
            (service) => {
              'service_code': service.serviceCode,
              'service_name': service.serviceName,
              'status': service.status,
            },
          )
          .toList(),
      'member_role': memberRole,
    };
  }
}
