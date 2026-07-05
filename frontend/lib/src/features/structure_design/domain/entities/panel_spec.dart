enum PanelOrientation { portrait, landscape }

class PanelSpec {
  const PanelSpec({
    required this.lengthMeters,
    required this.widthMeters,
    required this.thicknessMeters,
    required this.orientation,
    required this.horizontalGapMeters,
    required this.verticalGapMeters,
  });

  final double lengthMeters;
  final double widthMeters;
  final double thicknessMeters;
  final PanelOrientation orientation;
  final double horizontalGapMeters;
  final double verticalGapMeters;

  double get spanAcrossRowMeters =>
      orientation == PanelOrientation.portrait ? widthMeters : lengthMeters;

  double get slopeRunMeters =>
      orientation == PanelOrientation.portrait ? lengthMeters : widthMeters;

  PanelSpec copyWith({
    double? lengthMeters,
    double? widthMeters,
    double? thicknessMeters,
    PanelOrientation? orientation,
    double? horizontalGapMeters,
    double? verticalGapMeters,
  }) {
    return PanelSpec(
      lengthMeters: lengthMeters ?? this.lengthMeters,
      widthMeters: widthMeters ?? this.widthMeters,
      thicknessMeters: thicknessMeters ?? this.thicknessMeters,
      orientation: orientation ?? this.orientation,
      horizontalGapMeters: horizontalGapMeters ?? this.horizontalGapMeters,
      verticalGapMeters: verticalGapMeters ?? this.verticalGapMeters,
    );
  }
}
