import 'package:flutter/material.dart';

enum CellType { empty, panel, obstacle, shadow, tree, excluded }

enum ToolMode { placePanel, placeObstacle, placeShadow, placeTree, excludeRoof, erase }

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

enum PanelOrientation { portrait, landscape }

@immutable
class PvSystemDesignState {
  final int cols;
  final int rows;
  final double roofWidthM;
  final double roofLengthM;
  final double panelPowerW;
  final double panelLengthM;
  final double panelWidthM;
  final double panelWeightKg;
  final double panelThicknessM;
  final bool isPortrait;
  final double wallSetbackM;
  final String panelOrientation;
  final bool hasNorthWall;
  final bool hasSouthWall;
  final bool hasEastWall;
  final bool hasWestWall;
  final double northWallHeight;
  final double southWallHeight;
  final double eastWallHeight;
  final double westWallHeight;
  final List<CellType> grid;
  final List<List<CellType>> undoStack;
  final List<List<CellType>> redoStack;
  final List<Offset> polygonVertices;
  final bool isPolygonSketchMode;
  final bool isSafeOverlayActive;
  final double simulationTime;
  final ToolMode activeTool;
  final double latitude;
  final double longitude;
  final FacingDirectionPreference facingPreference;
  final MountType mountType;
  final double frontClearanceM;
  final double rearClearanceM;
  final double sideClearanceM;
  final double frontLegClearanceM;
  final double interRowGapM;
  final double horizontalGapM;
  final double verticalGapM;
  final RowMode rowMode;
  final List<double> rowBaseOffsetsM;
  final int? manualRows;
  final int? manualColumns;
  final int? targetPanelCount;
  final int currentStep;
  final bool isLocationLoading;
  final String? locationError;

  const PvSystemDesignState({
    required this.cols,
    required this.rows,
    required this.roofWidthM,
    required this.roofLengthM,
    required this.panelPowerW,
    required this.panelLengthM,
    required this.panelWidthM,
    required this.panelWeightKg,
    required this.panelThicknessM,
    required this.isPortrait,
    required this.wallSetbackM,
    required this.panelOrientation,
    required this.hasNorthWall,
    required this.hasSouthWall,
    required this.hasEastWall,
    required this.hasWestWall,
    required this.northWallHeight,
    required this.southWallHeight,
    required this.eastWallHeight,
    required this.westWallHeight,
    required this.grid,
    required this.undoStack,
    required this.redoStack,
    required this.polygonVertices,
    required this.isPolygonSketchMode,
    required this.isSafeOverlayActive,
    required this.simulationTime,
    required this.activeTool,
    required this.latitude,
    required this.longitude,
    required this.facingPreference,
    required this.mountType,
    required this.frontClearanceM,
    required this.rearClearanceM,
    required this.sideClearanceM,
    required this.frontLegClearanceM,
    required this.interRowGapM,
    required this.horizontalGapM,
    required this.verticalGapM,
    required this.rowMode,
    required this.rowBaseOffsetsM,
    required this.manualRows,
    required this.manualColumns,
    required this.targetPanelCount,
    required this.currentStep,
    required this.isLocationLoading,
    required this.locationError,
  });

