import 'package:flutter/foundation.dart';

/// A structured PV system loss diagram, replacing the old single
/// "systemLossesPercent" black-box number with the individually-adjustable
/// loss categories used by professional design tools (PVsyst, PVWatts).
///
/// All `*LossPercent` fields represent a percentage of energy lost to that
/// cause (e.g. `soilingLossPercent: 2.0` means 2% of otherwise-available
/// energy is lost to dust/dirt on the panels). `inverterEfficiencyPercent`
/// is expressed the opposite way round (as an efficiency, not a loss),
/// since that's how inverter datasheets publish it.
@immutable
class SystemLosses {
  final double soilingLossPercent;
  final double mismatchLossPercent;
  final double dcWiringLossPercent;
  final double acWiringLossPercent;
  final double inverterEfficiencyPercent;
  final double availabilityLossPercent;
  final double annualDegradationPercent;

  const SystemLosses({
    required this.soilingLossPercent,
    required this.mismatchLossPercent,
    required this.dcWiringLossPercent,
    required this.acWiringLossPercent,
    required this.inverterEfficiencyPercent,
    required this.availabilityLossPercent,
    required this.annualDegradationPercent,
  });

  /// Reasonable industry-typical defaults, roughly matching PVsyst/PVWatts
  /// "default loss diagram" values for a well-maintained residential/
  /// commercial rooftop system. Users should be able to override these
  /// once real site data (dusty climate, long DC runs, etc.) is known.
  factory SystemLosses.standard() => const SystemLosses(
        soilingLossPercent: 2.0,
        mismatchLossPercent: 2.0,
        dcWiringLossPercent: 1.5,
        acWiringLossPercent: 1.0,
        inverterEfficiencyPercent: 97.5,
        availabilityLossPercent: 1.0,
        annualDegradationPercent: 0.5,
      );

  /// Combined derate factor (0-1) applied to POA/temperature-corrected DC
  /// energy to get AC energy delivered, for `yearIndex` years after
  /// commissioning (0 = first year, no degradation yet applied).
  double combinedDerateFactor({int yearIndex = 0}) {
    final soiling = 1 - soilingLossPercent / 100.0;
    final mismatch = 1 - mismatchLossPercent / 100.0;
    final dcWiring = 1 - dcWiringLossPercent / 100.0;
    final acWiring = 1 - acWiringLossPercent / 100.0;
    final inverterEff = inverterEfficiencyPercent / 100.0;
    final availability = 1 - availabilityLossPercent / 100.0;
    final degradation = 1 - (annualDegradationPercent / 100.0) * yearIndex;
    return soiling * mismatch * dcWiring * acWiring * inverterEff * availability * degradation.clamp(0.0, 1.0);
  }

  /// A single "equivalent" performance-ratio-style percentage for display
  /// purposes (e.g. "System Losses: 14.2%"), for UIs that still want one
  /// headline number alongside the itemized breakdown.
  double get equivalentTotalLossPercent => (1 - combinedDerateFactor()) * 100.0;

  SystemLosses copyWith({
    double? soilingLossPercent,
    double? mismatchLossPercent,
    double? dcWiringLossPercent,
    double? acWiringLossPercent,
    double? inverterEfficiencyPercent,
    double? availabilityLossPercent,
    double? annualDegradationPercent,
  }) {
    return SystemLosses(
      soilingLossPercent: soilingLossPercent ?? this.soilingLossPercent,
      mismatchLossPercent: mismatchLossPercent ?? this.mismatchLossPercent,
      dcWiringLossPercent: dcWiringLossPercent ?? this.dcWiringLossPercent,
      acWiringLossPercent: acWiringLossPercent ?? this.acWiringLossPercent,
      inverterEfficiencyPercent: inverterEfficiencyPercent ?? this.inverterEfficiencyPercent,
      availabilityLossPercent: availabilityLossPercent ?? this.availabilityLossPercent,
      annualDegradationPercent: annualDegradationPercent ?? this.annualDegradationPercent,
    );
  }

  Map<String, dynamic> toJson() => {
        'soilingLossPercent': soilingLossPercent,
        'mismatchLossPercent': mismatchLossPercent,
        'dcWiringLossPercent': dcWiringLossPercent,
        'acWiringLossPercent': acWiringLossPercent,
        'inverterEfficiencyPercent': inverterEfficiencyPercent,
        'availabilityLossPercent': availabilityLossPercent,
        'annualDegradationPercent': annualDegradationPercent,
      };

  factory SystemLosses.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SystemLosses.standard();
    final defaults = SystemLosses.standard();
    return SystemLosses(
      soilingLossPercent: (json['soilingLossPercent'] as num? ?? defaults.soilingLossPercent).toDouble(),
      mismatchLossPercent: (json['mismatchLossPercent'] as num? ?? defaults.mismatchLossPercent).toDouble(),
      dcWiringLossPercent: (json['dcWiringLossPercent'] as num? ?? defaults.dcWiringLossPercent).toDouble(),
      acWiringLossPercent: (json['acWiringLossPercent'] as num? ?? defaults.acWiringLossPercent).toDouble(),
      inverterEfficiencyPercent: (json['inverterEfficiencyPercent'] as num? ?? defaults.inverterEfficiencyPercent).toDouble(),
      availabilityLossPercent: (json['availabilityLossPercent'] as num? ?? defaults.availabilityLossPercent).toDouble(),
      annualDegradationPercent: (json['annualDegradationPercent'] as num? ?? defaults.annualDegradationPercent).toDouble(),
    );
  }
}
