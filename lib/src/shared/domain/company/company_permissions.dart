class CompanyPermissions {
  final String? orders;
  final String? pos;
  final String? invoices;
  final String? inventory;
  final String? offers;
  final String? sales;
  final String? delivery;
  final String? systems;
  final String? members;
  final String? contacts;
  final String? accountant;
  final String? customers;
  final String? suppliers;
  final String? mySales;
  final String? analytics;
  final String? subscribers;

  const CompanyPermissions({
    this.orders,
    this.pos,
    this.invoices,
    this.inventory,
    this.offers,
    this.sales,
    this.delivery,
    this.systems,
    this.members,
    this.contacts,
    this.accountant,
    this.customers,
    this.suppliers,
    this.mySales,
    this.analytics,
    this.subscribers,
  });

  factory CompanyPermissions.fromJson(Map<String, dynamic> json) {
    return CompanyPermissions(
      orders: json['orders']?.toString(),
      pos: json['pos']?.toString(),
      invoices: json['invoices']?.toString(),
      inventory: json['inventory']?.toString(),
      offers: json['offers']?.toString(),
      sales: json['sales']?.toString(),
      delivery: json['delivery']?.toString(),
      systems: json['systems']?.toString(),
      members: json['members']?.toString(),
      contacts: json['contacts']?.toString(),
      accountant: json['accountant']?.toString(),
      customers: json['customers']?.toString(),
      suppliers: json['suppliers']?.toString(),
      mySales: json['my_sales']?.toString(),
      analytics: json['analytics']?.toString(),
      subscribers: json['subscribers']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders,
      'pos': pos,
      'invoices': invoices,
      'inventory': inventory,
      'offers': offers,
      'sales': sales,
      'delivery': delivery,
      'systems': systems,
      'members': members,
      'contacts': contacts,
      'accountant': accountant,
      'customers': customers,
      'suppliers': suppliers,
      'my_sales': mySales,
      'analytics': analytics,
      'subscribers': subscribers,
    };
  }

  Map<String, String> toMap() {
    final result = <String, String>{};

    void add(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        result[key] = value;
      }
    }

    add('orders', orders);
    add('pos', pos);
    add('invoices', invoices);
    add('inventory', inventory);
    add('offers', offers);
    add('sales', sales);
    add('delivery', delivery);
    add('systems', systems);
    add('members', members);
    add('contacts', contacts);
    add('accountant', accountant);
    add('customers', customers);
    add('suppliers', suppliers);
    add('my_sales', mySales);
    add('analytics', analytics);
    add('subscribers', subscribers);

    return result;
  }

  String? operator [](String key) => toMap()[key];

  CompanyPermissions copyWith({
    String? orders,
    String? pos,
    String? invoices,
    String? inventory,
    String? offers,
    String? sales,
    String? delivery,
    String? systems,
    String? members,
    String? contacts,
    String? accountant,
    String? customers,
    String? suppliers,
    String? mySales,
    String? analytics,
    String? subscribers,
  }) {
    return CompanyPermissions(
      orders: orders ?? this.orders,
      pos: pos ?? this.pos,
      invoices: invoices ?? this.invoices,
      inventory: inventory ?? this.inventory,
      offers: offers ?? this.offers,
      sales: sales ?? this.sales,
      delivery: delivery ?? this.delivery,
      systems: systems ?? this.systems,
      members: members ?? this.members,
      contacts: contacts ?? this.contacts,
      accountant: accountant ?? this.accountant,
      customers: customers ?? this.customers,
      suppliers: suppliers ?? this.suppliers,
      mySales: mySales ?? this.mySales,
      analytics: analytics ?? this.analytics,
      subscribers: subscribers ?? this.subscribers,
    );
  }
}
