class CompanySubscriptionPlan {
  const CompanySubscriptionPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    this.description,
    this.isActive = false,
    this.createdAt,
  });

  final int id;
  final String name;
  final int durationDays;
  final num price;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  factory CompanySubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return CompanySubscriptionPlan(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      durationDays: int.tryParse(json['duration_days']?.toString() ?? '') ?? 0,
      price: num.tryParse(json['price']?.toString() ?? '') ?? 0,
      description: json['description']?.toString(),
      isActive: json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
