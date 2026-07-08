import 'package:flutter/foundation.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/system_losses.dart';

@immutable
class EnergyEstimate {
  final double dailyKwh;
  final double monthlyKwh;
  final double yearlyKwh;

  /// Real per-calendar-month production totals (kWh), index 0 = January.
  /// Unlike the old model this is not just `yearlyKwh / 12` — it reflects
  /// the site's actual seasonal irradiance and temperature variation.
  final List<double> monthlyProductionKwh;

  final double capacityFactor;

  /// Overall DC-to-AC performance ratio actually applied (temperature
  /// derate × [SystemLosses.combinedDerateFactor]), for the headline
  /// "Performance Ratio" figure.
  final double performanceRatio;

  final double peakSunHours;
  final double peakPowerKwp;
  final double annualCo2OffsetKg;
  final SystemLosses losses;

  /// Average fractional energy loss from cell temperature rising above the
  /// 25°C STC rating (e.g. 0.06 = 6% average temperature loss), shown
  /// separately from [losses] since it's climate/mounting-driven rather
  /// than a fixed system loss.
  final double avgTemperatureLossFraction;

  /// Whether [peakSunHours]/[monthlyProductionKwh] came from a real
  /// weather-API fetch (Open-Meteo) vs. the latitude-only estimate
  /// fallback — surfaced in the UI so users know how much to trust the
  /// numbers.
  final bool isRealWeatherData;

  const EnergyEstimate({
    required this.dailyKwh,
    required this.monthlyKwh,
    required this.yearlyKwh,
    required this.monthlyProductionKwh,
    required this.capacityFactor,
    required this.performanceRatio,
    required this.peakSunHours,
    required this.peakPowerKwp,
    required this.annualCo2OffsetKg,
    required this.losses,
    required this.avgTemperatureLossFraction,
    required this.isRealWeatherData,
  });

  static const double co2PerKwh = 0.42;

  factory EnergyEstimate.empty() {
    return EnergyEstimate(
      dailyKwh: 0,
      monthlyKwh: 0,
      yearlyKwh: 0,
      monthlyProductionKwh: List<double>.filled(12, 0),
      capacityFactor: 0,
      performanceRatio: SystemLosses.standard().combinedDerateFactor(),
      peakSunHours: 0,
      peakPowerKwp: 0,
      annualCo2OffsetKg: 0,
      losses: SystemLosses.standard(),
      avgTemperatureLossFraction: 0,
      isRealWeatherData: false,
    );
  }

  EnergyEstimate copyWith({
    double? dailyKwh,
    double? monthlyKwh,
    double? yearlyKwh,
    List<double>? monthlyProductionKwh,
    double? capacityFactor,
    double? performanceRatio,
    double? peakSunHours,
    double? peakPowerKwp,
    double? annualCo2OffsetKg,
    SystemLosses? losses,
    double? avgTemperatureLossFraction,
    bool? isRealWeatherData,
  }) {
    return EnergyEstimate(
      dailyKwh: dailyKwh ?? this.dailyKwh,
      monthlyKwh: monthlyKwh ?? this.monthlyKwh,
      yearlyKwh: yearlyKwh ?? this.yearlyKwh,
      monthlyProductionKwh: monthlyProductionKwh ?? this.monthlyProductionKwh,
      capacityFactor: capacityFactor ?? this.capacityFactor,
      performanceRatio: performanceRatio ?? this.performanceRatio,
      peakSunHours: peakSunHours ?? this.peakSunHours,
      peakPowerKwp: peakPowerKwp ?? this.peakPowerKwp,
      annualCo2OffsetKg: annualCo2OffsetKg ?? this.annualCo2OffsetKg,
      losses: losses ?? this.losses,
      avgTemperatureLossFraction: avgTemperatureLossFraction ?? this.avgTemperatureLossFraction,
      isRealWeatherData: isRealWeatherData ?? this.isRealWeatherData,
    );
  }
}
