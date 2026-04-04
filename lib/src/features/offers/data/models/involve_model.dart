import 'package:solar_hub/src/features/offers/domain/entities/involve.dart';

class InvolveModel extends Involve {
  InvolveModel({
    required super.id,
    required super.name,
    super.isActive,
    required super.quantity,
    required super.cost,
    required super.totalCost,
  });

  factory InvolveModel.fromJson(Map<String, dynamic> json) {
    return InvolveModel(
      id: json['id'],
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? true,
      quantity:
          (double.tryParse(json['quantity']?.toString() ?? '0') ?? 0).toInt() ==
              0
          ? null
          : (double.tryParse(json['quantity']?.toString() ?? '0') ?? 0).toInt(),
      cost: double.tryParse(json['cost']?.toString() ?? '0') ?? 0.0,
      totalCost: json['total_cost'] == null
          ? null
          : double.tryParse(json['total_cost']?.toString() ?? '0') ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
      'quantity': quantity,
      'cost': cost,
      'total_cost': totalCost,
    };
  }
}
