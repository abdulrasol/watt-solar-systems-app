import 'dart:math' as math;

import 'package:flutter_riverpod/legacy.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/appliance_entity.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/calculated_system.dart';
import 'package:solar_hub/src/utils/app_enums.dart';

// Given the high number of fields, using a ChangeNotifier for this specific controller
// is more practical than creating a massive immutable state class.
import 'package:flutter/material.dart';

final calculatorProvider = ChangeNotifierProvider<CalculatorNotifier>((ref) {
  return CalculatorNotifier();
});

enum SystemCalculationMode { practicalHybrid, fullEnergy }

enum SystemLoadInputUnit { ampere, watt }

class CalculatorNotifier extends ChangeNotifier {
  // System Wizard State
  String? currentSystemId;

  List<ApplianceEntity> appliances = [
    ApplianceEntity(name: 'Refrigerator', power: 230, quantity: 1, hours: 24),
    ApplianceEntity(name: 'Lamps & Fans', power: 240, quantity: 1, hours: 24),
    ApplianceEntity(name: 'Washing Machine', power: 240, quantity: 1, hours: 2),
    ApplianceEntity(
      name: 'TV / Laptop / Mobile',
      power: 200,
      quantity: 1,
      hours: 5,
    ),
  ];

  double autonomyHours = 4.0;
  double sunPeakHours = 5.0;
  double systemVoltage = 12.0;
  int recommendedPanels = 570;
  double recommendedInverterSize = 5.0;
  int recommendedBatteries = 0;
  int recommendedControllerSize = 0;
  double systemCalcSingleBatteryVoltage = 12.0;

  // New Result Observables
  double totalPanelCapacityKw = 0.0;
  String totalBatteryCapacityAh = "";
  double dailyUsageKWh = 0.0;
  double dailyUsageWh = 0.0;
  double peakLoadW = 0.0;
  double acLoadCurrent = 0.0;
  double requiredPvWatts = 0.0;
  double requiredBatteryAh = 0.0;
  double requiredBatteryKWh = 0.0;
  double totalBatteryStorageKWh = 0.0;
  int batterySeriesCount = 0;
  int batteryParallelCount = 0;
  double usableDepthOfDischarge = 0.0;
  double inverterEfficiency = 0.92;
  double gridCoverageFactor = 1.0;
  double practicalBatteryNeedKWh = 0.0;
  double effectiveBatteryNeedWh = 0.0;
  double averageLoadW = 0.0;
  double gridCycleHours = 0.0;
  double batteryReservePercent = 20.0;

  // Global Settings for Tools
  double acSystemVoltage = 230.0;
  double batteryUnitCapacityAh = 200.0;
  double pvDerating = 0.78;
  double inverterSafetyFactor = 1.30;
  BatteryType systemBatteryType = BatteryType.lithium;
  SystemCalculationMode calculationMode = SystemCalculationMode.fullEnergy;
  SystemLoadInputUnit loadInputUnit = SystemLoadInputUnit.ampere;
  double directAcLoadInput = 10.0;
  double gridOnHours = 2.0;
  double gridOffHours = 4.0;
  double rechargePercentage = 0.0;

  // Lists
  final List<double> acVoltageOptions = [110, 230, 380];
  final List<double> systemVoltageOptions = [12, 24, 48];
  final List<double> batteryVoltageOptions = [2, 6, 12, 12.8, 25.6, 51.2];

  // Request Wizard State
  int selectedPanelWattage = 570;
  int panelCount = 0;
  double selectedBatteryVoltage = 51.2;
  double selectedBatteryAmp = 200.0;
  int batteryCount = 0;
  double selectedInverterKva = 5.0;
  int inverterCount = 0;
  String requestNotes = '';
  String installationType = 'Roof';
  String selectedInverterType = 'Hybrid';
  String selectedBatteryType = 'Lithium';

  // New Inverter Options
  String selectedInverterPhase = 'Single Phase';
  String selectedInverterVoltType = 'Low Voltage';

