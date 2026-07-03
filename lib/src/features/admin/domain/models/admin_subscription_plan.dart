class AdminSubscriptionPlan {
  final int id;
  final String name;
  final double price;
  final int durationDays;
  final Map<String, dynamic> features;
  final bool isActive;

  const AdminSubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.features,
    required this.isActive,
  });

  factory AdminSubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return AdminSubscriptionPlan(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      durationDays: json['duration_days'] as int? ?? 0,
      features: json['features'] as Map<String, dynamic>? ?? const {},
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration_days': durationDays,
      'features': features,
      'is_active': isActive,
    };
  }

  AdminSubscriptionPlan copyWith({
    int? id,
    String? name,
    double? price,
    int? durationDays,
    Map<String, dynamic>? features,
    bool? isActive,
  }) {
    return AdminSubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
    );
  }
}