  factory PvSystemDesignState.initial() {
    const int initialCols = 9;
    const int initialRows = 3;
    return PvSystemDesignState(
      cols: initialCols,
      rows: initialRows,
      roofWidthM: 10.0,
      roofLengthM: 8.0,
      panelPowerW: 620.0,
      panelLengthM: 2.28,
      panelWidthM: 1.13,
      panelWeightKg: 22.0,
      panelThicknessM: 0.035,
      isPortrait: true,
      wallSetbackM: 0.5,
      panelOrientation: 'South',
      hasNorthWall: false,
      hasSouthWall: false,
      hasEastWall: false,
      hasWestWall: false,
      northWallHeight: 1.0,
      southWallHeight: 1.0,
      eastWallHeight: 1.0,
      westWallHeight: 1.0,
      grid: List<CellType>.filled(initialCols * initialRows, CellType.empty),
      undoStack: const [],
      redoStack: const [],
      polygonVertices: const [],
      isPolygonSketchMode: false,
      isSafeOverlayActive: false,
      simulationTime: 12.0,
      activeTool: ToolMode.placePanel,
      latitude: 33.3,
      longitude: 44.3,
      facingPreference: FacingDirectionPreference.any,
      mountType: MountType.flatRoof,
      frontClearanceM: 0.5,
      rearClearanceM: 0.5,
      sideClearanceM: 0.3,
      frontLegClearanceM: 0.5,
      interRowGapM: 0.5,
      horizontalGapM: 0.03,
      verticalGapM: 0.03,
      rowMode: RowMode.independent,
      rowBaseOffsetsM: const [0.0],
      manualRows: null,
      manualColumns: null,
      targetPanelCount: null,
      currentStep: 0,
      isLocationLoading: false,
      locationError: null,
    );
  }