  // Section Notes
  String panelNote = '';
  String inverterNote = '';
  String batteryNote = '';

  // Single Calculations State
  double panelCalcDailyUsage = 0.0;
  double panelCalcWattage = 450.0;
  double panelCalcEfficiency = 0.75;
  double panelCalcVoltage = 12.0;
  int panelCalcResult = 0;
  double panelCalcTotalWattage = 0.0;

  // Inverter
  double inverterCalcAmps = 0.0;
  double inverterCalcTotalLoad = 0.0;
  double inverterCalcSafetyFactor = 1.25;
  double inverterCalcResult = 0.0;

  // Battery
  double batteryCalcAmps = 0.0;
  double batteryCalcTotalLoad = 0.0;
  double batteryCalcHours = 0.0;
  double batteryCalcVoltage = 12.0;
  double batteryCalcAmp = 200.0;
  int batteryCalcResult = 0;
  double batteryCalcRuntimeResult = 0.0;
  int batteryCalcCountCount = 1;
  double batteryCalcDoD = 50.0;

  // Wires
  double wireCalcCurrent = 0.0;
  double wireCalcLength = 0.0;
  double wireCalcVoltage = 12.0;
  double wireCalcVoltageDrop = 3.0;
  String wireCalcResult = '';

  String wireCalcType = 'DC Solar';
  String wireCalcMaterial = 'Copper';

  // Pump
  double pumpDailyWater = 0.0;
  double pumpTDH = 0.0;
  double pumpEfficiency = 0.5;
  double pumpDailyHours = 6.0;
  double pumpPeakSunHours = 5.0;
  double pumpSystemEfficiency = 0.85;
  double pumpPanelWattage = 550.0;

  // Pump Results
  double pumpHydraulicPowerW = 0.0;
  double pumpDailyEnergyWh = 0.0;
  double pumpRequiredPanelKw = 0.0;
  int pumpRequiredPanelCount = 0;

  // Orientation
  double orientationLat = 0.0;
  double optimalTilt = 0.0;
  String optimalDirection = "South";
  String pumpResultWait = '';

  void updateField(void Function() update) {
    update();
    notifyListeners();
  }

  void loadCalculation(CalculatedSystem system) {
    currentSystemId = system.id;
    system.loadIntoCalculator(this);
  }

  void addAppliance() {
    appliances.add(
      ApplianceEntity(name: 'New Appliance', power: 100, quantity: 1, hours: 5),
    );
    notifyListeners();
  }

  void removeAppliance(int index) {
    appliances.removeAt(index);
    notifyListeners();
  }

  void updateAppliance(int index, ApplianceEntity updated) {
    appliances[index] = updated;
    notifyListeners();
  }

