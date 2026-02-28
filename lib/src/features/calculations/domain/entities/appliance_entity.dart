class ApplianceEntity {
  String name;
  double power;
  int quantity;
  double hours;

  ApplianceEntity({required this.name, this.power = 0.0, this.quantity = 1, this.hours = 0.0});

  ApplianceEntity copyWith({String? name, double? power, int? quantity, double? hours}) {
    return ApplianceEntity(name: name ?? this.name, power: power ?? this.power, quantity: quantity ?? this.quantity, hours: hours ?? this.hours);
  }
}
