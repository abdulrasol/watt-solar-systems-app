class HomeSolarSystemCalculator {
  // Calculate number of solar panels needed
  // dailyUsageKWh: daily energy usage in kWh
  // panelWatt: wattage of a single panel
  // sunHours: average sun hours per day

  static int calculatePanelCount({
    num dayloadAmpere = 0,
    num activeHours = 0,
    num batteryCapacityInput = 0,
    num panelWattage = 0,
    num gridFeedWattge = 0,
    num gridChargeHours = 0,
    num gridChargeCurrent = 0,
    num effativepanelWatts = 70,
    bool batteryCharge = false,
    bool gridFeed = false,
  }) {
    num panels = (dayloadAmpere * 230) / (effativepanelWatts);

    num gridChargePower = gridChargeCurrent * 230 * gridChargeHours;
    num remainBatteryToChargeFromPv = batteryCapacityInput - gridChargePower;

    if (!remainBatteryToChargeFromPv.isNegative && batteryCharge) {
      panels +=
          (remainBatteryToChargeFromPv / activeHours) / effativepanelWatts;
      // print('$batteryChargePanels  add remain battery to charge');
    }

    if (gridFeed) {
      panels += (gridFeedWattge / activeHours) / effativepanelWatts;
    }

    return (panels).ceil();
  }

  // Calculate battery bank size (Ah) and number of batteries
  // dailyUsageKWh: daily energy usage in kWh
  // batteryVoltage: voltage of a single battery
  // batteryCapacityAh: capacity of a single battery in Ah
  // autonomyDays: days of backup required
  // dod: depth of discharge (0.5 for 50%)
  // Map<String, dynamic> calculateBatteryBank({
  //   required double dailyUsageKWh,
  //   required double batteryVoltage,
  //   required double batteryCapacityAh,
  //   required int autonomyDays,
  //   double dod = 0.5,
  // }) {
  //   double totalWhNeeded = dailyUsageKWh * autonomyDays * 1000 / dod;
  //   double totalAhNeeded = totalWhNeeded / batteryVoltage;
  //   int batteryCount = (totalAhNeeded / batteryCapacityAh).ceil();
  //   return {'totalAhNeeded': totalAhNeeded, 'batteryCount': batteryCount};
  // }

  static Map<String, dynamic> calculateBatteryBank({
    required double dailyUsageKWh,
    required double batteryVoltage,
    required double batteryCapacityAh,
    // required int autonomyDays,
    double dod = 0.5,
  }) {
    if (dod == 0) {
      return {'totalAhNeeded': 0, 'batteryCount': 0};
    }
    double totalWhNeeded = dailyUsageKWh * 100 / dod;
    double totalAhNeeded = totalWhNeeded / batteryVoltage;
    int batteryCount = (totalAhNeeded / batteryCapacityAh).ceil();
    return {'totalAhNeeded': totalAhNeeded, 'batteryCount': batteryCount};
  }

  static double calculateBatteryBankTimeRunning({
    required double dailyUsageKWh,
    required double batteryVoltage,
    required double batteryCapacityAh,
    required int batteryCount,
    double dod = 0.5,
  }) {
    if (dod == 0) {
      return 0.0;
    }

    print('$dailyUsageKWh, $batteryVoltage, $batteryCapacityAh');
    double time =
        (batteryVoltage * batteryCapacityAh * batteryCount * dod / 100) /
        (dailyUsageKWh);

    return time;
  }

  // Calculate inverter size (W)
  // peakLoadWatt: maximum load in watts
  // surgeFactor: factor for surge (e.g., 1.25 for 25% surge)
  static Map<String, dynamic> calculateInverterSize({
    required double peakLoadWatt,
    double surgeFactor = 1.25,
  }) {
    return {};
  }
}
