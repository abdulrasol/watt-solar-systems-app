final d = {
  "categories": [],
  "members": 1,
  "orders": 0,
  "my_purchases": 0,
  "offers": 0,
  "customers": 0,
  "contacts": 0,
  "financial_transactions": 0,
  "delivery_options": 0,
  "expenses": 0,
  "products": 0,
  "subscription_plan": null,
  "expire_date": "2026-03-04T07:14:24.910Z",
  "created_at": "2026-02-28T01:37:35.278Z",
  "updated_at": "2026-03-04T07:14:24.910Z",
  "role": "delivery",
  "permissions": {
    "orders": "read",
    "pos": "read",
    "invoices": "read",
    "inventory": "read",
    "offers": "read",
    "sales": "read",
    "delivery": "write",
    "systems": "read",
    "members": "read",
    "contacts": "none",
    "accountant": "none",
    "customers": "read",
    "suppliers": "read",
    "my_sales": "read",
    "analytics": "read",
    "subscribers": "read",
  },
};

class Dashboard {
  final List<dynamic> categories;
  final int orders;
  final int myPurchases;
  final int offers;
  final int customers;
  final int members;
  final int contacts;
  final int financialTransactions;
  final int deliveryOptions;
  final int expenses;
  final int products;
  final int systems;
  final String? subscriptionPlan;
  final String? expireDate;
  final String? createdAt;
  final String? updatedAt;
  final String? role;
  final Map<String, String> permissions;

  Dashboard({
    required this.categories,
    required this.members,
    required this.contacts,
    required this.financialTransactions,
    required this.deliveryOptions,
    required this.expenses,
    required this.products,
    required this.orders,
    required this.myPurchases,
    required this.offers,
    required this.customers,
    required this.systems,
    this.subscriptionPlan,
    this.expireDate,
    this.createdAt,
    this.updatedAt,
    this.role,
    required this.permissions,
  });
}
