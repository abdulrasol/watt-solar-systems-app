import 'package:watt/src/features/structure_design/domain/entities/panel_spec.dart';

enum MountType { ground, flatRoof, pitchedRoof, custom }

enum RowMode { independent, stepped }

enum FacingDirectionPreference {
  any,
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest,
}

class StructureDesignInput {
  const StructureDesignInput({
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.latitude,
    required this.facingPreference,
    required this.mountType,
    required this.frontClearanceMeters,
    required this.rearClearanceMeters,
    required this.sideClearanceMeters,
    required this.frontLegClearanceMeters,
    required this.interRowGapMeters,
    required this.panelSpec,
    required this.rowMode,
    required this.rowBaseOffsetsMeters,
    this.targetPanelCount,
    this.manualRows,
    this.manualColumns,
  });

  final double siteWidthMeters;
  final double siteDepthMeters;
  final double latitude;
  final FacingDirectionPreference facingPreference;
  final MountType mountType;
  final double frontClearanceMeters;
  final double rearClearanceMeters;
  final double sideClearanceMeters;
  final double frontLegClearanceMeters;
  final double interRowGapMeters;
  final PanelSpec panelSpec;
  final RowMode rowMode;
  final List<double> rowBaseOffsetsMeters;
  final int? targetPanelCount;
  final int? manualRows;
  final int? manualColumns;

  StructureDesignInput copyWith({
    double? siteWidthMeters,
    double? siteDepthMeters,
    double? latitude,
    FacingDirectionPreference? facingPreference,
    MountType? mountType,
    double? frontClearanceMeters,
    double? rearClearanceMeters,
    double? sideClearanceMeters,
    double? frontLegClearanceMeters,
    double? interRowGapMeters,
    PanelSpec? panelSpec,
    RowMode? rowMode,
    List<double>? rowBaseOffsetsMeters,
    int? targetPanelCount,
    int? manualRows,
    int? manualColumns,
    bool clearTargetPanelCount = false,
    bool clearManualRows = false,
    bool clearManualColumns = false,
  }) {
    return StructureDesignInput(
      siteWidthMeters: siteWidthMeters ?? this.siteWidthMeters,
      siteDepthMeters: siteDepthMeters ?? this.siteDepthMeters,
      latitude: latitude ?? this.latitude,
      facingPreference: facingPreference ?? this.facingPreference,
      mountType: mountType ?? this.mountType,
      frontClearanceMeters: frontClearanceMeters ?? this.frontClearanceMeters,
      rearClearanceMeters: rearClearanceMeters ?? this.rearClearanceMeters,
      sideClearanceMeters: sideClearanceMeters ?? this.sideClearanceMeters,
      frontLegClearanceMeters:
          frontLegClearanceMeters ?? this.frontLegClearanceMeters,
      interRowGapMeters: interRowGapMeters ?? this.interRowGapMeters,
      panelSpec: panelSpec ?? this.panelSpec,
      rowMode: rowMode ?? this.rowMode,
      rowBaseOffsetsMeters:
          rowBaseOffsetsMeters ?? List<double>.from(this.rowBaseOffsetsMeters),
      targetPanelCount: clearTargetPanelCount
          ? null
          : (targetPanelCount ?? this.targetPanelCount),
      manualRows: clearManualRows ? null : (manualRows ?? this.manualRows),
      manualColumns: clearManualColumns
          ? null
          : (manualColumns ?? this.manualColumns),
    );
  }
}
