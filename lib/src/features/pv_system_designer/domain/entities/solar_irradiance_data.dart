import 'package:flutter/foundation.dart';

@immutable
class SolarIrradianceData {
  final double latitude;
  final double longitude;
  final List<double> monthlyGlobalTilted;
  final double annualGlobalHorizontal;
  final double averagePeakSunHours;

  const SolarIrradianceData({
    required this.latitude,
    required this.longitude,
    required this.monthlyGlobalTilted,
    required this.annualGlobalHorizontal,
    required this.averagePeakSunHours,
  });

  double get monthlyPeakSunHours => averagePeakSunHours;

  factory SolarIrradianceData.estimate(double latitude) {
    final lat = latitude.abs();
    final double basePsh;
    if (lat < 15) {
      basePsh = 6.0;
    } else if (lat < 30) {
      basePsh = 5.5;
    } else if (lat < 45) {
      basePsh = 4.5;
    } else if (lat < 60) {
      basePsh = 3.5;
    } else {
      basePsh = 2.5;
    }

    const seasonalVariation = [0.7, 0.8, 0.95, 1.1, 1.2, 1.25, 1.2, 1.1, 0.95, 0.8, 0.7, 0.65];
    final monthly = seasonalVariation.map((f) => basePsh * f).toList();
    final annualGhi = basePsh * 365 * 1000 / 1000;

    return SolarIrradianceData(
      latitude: latitude,
      longitude: 0,
      monthlyGlobalTilted: monthly.map((p) => p * 30).toList(),
      annualGlobalHorizontal: annualGhi,
      averagePeakSunHours: basePsh,
    );
  }
}
