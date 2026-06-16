import 'package:solar_hub/src/features/pv_system_designer/domain/entities/energy_estimate.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/solar_irradiance_data.dart';

class EnergyEstimator {
  EnergyEstimate estimate({
    required double peakPowerKwp,
    required double latitude,
    required double systemLossesPercent,
    SolarIrradianceData? irradianceData,
  }) {
    if (peakPowerKwp <= 0) return EnergyEstimate.empty();

    final irradiance = irradianceData ?? SolarIrradianceData.estimate(latitude);
    final psh = irradiance.averagePeakSunHours;
    final pr = (100 - systemLossesPercent) / 100.0;

    final dailyKwh = peakPowerKwp * psh * pr;
    final monthlyKwh = dailyKwh * 30.44;
    final yearlyKwh = dailyKwh * 365.25;
    final capacityFactor = yearlyKwh / (peakPowerKwp * 8766);
    final co2Offset = yearlyKwh * EnergyEstimate.co2PerKwh;

    return EnergyEstimate(
      dailyKwh: dailyKwh,
      monthlyKwh: monthlyKwh,
      yearlyKwh: yearlyKwh,
      capacityFactor: capacityFactor,
      performanceRatio: pr,
      peakSunHours: psh,
      peakPowerKwp: peakPowerKwp,
      annualCo2OffsetKg: co2Offset,
      systemLossesPercent: systemLossesPercent,
    );
  }

  List<double> monthlyProduction({
    required double peakPowerKwp,
    required double latitude,
    required double systemLossesPercent,
  }) {
    final irradiance = SolarIrradianceData.estimate(latitude);
    final pr = (100 - systemLossesPercent) / 100.0;
    return irradiance.monthlyGlobalTilted.map((m) => peakPowerKwp * m * pr).toList();
  }
}
