import 'package:solar_hub/src/features/auth/domain/entities/city.dart';

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
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      address: json['address'],
      allowsB2B: json['allows_b2b'],
      allowsB2C: json['allows_b2c'],
      status: json['status'],
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
    };
  }
}
