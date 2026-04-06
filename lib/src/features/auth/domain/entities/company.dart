import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/service.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

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
  final int? subscriptionPlan;
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
    dPrint('company json: ${json['id']}', tag: 'Company');
    return Company(
      id: int.parse(json['id'].toString()),
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
              requestedAt: e['requested_at'] != null ? DateTime.parse(e['requested_at']) : null,
              approvedAt: e['approved_at'] != null ? DateTime.parse(e['approved_at']) : null,
              activatedAt: e['activated_at'] != null ? DateTime.parse(e['activated_at']) : null,
              startsAt: e['starts_at'] != null ? DateTime.parse(e['starts_at']) : null,
              endsAt: e['ends_at'] != null ? DateTime.parse(e['ends_at']) : null,
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
      'services': services.map((service) => {'service_code': service.serviceCode, 'service_name': service.serviceName, 'status': service.status}).toList(),
      'member_role': memberRole,
    };
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isSuspended => status.toLowerCase() == 'suspended';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  Company copyWith({
    int? id,
    String? name,
    String? type,
    String? description,
    String? address,
    bool? allowsB2B,
    bool? allowsB2C,
    String? status,
    String? tier,
    String? logo,
    City? city,
    String? currency,
    List<dynamic>? categories,
    int? subscriptionPlan,
    String? expireDate,
    String? createdAt,
    String? updatedAt,
    dynamic userPermission,
    List<CompanyService>? services,
    String? memberRole,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      address: address ?? this.address,
      allowsB2B: allowsB2B ?? this.allowsB2B,
      allowsB2C: allowsB2C ?? this.allowsB2C,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      logo: logo ?? this.logo,
      city: city ?? this.city,
      currency: currency ?? this.currency,
      categories: categories ?? this.categories,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      expireDate: expireDate ?? this.expireDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userPermission: userPermission ?? this.userPermission,
      services: services ?? this.services,
      memberRole: memberRole ?? this.memberRole,
    );
  }
}
