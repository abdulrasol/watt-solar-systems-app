class DeliveryOption {
  final int id;
  final String name;
  final double cost;
  final int? estimatedDaysMin;
  final int? estimatedDaysMax;
  final String? description;
  final bool isActive;
  final int? company;
  final DateTime? createdAt;

  const DeliveryOption({
    required this.id,
    required this.name,
    required this.cost,
    this.estimatedDaysMin,
    this.estimatedDaysMax,
    this.description,
    this.isActive = true,
    this.company,
    this.createdAt,
  });

  factory DeliveryOption.fromJson(Map<String, dynamic> json) {
    return DeliveryOption(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      estimatedDaysMin: int.tryParse(json['estimated_days_min']?.toString() ?? ''),
      estimatedDaysMax: int.tryParse(json['estimated_days_max']?.toString() ?? ''),
      description: json['description']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      company: int.tryParse(json['company']?.toString() ?? ''),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

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