  PvSystemDesignState copyWith({
    int? cols,
    int? rows,
    double? roofWidthM,
    double? roofLengthM,
    double? panelPowerW,
    double? panelLengthM,
    double? panelWidthM,
    double? panelWeightKg,
    double? panelThicknessM,
    bool? isPortrait,
    double? wallSetbackM,
    String? panelOrientation,
    bool? hasNorthWall,
    bool? hasSouthWall,
    bool? hasEastWall,
    bool? hasWestWall,
    double? northWallHeight,
    double? southWallHeight,
    double? eastWallHeight,
    double? westWallHeight,
    List<CellType>? grid,
    List<List<CellType>>? undoStack,
    List<List<CellType>>? redoStack,
    List<Offset>? polygonVertices,
    bool? isPolygonSketchMode,
    bool? isSafeOverlayActive,
    double? simulationTime,
    ToolMode? activeTool,
    double? latitude,
    double? longitude,
    FacingDirectionPreference? facingPreference,
    MountType? mountType,
    double? frontClearanceM,
    double? rearClearanceM,
    double? sideClearanceM,
    double? frontLegClearanceM,
    double? interRowGapM,
    double? horizontalGapM,
    double? verticalGapM,
    RowMode? rowMode,
    List<double>? rowBaseOffsetsM,
    int? manualRows,
    int? manualColumns,
    int? targetPanelCount,
    int? currentStep,
    bool? isLocationLoading,
    String? locationError,
    bool clearManualRows = false,
    bool clearManualColumns = false,
    bool clearTargetPanelCount = false,
  }) {
    return PvSystemDesignState(
      cols: cols ?? this.cols,
      rows: rows ?? this.rows,
      roofWidthM: roofWidthM ?? this.roofWidthM,
      roofLengthM: roofLengthM ?? this.roofLengthM,
      panelPowerW: panelPowerW ?? this.panelPowerW,
      panelLengthM: panelLengthM ?? this.panelLengthM,
      panelWidthM: panelWidthM ?? this.panelWidthM,
      panelWeightKg: panelWeightKg ?? this.panelWeightKg,
      panelThicknessM: panelThicknessM ?? this.panelThicknessM,
      isPortrait: isPortrait ?? this.isPortrait,
      wallSetbackM: wallSetbackM ?? this.wallSetbackM,
      panelOrientation: panelOrientation ?? this.panelOrientation,
      hasNorthWall: hasNorthWall ?? this.hasNorthWall,
      hasSouthWall: hasSouthWall ?? this.hasSouthWall,
      hasEastWall: hasEastWall ?? this.hasEastWall,
      hasWestWall: hasWestWall ?? this.hasWestWall,
      northWallHeight: northWallHeight ?? this.northWallHeight,
      southWallHeight: southWallHeight ?? this.southWallHeight,
      eastWallHeight: eastWallHeight ?? this.eastWallHeight,
      westWallHeight: westWallHeight ?? this.westWallHeight,
      grid: grid ?? List<CellType>.from(this.grid),
      undoStack: undoStack ?? List<List<CellType>>.from(this.undoStack.map((l) => List<CellType>.from(l))),
      redoStack: redoStack ?? List<List<CellType>>.from(this.redoStack.map((l) => List<CellType>.from(l))),
      polygonVertices: polygonVertices ?? List<Offset>.from(this.polygonVertices),
      isPolygonSketchMode: isPolygonSketchMode ?? this.isPolygonSketchMode,
      isSafeOverlayActive: isSafeOverlayActive ?? this.isSafeOverlayActive,
      simulationTime: simulationTime ?? this.simulationTime,
      activeTool: activeTool ?? this.activeTool,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      facingPreference: facingPreference ?? this.facingPreference,
      mountType: mountType ?? this.mountType,
      frontClearanceM: frontClearanceM ?? this.frontClearanceM,
      rearClearanceM: rearClearanceM ?? this.rearClearanceM,
      sideClearanceM: sideClearanceM ?? this.sideClearanceM,
      frontLegClearanceM: frontLegClearanceM ?? this.frontLegClearanceM,
      interRowGapM: interRowGapM ?? this.interRowGapM,
      horizontalGapM: horizontalGapM ?? this.horizontalGapM,
      verticalGapM: verticalGapM ?? this.verticalGapM,
      rowMode: rowMode ?? this.rowMode,
      rowBaseOffsetsM: rowBaseOffsetsM ?? List<double>.from(this.rowBaseOffsetsM),
      manualRows: clearManualRows ? null : (manualRows ?? this.manualRows),
      manualColumns: clearManualColumns ? null : (manualColumns ?? this.manualColumns),
      targetPanelCount: clearTargetPanelCount ? null : (targetPanelCount ?? this.targetPanelCount),
      currentStep: currentStep ?? this.currentStep,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      locationError: locationError ?? this.locationError,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cols': cols,
      'rows': rows,
      'roofWidthM': roofWidthM,
      'roofLengthM': roofLengthM,
      'panelPowerW': panelPowerW,
      'panelLengthM': panelLengthM,
      'panelWidthM': panelWidthM,
      'panelWeightKg': panelWeightKg,
      'panelThicknessM': panelThicknessM,
      'isPortrait': isPortrait,
      'wallSetbackM': wallSetbackM,
      'panelOrientation': panelOrientation,
      'hasNorthWall': hasNorthWall,
      'hasSouthWall': hasSouthWall,
      'hasEastWall': hasEastWall,
      'hasWestWall': hasWestWall,
      'northWallHeight': northWallHeight,
      'southWallHeight': southWallHeight,
      'eastWallHeight': eastWallHeight,
      'westWallHeight': westWallHeight,
      'grid': grid.map((e) => e.name).toList(),
      'polygonVertices': polygonVertices.map((v) => {'dx': v.dx, 'dy': v.dy}).toList(),
      'simulationTime': simulationTime,
      'latitude': latitude,
      'longitude': longitude,
      'facingPreference': facingPreference.name,
      'mountType': mountType.name,
      'frontClearanceM': frontClearanceM,
      'rearClearanceM': rearClearanceM,
      'sideClearanceM': sideClearanceM,
      'frontLegClearanceM': frontLegClearanceM,
      'interRowGapM': interRowGapM,
      'horizontalGapM': horizontalGapM,
      'verticalGapM': verticalGapM,
      'rowMode': rowMode.name,
      'rowBaseOffsetsM': rowBaseOffsetsM,
    };
  }

