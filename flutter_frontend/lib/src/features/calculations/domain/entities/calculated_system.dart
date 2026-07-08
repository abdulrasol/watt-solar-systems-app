import 'package:solar_hub/src/features/calculations/domain/entities/appliance_entity.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/utils/app_enums.dart';

class CalculatedSystem {
  final String id;
  final String title;
  final DateTime date;

  // Appliance List
  final List<ApplianceEntity> appliances;

  // Specs
  final double dailyUsageKWh;
  final int recommendedPanels;
  final double totalPanelCapacityKw;
  final String totalBatteryCapacityAh;
  final double recommendedInverterSize;
  final int recommendedBatteries;
  final int recommendedControllerSize;
  final double peakLoadW;
  final double acSystemVoltage;
  final double acLoadCurrent;
  final double systemCalcSingleBatteryVoltage;
  final double batteryUnitCapacityAh;
  final double pvDerating;
  final double inverterSafetyFactor;
  final BatteryType systemBatteryType;
  final int batterySeriesCount;
  final int batteryParallelCount;
  final double requiredBatteryAh;
  final double requiredBatteryKWh;
  final double practicalBatteryNeedKWh;
  final double effectiveBatteryNeedWh;
  final double averageLoadW;
  final double gridCoverageFactor;
  final double gridCycleHours;
  final SystemCalculationMode calculationMode;
  final SystemLoadInputUnit loadInputUnit;
  final double directAcLoadInput;
  final double gridOnHours;
  final double gridOffHours;
  final double rechargePercentage;
  final double batteryReservePercent;

  // Preferences
  final double autonomyHours;
  final double sunPeakHours;
  final double systemVoltage;

  CalculatedSystem({
    required this.id,
    required this.title,
    required this.date,
    required this.appliances,
    required this.dailyUsageKWh,
    required this.recommendedPanels,
    required this.totalPanelCapacityKw,
    required this.totalBatteryCapacityAh,
    required this.recommendedInverterSize,
    required this.recommendedBatteries,
    required this.recommendedControllerSize,
    required this.peakLoadW,
    required this.acSystemVoltage,
    required this.acLoadCurrent,
    required this.systemCalcSingleBatteryVoltage,
    required this.batteryUnitCapacityAh,
    required this.pvDerating,
    required this.inverterSafetyFactor,
    required this.systemBatteryType,
    required this.batterySeriesCount,
    required this.batteryParallelCount,
    required this.requiredBatteryAh,
    required this.requiredBatteryKWh,
    required this.practicalBatteryNeedKWh,
    required this.effectiveBatteryNeedWh,
    required this.averageLoadW,
    required this.gridCoverageFactor,
    required this.gridCycleHours,
    required this.calculationMode,
    required this.loadInputUnit,
    required this.directAcLoadInput,
    required this.gridOnHours,
    required this.gridOffHours,
    required this.rechargePercentage,
    required this.batteryReservePercent,
    required this.autonomyHours,
    required this.sunPeakHours,
    required this.systemVoltage,
  });

  factory CalculatedSystem.fromCalculator(
    String id,
    String title,
    CalculatorNotifier calc,
  ) {
    return CalculatedSystem(
      id: id,
      title: title,
      date: DateTime.now(),
      appliances: List.from(calc.appliances),
      dailyUsageKWh: calc.dailyUsageKWh,
      recommendedPanels: calc.recommendedPanels,
      totalPanelCapacityKw: calc.totalPanelCapacityKw,
      totalBatteryCapacityAh: calc.totalBatteryCapacityAh,
      recommendedInverterSize: calc.recommendedInverterSize,
      recommendedBatteries: calc.recommendedBatteries,
      recommendedControllerSize: calc.recommendedControllerSize,
      peakLoadW: calc.peakLoadW,
      acSystemVoltage: calc.acSystemVoltage,
      acLoadCurrent: calc.acLoadCurrent,
      systemCalcSingleBatteryVoltage: calc.systemCalcSingleBatteryVoltage,
      batteryUnitCapacityAh: calc.batteryUnitCapacityAh,
      pvDerating: calc.pvDerating,
      inverterSafetyFactor: calc.inverterSafetyFactor,
      systemBatteryType: calc.systemBatteryType,
      batterySeriesCount: calc.batterySeriesCount,
      batteryParallelCount: calc.batteryParallelCount,
      requiredBatteryAh: calc.requiredBatteryAh,
      requiredBatteryKWh: calc.requiredBatteryKWh,
      practicalBatteryNeedKWh: calc.practicalBatteryNeedKWh,
      effectiveBatteryNeedWh: calc.effectiveBatteryNeedWh,
      averageLoadW: calc.averageLoadW,
      gridCoverageFactor: calc.gridCoverageFactor,
      gridCycleHours: calc.gridCycleHours,
      calculationMode: calc.calculationMode,
      loadInputUnit: calc.loadInputUnit,
      directAcLoadInput: calc.directAcLoadInput,
      gridOnHours: calc.gridOnHours,
      gridOffHours: calc.gridOffHours,
      rechargePercentage: calc.rechargePercentage,
      batteryReservePercent: calc.batteryReservePercent,
      autonomyHours: calc.autonomyHours,
      sunPeakHours: calc.sunPeakHours,
      systemVoltage: calc.systemVoltage,
    );
  }

