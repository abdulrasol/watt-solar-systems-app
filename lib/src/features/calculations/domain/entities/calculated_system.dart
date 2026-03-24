import 'package:solar_hub/src/features/calculations/domain/entities/appliance_entity.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';

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
    required this.autonomyHours,
    required this.sunPeakHours,
    required this.systemVoltage,
  });

  factory CalculatedSystem.fromCalculator(String id, String title, CalculatorNotifier calc) {
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
      recommendedInverterSize: json['recommendedInverterSize']?.toDouble() ?? 0.0,
      recommendedBatteries: json['recommendedBatteries'] ?? 0,
      recommendedControllerSize: json['recommendedControllerSize'] ?? 0,
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
      'autonomyHours': autonomyHours,
      'sunPeakHours': sunPeakHours,
      'systemVoltage': systemVoltage,
    };
  }
}
