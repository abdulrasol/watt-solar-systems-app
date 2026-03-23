import 'package:solar_hub/src/features/company_dashboard/domain/entites/dashboard.dart';

class DashboardModel extends Dashboard {
  DashboardModel({
    required super.categories,
    required super.members,
    required super.contacts,
    required super.financialTransactions,
    required super.deliveryOptions,
    required super.expenses,
    required super.products,
    required super.orders,
    required super.myPurchases,
    required super.offers,
    required super.customers,
    required super.systems,
    super.subscriptionPlan,
    super.expireDate,
    super.createdAt,
    super.updatedAt,
    super.role,
    required super.permissions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      categories: json['categories'] != null ? List<dynamic>.from(json['categories']) : [],
      members: json['members'] ?? 0,
      contacts: json['contacts'] ?? 0,
      financialTransactions: json['financial_transactions'] ?? 0,
      deliveryOptions: json['delivery_options'] ?? 0,
      expenses: json['expenses'] ?? 0,
      products: json['products'] ?? 0,
      orders: json['orders'] ?? 0,
      myPurchases: json['my_purchases'] ?? 0,
      offers: json['offers'] ?? 0,
      customers: json['customers'] ?? 0,
      systems: json['systems'] ?? 0,
      subscriptionPlan: json['subscription_plan'],
      expireDate: json['expire_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      role: json['role'],
      permissions: json['permissions'] != null ? Map<String, String>.from(json['permissions']) : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'members': members,
      'contacts': contacts,
      'financial_transactions': financialTransactions,
      'delivery_options': deliveryOptions,
      'expenses': expenses,
      'products': products,
      'subscription_plan': subscriptionPlan,
      'expire_date': expireDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'role': role,
      'permissions': permissions,
    };
  }
}
