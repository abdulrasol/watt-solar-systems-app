import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/shared/domain/company/company_category.dart';
import 'package:solar_hub/src/shared/domain/company/company_contact.dart';
import 'package:solar_hub/src/shared/domain/company/company_currency.dart';
import 'package:solar_hub/src/shared/domain/company/company_delivery_option.dart';
import 'package:solar_hub/src/shared/domain/company/company_permissions.dart';
import 'package:solar_hub/src/shared/domain/company/company_public_service.dart';
import 'package:solar_hub/src/shared/domain/company/company_stats.dart';
import 'package:solar_hub/src/shared/domain/company/company_type.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/service.dart';

class Company {
  final int id;
  final String name;
  final String? type;
  final String? typeName;
  final String? description;
  final String? address;
  final String? phone;
  final bool allowsB2B;
  final bool allowsB2C;
  final String status;
  final String? tier;
  final String? logo;
  final City? city;
  final CompanyCurrency? currency;
  final List<CompanyCategory> categories;
  final int? subscriptionPlan;
  final bool? subscriptionIsValid;
  final DateTime? expireDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CompanyType? companyType;
  final List<CompanyContact> contacts;
  final List<CompanyDeliveryOption> deliveryOptions;
  final List<CompanyPublicService> publicServices;
  final List<ServiceType> serviceTypes;
  final List<CompanyService> services;
  final String? memberRole;
  final CompanyPermissions? permissions;
  final CompanyStats? stats;

