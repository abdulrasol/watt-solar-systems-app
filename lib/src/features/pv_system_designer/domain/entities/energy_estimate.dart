import 'package:flutter/material.dart';

@immutable
class EnergyEstimate {
  const EnergyEstimate({
    this.monthlyKwh = const {},
    this.yearlyKwh = 0.0,
    this.peakKw = 0.0,
    this.capacityFactor = 0.0,
    this.co2OffsetKg = 0.0,
    this.estimatedSavings = 0.0,
    this.avgTariffPerKwh = 0.0,
    this.dataSource = '',
  });

  final Map<int, double> monthlyKwh;
  final double yearlyKwh;
  final double peakKw;
  final double capacityFactor;
  final double co2OffsetKg;
  final double estimatedSavings;
  final double avgTariffPerKwh;
  final String dataSource;

  EnergyEstimate copyWith({
    Map<int, double>? monthlyKwh,
    double? yearlyKwh,
    double? peakKw,
    double? capacityFactor,
    double? co2OffsetKg,
    double? estimatedSavings,
    double? avgTariffPerKwh,
    String? dataSource,
  }) {
    return EnergyEstimate(
      monthlyKwh: monthlyKwh ?? this.monthlyKwh,
      yearlyKwh: yearlyKwh ?? this.yearlyKwh,
      peakKw: peakKw ?? this.peakKw,
      capacityFactor: capacityFactor ?? this.capacityFactor,
      co2OffsetKg: co2OffsetKg ?? this.co2OffsetKg,
      estimatedSavings: estimatedSavings ?? this.estimatedSavings,
      avgTariffPerKwh: avgTariffPerKwh ?? this.avgTariffPerKwh,
      dataSource: dataSource ?? this.dataSource,
    );
  }
}