  factory PvSystemDesignState.fromJson(Map<String, dynamic> json) {
    final gridJson = json['grid'] as List<dynamic>? ?? [];
    final parsedGrid = gridJson.map((e) => CellType.values.firstWhere((v) => v.name == e, orElse: () => CellType.empty)).toList();
    final verticesJson = json['polygonVertices'] as List<dynamic>? ?? [];
    final parsedVertices = verticesJson.map((v) {
      final map = v as Map<String, dynamic>;
      return Offset((map['dx'] as num).toDouble(), (map['dy'] as num).toDouble());
    }).toList();

    return PvSystemDesignState(
      cols: json['cols'] as int? ?? 9,
      rows: json['rows'] as int? ?? 3,
      roofWidthM: (json['roofWidthM'] as num? ?? 10.0).toDouble(),
      roofLengthM: (json['roofLengthM'] as num? ?? 8.0).toDouble(),
      panelPowerW: (json['panelPowerW'] as num? ?? 620.0).toDouble(),
      panelLengthM: (json['panelLengthM'] as num? ?? 2.28).toDouble(),
      panelWidthM: (json['panelWidthM'] as num? ?? 1.13).toDouble(),
      panelWeightKg: (json['panelWeightKg'] as num? ?? 22.0).toDouble(),
      panelThicknessM: (json['panelThicknessM'] as num? ?? 0.035).toDouble(),
      isPortrait: json['isPortrait'] as bool? ?? true,
      wallSetbackM: (json['wallSetbackM'] as num? ?? 0.5).toDouble(),
      panelOrientation: json['panelOrientation'] as String? ?? 'South',
      hasNorthWall: json['hasNorthWall'] as bool? ?? false,
      hasSouthWall: json['hasSouthWall'] as bool? ?? false,
      hasEastWall: json['hasEastWall'] as bool? ?? false,
      hasWestWall: json['hasWestWall'] as bool? ?? false,
      northWallHeight: (json['northWallHeight'] as num? ?? 1.0).toDouble(),
      southWallHeight: (json['southWallHeight'] as num? ?? 1.0).toDouble(),
      eastWallHeight: (json['eastWallHeight'] as num? ?? 1.0).toDouble(),
      westWallHeight: (json['westWallHeight'] as num? ?? 1.0).toDouble(),
      grid: parsedGrid,
      undoStack: const [],
      redoStack: const [],
      polygonVertices: parsedVertices,
      isPolygonSketchMode: false,
      isSafeOverlayActive: false,
      simulationTime: (json['simulationTime'] as num? ?? 12.0).toDouble(),
      activeTool: ToolMode.placePanel,
      latitude: (json['latitude'] as num? ?? 33.3).toDouble(),
      longitude: (json['longitude'] as num? ?? 44.3).toDouble(),
      facingPreference: FacingDirectionPreference.values.firstWhere(
        (v) => v.name == json['facingPreference'],
        orElse: () => FacingDirectionPreference.any,
      ),
      mountType: MountType.values.firstWhere((v) => v.name == json['mountType'], orElse: () => MountType.flatRoof),
      frontClearanceM: (json['frontClearanceM'] as num? ?? 0.5).toDouble(),
      rearClearanceM: (json['rearClearanceM'] as num? ?? 0.5).toDouble(),
      sideClearanceM: (json['sideClearanceM'] as num? ?? 0.3).toDouble(),
      frontLegClearanceM: (json['frontLegClearanceM'] as num? ?? 0.5).toDouble(),
      interRowGapM: (json['interRowGapM'] as num? ?? 0.5).toDouble(),
      horizontalGapM: (json['horizontalGapM'] as num? ?? 0.03).toDouble(),
      verticalGapM: (json['verticalGapM'] as num? ?? 0.03).toDouble(),
      rowMode: RowMode.values.firstWhere((v) => v.name == json['rowMode'], orElse: () => RowMode.independent),
      rowBaseOffsetsM: const [0.0],
      manualRows: null,
      manualColumns: null,
      targetPanelCount: null,
      currentStep: 0,
      isLocationLoading: false,
      locationError: null,
    );
  }
}
