import 'package:flutter/material.dart';

@immutable
class ShadingAnalysis {
  const ShadingAnalysis({
    this.shadedCells = const {},
    this.hourlyShadingFactors = const {},
    this.monthlyShadingFactors = const {},
    this.simulationDate,
    this.simulationHour = 12.0,
  });

  /// Set of linear cell indices that are shaded at the current simulation time.
  final Set<int> shadedCells;

  /// Hourly shading factor [0..1] keyed by 'YYYY-MM-DDTHH'.
  final Map<String, double> hourlyShadingFactors;

  /// Average shading factor per month [1..12].
  final Map<int, double> monthlyShadingFactors;

  final DateTime? simulationDate;
  final double simulationHour;

  double get overallShadingFactor {
    if (monthlyShadingFactors.isEmpty) return 1.0;
    final sum = monthlyShadingFactors.values.reduce((a, b) => a + b);
    return sum / monthlyShadingFactors.length;
  }

  ShadingAnalysis copyWith({
    Set<int>? shadedCells,
    Map<String, double>? hourlyShadingFactors,
    Map<int, double>? monthlyShadingFactors,
    DateTime? simulationDate,
    double? simulationHour,
  }) {
    return ShadingAnalysis(
      shadedCells: shadedCells ?? this.shadedCells,
      hourlyShadingFactors: hourlyShadingFactors ?? this.hourlyShadingFactors,
      monthlyShadingFactors: monthlyShadingFactors ?? this.monthlyShadingFactors,
      simulationDate: simulationDate ?? this.simulationDate,
      simulationHour: simulationHour ?? this.simulationHour,
    );
  }
}