  void calculateSystem() {
    final panelWattage = selectedPanelWattage > 0
        ? selectedPanelWattage.toDouble()
        : 570.0;
    final safeSunHours = sunPeakHours <= 0 ? 1.0 : sunPeakHours;
    final safePvDerating = pvDerating.clamp(0.55, 0.95);
    final safeInverterFactor = inverterSafetyFactor.clamp(1.05, 1.8);
    final safeBatteryAh = batteryUnitCapacityAh <= 0
        ? 200.0
        : batteryUnitCapacityAh;
    final safeSystemVoltage = systemVoltage <= 0 ? 12.0 : systemVoltage;
    final safeSingleBatteryVoltage = systemCalcSingleBatteryVoltage <= 0
        ? 12.0
        : systemCalcSingleBatteryVoltage;
    final safeRechargeFactor = (1 - (rechargePercentage.clamp(0, 100) / 100));
    final safeGridOnHours = gridOnHours < 0 ? 0.0 : gridOnHours;
    final safeGridOffHours = gridOffHours < 0 ? 0.0 : gridOffHours;

    usableDepthOfDischarge = systemBatteryType == BatteryType.lithium
        ? 0.8
        : 0.5;
    inverterEfficiency = systemBatteryType == BatteryType.lithium ? 0.95 : 0.9;
    gridCycleHours = safeGridOnHours + safeGridOffHours;
    gridCoverageFactor = gridCycleHours <= 0
        ? 1.0
        : (safeGridOffHours / gridCycleHours).clamp(0.0, 1.0);

    dailyUsageWh = 0;
    peakLoadW = 0;
    averageLoadW = 0;
    requiredPvWatts = 0;
    requiredBatteryAh = 0;
    requiredBatteryKWh = 0;
    practicalBatteryNeedKWh = 0;
    effectiveBatteryNeedWh = 0;

    if (calculationMode == SystemCalculationMode.practicalHybrid) {
      peakLoadW = _resolveDirectLoadW();
      averageLoadW = peakLoadW;
      dailyUsageWh = peakLoadW * 24;
      dailyUsageKWh = dailyUsageWh / 1000;

      requiredPvWatts = peakLoadW * safeInverterFactor;
      recommendedPanels = requiredPvWatts <= 0
          ? 0
          : (requiredPvWatts / panelWattage).ceil();
      totalPanelCapacityKw = (recommendedPanels * panelWattage) / 1000;

      recommendedInverterSize = peakLoadW <= 0
          ? 0
          : ((peakLoadW * safeInverterFactor) / 1000).ceilToDouble();

      practicalBatteryNeedKWh = (peakLoadW * safeGridOffHours) / 1000;
      effectiveBatteryNeedWh =
          peakLoadW * safeGridOffHours * safeRechargeFactor;
      requiredBatteryKWh = effectiveBatteryNeedWh / 1000;
      requiredBatteryAh = effectiveBatteryNeedWh <= 0
          ? 0
          : effectiveBatteryNeedWh / safeSystemVoltage;
    } else {
      for (final app in appliances) {
        final itemPower = app.power * app.quantity;
        dailyUsageWh += itemPower * app.hours;
        peakLoadW += itemPower;
      }

      dailyUsageKWh = dailyUsageWh / 1000;
      averageLoadW = dailyUsageWh <= 0 ? 0 : dailyUsageWh / 24;

      final pvEnergyTargetWh = dailyUsageWh * gridCoverageFactor;
      requiredPvWatts = pvEnergyTargetWh <= 0
          ? 0
          : pvEnergyTargetWh / (safeSunHours * safePvDerating);
      recommendedPanels = requiredPvWatts <= 0
          ? 0
          : (requiredPvWatts / panelWattage).ceil();
      totalPanelCapacityKw = (recommendedPanels * panelWattage) / 1000;

      recommendedInverterSize = peakLoadW <= 0
          ? 0
          : ((peakLoadW * safeInverterFactor) / 1000).ceilToDouble();

      final batteryCoverageHours = safeGridOffHours > 0
          ? math.min(
              autonomyHours <= 0 ? safeGridOffHours : autonomyHours,
              safeGridOffHours,
            )
          : autonomyHours;
      final batteryTargetWh = averageLoadW * batteryCoverageHours;
      effectiveBatteryNeedWh = batteryTargetWh * safeRechargeFactor;
      final usableFactor = usableDepthOfDischarge * inverterEfficiency;
      requiredBatteryKWh = effectiveBatteryNeedWh <= 0 || usableFactor <= 0
          ? 0
          : (effectiveBatteryNeedWh / usableFactor) / 1000;
      requiredBatteryAh = requiredBatteryKWh <= 0
          ? 0
          : (requiredBatteryKWh * 1000) / safeSystemVoltage;
    }

    batterySeriesCount = math.max(
      1,
      (safeSystemVoltage / safeSingleBatteryVoltage).ceil(),
    );
    batteryParallelCount = requiredBatteryAh <= 0
        ? 0
        : math.max(1, (requiredBatteryAh / safeBatteryAh).ceil());
    recommendedBatteries = batteryParallelCount == 0
        ? 0
        : batterySeriesCount * batteryParallelCount;

    final totalBankAh = batteryParallelCount * safeBatteryAh;
    totalBatteryStorageKWh = recommendedBatteries == 0
        ? 0
        : (recommendedBatteries * safeSingleBatteryVoltage * safeBatteryAh) /
              1000;
    totalBatteryCapacityAh = recommendedBatteries == 0
        ? "0 Ah"
        : "${totalBankAh.toStringAsFixed(0)}Ah @ ${safeSystemVoltage.toStringAsFixed(0)}V (${batterySeriesCount}S${batteryParallelCount}P)";

    final totalPvWatt = recommendedPanels * panelWattage;
    recommendedControllerSize = totalPvWatt <= 0
        ? 0
        : ((totalPvWatt / safeSystemVoltage) * 1.25).ceil();

    if (peakLoadW <= 0 || acSystemVoltage <= 0) {
      acLoadCurrent = 0;
    } else if (isThreePhase) {
      acLoadCurrent = peakLoadW / (math.sqrt(3) * acSystemVoltage);
    } else {
      acLoadCurrent = peakLoadW / acSystemVoltage;
    }

    prepareRequestFromCalculation(notify: false);

    _saveToCache();

    notifyListeners();
  }

