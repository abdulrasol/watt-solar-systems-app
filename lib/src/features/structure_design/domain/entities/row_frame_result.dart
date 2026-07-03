class RowFrameResult {
  const RowFrameResult({
    required this.rowIndex,
    required this.baseOffsetMeters,
    required this.frontLegHeightMeters,
    required this.rearLegHeightMeters,
    required this.rowSpacingMeters,
    required this.localFootprintDepthMeters,
  });

  final int rowIndex;
  final double baseOffsetMeters;
  final double frontLegHeightMeters;
  final double rearLegHeightMeters;
  final double rowSpacingMeters;
  final double localFootprintDepthMeters;
}