  void loadIntoCalculator(CalculatorNotifier calc) {
    calc.appliances = List.from(appliances);
    calc.dailyUsageKWh = dailyUsageKWh;
    calc.recommendedPanels = recommendedPanels;
    calc.totalPanelCapacityKw = totalPanelCapacityKw;
    calc.totalBatteryCapacityAh = totalBatteryCapacityAh;
    calc.recommendedInverterSize = recommendedInverterSize;
    calc.recommendedBatteries = recommendedBatteries;
    calc.recommendedControllerSize = recommendedControllerSize;
    calc.peakLoadW = peakLoadW;
    calc.acSystemVoltage = acSystemVoltage;
    calc.acLoadCurrent = acLoadCurrent;
    calc.systemCalcSingleBatteryVoltage = systemCalcSingleBatteryVoltage;
    calc.batteryUnitCapacityAh = batteryUnitCapacityAh;
    calc.pvDerating = pvDerating;
    calc.inverterSafetyFactor = inverterSafetyFactor;
    calc.systemBatteryType = systemBatteryType;
    calc.batterySeriesCount = batterySeriesCount;
    calc.batteryParallelCount = batteryParallelCount;
    calc.requiredBatteryAh = requiredBatteryAh;
    calc.requiredBatteryKWh = requiredBatteryKWh;
    calc.practicalBatteryNeedKWh = practicalBatteryNeedKWh;
    calc.effectiveBatteryNeedWh = effectiveBatteryNeedWh;
    calc.averageLoadW = averageLoadW;
    calc.gridCoverageFactor = gridCoverageFactor;
    calc.gridCycleHours = gridCycleHours;
    calc.calculationMode = calculationMode;
    calc.loadInputUnit = loadInputUnit;
    calc.directAcLoadInput = directAcLoadInput;
    calc.gridOnHours = gridOnHours;
    calc.gridOffHours = gridOffHours;
    calc.rechargePercentage = rechargePercentage;
    calc.batteryReservePercent = batteryReservePercent;
    calc.autonomyHours = autonomyHours;
    calc.sunPeakHours = sunPeakHours;
    calc.systemVoltage = systemVoltage;

    // Also notify listeners after setting state
    calc.updateField(() {});
  }

