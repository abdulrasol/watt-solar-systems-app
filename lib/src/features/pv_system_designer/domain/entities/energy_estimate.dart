import 'package:flutter/foundation.dart';

@immutable
class EnergyEstimate {
  final double dailyKwh;
  final double monthlyKwh;
  final double yearlyKwh;
  final double capacityFactor;
  final double performanceRatio;
  final double peakSunHours;
  final double peakPowerKwp;
  final double annualCo2OffsetKg;
  final double systemLossesPercent;

  const EnergyEstimate({
    required this.dailyKwh,
    required this.monthlyKwh,
    required this.yearlyKwh,
    required this.capacityFactor,
    required this.performanceRatio,
    required this.peakSunHours,
    required this.peakPowerKwp,
    required this.annualCo2OffsetKg,
    required this.systemLossesPercent,
  });

  static const double co2PerKwh = 0.42;
  static const double defaultSystemLossesPercent = 14.0;
  static const double defaultPerformanceRatio = 0.86;

  factory EnergyEstimate.empty() {
    return const EnergyEstimate(
      dailyKwh: 0,
      monthlyKwh: 0,
      yearlyKwh: 0,
      capacityFactor: 0,
      performanceRatio: defaultPerformanceRatio,
      peakSunHours: 0,
      peakPowerKwp: 0,
      annualCo2OffsetKg: 0,
      systemLossesPercent: defaultSystemLossesPercent,
    );
  }

  EnergyEstimate copyWith({
    double? dailyKwh,
    double? monthlyKwh,
    double? yearlyKwh,
    double? capacityFactor,
    double? performanceRatio,
    double? peakSunHours,
    double? peakPowerKwp,
    double? annualCo2OffsetKg,
    double? systemLossesPercent,
  }) {
    return EnergyEstimate(
      dailyKwh: dailyKwh ?? this.dailyKwh,
      monthlyKwh: monthlyKwh ?? this.monthlyKwh,
      yearlyKwh: yearlyKwh ?? this.yearlyKwh,
      capacityFactor: capacityFactor ?? this.capacityFactor,
      performanceRatio: performanceRatio ?? this.performanceRatio,
      peakSunHours: peakSunHours ?? this.peakSunHours,
      peakPowerKwp: peakPowerKwp ?? this.peakPowerKwp,
      annualCo2OffsetKg: annualCo2OffsetKg ?? this.annualCo2OffsetKg,
      systemLossesPercent: systemLossesPercent ?? this.systemLossesPercent,
    );
  }
}
