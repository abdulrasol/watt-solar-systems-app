class DeliveryOptionModel {
  final String? id;
  final String companyId;
  final String name;
  final double cost;
  final int? estimatedDaysMin;
  final int? estimatedDaysMax;
  final String? description;
  final bool isActive;

  DeliveryOptionModel({
    this.id,
    required this.companyId,
    required this.name,
    required this.cost,
    this.estimatedDaysMin,
    this.estimatedDaysMax,
    this.description,
    this.isActive = true,
  });

  factory DeliveryOptionModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOptionModel(
      id: json['id'],
      companyId: json['company_id'],
      name: json['name'],
      cost: (json['cost'] as num).toDouble(),
      estimatedDaysMin: json['estimated_days_min'],
      estimatedDaysMax: json['estimated_days_max'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'company_id': companyId,
      'name': name,
      'cost': cost,
      'estimated_days_min': estimatedDaysMin,
      'estimated_days_max': estimatedDaysMax,
      'description': description,
      'is_active': isActive,
    };
  }
}
