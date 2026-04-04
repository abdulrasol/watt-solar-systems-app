import 'package:solar_hub/src/features/company_dashboard/domain/entities/service.dart';

class CompanySummery {
  final List<dynamic> categories;
  final int? members;
  final int? orders;
  final int? myPurchases;
  final int? offers;
  final int? customers;
  final int? systems;
  final int? contacts;
  final int? financialTransactions;
  final int? deliveryOptions;
  final int? expenses;
  final int? products;
  // final SubscriptionPlan? subscriptionPlan;
  final Object? subscriptionPlan;
  final DateTime? expireDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? role;
  final Map<String, String>? permissions;
  final List<CompanyService> services;

  CompanySummery({
    required this.categories,
    required this.members,
    required this.orders,
    required this.myPurchases,
    required this.offers,
    required this.customers,
    required this.systems,
    required this.contacts,
    required this.financialTransactions,
    required this.deliveryOptions,
    required this.expenses,
    required this.products,
    required this.subscriptionPlan,
    required this.expireDate,
    required this.createdAt,
    required this.updatedAt,
    required this.role,
    required this.permissions,
    required this.services,
  });

  factory CompanySummery.fromJson(Map<String, dynamic> json) {
    return CompanySummery(
      categories: json['categories'] ?? [],
      members: json['members'],
      orders: json['orders'],
      myPurchases: json['my_purchases'],
      offers: json['offers'],
      customers: json['customers'],
      systems: json['systems'],
      contacts: json['contacts'],
      financialTransactions: json['financial_transactions'],
      deliveryOptions: json['delivery_options'],
      expenses: json['expenses'],
      products: json['products'],
      subscriptionPlan: json['subscription_plan'],
      expireDate: json['expire_date'] != null
          ? DateTime.tryParse(json['expire_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      role: json['role']?.toString(),
      permissions: json['permissions'] != null
          ? (json['permissions'] as Map).map(
              (k, v) => MapEntry(k.toString(), v.toString()),
            )
          : null,
      services:
          (json['services'] as List?)
              ?.map((x) => CompanyService.fromJson(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'members': members,
      'orders': orders,
      'my_purchases': myPurchases,
      'offers': offers,
      'customers': customers,
      'systems': systems,
      'contacts': contacts,
      'financial_transactions': financialTransactions,
      'delivery_options': deliveryOptions,
      'expenses': expenses,
      'products': products,
      'subscription_plan': subscriptionPlan,
      'expire_date': expireDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'role': role,
      'permissions': permissions,
      'services': services.map((x) => x.toJson()).toList(),
    };
  }
}