  factory CalculatedSystem.fromJson(Map<String, dynamic> json) {
    return CalculatedSystem(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      appliances: (json['appliances'] as List)
          .map((e) => ApplianceEntity.fromJson(e))
          .toList(),
      dailyUsageKWh: json['dailyUsageKWh']?.toDouble() ?? 0.0,
      recommendedPanels: json['recommendedPanels'] ?? 0,
      totalPanelCapacityKw: json['totalPanelCapacityKw']?.toDouble() ?? 0.0,
      totalBatteryCapacityAh: json['totalBatteryCapacityAh'] ?? '',
      recommendedInverterSize:
          json['recommendedInverterSize']?.toDouble() ?? 0.0,
      recommendedBatteries: json['recommendedBatteries'] ?? 0,
      recommendedControllerSize: json['recommendedControllerSize'] ?? 0,
      peakLoadW: json['peakLoadW']?.toDouble() ?? 0.0,
      acSystemVoltage: json['acSystemVoltage']?.toDouble() ?? 230.0,
      acLoadCurrent: json['acLoadCurrent']?.toDouble() ?? 0.0,
      systemCalcSingleBatteryVoltage:
          json['systemCalcSingleBatteryVoltage']?.toDouble() ?? 12.0,
      batteryUnitCapacityAh: json['batteryUnitCapacityAh']?.toDouble() ?? 200.0,
      pvDerating: json['pvDerating']?.toDouble() ?? 0.78,
      inverterSafetyFactor: json['inverterSafetyFactor']?.toDouble() ?? 1.3,
      systemBatteryType: BatteryType.values.firstWhere(
        (value) => value.name == json['systemBatteryType'],
        orElse: () => BatteryType.lithium,
      ),
      batterySeriesCount: json['batterySeriesCount'] ?? 0,
      batteryParallelCount: json['batteryParallelCount'] ?? 0,
      requiredBatteryAh: json['requiredBatteryAh']?.toDouble() ?? 0.0,
      requiredBatteryKWh: json['requiredBatteryKWh']?.toDouble() ?? 0.0,
      practicalBatteryNeedKWh:
          json['practicalBatteryNeedKWh']?.toDouble() ?? 0.0,
      effectiveBatteryNeedWh: json['effectiveBatteryNeedWh']?.toDouble() ?? 0.0,
      averageLoadW: json['averageLoadW']?.toDouble() ?? 0.0,
      gridCoverageFactor: json['gridCoverageFactor']?.toDouble() ?? 1.0,
      gridCycleHours: json['gridCycleHours']?.toDouble() ?? 0.0,
      calculationMode: SystemCalculationMode.values.firstWhere(
        (value) => value.name == json['calculationMode'],
        orElse: () => SystemCalculationMode.fullEnergy,
      ),
      loadInputUnit: SystemLoadInputUnit.values.firstWhere(
        (value) => value.name == json['loadInputUnit'],
        orElse: () => SystemLoadInputUnit.ampere,
      ),
      directAcLoadInput: json['directAcLoadInput']?.toDouble() ?? 10.0,
      gridOnHours: json['gridOnHours']?.toDouble() ?? 2.0,
      gridOffHours: json['gridOffHours']?.toDouble() ?? 4.0,
      rechargePercentage: json['rechargePercentage']?.toDouble() ?? 0.0,
      batteryReservePercent: json['batteryReservePercent']?.toDouble() ?? 20.0,
      autonomyHours: json['autonomyHours']?.toDouble() ?? 4.0,
      sunPeakHours: json['sunPeakHours']?.toDouble() ?? 5.0,
      systemVoltage: json['systemVoltage']?.toDouble() ?? 12.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'appliances': appliances.map((e) => e.toJson()).toList(),
      'dailyUsageKWh': dailyUsageKWh,
      'recommendedPanels': recommendedPanels,
      'totalPanelCapacityKw': totalPanelCapacityKw,
      'totalBatteryCapacityAh': totalBatteryCapacityAh,
      'recommendedInverterSize': recommendedInverterSize,
      'recommendedBatteries': recommendedBatteries,
      'recommendedControllerSize': recommendedControllerSize,
      'peakLoadW': peakLoadW,
      'acSystemVoltage': acSystemVoltage,
      'acLoadCurrent': acLoadCurrent,
      'systemCalcSingleBatteryVoltage': systemCalcSingleBatteryVoltage,
      'batteryUnitCapacityAh': batteryUnitCapacityAh,
      'pvDerating': pvDerating,
      'inverterSafetyFactor': inverterSafetyFactor,
      'systemBatteryType': systemBatteryType.name,
      'batterySeriesCount': batterySeriesCount,
      'batteryParallelCount': batteryParallelCount,
      'requiredBatteryAh': requiredBatteryAh,
      'requiredBatteryKWh': requiredBatteryKWh,
      'practicalBatteryNeedKWh': practicalBatteryNeedKWh,
      'effectiveBatteryNeedWh': effectiveBatteryNeedWh,
      'averageLoadW': averageLoadW,
      'gridCoverageFactor': gridCoverageFactor,
      'gridCycleHours': gridCycleHours,
      'calculationMode': calculationMode.name,
      'loadInputUnit': loadInputUnit.name,
      'directAcLoadInput': directAcLoadInput,
      'gridOnHours': gridOnHours,
      'gridOffHours': gridOffHours,
      'rechargePercentage': rechargePercentage,
      'batteryReservePercent': batteryReservePercent,
      'autonomyHours': autonomyHours,
      'sunPeakHours': sunPeakHours,
      'systemVoltage': systemVoltage,
    };
  }
}

List<CalculatedSystem> parseCalculatedSystems(dynamic raw) {
  if (raw is! List) {
    return const [];
  }

  final systems = <CalculatedSystem>[];
  for (final item in raw) {
    if (item is! Map) {
      continue;
    }
    try {
      systems.add(CalculatedSystem.fromJson(Map<String, dynamic>.from(item)));
    } catch (_) {
      continue;
    }
  }
  return systems;
}
