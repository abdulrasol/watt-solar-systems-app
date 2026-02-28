import 'package:flutter_riverpod/legacy.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/appliance_entity.dart';
import 'package:solar_hub/src/features/calculations/domain/usecases/home_solar_system_calculator.dart';

// Given the high number of fields, using a ChangeNotifier for this specific controller
// is more practical than creating a massive immutable state class.
import 'package:flutter/material.dart';

final calculatorProvider = ChangeNotifierProvider<CalculatorNotifier>((ref) {
  return CalculatorNotifier();
});

class CalculatorNotifier extends ChangeNotifier {
  // System Wizard State
  List<ApplianceEntity> appliances = [
    ApplianceEntity(name: 'Refrigerator', power: 230, quantity: 1, hours: 24),
    ApplianceEntity(name: 'Lamps & Fans', power: 240, quantity: 1, hours: 24),
    ApplianceEntity(name: 'Washing Machine', power: 240, quantity: 1, hours: 2),
    ApplianceEntity(name: 'TV / Laptop / Mobile', power: 200, quantity: 1, hours: 5),
  ];

  double autonomyHours = 12.0;
  double sunPeakHours = 5.0;
  double systemVoltage = 24.0;
  int recommendedPanels = 570;
  double recommendedInverterSize = 0.0;
  int recommendedBatteries = 0;
  int recommendedControllerSize = 0;
  double systemCalcSingleBatteryVoltage = 12.0;

  // New Result Observables
  double totalPanelCapacityKw = 0.0;
  String totalBatteryCapacityAh = "";
  double dailyUsageKWh = 0.0;

  // Global Settings for Tools
  double acSystemVoltage = 230.0;

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

  void addAppliance() {
    appliances.add(ApplianceEntity(name: 'New Appliance', power: 100, quantity: 1, hours: 5));
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
    double totalEnergyWh = 0;
    double maxPowerW = 0;

    for (var app in appliances) {
      totalEnergyWh += app.power * app.quantity * app.hours;
      maxPowerW += app.power * app.quantity;
    }

    dailyUsageKWh = totalEnergyWh / 1000;

    double panelWattage = selectedPanelWattage > 0 ? selectedPanelWattage.toDouble() : 570.0;
    double panelsNeeded = totalEnergyWh / (sunPeakHours * panelWattage * 0.75);
    recommendedPanels = panelsNeeded.ceil();
    totalPanelCapacityKw = (recommendedPanels * panelWattage) / 1000;

    const double batteryCapacityAh = 200.0;
    final battResult = HomeSolarSystemCalculator.calculateBatteryBank(
      dailyUsageKWh: dailyUsageKWh,
      batteryCapacityAh: batteryCapacityAh,
      batteryVoltage: systemVoltage,
      dod: 50.0,
    );

    double totalAhNeeded = battResult['totalAhNeeded'];
    double singleBattVoltage = systemCalcSingleBatteryVoltage;

    int seriesCount = (systemVoltage / singleBattVoltage).ceil();
    int parallelCount = (totalAhNeeded / batteryCapacityAh).ceil();

    recommendedBatteries = seriesCount * parallelCount;
    if (parallelCount == 0) parallelCount = 1;

    totalBatteryCapacityAh =
        "\${(parallelCount * batteryCapacityAh).toStringAsFixed(0)}Ah @ \${systemVoltage.toStringAsFixed(0)}V (\${seriesCount}S\${parallelCount}P)";

    final invResult = HomeSolarSystemCalculator.calculateInverterSize(
      peakLoadWatt: maxPowerW,
      batteryAh: totalAhNeeded,
      batteryVoltage: systemVoltage,
      batteryCount: recommendedBatteries.toDouble(),
      batteryUserChargeCurrent: 0,
      batteryType: 'Lead-Acid',
      dod: 50.0,
    );

    recommendedInverterSize = invResult['inverterSize'];

    double size = recommendedInverterSize;
    double volt = systemVoltage;
    if (volt == 12.0) {
      size = size.clamp(1.0, 2.0);
    } else if (volt == 24.0) {
      size = size.clamp(1.5, 4.0);
    } else if (volt == 48.0) {
      if (size < 4.0) size = 4.0;
    }
    recommendedInverterSize = size;
    recommendedControllerSize = ((recommendedPanels * selectedPanelWattage) / systemVoltage).ceil();

    notifyListeners();
  }

  void prepareRequestFromCalculation() {
    panelCount = recommendedPanels;
    inverterCount = 1;
    selectedInverterKva = recommendedInverterSize;
    selectedInverterVoltType = 'Low Voltage';
    selectedInverterPhase = 'Single Phase';

    batteryCount = recommendedBatteries;
    selectedBatteryAmp = 200.0;
    selectedBatteryType = 'Gel / Lead-Acid / Tubular';

    notifyListeners();
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
    double totalWh = batteryCalcCountCount * batteryCalcAmp * batteryCalcVoltage;
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
    double area = (2 * wireCalcLength * wireCalcCurrent * 0.01724) / allowedDrop;
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
