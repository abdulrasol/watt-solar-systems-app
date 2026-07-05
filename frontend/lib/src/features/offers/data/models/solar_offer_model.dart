import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/features/offers/data/models/involve_model.dart';
import 'package:solar_hub/src/features/offers/domain/entities/involve.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import '../../domain/entities/solar_offer.dart';

class SolarOfferModel extends SolarOffer {
  SolarOfferModel({
    super.id,
    super.requestId,
    required super.price,
    super.involves,
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
    required super.company,
    super.createdAt,
  });

  factory SolarOfferModel.fromJson(Map<String, dynamic> json) {
    return SolarOfferModel(
      id: json['id'],
      requestId: json['request_id'] ?? json['offer_request_id'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      involves: (json['involves'] ?? json['offer_involves']) != null
          ? List<Involve>.from(
              (json['involves'] ?? json['offer_involves']).map(
                (x) => InvolveModel.fromJson(x),
              ),
            )
          : [],
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
      status: _parseOfferStatus(json['status']),
      company: json['company'] != null
          ? Company.fromJson(json['company'])
          : Company(
              id: 0,
              name: 'Provider',
              allowsB2B: false,
              allowsB2C: false,
              status: 'unknown',
            ),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'involves': involves?.map((x) => x.toJson()).toList(),
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

  static OfferStatus _parseOfferStatus(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return OfferStatus.pending;
      case 'accepted':
        return OfferStatus.accepted;
      case 'rejected':
        return OfferStatus.rejected;
      case 'completed':
        return OfferStatus.completed;
      default:
        return OfferStatus.pending;
    }
  }
}
