import 'package:solar_hub/models/city.dart';

final company = {
  "id": 4,
  "name": "admin",
  "company_type": "installation",
  "description": "sddf",
  "address": "sdad",
  "allows_b2b": true,
  "allows_b2c": true,
  "status": "active",
  "tier": "premium",
  "logo": null,
  "city": {
    "id": 1,
    "name": "بغداد",
    "country": {"name": "العراق", "code": "IQ"},
    "code": "BGW",
  },
  "currency": null,
  "categories": [],
  "subscription_plan": null,
  "expire_date": "2026-02-23T22:53:48.300Z",
  "created_at": "2026-02-23T22:53:48.299Z",
  "updated_at": "2026-02-23T22:53:48.300Z",
};

class Company {
  final int id;
  final String name;
  final String companyType;
  final String description;
  final String? address;
  final bool allowsB2B;
  final bool allowsB2C;
  final String status;
  final String tier;
  final String? logo;
  final City city;
  // final Currency currency;
  //final List<Category> categories;
  //final SubscriptionPlan subscriptionPlan;
  final String expireDate;
  final String createdAt;
  final String updatedAt;

  Company({
    required this.id,
    required this.name,
    required this.companyType,
    required this.description,
    required this.address,
    required this.allowsB2B,
    required this.allowsB2C,
    required this.status,
    required this.tier,
    required this.logo,
    required this.city,
    // required this.currency,
    // required this.categories,
    // required this.subscriptionPlan,
    required this.expireDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      companyType: json['company_type'],
      description: json['description'],
      address: json['address'],
      allowsB2B: json['allows_b2b'],
      allowsB2C: json['allows_b2c'],
      status: json['status'],
      tier: json['tier'],
      logo: json['logo'],
      city: City.fromJson(json['city']),
      // currency: Currency.fromJson(json['currency']),
      // categories: List<Category>.from(json['categories'].map((x) => Category.fromJson(x))),
      // subscriptionPlan: SubscriptionPlan.fromJson(json['subscription_plan']),
      expireDate: json['expire_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_type': companyType,
      'description': description,
      'address': address,
      'allows_b2b': allowsB2B,
      'allows_b2c': allowsB2C,
      'status': status,
      'tier': tier,
      'logo': logo,
      'city': city.toJson(),
      // 'currency': currency.toJson(),
      // 'categories': List<dynamic>.from(categories.map((x) => x.toJson())),
      // 'subscription_plan': subscriptionPlan.toJson(),
      'expire_date': expireDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
