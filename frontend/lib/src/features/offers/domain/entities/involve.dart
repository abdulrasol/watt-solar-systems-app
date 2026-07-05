class Involve {
  final int id;
  final String name;
  final bool isActive;
  final int? quantity;
  final num cost;
  final num? totalCost;

  Involve({
    required this.id,
    required this.name,
    this.isActive = true,
    this.quantity,
    required this.cost,
    this.totalCost,
  });

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
