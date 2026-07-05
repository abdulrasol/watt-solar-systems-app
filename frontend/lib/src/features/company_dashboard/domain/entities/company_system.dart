import 'package:solar_hub/src/core/utils/date_parser.dart';
/// A solar system installed by this company for a customer, as returned by
/// `GET /companies/{id}/systems` — read-only from the company dashboard
/// (systems are created via the customer-facing `/systems/` self-service
/// endpoints, not by the installing company).
class CompanySystem {
  final int id;
  final int? userId;
  final int? orderId;
  final int panelPower;
  final int panelCount;
  final double batteryPower;
  final int batteryCount;
  final int inverterPower;
  final int inverterCount;
  final String systemType;
  final String? address;
  final String? city;
  final String? country;
  final DateTime? installedAt;
  final DateTime? createdAt;

  const CompanySystem({
    required this.id,
    this.userId,
    this.orderId,
    required this.panelPower,
    required this.panelCount,
    required this.batteryPower,
    required this.batteryCount,
    required this.inverterPower,
    required this.inverterCount,
    required this.systemType,
    this.address,
    this.city,
    this.country,
    this.installedAt,
    this.createdAt,
  });

  double get totalPanelKw => (panelPower * panelCount) / 1000.0;

  factory CompanySystem.fromJson(Map<String, dynamic> json) {
    return CompanySystem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? ''),
      orderId: int.tryParse(json['order_id']?.toString() ?? ''),
      panelPower: int.tryParse(json['panel_power']?.toString() ?? '') ?? 0,
      panelCount: int.tryParse(json['panel_count']?.toString() ?? '') ?? 0,
      batteryPower: (json['battery_power'] as num?)?.toDouble() ?? 0,
      batteryCount: int.tryParse(json['battery_count']?.toString() ?? '') ?? 0,
      inverterPower: int.tryParse(json['inverter_power']?.toString() ?? '') ?? 0,
      inverterCount: int.tryParse(json['inverter_count']?.toString() ?? '') ?? 0,
      systemType: json['system_type']?.toString() ?? '',
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      installedAt: json['installed_at'] != null ? safeParseDate(json['installed_at']) : null,
      createdAt: json['created_at'] != null ? safeParseDate(json['created_at']) : null,
    );
  }
}
