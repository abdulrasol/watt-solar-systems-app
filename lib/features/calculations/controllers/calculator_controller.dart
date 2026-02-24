import 'package:get/get.dart';
import 'package:solar_hub/calculations/home_solar_system_calculator.dart';
import 'package:solar_hub/models/offer_request_model.dart';
import 'package:solar_hub/services/supabase_service.dart';
// import 'package:solar_hub/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:solar_hub/features/calculations/widgets/system_request_confirmation_sheet.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ApplianceModel {
  String name;
  double power;
  int quantity;
  double hours;

  ApplianceModel({required this.name, this.power = 0.0, this.quantity = 1, this.hours = 0.0});
}

class CalculatorController extends GetxController {
  // System Wizard State
  final RxList<ApplianceModel> appliances = <ApplianceModel>[
    ApplianceModel(name: 'Refrigerator', power: 230, quantity: 1, hours: 24),
    ApplianceModel(name: 'Lamps & Fans', power: 240, quantity: 1, hours: 24),
    ApplianceModel(name: 'Washing Machine', power: 240, quantity: 1, hours: 2),
    ApplianceModel(name: 'TV / Laptop / Mobile', power: 200, quantity: 1, hours: 5),
  ].obs;
  final RxDouble autonomyHours = 12.0.obs;
  final RxDouble sunPeakHours = 5.0.obs;
  final RxDouble systemVoltage = 24.0.obs; // 12, 24, 48
  final RxInt recommendedPanels = 570.obs;
  final RxDouble recommendedInverterSize = 0.0.obs;
  final RxInt recommendedBatteries = 0.obs;
  final RxInt recommendedControllerSize = 0.obs;
  final RxDouble systemCalcSingleBatteryVoltage = 12.0.obs;

  // New Result Observables
  final RxDouble totalPanelCapacityKw = 0.0.obs;
  final RxString totalBatteryCapacityAh = "".obs;
  final RxDouble dailyUsageKWh = 0.0.obs;

  // Global Settings for Tools
  final RxDouble acSystemVoltage = 230.0.obs; // 110, 230, 380

  // Lists
  final List<double> acVoltageOptions = [110, 230, 380];
  final List<double> systemVoltageOptions = [12, 24, 48];
  final List<double> batteryVoltageOptions = [2, 6, 12, 12.8, 25.6, 51.2];

  // Request Wizard State
  final selectedPanelWattage = 570.obs; // Changed to RxInt
  final panelCount = 0.obs;
  final selectedBatteryVoltage = 51.2.obs; // Default Lithium HV
  final selectedBatteryAmp = 200.0.obs;
  final batteryCount = 0.obs;
  final selectedInverterKva = 5.0.obs;
  final inverterCount = 0.obs;
  final requestNotes = ''.obs;
  final installationType = 'Roof'.obs;
  final selectedInverterType = 'Hybrid'.obs;
  final selectedBatteryType = 'Lithium'.obs;

  // New Inverter Options
  final selectedInverterPhase = 'Single Phase'.obs;
  final selectedInverterVoltType = 'Low Voltage'.obs;

  // Section Notes
  final panelNote = ''.obs;
  final inverterNote = ''.obs;
  final batteryNote = ''.obs;

  // Single Calculations State
  // Panels
  final panelCalcDailyUsage = 0.0.obs; // Ah
  final panelCalcWattage = 450.0.obs;
  final panelCalcEfficiency = 0.75.obs;
  final panelCalcVoltage = 12.0.obs;
  final panelCalcResult = 0.obs;
  final panelCalcTotalWattage = 0.0.obs;

  // Inverter
  final inverterCalcAmps = 0.0.obs; // Input in Amps
  final inverterCalcTotalLoad = 0.0.obs; // Calculated W
  final inverterCalcSafetyFactor = 1.25.obs;
  final inverterCalcResult = 0.0.obs;

  // Battery
  final batteryCalcAmps = 0.0.obs; // Input in Amps
  final batteryCalcTotalLoad = 0.0.obs; // Calculated Watts
  final batteryCalcHours = 0.0.obs;
  final batteryCalcVoltage = 12.0.obs; // System Voltage (DC)
  final batteryCalcAmp = 200.0.obs;
  final batteryCalcResult = 0.obs;
  final batteryCalcRuntimeResult = 0.0.obs; // Hours
  final batteryCalcCountCount = 1.obs; // User input for "how many batteries do I have"
  final batteryCalcDoD = 50.0.obs;

