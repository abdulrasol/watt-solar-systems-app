import 'package:flutter/material.dart';

@immutable
class SolarIrradianceData {
  const SolarIrradianceData({
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.endDate,
    required this.hourlyTimes,
    required this.hourlyGtiWm2,
    required this.source,
  });

  final double latitude;
  final double longitude;
  final DateTime startDate;
  final DateTime endDate;
  final List<DateTime> hourlyTimes;
  final List<double> hourlyGtiWm2;
  final String source;

  bool get isEmpty => hourlyGtiWm2.isEmpty;
}
