class CustomerModel {
  final String? id;
  final String companyId;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final double balance;
  final double totalSales;
  final double totalPaid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    this.id,
    required this.companyId,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.address,
    this.balance = 0.0,
    this.totalSales = 0.0,
    this.totalPaid = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      companyId: json['company_id'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'balance': balance,
      'total_sales': totalSales,
      'total_paid': totalPaid,
    };
  }
}