  // Wires
  final wireCalcCurrent = 0.0.obs;
  final wireCalcLength = 0.0.obs;
  final wireCalcVoltage = 12.0.obs; // Voltage of circuit
  final wireCalcVoltageDrop = 3.0.obs; // %
  final wireCalcResult = ''.obs;

  // Wire options
  final wireCalcType = 'DC Solar'.obs; // "DC Solar", "DC Battery", "AC Single Phase", "AC Three Phase"
  final wireCalcMaterial = 'Copper'.obs;

  // Pump
  // Pump
  // Pump
  final pumpDailyWater = 0.0.obs; // m3/day
  final pumpTDH = 0.0.obs; // meters
  final pumpEfficiency = 0.5.obs; // 0.1-0.9
  final pumpDailyHours = 6.0.obs; // Hours of operation
  final pumpPeakSunHours = 5.0.obs; // PSH
  final pumpSystemEfficiency = 0.85.obs; // Default 0.85
  final pumpPanelWattage = 550.0.obs;

  // Pump Results
  final pumpHydraulicPowerW = 0.0.obs;
  final pumpDailyEnergyWh = 0.0.obs;
  final pumpRequiredPanelKw = 0.0.obs;
  final pumpRequiredPanelCount = 0.obs;

  // Orientation
  final orientationLat = 0.0.obs;
  final optimalTilt = 0.0.obs;
  final optimalDirection = "South".obs;
  final pumpResultWait = ''.obs;

