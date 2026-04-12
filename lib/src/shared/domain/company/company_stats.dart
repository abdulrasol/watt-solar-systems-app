class CompanyStats {
  final int members;
  final int orders;
  final int myPurchases;
  final int offers;
  final int customers;
  final int systems;
  final int contacts;
  final int financialTransactions;
  final int deliveryOptions;
  final int expenses;
  final int products;

  const CompanyStats({
    this.members = 0,
    this.orders = 0,
    this.myPurchases = 0,
    this.offers = 0,
    this.customers = 0,
    this.systems = 0,
    this.contacts = 0,
    this.financialTransactions = 0,
    this.deliveryOptions = 0,
    this.expenses = 0,
    this.products = 0,
  });

  factory CompanyStats.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

    return CompanyStats(
      members: parseInt(json['members']),
      orders: parseInt(json['orders']),
      myPurchases: parseInt(json['my_purchases']),
      offers: parseInt(json['offers']),
      customers: parseInt(json['customers']),
      systems: parseInt(json['systems']),
      contacts: parseInt(json['contacts']),
      financialTransactions: parseInt(json['financial_transactions']),
      deliveryOptions: parseInt(json['delivery_options']),
      expenses: parseInt(json['expenses']),
      products: parseInt(json['products']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    };
  }

  CompanyStats copyWith({
    int? members,
    int? orders,
    int? myPurchases,
    int? offers,
    int? customers,
    int? systems,
    int? contacts,
    int? financialTransactions,
    int? deliveryOptions,
    int? expenses,
    int? products,
  }) {
    return CompanyStats(
      members: members ?? this.members,
      orders: orders ?? this.orders,
      myPurchases: myPurchases ?? this.myPurchases,
      offers: offers ?? this.offers,
      customers: customers ?? this.customers,
      systems: systems ?? this.systems,
      contacts: contacts ?? this.contacts,
      financialTransactions:
          financialTransactions ?? this.financialTransactions,
      deliveryOptions: deliveryOptions ?? this.deliveryOptions,
      expenses: expenses ?? this.expenses,
      products: products ?? this.products,
    );
  }
}