  void _saveToCache() {
    try {
      final cache = getIt<CasheInterface>();
      final existingData = cache.get('saved_calculated_systems');
      List<CalculatedSystem> systems = [];
      if (existingData != null) {
        systems = List<dynamic>.from(existingData)
            .map((e) => CalculatedSystem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (currentSystemId != null) {
        final idx = systems.indexWhere((s) => s.id == currentSystemId);
        if (idx >= 0) {
          systems[idx] = CalculatedSystem.fromCalculator(
            currentSystemId!,
            systems[idx].title,
            this,
          );
        } else {
          systems.add(
            CalculatedSystem.fromCalculator(
              currentSystemId!,
              'System ${DateTime.now().toLocal().toString().substring(0, 16)}',
              this,
            ),
          );
        }
      } else {
        currentSystemId = DateTime.now().millisecondsSinceEpoch.toString();
        systems.add(
          CalculatedSystem.fromCalculator(
            currentSystemId!,
            'System ${DateTime.now().toLocal().toString().substring(0, 16)}',
            this,
          ),
        );
      }

      cache.save(
        'saved_calculated_systems',
        systems.map((e) => e.toJson()).toList(),
      );
    } catch (e) {
      debugPrint('Error saving calculation to cache: $e');
    }
  }

  bool get isThreePhase => acSystemVoltage == 380.0;

  String get systemPhaseLabel => isThreePhase ? 'Three Phase' : 'Single Phase';

  bool get isPracticalHybridMode =>
      calculationMode == SystemCalculationMode.practicalHybrid;

  double get directAcLoadWatts => _resolveDirectLoadW();

  double _resolveDirectLoadW() {
    final safeInput = directAcLoadInput < 0 ? 0.0 : directAcLoadInput;
    if (loadInputUnit == SystemLoadInputUnit.watt) {
      return safeInput;
    }
    return safeInput * acSystemVoltage;
  }

  void prepareRequestFromCalculation({bool notify = true}) {
    panelCount = recommendedPanels;
    inverterCount = 1;
    selectedInverterKva = recommendedInverterSize;
    selectedInverterVoltType = systemVoltage >= 48
        ? 'High Voltage'
        : 'Low Voltage';
    selectedInverterPhase = systemPhaseLabel;

    batteryCount = recommendedBatteries;
    selectedBatteryVoltage = systemCalcSingleBatteryVoltage;
    selectedBatteryAmp = batteryUnitCapacityAh;
    selectedBatteryType = systemBatteryType.label;

    if (notify) {
      notifyListeners();
    }
  }

  // Calculate Pump
  void calculatePump() {
    if (pumpDailyHours == 0) return;
    double hourlyFlow = pumpDailyWater / pumpDailyHours; // m3/h
    double q = hourlyFlow / 3600; // m3/s

    if (pumpEfficiency == 0) pumpEfficiency = 0.5;

    double pWatts = (q * pumpTDH * 9.81 * 1000) / pumpEfficiency;
    pumpHydraulicPowerW = pWatts;

    double energyWh = pWatts * pumpDailyHours;
    pumpDailyEnergyWh = energyWh;

    double reqEnergyWh = energyWh / pumpSystemEfficiency;

    if (pumpPeakSunHours == 0) pumpPeakSunHours = 1;
    double arrayWp = reqEnergyWh / pumpPeakSunHours;
    pumpRequiredPanelKw = arrayWp / 1000;

    if (pumpPanelWattage > 0) {
      pumpRequiredPanelCount = (arrayWp / pumpPanelWattage).ceil();
    } else {
      pumpRequiredPanelCount = 0;
    }
    notifyListeners();
  }

  void calculatePanels() {
    if (panelCalcWattage == 0) return;
    double numer = panelCalcDailyUsage * panelCalcVoltage;
    double result = numer / (panelCalcWattage * panelCalcEfficiency);

    panelCalcResult = result.ceil();
    if (panelCalcResult == 0 && result > 0) panelCalcResult = 1;

    panelCalcTotalWattage = panelCalcResult * panelCalcWattage;
    notifyListeners();
  }

  void calculateInverter() {
    double loadW = inverterCalcAmps * acSystemVoltage;
    inverterCalcTotalLoad = loadW;
    inverterCalcResult = (loadW * inverterCalcSafetyFactor) / 1000;
    notifyListeners();
  }

  void calculateBattery() {
    double loadW = batteryCalcAmps * acSystemVoltage;
    batteryCalcTotalLoad = loadW;

    double totalWh = loadW * batteryCalcHours;
    double requiredWh = totalWh / (batteryCalcDoD / 100.0);
    double requiredBankAh = requiredWh / batteryCalcVoltage;

    batteryCalcResult = (requiredBankAh / batteryCalcAmp).ceil();
    notifyListeners();
  }

  void calculateBatteryRuntime() {
    double totalWh =
        batteryCalcCountCount * batteryCalcAmp * batteryCalcVoltage;
    double availableWh = totalWh * (batteryCalcDoD / 100.0);

    if (batteryCalcTotalLoad > 0) {
      batteryCalcRuntimeResult = availableWh / batteryCalcTotalLoad;
    } else {
      batteryCalcRuntimeResult = 0;
    }
    notifyListeners();
  }

  void calculateWire() {
    double voltage = wireCalcVoltage;
    double allowedDrop = voltage * wireCalcVoltageDrop / 100;
    double area =
        (2 * wireCalcLength * wireCalcCurrent * 0.01724) / allowedDrop;
    if (area < 1.5) {
      wireCalcResult = "1.5 mm²";
    } else if (area < 2.5) {
      wireCalcResult = "2.5 mm²";
    } else if (area < 4) {
      wireCalcResult = "4 mm²";
    } else if (area < 6) {
      wireCalcResult = "6 mm²";
    } else if (area < 10) {
      wireCalcResult = "10 mm²";
    } else if (area < 16) {
      wireCalcResult = "16 mm²";
    } else if (area < 25) {
      wireCalcResult = "25 mm²";
    } else if (area < 35) {
      wireCalcResult = "35 mm²";
    } else if (area < 50) {
      wireCalcResult = "50 mm²";
    } else if (area < 70) {
      wireCalcResult = "70 mm²";
    } else if (area < 95) {
      wireCalcResult = "95 mm²";
    } else if (area < 120) {
      wireCalcResult = "120 mm²";
    } else {
      wireCalcResult = "\${area.toStringAsFixed(1)} mm²";
    }
    notifyListeners();
  }
}