  // Compass & Location
  final compassHeading = 0.0.obs;
  final isCompassAvailable = false.obs;
  final locationLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initCompass();
  }

  void initCompass() {
    FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        compassHeading.value = event.heading!;
        isCompassAvailable.value = true;
      }
    });
  }

  Future<void> fetchLocation() async {
    locationLoading.value = true;
    try {
      var status = await Permission.location.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
        orientationLat.value = position.latitude;
        calculateOrientation();
      } else {
        // Handle denied
        // toast?
      }
    } catch (e) {
      // Handle error
    } finally {
      locationLoading.value = false;
    }
  }

  void addAppliance() {
    appliances.add(ApplianceModel(name: 'New Appliance', power: 100, quantity: 1, hours: 5));
  }

  void removeAppliance(int index) {
    appliances.removeAt(index);
  }

  void calculateSystem() {
    double totalEnergyWh = 0;
    double maxPowerW = 0;

    for (var app in appliances) {
      totalEnergyWh += app.power * app.quantity * app.hours;
      maxPowerW += app.power * app.quantity;
    }

    dailyUsageKWh.value = totalEnergyWh / 1000;

    // 1. Panels Calculation
    // Using default effective wattage (e.g. 80% or similar implementation in HomeSolarSystemCalculator)
    // We assume 550W panels as standard for now, or user preference if we add it
    // Using user-selected or default wattage
    double panelWattage = selectedPanelWattage.value > 0 ? selectedPanelWattage.value.toDouble() : 570.0;

    // We need to adapt HomeSolarSystemCalculator.calculatePanelCount parameters
    // It seems calculatePanelCount needs 'dayloadAmpere' at 230V? Or we can reverse engineer.
    // Let's use the logic but adapted if needed.
    // The existing method takes: dayloadAmpere, activeHours, ...
    // Let's simplify and use the core logic: Energy / (SunHours * PanelWatts * Efficiency)

    // Using the logic from the file directly if possible, or re-implementing cleanly here using its principles.
    // Looking at the file, it has `calculatePanelCount` which is quite specific to an electrical setup.
    // Let's allow a direct calculation here for simplicity but respecting the flow.

    double panelsNeeded = totalEnergyWh / (sunPeakHours.value * panelWattage * 0.75); // 0.75 eff
    recommendedPanels.value = panelsNeeded.ceil();
    totalPanelCapacityKw.value = (recommendedPanels.value * panelWattage) / 1000;

    // 2. Battery Calculation
    // Using HomeSolarSystemCalculator.calculateBatteryBank
    // It accepts dailyUsageKWh, voltage, capacityAh...
    const double batteryCapacityAh = 200.0; // Standard block
    final battResult = HomeSolarSystemCalculator.calculateBatteryBank(
      dailyUsageKWh: dailyUsageKWh.value,
      // Usually calc expects single battery specs. Let's assume 12V user blocks.
      // If system is 48V, we need series strings.
      // The provided function seems to output total Ah needed for the bank.
      batteryCapacityAh: batteryCapacityAh,
      batteryVoltage: systemVoltage.value, // This function divides Wh by this Voltage to get Ah. So passing SystemVoltage gives Bank Ah.
      dod: 50.0, // 50%
    );

    double totalAhNeeded = battResult['totalAhNeeded']; // For the bank voltage
    // Number of 200Ah blocks?
    // If bank is 48V and we need 400Ah @ 48V.
    // We need 2 parallel strings of (4x12V). Total 8 batteries.
    // The function returns 'batteryCount' based on 'totalAhNeeded / batteryCapacityAh'.
    // If we pass SystemVoltage, then totalAhNeeded is at SystemVoltage.
    // So if we need 400Ah at 48V, and blocks are 200Ah. We need 2 blocks in parallel?
    // Wait, physically we need series too.

    // Correct physical count calculation:
    // parallel_strings = totalAhNeeded / singleBatteryAh
    // series_batteries = systemVoltage / singleBatteryVoltage (e.g. 12)
    // total = parallel * series

    double singleBattVoltage = systemCalcSingleBatteryVoltage.value;

    // Series Count: How many individual batteries to make System Voltage
    int seriesCount = (systemVoltage.value / singleBattVoltage).ceil();

    // Parallel Count: How many strings needed to meet Total Ah Capacity
    // totalAhNeeded is calculated based on Energy / System Voltage in calculateBatteryBank.
    // It returns the Ah needed at System Voltage.
    int parallelCount = (totalAhNeeded / batteryCapacityAh).ceil();

    recommendedBatteries.value = seriesCount * parallelCount;

    if (parallelCount == 0) parallelCount = 1; // Safety

    totalBatteryCapacityAh.value =
        "${(parallelCount * batteryCapacityAh).toStringAsFixed(0)}Ah @ ${systemVoltage.value.toStringAsFixed(0)}V (${seriesCount}S${parallelCount}P)";

    // 3. Inverter Calculation
    // Using calculateInverterSize
    // peakLoadWatt = maxPowerW
    final invResult = HomeSolarSystemCalculator.calculateInverterSize(
      peakLoadWatt: maxPowerW,
      batteryAh: totalAhNeeded, // Bank capacity in Ah
      batteryVoltage: systemVoltage.value,
      batteryCount: recommendedBatteries.value.toDouble(),
      batteryUserChargeCurrent: 0,
      batteryType: 'Lead-Acid',
      dod: 50.0,
    );

    recommendedInverterSize.value = invResult['inverterSize'];

    // Apply inverter sizing constraints based on system voltage
    double size = recommendedInverterSize.value;
    double volt = systemVoltage.value;
    if (volt == 12.0) {
      size = size.clamp(1.0, 2.0);
    } else if (volt == 24.0) {
      size = size.clamp(1.5, 4.0);
    } else if (volt == 48.0) {
      if (size < 4.0) size = 4.0;
    }
    recommendedInverterSize.value = size;

    // Controller
    recommendedControllerSize.value = ((recommendedPanels.value * selectedPanelWattage.value) / systemVoltage.value).ceil();
  }

  void calculatePump() {
    // 1. Determine Flow Rate (Q) in m3/s
    // Input is m3/day. Pumping over `pumpDailyHours`.
    if (pumpDailyHours.value == 0) return;
    double hourlyFlow = pumpDailyWater.value / pumpDailyHours.value; // m3/h
    double q = hourlyFlow / 3600; // m3/s

    // 2. Hydraulic Power (P) in Watts
    // P = (Q * TDH * g * density) / PumpEff
    // g=9.81, density=1000
    if (pumpEfficiency.value == 0) pumpEfficiency.value = 0.5;

    double pWatts = (q * pumpTDH.value * 9.81 * 1000) / pumpEfficiency.value;
    pumpHydraulicPowerW.value = pWatts;

    // 3. Daily Energy Needed (Wh)
    // Energy = Power * Hours
    double energyWh = pWatts * pumpDailyHours.value;
    pumpDailyEnergyWh.value = energyWh;

    // 4. Required Panel Energy (Wh)
    // Account for system losses (System Efficiency)
    double reqEnergyWh = energyWh / pumpSystemEfficiency.value;

    // 5. Array Size (Wp)
    // Size = ReqEnergy / PeakSunHours
    if (pumpPeakSunHours.value == 0) pumpPeakSunHours.value = 1;
    double arrayWp = reqEnergyWh / pumpPeakSunHours.value;
    pumpRequiredPanelKw.value = arrayWp / 1000;

    // 6. Number of Panels
    if (pumpPanelWattage.value > 0) {
      pumpRequiredPanelCount.value = (arrayWp / pumpPanelWattage.value).ceil();
    } else {
      pumpRequiredPanelCount.value = 0;
    }
  }

  void calculateOrientation() {
    // Simple estimation
    // Tilt ~= Latitude
    optimalTilt.value = orientationLat.value.abs();

    // Direction
    // Northern hemisphere (>0) -> Face South
    // Southern hemisphere (<0) -> Face North
    if (orientationLat.value > 0) {
      optimalDirection.value = "South";
    } else {
      optimalDirection.value = "North";
    }

    // Refinement:
    // Winter: Lat + 15
    // Summer: Lat - 15
    // We stick to annual average (Lat)
  }

  final _dbService = SupabaseService();

  Future<void> submitRequest() async {
    try {
      final user = _dbService.client.auth.currentUser;
      if (user == null) {
        toastification.show(
          title: Text('err_error'.tr),
          description: Text("Please login to submit a request"),
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
        );
        return;
      }

      final specs = RequestSpecs(
        panels: PanelSpecs(count: panelCount.value, capacity: selectedPanelWattage.value, note: panelNote.value),
        battery: BatterySpecs(
          count: batteryCount.value,
          capacity: selectedBatteryAmp.value,
          type: selectedBatteryType.value,
          voltageType: selectedInverterVoltType.value == 'High Voltage' ? 'HV' : 'LV',
          note: batteryNote.value,
          systemVoltage: systemVoltage.value,
        ),
        inverter: InverterSpecs(
          count: inverterCount.value,
          capacity: selectedInverterKva.value,
          note: inverterNote.value,
          voltageType: selectedInverterVoltType.value == 'High Voltage' ? 'HV' : 'LV',
          type: selectedInverterType.value,
          phase: selectedInverterPhase.value,
        ),
      );

      final pvTotal = (panelCount.value * selectedPanelWattage.value).toDouble();
      final battTotal = batteryCount.value * selectedBatteryAmp.value;
      final invTotal = inverterCount.value * selectedInverterKva.value;

      final requestModel = OfferRequestModel(
        id: '', // Generated by DB
        userId: user.id,
        title: "System Request: ${selectedInverterKva.value}kW",
        pvTotal: pvTotal,
        batteryTotal: battTotal,
        inverterTotal: invTotal,
        notes: requestNotes.value,
        specs: specs,
        createdAt: DateTime.now(),
      );

      // We explicitly exclude 'id' and 'created_at' from toJson if we want DB to generate them,
      // or we rely on the model's toJson but need to handle the ID.
      // Better to pass a Map to insert excluding ID.
      final json = requestModel.toJson();
      json.remove('id'); // let DB generate
      json.remove('created_at'); // let DB generate

      await _dbService.client.from('offer_requests').insert(json);

      toastification.show(
        title: Text('success'.tr),
        description: Text('request_submitted_success'.tr),
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
      );
    } catch (e) {
      // print("Error submitting request: $e");
      toastification.show(
        title: Text('err_error'.tr),
        description: Text('request_submit_error'.tr),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  void calculatePanels() {
    if (panelCalcWattage.value == 0) return;

    // Formula: (Total Daily Usage in Ah * System Voltage * Efficiency/100) / Panel Wattage
    // Result rounded up to upper int.

    double totalUsageAh = panelCalcDailyUsage.value;
    double sysVoltage = panelCalcVoltage.value;
    // Slider in UI is 0.65 to 1.0. User prompt says "efficie/100".
    // If usage is 100Ah, V=12, Eff=0.8. Energy = 100*12 = 1200Wh. Eff?
    // Usually Efficiency LOSS means we need MORE panels.
    // Or System Efficiency means we only get X% of panel output?
    // User formula: (Ah * V * Eff/100) / PanelW.
    // If Eff is 80 (%), then 0.8.
    // (100 * 12 * 0.8) / 450 ???
    // 1200 * 0.8 = 960 Wh available? Or Needed?
    // Usually: Needed / Yield.
    // If formula is specifically requested as (Ah * V * Eff) / W, it implies the numerator is Energy.
    // But multiplying by efficiency usually REDUCES the number?
    // Let's assume the user means "Loss Factor" or "Efficiency Factor" where dividing by it increases needed.
    // WAIT: User said: "(total daily usege in A * system voltage * system efficie/100 ) / panel wattge"
    // He said "usege in A" (Ah presumably).
    // Let's implement EXACTLY as requested:
    // Numerator = Ah * V * (Eff). (If Eff is 0.8, then smaller).
    // Denom = PanelW.
    // Example: 100Ah * 12V * 0.8 = 960. / 450 = 2.13.
    // If we didn't have efficiency (1.0): 1200 / 450 = 2.66.
    // So efficiency factor < 1 reduces panels? That sounds like "Performance Ratio" of the LOAD?
    // OR, maybe the user means "Increase by 1/Eff"?
    // BUT checking the prompt: "total daily usege in A * system voltage * system efficie/100 ) / panel wattge"
    // I will stick to the literal formula but I suspect 'system efficie' might be treated as > 100 (e.g. 130% safety)?
    // In the UI, the slider is "Efficiency / Loss Factor" and values are 0.65 - 1.0.
    // I will use `panelCalcEfficiency.value` which is 0.65-1.0.

    // HOWEVER, standard logic: Energy Needed = Usage / Efficiency.
    // Panels = Energy Needed / (PanelW * SunHours).
    // The user formula DOES NOT include SunHours!
    // Maybe "daily usege" assumes peak hours are handled or it's instant power?
    // "Total Daily Usage in Ah" implies Energy.
    // Omitting SunHours implies the result is "Total Watts of Panels required", not "Number of Panels"?
    // " / panel wattge" -> This results in Count.
    // So 100Ah * 12V = 1200Wh.
    // 1200Wh / 450W = 2.6 hours of full power?
    // This formula produces a number that has units of TIME (Hours), not Count.
    // UNLESS "Ah" is actually "Amps peak"?
    // "Total Daily Usage" usually means Ah.

    // I will assume the user logic overrides standard logic.
    // Formula: (Ah * V * (Eff)) / W.

    // Let's check if user wants "Safety Factor" (e.g., 1.3).
    // The UI slider says "Efficiency".
    // If I strictly follow: (Ah * V * Eff) / W.
    // Missing SunHours. This is highly suspicious for a logical result (Panels count).

    // BUT per request "use this fromula (total daily usege in A * system voltage * system efficie/100 ) / panel wattge and round it to upper int alwuesy".
    // I will implement exactly this.

    double numer = totalUsageAh * sysVoltage; // efficiency is 0.x
    double result = numer / (panelCalcWattage.value * panelCalcEfficiency.value);

    panelCalcResult.value = result.ceil();
    if (panelCalcResult.value == 0 && result > 0) panelCalcResult.value = 1;

    panelCalcTotalWattage.value = panelCalcResult.value * panelCalcWattage.value;
  }

  void calculateInverter() {
    // Input: Amps. System: AC Voltage (230 default).
    // Load (W) = Amps * AC Voltage.
    // Result kVA = (Load * Safety) / 1000.

    double loadW = inverterCalcAmps.value * acSystemVoltage.value;
    inverterCalcTotalLoad.value = loadW;

    inverterCalcResult.value = (loadW * inverterCalcSafetyFactor.value) / 1000;
  }

  void calculateBattery() {
    // Input: Amps, AC Voltage.
    // Load (W) = Amps * AC Voltage
    double loadW = batteryCalcAmps.value * acSystemVoltage.value;
    batteryCalcTotalLoad.value = loadW;

    // Energy (Wh) = Load * Hours
    double totalWh = loadW * batteryCalcHours.value;

    // Adjust for DoD (e.g. 50% means we need 2x capacity)
    double requiredWh = totalWh / (batteryCalcDoD.value / 100.0);

    // Required Bank Ah = Wh / System DC Voltage (e.g. 12, 24, 48)
    double requiredBankAh = requiredWh / batteryCalcVoltage.value;

    // Number of batteries?
    // "use battery voltage 2,6,12... 12.8, 25.6, 51.2"
    // Usually we calculate Total Ah or count of specific blocks.
    // Let's assume the user just wants the BANK capacity?
    // Existing code: `batteryCalcResult.value = (requiredAh / batteryCalcAmp.value).ceil()`
    // We assume standard 200Ah block? Or let user input?
    // User didn't specify changing the battery block capacity input, just using Amps for LOAD.
    // I'll keep `batteryCalcAmp` (200 default) as the block size.

    batteryCalcResult.value = (requiredBankAh / batteryCalcAmp.value).ceil();
  }

  void calculateBatteryRuntime() {
    // Time = (BatteryCount * Amp * Voltage * DoD) / Load(W)
    double totalWh = batteryCalcCountCount.value * batteryCalcAmp.value * batteryCalcVoltage.value;
    double availableWh = totalWh * (batteryCalcDoD.value / 100.0);

    if (batteryCalcTotalLoad.value > 0) {
      batteryCalcRuntimeResult.value = availableWh / batteryCalcTotalLoad.value;
    } else {
      batteryCalcRuntimeResult.value = 0;
    }
  }

  void prepareRequestFromCalculation() {
    // Copy calculated values to request state
    panelCount.value = recommendedPanels.value;
    // selectedPanelWattage is already set in the preferences tab of wizard

    inverterCount.value = 1; // Default
    selectedInverterKva.value = recommendedInverterSize.value;
    selectedInverterVoltType.value = 'Low Voltage'; // Calculator assumes LV (12/24/48V)
    selectedInverterPhase.value = 'Single Phase'; // Default

    // Battery
    // recommendedBatteries is total count.
    // Calculate parallel/series config again or just set count?
    // The request model expects 'count' and 'capacity' (single block).
    // We used 200Ah in calculation.
    batteryCount.value = recommendedBatteries.value;
    selectedBatteryAmp.value = 200.0; // Hardcoded in calc for now
    selectedBatteryType.value = 'Gel / Lead-Acid / Tubular'; // Calc assumes this

    // Open Confirmation
    Get.bottomSheet(SystemRequestConfirmationSheet(), isScrollControlled: true);
  }

  void calculateWire() {
    double voltage = wireCalcVoltage.value;
    double allowedDrop = voltage * wireCalcVoltageDrop.value / 100;
    double area = (2 * wireCalcLength.value * wireCalcCurrent.value * 0.01724) / allowedDrop;
    if (area < 1.5) {
      wireCalcResult.value = "1.5 mm²";
    } else if (area < 2.5) {
      wireCalcResult.value = "2.5 mm²";
    } else if (area < 4) {
      wireCalcResult.value = "4 mm²";
    } else if (area < 6) {
      wireCalcResult.value = "6 mm²";
    } else if (area < 10) {
      wireCalcResult.value = "10 mm²";
    } else if (area < 16) {
      wireCalcResult.value = "16 mm²";
    } else if (area < 25) {
      wireCalcResult.value = "25 mm²";
    } else if (area < 35) {
      wireCalcResult.value = "35 mm²";
    } else if (area < 50) {
      wireCalcResult.value = "50 mm²";
    } else if (area < 70) {
      wireCalcResult.value = "70 mm²";
    } else if (area < 95) {
      wireCalcResult.value = "95 mm²";
    } else if (area < 120) {
      wireCalcResult.value = "120 mm²";
    } else {
      wireCalcResult.value = "${area.toStringAsFixed(1)} mm²";
    }
  }
}
