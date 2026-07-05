class DeliveryOptionFormModel {
  const DeliveryOptionFormModel({
    required this.name,
    required this.cost,
    this.estimatedDaysMin,
    this.estimatedDaysMax,
    this.description,
    this.isActive = true,
  });

  final String name;
  final double cost;
  final int? estimatedDaysMin;
  final int? estimatedDaysMax;
  final String? description;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cost': cost,
      'estimated_days_min': estimatedDaysMin,
      'estimated_days_max': estimatedDaysMax,
      'description': description,
      'is_active': isActive,
    };
  }
}
