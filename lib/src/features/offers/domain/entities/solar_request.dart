import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/utils/app_enums.dart';

class SolarRequest {
  final int? id;
  final int? cityId;
  final City? city;
  final bool allCities;
  final int totalPanelPower;
  final int panelPower;
  final int panelCount;
  final String? panelNote;
  final double totalBatteryPower;
  final double batterySize;
  final int batteryCount;
  final String? batteryNote;
  final BatteryType batteryType;
  final double totalInvertersPower;
  final double inverterSize;
  final int inverterCount;
  final String? inverterNote;
  final InverterType inverterType;
  final String? note;
  final RequestStatus status;
  final DateTime? createdAt;
  final int? offersCount;

  SolarRequest({
    this.id,
    this.cityId,
    this.city,
    this.allCities = false,
    required this.totalPanelPower,
    required this.panelPower,
    required this.panelCount,
    this.panelNote,
    required this.totalBatteryPower,
    required this.batterySize,
    required this.batteryCount,
    this.batteryNote,
    required this.batteryType,
    required this.totalInvertersPower,
    required this.inverterSize,
    required this.inverterCount,
    this.inverterNote,
    required this.inverterType,
    this.note,
    this.status = RequestStatus.open,
    this.createdAt,
    this.offersCount,
  });

  // Helper to calculate total power if not provided
  static int calculateTotalPower(int count, int unitSize) => count * unitSize;
}
