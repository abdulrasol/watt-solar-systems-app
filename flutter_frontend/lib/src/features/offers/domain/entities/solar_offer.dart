import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/features/offers/domain/entities/involve.dart';
import 'package:solar_hub/src/utils/app_enums.dart';

class SolarOffer {
  final int? id;
  final int? requestId;
  final double price;
  final List<Involve>? involves;
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
  final OfferStatus status;
  final Company company;
  final DateTime? createdAt;

  SolarOffer({
    this.id,
    this.requestId,
    required this.price,
    required this.company,
    this.involves,
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
    this.status = OfferStatus.pending,

    this.createdAt,
  });
}
