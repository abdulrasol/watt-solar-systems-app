import 'package:flutter/material.dart';

enum PvPanelOrientation { portrait, landscape }

@immutable
class PvPanelSpec {
  const PvPanelSpec({
    this.powerW = 620.0,
    this.lengthM = 2.2,
    this.widthM = 1.1,
    this.thicknessM = 0.04,
    this.weightKg = 22.0,
    this.orientation = PvPanelOrientation.portrait,
    this.horizontalGapM = 0.02,
    this.verticalGapM = 0.02,
  });

  final double powerW;
  final double lengthM;
  final double widthM;
  final double thicknessM;
  final double weightKg;
  final PvPanelOrientation orientation;
  final double horizontalGapM;
  final double verticalGapM;

  double get spanAcrossRowM =>
      orientation == PvPanelOrientation.portrait ? widthM : lengthM;

  double get slopeRunM =>
      orientation == PvPanelOrientation.portrait ? lengthM : widthM;

  double get areaM2 => lengthM * widthM;

  double get efficiency => powerW / (areaM2 * 1000.0);

  PvPanelSpec copyWith({
    double? powerW,
    double? lengthM,
    double? widthM,
    double? thicknessM,
    double? weightKg,
    PvPanelOrientation? orientation,
    double? horizontalGapM,
    double? verticalGapM,
  }) {
    return PvPanelSpec(
      powerW: powerW ?? this.powerW,
      lengthM: lengthM ?? this.lengthM,
      widthM: widthM ?? this.widthM,
      thicknessM: thicknessM ?? this.thicknessM,
      weightKg: weightKg ?? this.weightKg,
      orientation: orientation ?? this.orientation,
      horizontalGapM: horizontalGapM ?? this.horizontalGapM,
      verticalGapM: verticalGapM ?? this.verticalGapM,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'powerW': powerW,
      'lengthM': lengthM,
      'widthM': widthM,
      'thicknessM': thicknessM,
      'weightKg': weightKg,
      'orientation': orientation.name,
      'horizontalGapM': horizontalGapM,
      'verticalGapM': verticalGapM,
    };
  }

  factory PvPanelSpec.fromJson(Map<String, dynamic> json) {
    return PvPanelSpec(
      powerW: (json['powerW'] as num? ?? 620.0).toDouble(),
      lengthM: (json['lengthM'] as num? ?? 2.2).toDouble(),
      widthM: (json['widthM'] as num? ?? 1.1).toDouble(),
      thicknessM: (json['thicknessM'] as num? ?? 0.04).toDouble(),
      weightKg: (json['weightKg'] as num? ?? 22.0).toDouble(),
      orientation: PvPanelOrientation.values.firstWhere(
        (e) => e.name == json['orientation'],
        orElse: () => PvPanelOrientation.portrait,
      ),
      horizontalGapM: (json['horizontalGapM'] as num? ?? 0.02).toDouble(),
      verticalGapM: (json['verticalGapM'] as num? ?? 0.02).toDouble(),
    );
  }
}
