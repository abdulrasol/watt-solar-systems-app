import 'package:flutter/material.dart';

enum CellType { empty, panel, obstacle, shadow, tree, excluded }

enum ToolMode { placePanel, placeObstacle, placeShadow, placeTree, excludeRoof, erase }

@immutable
class RoofSimulatorState {
  final int cols;
  final int rows;

  // Roof dimensions
  final double roofWidthM;
  final double roofLengthM;

  // Panel specifications
  final double panelPowerW;
  final double panelLengthM;
  final double panelWidthM;
  final double panelWeightKg;

  // Setback and orientation specifications
  final bool isPortrait;
  final double wallSetbackM;
  final String panelOrientation; // 'South', 'North', 'East', 'West'

  // Optional Boundary Walls config
  final bool hasNorthWall;
  final bool hasSouthWall;
  final bool hasEastWall;
  final bool hasWestWall;

  final double northWallHeight;
  final double southWallHeight;
  final double eastWallHeight;
  final double westWallHeight;

  // Simulation Grid and Overlay States
  final List<CellType> grid;
  final List<List<CellType>> undoStack;
  final List<List<CellType>> redoStack;
  final List<Offset> polygonVertices;
  final bool isPolygonSketchMode;
  final bool isSafeOverlayActive;

  // Dynamic Sun Ray Shadow time parameter (hours: 8.0 - 17.0)
  final double simulationTime;

  // Active Tool Mode
  final ToolMode activeTool;

  const RoofSimulatorState({
    required this.cols,
    required this.rows,
    required this.roofWidthM,
    required this.roofLengthM,
    required this.panelPowerW,
    required this.panelLengthM,
    required this.panelWidthM,
    required this.panelWeightKg,
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
  });

  /// Factory constructor to initialize default/starting state
  factory RoofSimulatorState.initial() {
    const int initialCols = 9;
    const int initialRows = 3;
    return RoofSimulatorState(
      cols: initialCols,
      rows: initialRows,
      roofWidthM: 10.0,
      roofLengthM: 8.0,
      panelPowerW: 620.0,
      panelLengthM: 2.2,
      panelWidthM: 1.1,
      panelWeightKg: 22.0,
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
      simulationTime: 12.0, // Default to Noon solar altitude
      activeTool: ToolMode.placePanel,
    );
  }

  /// Deep copies the state with optional adjustments
  RoofSimulatorState copyWith({
    int? cols,
    int? rows,
    double? roofWidthM,
    double? roofLengthM,
    double? panelPowerW,
    double? panelLengthM,
    double? panelWidthM,
    double? panelWeightKg,
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
  }) {
    return RoofSimulatorState(
      cols: cols ?? this.cols,
      rows: rows ?? this.rows,
      roofWidthM: roofWidthM ?? this.roofWidthM,
      roofLengthM: roofLengthM ?? this.roofLengthM,
      panelPowerW: panelPowerW ?? this.panelPowerW,
      panelLengthM: panelLengthM ?? this.panelLengthM,
      panelWidthM: panelWidthM ?? this.panelWidthM,
      panelWeightKg: panelWeightKg ?? this.panelWeightKg,
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
    );
  }

  /// Converts Simulator state to Map/JSON
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
      'isPolygonSketchMode': isPolygonSketchMode,
      'isSafeOverlayActive': isSafeOverlayActive,
      'simulationTime': simulationTime,
      'activeTool': activeTool.name,
    };
  }

  /// Parses Simulator state from Map/JSON
  factory RoofSimulatorState.fromJson(Map<String, dynamic> json) {
    final List<dynamic> gridJson = json['grid'] as List<dynamic>? ?? [];
    final List<CellType> parsedGrid = gridJson.map((e) {
      return CellType.values.firstWhere(
        (val) => val.name == e,
        orElse: () => CellType.empty,
      );
    }).toList();

    final List<dynamic> verticesJson = json['polygonVertices'] as List<dynamic>? ?? [];
    final List<Offset> parsedVertices = verticesJson.map((v) {
      final map = v as Map<String, dynamic>;
      return Offset((map['dx'] as num).toDouble(), (map['dy'] as num).toDouble());
    }).toList();

    final activeToolName = json['activeTool'] as String? ?? 'placePanel';
    final ToolMode parsedTool = ToolMode.values.firstWhere(
      (val) => val.name == activeToolName,
      orElse: () => ToolMode.placePanel,
    );

    return RoofSimulatorState(
      cols: json['cols'] as int? ?? 9,
      rows: json['rows'] as int? ?? 3,
      roofWidthM: (json['roofWidthM'] as num? ?? 10.0).toDouble(),
      roofLengthM: (json['roofLengthM'] as num? ?? 8.0).toDouble(),
      panelPowerW: (json['panelPowerW'] as num? ?? 620.0).toDouble(),
      panelLengthM: (json['panelLengthM'] as num? ?? 2.2).toDouble(),
      panelWidthM: (json['panelWidthM'] as num? ?? 1.1).toDouble(),
      panelWeightKg: (json['panelWeightKg'] as num? ?? 22.0).toDouble(),
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
      isPolygonSketchMode: json['isPolygonSketchMode'] as bool? ?? false,
      isSafeOverlayActive: json['isSafeOverlayActive'] as bool? ?? false,
      simulationTime: (json['simulationTime'] as num? ?? 12.0).toDouble(),
      activeTool: parsedTool,
    );
  }
}