  const Company({
    required this.id,
    required this.name,
    this.type,
    this.typeName,
    this.description,
    this.address,
    this.phone,
    required this.allowsB2B,
    required this.allowsB2C,
    required this.status,
    this.tier,
    this.logo,
    this.city,
    this.currency,
    this.categories = const [],
    this.subscriptionPlan,
    this.subscriptionIsValid,
    this.expireDate,
    this.createdAt,
    this.updatedAt,
    this.companyType,
    this.contacts = const [],
    this.deliveryOptions = const [],
    this.publicServices = const [],
    this.serviceTypes = const [],
    this.services = const [],
    this.memberRole,
    this.permissions,
    this.stats,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    final permissionsJson = json['permissions'] ?? json['user_permission'];
    final rawStats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : <String, dynamic>{
            'members': json['members'],
            'orders': json['orders'],
            'my_purchases': json['my_purchases'],
            'offers': json['offers'],
            'customers': json['customers'],
            'systems': json['systems'],
            'contacts': json['contacts'],
            'financial_transactions': json['financial_transactions'],
            'delivery_options': json['delivery_options'],
            'expenses': json['expenses'],
            'products': json['products'],
          };

    return Company(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      type: json['type']?.toString(),
      typeName: json['type_name']?.toString(),
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      allowsB2B: json['allows_b2b'] ?? false,
      allowsB2C: json['allows_b2c'] ?? false,
      status: json['status']?.toString() ?? 'active',
      tier: json['tier']?.toString(),
      logo: json['logo']?.toString(),
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      currency: json['currency'] is Map<String, dynamic>
          ? CompanyCurrency.fromJson(json['currency'])
          : null,
      categories: (json['categories'] as List? ?? const []).map((item) {
        if (item is Map<String, dynamic>) {
          return CompanyCategory.fromJson(item);
        }
        return CompanyCategory(id: 0, name: item?.toString() ?? '');
      }).toList(),
      subscriptionPlan: json['subscription_plan'],
      subscriptionIsValid: json['subscription_is_valid'] as bool?,
      expireDate: json['expire_date'] != null
          ? DateTime.tryParse(json['expire_date'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      companyType: json['company_type'] is Map<String, dynamic>
          ? CompanyType.fromJson(json['company_type'])
          : null,
      contacts: (json['contacts'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CompanyContact.fromJson)
          .toList(),
      deliveryOptions: (json['delivery_options'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CompanyDeliveryOption.fromJson)
          .toList(),
      publicServices: (json['public_services'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                CompanyPublicService.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      serviceTypes: (json['service_types'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => ServiceType.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      services: (json['services'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => CompanyService.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      memberRole: json['member_role']?.toString(),
      permissions: permissionsJson is Map<String, dynamic>
          ? CompanyPermissions.fromJson(permissionsJson)
          : null,
      stats: CompanyStats.fromJson(rawStats),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'type_name': typeName,
      'description': description,
      'address': address,
      'phone': phone,
      'allows_b2b': allowsB2B,
      'allows_b2c': allowsB2C,
      'status': status,
      'tier': tier,
      'logo': logo,
      'city': city?.toJson(),
      'currency': currency?.toJson(),
      'categories': categories.map((category) => category.toJson()).toList(),
      'subscription_plan': subscriptionPlan,
      'subscription_is_valid': subscriptionIsValid,
      'expire_date': expireDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'company_type': companyType?.toJson(),
      'contacts': contacts.map((contact) => contact.toJson()).toList(),
      'delivery_options': deliveryOptions
          .map((option) => option.toJson())
          .toList(),
      'public_services': publicServices
          .map((service) => service.toJson())
          .toList(),
      'service_types': serviceTypes.map((type) => type.toJson()).toList(),
      'services': services.map((service) => service.toJson()).toList(),
      'member_role': memberRole,
      'permissions': permissions?.toJson(),
      'stats': stats?.toJson(),
    };
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isSuspended => status.toLowerCase() == 'suspended';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isPendingActivation => isPending;
  bool get requiresSubscriptionRenewal =>
      isActive && subscriptionIsValid != true;
  bool get canContactAdminForActivation => !isActive && !isPendingActivation;
  bool get hasActivationReminderRole {
    final role = memberRole?.toLowerCase();
    return role == 'admin' || role == 'manager';
  }

  bool get isOlderThan24HoursForReminder {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inHours >= 24;
  }

  bool get canSendActivationReminderNow =>
      isPendingActivation &&
      hasActivationReminderRole &&
      isOlderThan24HoursForReminder;
  bool get requiresActivationAttention =>
      !isActive || subscriptionIsValid != true;
  bool get canManageWorkspace => isActive && subscriptionIsValid == true;
  String? get currencyLabel => currency?.name ?? currency?.code;
  List<String> get categoryNames =>
      categories.map((category) => category.name).toList();
  String? get typeLabel => companyType?.name ?? companyType?.code;
  String? get createdAtDateOnly => createdAt == null
      ? null
      : '${createdAt!.year.toString().padLeft(4, '0')}-${createdAt!.month.toString().padLeft(2, '0')}-${createdAt!.day.toString().padLeft(2, '0')}';
  int get members => stats?.members ?? 0;
  int get orders => stats?.orders ?? 0;
  int get myPurchases => stats?.myPurchases ?? 0;
  int get offers => stats?.offers ?? 0;
  int get customers => stats?.customers ?? 0;
  int get systems => stats?.systems ?? 0;
  int get contactsCount => stats?.contacts ?? 0;
  int get financialTransactions => stats?.financialTransactions ?? 0;
  int get deliveryOptionsCount => stats?.deliveryOptions ?? 0;
  int get expenses => stats?.expenses ?? 0;
  int get products => stats?.products ?? 0;
  Map<String, String> get permissionsMap => permissions?.toMap() ?? const {};
  String? permissionValue(String key) => permissions?[key];

  Company copyWith({
    int? id,
    String? name,
    String? type,
    String? typeName,
    String? description,
    String? address,
    String? phone,
    bool? allowsB2B,
    bool? allowsB2C,
    String? status,
    String? tier,
    String? logo,
    City? city,
    CompanyCurrency? currency,
    List<CompanyCategory>? categories,
    int? subscriptionPlan,
    bool? subscriptionIsValid,
    DateTime? expireDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    CompanyType? companyType,
    List<CompanyContact>? contacts,
    List<CompanyDeliveryOption>? deliveryOptions,
    List<CompanyPublicService>? publicServices,
    List<ServiceType>? serviceTypes,
    List<CompanyService>? services,
    String? memberRole,
    CompanyPermissions? permissions,
    CompanyStats? stats,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      typeName: typeName ?? this.typeName,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      allowsB2B: allowsB2B ?? this.allowsB2B,
      allowsB2C: allowsB2C ?? this.allowsB2C,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      logo: logo ?? this.logo,
      city: city ?? this.city,
      currency: currency ?? this.currency,
      categories: categories ?? this.categories,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionIsValid: subscriptionIsValid ?? this.subscriptionIsValid,
      expireDate: expireDate ?? this.expireDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      companyType: companyType ?? this.companyType,
      contacts: contacts ?? this.contacts,
      deliveryOptions: deliveryOptions ?? this.deliveryOptions,
      publicServices: publicServices ?? this.publicServices,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      services: services ?? this.services,
      memberRole: memberRole ?? this.memberRole,
      permissions: permissions ?? this.permissions,
      stats: stats ?? this.stats,
    );
  }
}
