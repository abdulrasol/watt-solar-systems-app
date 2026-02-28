class SubscriptionPlanModel {
  final String id;
  final String name;
  final int durationDays;
  final double price;
  final String? description;

  SubscriptionPlanModel({required this.id, required this.name, required this.durationDays, required this.price, this.description});

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'],
      name: json['name'],
      durationDays: json['duration_days'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
    );
  }
}

class CompanySubscriptionModel {
  final String id;
  final String companyId;
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  CompanySubscriptionModel({
    required this.id,
    required this.companyId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory CompanySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return CompanySubscriptionModel(
      id: json['id'],
      companyId: json['company_id'],
      planId: json['plan_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'],
    );
  }

  bool get isValid => status == 'active' && endDate.isAfter(DateTime.now());
}
