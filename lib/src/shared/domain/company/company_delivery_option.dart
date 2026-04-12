class CompanyDeliveryOption {
  final int id;
  final String name;
  final num? cost;
  final int? estimatedDaysMin;
  final int? estimatedDaysMax;
  final String? description;
  final bool isActive;
  final int? company;
  final DateTime? createdAt;

  const CompanyDeliveryOption({
    required this.id,
    required this.name,
    this.cost,
    this.estimatedDaysMin,
    this.estimatedDaysMax,
    this.description,
    required this.isActive,
    this.company,
    this.createdAt,
  });

  factory CompanyDeliveryOption.fromJson(Map<String, dynamic> json) {
    return CompanyDeliveryOption(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      cost: json['cost'] as num?,
      estimatedDaysMin: int.tryParse(
        json['estimated_days_min']?.toString() ?? '',
      ),
      estimatedDaysMax: int.tryParse(
        json['estimated_days_max']?.toString() ?? '',
      ),
      description: json['description']?.toString(),
      isActive: json['is_active'] == true,
      company: int.tryParse(json['company']?.toString() ?? ''),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
      'estimated_days_min': estimatedDaysMin,
      'estimated_days_max': estimatedDaysMax,
      'description': description,
      'is_active': isActive,
      'company': company,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  CompanyDeliveryOption copyWith({
    int? id,
    String? name,
    num? cost,
    int? estimatedDaysMin,
    int? estimatedDaysMax,
    String? description,
    bool? isActive,
    int? company,
    DateTime? createdAt,
  }) {
    return CompanyDeliveryOption(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      estimatedDaysMin: estimatedDaysMin ?? this.estimatedDaysMin,
      estimatedDaysMax: estimatedDaysMax ?? this.estimatedDaysMax,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      company: company ?? this.company,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
