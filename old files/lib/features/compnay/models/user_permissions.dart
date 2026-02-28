class UserPermissions {
  final String financials;
  final String operations;
  final String sales;
  final String delivery;
  final String systems;
  final String members;
  final String contacts;

  UserPermissions({
    required this.financials,
    required this.operations,
    required this.sales,
    required this.delivery,
    required this.systems,
    required this.members,
    required this.contacts,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      financials: json['financials'],
      operations: json['operations'],
      sales: json['sales'],
      delivery: json['delivery'],
      systems: json['systems'],
      members: json['members'],
      contacts: json['contacts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'financials': financials,
      'operations': operations,
      'sales': sales,
      'delivery': delivery,
      'systems': systems,
      'members': members,
      'contacts': contacts,
    };
  }

  bool canEdit(String permission) {
    return toJson()[permission] == 'write';
  }

  bool canRead(String permission) {
    return toJson()[permission] == 'read';
  }
}
