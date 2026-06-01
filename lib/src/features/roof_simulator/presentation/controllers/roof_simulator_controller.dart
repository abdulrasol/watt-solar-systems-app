import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/roof_simulator/domain/models/roof_simulator_state.dart';

class RoofSimulatorController extends Notifier<RoofSimulatorState> {
  @override
  RoofSimulatorState build() {
    return RoofSimulatorState.initial();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // HISTORY / UNDO-REDO STATE MANAGEMENT
  // ───────────────────────────────────────────────────────────────────────────

  void saveStateToHistory() {
    final List<CellType> gridCopy = List<CellType>.from(state.grid);
    final List<List<CellType>> updatedUndo = List<List<CellType>>.from(
      state.undoStack.map((l) => List<CellType>.from(l)),
    );
    updatedUndo.add(gridCopy);

    state = state.copyWith(
      undoStack: updatedUndo,
      redoStack: const [], // Clear redo stack on new action
    );
  }

  void undo() {
    if (state.undoStack.isEmpty) return;

    final updatedUndo = List<List<CellType>>.from(
      state.undoStack.map((l) => List<CellType>.from(l)),
    );
    final prev = updatedUndo.removeLast();

    final updatedRedo = List<List<CellType>>.from(
      state.redoStack.map((l) => List<CellType>.from(l)),
    );
    updatedRedo.add(List<CellType>.from(state.grid));

    state = state.copyWith(
      grid: prev,
      undoStack: updatedUndo,
      redoStack: updatedRedo,
    );
  }

  void redo() {
    if (state.redoStack.isEmpty) return;

    final updatedRedo = List<List<CellType>>.from(
      state.redoStack.map((l) => List<CellType>.from(l)),
    );
    final next = updatedRedo.removeLast();

    final updatedUndo = List<List<CellType>>.from(
      state.undoStack.map((l) => List<CellType>.from(l)),
    );
    updatedUndo.add(List<CellType>.from(state.grid));

    state = state.copyWith(
      grid: next,
      undoStack: updatedUndo,
      redoStack: updatedRedo,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // PARAMETER UPDATES AND GRID ADAPTATIONS
  // ───────────────────────────────────────────────────────────────────────────

  void updateRoofDimensions(double width, double length) {
    state = state.copyWith(roofWidthM: width, roofLengthM: length);
    updateGridFromDimensions();
  }

  void updatePanelSpecifications({
    double? powerW,
    double? lengthM,
    double? widthM,
    double? weightKg,
  }) {
    state = state.copyWith(
      panelPowerW: powerW ?? state.panelPowerW,
      panelLengthM: lengthM ?? state.panelLengthM,
      panelWidthM: widthM ?? state.panelWidthM,
      panelWeightKg: weightKg ?? state.panelWeightKg,
    );
    updateGridFromDimensions();
  }

  void updatePortrait(bool isPortrait) {
    state = state.copyWith(isPortrait: isPortrait);
    updateGridFromDimensions();
  }

  void updateWallSetback(double setback) {
    state = state.copyWith(wallSetbackM: setback);
  }

  void updateWallToggles({
    bool? north,
    bool? south,
    bool? east,
    bool? west,
  }) {
    state = state.copyWith(
      hasNorthWall: north ?? state.hasNorthWall,
      hasSouthWall: south ?? state.hasSouthWall,
      hasEastWall: east ?? state.hasEastWall,
      hasWestWall: west ?? state.hasWestWall,
    );
  }

  void updateWallHeights({
    double? north,
    double? south,
    double? east,
    double? west,
  }) {
    state = state.copyWith(
      northWallHeight: north ?? state.northWallHeight,
      southWallHeight: south ?? state.southWallHeight,
      eastWallHeight: east ?? state.eastWallHeight,
      westWallHeight: west ?? state.westWallHeight,
    );
  }

  void updateGridFromDimensions() {
    final double cellW = state.isPortrait ? state.panelWidthM : state.panelLengthM;
    final double cellH = state.isPortrait ? state.panelLengthM : state.panelWidthM;
    final computedCols = (state.roofWidthM / cellW).floor().clamp(2, 25);
    final computedRows = (state.roofLengthM / cellH).floor().clamp(2, 25);

    if (computedCols != state.cols || computedRows != state.rows) {
      final oldCols = state.cols;
      final oldRows = state.rows;
      
      final newGrid = List<CellType>.filled(computedCols * computedRows, CellType.empty);
      for (int r = 0; r < computedRows; r++) {
        for (int c = 0; c < computedCols; c++) {
          if (r < oldRows && c < oldCols) {
            newGrid[r * computedCols + c] = state.grid[r * oldCols + c];
          }
        }
      }

      state = state.copyWith(
        cols: computedCols,
        rows: computedRows,
        grid: newGrid,
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CELL TOUCH OPERATIONS & GRID ACTIONS
  // ───────────────────────────────────────────────────────────────────────────

  void handleCellTap(int index) {
    saveStateToHistory();

    final List<CellType> newGrid = List<CellType>.from(state.grid);
    final CellType targetType = newGrid[index];

    switch (state.activeTool) {
      case ToolMode.placePanel:
        newGrid[index] = (targetType == CellType.panel) ? CellType.empty : CellType.panel;
        break;
      case ToolMode.placeObstacle:
        newGrid[index] = (targetType == CellType.obstacle) ? CellType.empty : CellType.obstacle;
        break;
      case ToolMode.placeShadow:
        newGrid[index] = (targetType == CellType.shadow) ? CellType.empty : CellType.shadow;
        break;
      case ToolMode.placeTree:
        newGrid[index] = (targetType == CellType.tree) ? CellType.empty : CellType.tree;
        break;
      case ToolMode.excludeRoof:
        newGrid[index] = (targetType == CellType.excluded) ? CellType.empty : CellType.excluded;
        break;
      case ToolMode.erase:
        newGrid[index] = CellType.empty;
        break;
    }

    state = state.copyWith(grid: newGrid);
  }

  void clearGrid() {
    saveStateToHistory();
    state = state.copyWith(
      grid: List<CellType>.filled(state.cols * state.rows, CellType.empty),
    );
  }

  void autofillRoof({bool avoidShade = true}) {
    saveStateToHistory();
    final List<CellType> newGrid = List<CellType>.from(state.grid);
    for (int i = 0; i < newGrid.length; i++) {
      if (newGrid[i] == CellType.empty) {
        final int r = i ~/ state.cols;
        final int c = i % state.cols;
        if (isInSetbackZone(r, c)) continue;
        if (avoidShade && isCellShaded(i)) continue;
        newGrid[i] = CellType.panel;
      }
    }
    state = state.copyWith(grid: newGrid);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ALIGNMENTS & ROTATIONS
  // ───────────────────────────────────────────────────────────────────────────

  void alignLayoutToSouth() {
    saveStateToHistory();
    state = state.copyWith(panelOrientation: 'South');
  }

  void rotateGrid90Clockwise() {
    saveStateToHistory();
    final int oldRows = state.rows;
    final int oldCols = state.cols;
    final int newRows = oldCols;
    final int newCols = oldRows;

    final List<CellType> newGrid = List.filled(newRows * newCols, CellType.empty);

    for (int r = 0; r < oldRows; r++) {
      for (int c = 0; c < oldCols; c++) {
        final oldIndex = r * oldCols + c;
        final newRow = c;
        final newCol = oldRows - 1 - r;
        final newIndex = newRow * newCols + newCol;
        newGrid[newIndex] = state.grid[oldIndex];
      }
    }

    // Rotate border walls configuration clockwise:
    // Old West (left) -> New North (top)
    // Old North (top) -> New East (right)
    // Old East (right) -> New South (bottom)
    // Old South (bottom) -> New West (left)
    final bool newHasNorth = state.hasWestWall;
    final bool newHasEast = state.hasNorthWall;
    final bool newHasSouth = state.hasEastWall;
    final bool newHasWest = state.hasSouthWall;

    final double oldNorthHeight = state.northWallHeight;
    final double oldEastHeight = state.eastWallHeight;
    final double oldSouthHeight = state.southWallHeight;
    final double oldWestHeight = state.westWallHeight;

    state = state.copyWith(
      rows: newRows,
      cols: newCols,
      grid: newGrid,
      hasNorthWall: newHasNorth,
      hasEastWall: newHasEast,
      hasSouthWall: newHasSouth,
      hasWestWall: newHasWest,
      northWallHeight: oldWestHeight,
      eastWallHeight: oldNorthHeight,
      southWallHeight: oldEastHeight,
      westWallHeight: oldSouthHeight,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // POLYGON PERIMETER DRAWING & MANIPULATION
  // ───────────────────────────────────────────────────────────────────────────

  void togglePolygonSketchMode() {
    state = state.copyWith(
      isPolygonSketchMode: !state.isPolygonSketchMode,
      polygonVertices: const [],
    );
  }

  void addPolygonVertex(Offset vertex) {
    if (!state.isPolygonSketchMode) return;
    final updatedVertices = List<Offset>.from(state.polygonVertices)..add(vertex);
    state = state.copyWith(polygonVertices: updatedVertices);
  }

  void removeLastPolygonVertex() {
    if (!state.isPolygonSketchMode || state.polygonVertices.isEmpty) return;
    final updatedVertices = List<Offset>.from(state.polygonVertices)..removeLast();
    state = state.copyWith(polygonVertices: updatedVertices);
  }

  void clearPolygonVertices() {
    state = state.copyWith(polygonVertices: const []);
  }

  void updatePolygonVertex(int index, Offset newOffset) {
    if (index < 0 || index >= state.polygonVertices.length) return;
    final updatedVertices = List<Offset>.from(state.polygonVertices);
    updatedVertices[index] = newOffset;
    state = state.copyWith(polygonVertices: updatedVertices);
  }

  void applyPolygonSketch() {
    if (state.polygonVertices.length < 3) return;

    saveStateToHistory();

    final List<CellType> newGrid = List<CellType>.from(state.grid);
    for (int r = 0; r < state.rows; r++) {
      for (int c = 0; c < state.cols; c++) {
        final index = r * state.cols + c;
        final inside = isPointInPolygon(c.toDouble(), r.toDouble(), state.polygonVertices);
        if (!inside) {
          newGrid[index] = CellType.excluded;
        } else {
          if (newGrid[index] == CellType.excluded) {
            newGrid[index] = CellType.empty;
          }
        }
      }
    }

    state = state.copyWith(
      grid: newGrid,
      isPolygonSketchMode: false,
      polygonVertices: const [],
    );
  }

  bool isPointInPolygon(double x, double y, List<Offset> polygon) {
    if (polygon.length < 3) return false;
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].dy > y) != (polygon[j].dy > y) &&
          (x < (polygon[j].dx - polygon[i].dx) * (y - polygon[i].dy) / (polygon[j].dy - polygon[i].dy) + polygon[i].dx)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SOLAR & WALL SHADING & SETBACK CALCULATIONS
  // ───────────────────────────────────────────────────────────────────────────

  void toggleSafeOverlay() {
    state = state.copyWith(isSafeOverlayActive: !state.isSafeOverlayActive);
  }

  void updateSimulationTime(double hour) {
    state = state.copyWith(simulationTime: hour);
  }

  void selectTool(ToolMode tool) {
    state = state.copyWith(activeTool: tool);
  }

  void loadState(RoofSimulatorState newState) {
    saveStateToHistory();
    state = newState;
  }

  void updateGrid(List<CellType> newGrid) {
    state = state.copyWith(grid: newGrid);
  }

  /// Dynamic shadow multiplier based on diurnal hours (8 AM to 5 PM)
  double get shadowMultiplier {
    // Hour 12.0 is Noon (multiplier = 0.5)
    // Hour 8.0 and 17.0 are extreme hours (multiplier = 2.5)
    double distanceFromNoon = (state.simulationTime - 12.0).abs();
    return 0.5 + (distanceFromNoon / 4.5) * 2.0;
  }

  bool isInSetbackZone(int r, int c) {
    if (state.wallSetbackM <= 0) return false;
    final double cellW = state.isPortrait ? state.panelWidthM : state.panelLengthM;
    final double cellH = state.isPortrait ? state.panelLengthM : state.panelWidthM;

    final double distLeft = c * cellW;
    final double distRight = (state.cols - 1 - c) * cellW;
    final double distTop = r * cellH;
    final double distBottom = (state.rows - 1 - r) * cellH;

    bool nearLeft = distLeft < state.wallSetbackM;
    bool nearRight = distRight < state.wallSetbackM;
    bool nearTop = distTop < state.wallSetbackM;
    bool nearBottom = distBottom < state.wallSetbackM;

    return (state.hasWestWall && nearLeft) ||
        (state.hasEastWall && nearRight) ||
        (state.hasNorthWall && nearTop) ||
        (state.hasSouthWall && nearBottom);
  }

  CellType? shadingSourceCell(int index) {
    int row = index ~/ state.cols;
    int col = index % state.cols;

    // 1. Calculate physical wall shadows based on active walls, heights, and panel orientation
    final double cellW = state.isPortrait ? state.panelWidthM : state.panelLengthM;
    final double cellH = state.isPortrait ? state.panelLengthM : state.panelWidthM;

    final double distToNorth = (row + 0.5) * cellH;
    final double distToSouth = (state.rows - 0.5 - row) * cellH;
    final double distToWest = (col + 0.5) * cellW;
    final double distToEast = (state.cols - 0.5 - col) * cellW;

    bool isShadedByWall = false;
    final double shadowFactor = shadowMultiplier;

    if (state.panelOrientation == 'South') {
      if (state.hasSouthWall && distToSouth < state.southWallHeight * shadowFactor) isShadedByWall = true;
      if (state.hasEastWall && distToEast < state.eastWallHeight * shadowFactor) isShadedByWall = true;
      if (state.hasWestWall && distToWest < state.westWallHeight * shadowFactor) isShadedByWall = true;
    } else if (state.panelOrientation == 'North') {
      if (state.hasNorthWall && distToNorth < state.northWallHeight * shadowFactor) isShadedByWall = true;
      if (state.hasEastWall && distToEast < state.eastWallHeight * shadowFactor) isShadedByWall = true;
      if (state.hasWestWall && distToWest < state.westWallHeight * shadowFactor) isShadedByWall = true;
    } else if (state.panelOrientation == 'East') {
      if (state.hasEastWall && distToEast < state.eastWallHeight * shadowFactor) isShadedByWall = true;
      if (state.hasNorthWall && distToNorth < state.northWallHeight * shadowFactor) isShadedByWall = true;
      if (state.hasSouthWall && distToSouth < state.southWallHeight * shadowFactor) isShadedByWall = true;
    } else if (state.panelOrientation == 'West') {
      if (state.hasWestWall && distToWest < state.westWallHeight * shadowFactor) isShadedByWall = true;
      if (state.hasNorthWall && distToNorth < state.northWallHeight * shadowFactor) isShadedByWall = true;
      if (state.hasSouthWall && distToSouth < state.southWallHeight * shadowFactor) isShadedByWall = true;
    }

    if (isShadedByWall) {
      return CellType.shadow;
    }

    // 2. Calculate shading from adjacent custom objects (trees, chimneys, etc.)
    CellType? getBlockerType(int r, int c) {
      if (r < 0 || r >= state.rows || c < 0 || c >= state.cols) return null;
      final type = state.grid[r * state.cols + c];
      if (type == CellType.obstacle || type == CellType.shadow || type == CellType.tree) {
        return type;
      }
      return null;
    }

    if (state.panelOrientation == 'South') {
      return getBlockerType(row + 1, col) ?? getBlockerType(row + 1, col - 1) ?? getBlockerType(row + 1, col + 1);
    } else if (state.panelOrientation == 'North') {
      return getBlockerType(row - 1, col) ?? getBlockerType(row - 1, col - 1) ?? getBlockerType(row - 1, col + 1);
    } else if (state.panelOrientation == 'East') {
      return getBlockerType(row, col + 1) ?? getBlockerType(row - 1, col + 1) ?? getBlockerType(row + 1, col + 1);
    } else if (state.panelOrientation == 'West') {
      return getBlockerType(row, col - 1) ?? getBlockerType(row - 1, col - 1) ?? getBlockerType(row + 1, col - 1);
    }
    return null;
  }

  bool isCellShaded(int index) {
    return shadingSourceCell(index) != null;
  }

  double get peakPower {
    double total = 0.0;
    for (int i = 0; i < state.grid.length; i++) {
      if (state.grid[i] == CellType.panel) {
        final shadeSource = shadingSourceCell(i);
        if (shadeSource != null) {
          double factor = 1.0;
          if (shadeSource == CellType.tree) {
            factor = 0.60; // 40% yield loss
          } else if (shadeSource == CellType.shadow) {
            factor = 0.25; // 75% yield loss
          } else if (shadeSource == CellType.obstacle) {
            factor = 0.10; // 90% yield loss
          }
          total += (state.panelPowerW * factor) / 1000.0;
        } else {
          total += state.panelPowerW / 1000.0;
        }
      }
    }
    return total;
  }

  int get panelsCount => state.grid.where((c) => c == CellType.panel).length;
  int get obstaclesCount => state.grid.where((c) => c == CellType.obstacle || c == CellType.shadow || c == CellType.tree).length;

  double get panelAreaM2 => state.panelLengthM * state.panelWidthM;
  double get totalArea => panelsCount * panelAreaM2;
}

final roofSimulatorProvider = NotifierProvider<RoofSimulatorController, RoofSimulatorState>(() {
  return RoofSimulatorController();
});
