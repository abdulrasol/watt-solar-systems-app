import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import '../../domain/entities/solar_request.dart';

class SolarRequestModel extends SolarRequest {
  SolarRequestModel({
    super.id,
    super.cityId,
    super.city,
    super.allCities,
    required super.totalPanelPower,
    required super.panelPower,
    required super.panelCount,
    super.panelNote,
    required super.totalBatteryPower,
    required super.batterySize,
    required super.batteryCount,
    super.batteryNote,
    required super.batteryType,
    required super.totalInvertersPower,
    required super.inverterSize,
    required super.inverterCount,
    super.inverterNote,
    required super.inverterType,
    super.note,
    super.status,
    super.createdAt,
    super.offersCount,
  });

  factory SolarRequestModel.fromJson(Map<String, dynamic> json) {
    return SolarRequestModel(
      id: json['id'],
      cityId: json['city_id'] ?? json['city']?['id'],
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      allCities: json['all_cities'] ?? false,
      totalPanelPower:
          (double.tryParse(json['total_panel_power']?.toString() ?? '') ??
                  ((double.tryParse(json['panel_power']?.toString() ?? '0') ??
                          0) *
                      (double.tryParse(
                            json['panel_count']?.toString() ?? '0',
                          ) ??
                          0)))
              .toInt(),
      panelPower: (double.tryParse(json['panel_power']?.toString() ?? '0') ?? 0)
          .toInt(),
      panelCount: (double.tryParse(json['panel_count']?.toString() ?? '0') ?? 0)
          .toInt(),
      panelNote: json['panel_note'],
      totalBatteryPower:
          (double.tryParse(json['total_battery_power']?.toString() ?? '') ??
                  ((double.tryParse(json['battery_size']?.toString() ?? '0') ??
                          0) *
                      (double.tryParse(
                            json['battery_count']?.toString() ?? '0',
                          ) ??
                          0)))
              .toDouble(),
      batterySize:
          (double.tryParse(json['battery_size']?.toString() ?? '0') ?? 0)
              .toDouble(),
      batteryCount:
          (double.tryParse(json['battery_count']?.toString() ?? '0') ?? 0)
              .toInt(),
      batteryNote: json['battery_note'],
      batteryType: _parseBatteryType(json['battery_type']),
      totalInvertersPower:
          (double.tryParse(json['total_inverters_power']?.toString() ?? '') ??
                  ((double.tryParse(json['inverter_size']?.toString() ?? '0') ??
                          0) *
                      (double.tryParse(
                            json['inverter_count']?.toString() ?? '0',
                          ) ??
                          0)))
              .toDouble(),
      inverterSize:
          (double.tryParse(json['inverter_size']?.toString() ?? '0') ?? 0)
              .toDouble(),
      inverterCount:
          (double.tryParse(json['inverter_count']?.toString() ?? '0') ?? 0)
              .toInt(),
      inverterNote: json['inverter_note'],
      inverterType: _parseInverterType(json['inverter_type']),
      note: json['note'],
      status: _parseRequestStatus(json['status']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      offersCount: int.tryParse(json['offers_count']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city_id': cityId ?? city?.id,
      'all_cities': allCities,
      'total_panel_power': totalPanelPower,
      'panel_power': panelPower,
      'panel_count': panelCount,
      'panel_note': panelNote,
      'total_battery_power': totalBatteryPower,
      'battery_size': batterySize,
      'battery_count': batteryCount,
      'battery_note': batteryNote,
      'battery_type': batteryType.name,
      'total_inverters_power': totalInvertersPower,
      'inverter_size': inverterSize,
      'inverter_count': inverterCount,
      'inverter_note': inverterNote,
      'inverter_type': inverterType.name,
      'note': note,
    };
  }

  static BatteryType _parseBatteryType(String? value) {
    switch (value?.toLowerCase()) {
      case 'gel':
        return BatteryType.gel;
      case 'tubular':
        return BatteryType.tubular;
      case 'lithium':
        return BatteryType.lithium;
      default:
        return BatteryType.lithium;
    }
  }

  static InverterType _parseInverterType(String? value) {
    switch (value?.toLowerCase()) {
      case 'off_grid':
        return InverterType.offGrid;
      case 'on_grid':
        return InverterType.onGrid;
      case 'hybrid':
        return InverterType.hybrid;
      default:
        return InverterType.hybrid;
    }
  }

  static RequestStatus _parseRequestStatus(String? value) {
    switch (value?.toLowerCase()) {
      case 'open':
        return RequestStatus.open;
      case 'closed':
        return RequestStatus.closed;
      case 'fulfilled':
        return RequestStatus.fulfilled;
      default:
        return RequestStatus.open;
    }
  }
}
