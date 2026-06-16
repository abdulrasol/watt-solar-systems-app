import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/energy_estimate.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/shadow_calculator.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/structure_design_calculator.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/energy_estimator.dart';
import 'package:solar_hub/src/features/pv_system_designer/data/location_service.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/utils/debounce_util.dart';

final pvSystemDesignerProvider = NotifierProvider<PvSystemDesignerController, PvSystemDesignState>(() {
  return PvSystemDesignerController();
});

class PvSystemDesignerController extends Notifier<PvSystemDesignState> {
  final _shadowCalc = ShadowCalculator();
  final _structureCalc = StructureDesignCalculator();
  final _energyEstimator = EnergyEstimator();
  final _locationService = GeolocatorLocationService();
  final _debouncer = Debouncer(milliseconds: 300);

  FrameResult? _frameResult;
  EnergyEstimate? _energyEstimate;

  FrameResult? get frameResult => _frameResult;
  EnergyEstimate? get energyEstimate => _energyEstimate;

  @override
  PvSystemDesignState build() => PvSystemDesignState.initial();

  void cleanup() {
    _debouncer.dispose();
  }

  // ── STEP NAVIGATION ──

  void setStep(int step) => state = state.copyWith(currentStep: step);
  void nextStep() => state = state.copyWith(currentStep: (state.currentStep + 1).clamp(0, 6));
  void previousStep() => state = state.copyWith(currentStep: (state.currentStep - 1).clamp(0, 6));

  // ── HISTORY / UNDO-REDO ──

  void saveStateToHistory() {
    final gridCopy = List<CellType>.from(state.grid);
    final updatedUndo = List<List<CellType>>.from(state.undoStack.map((l) => List<CellType>.from(l)));
    updatedUndo.add(gridCopy);
    state = state.copyWith(undoStack: updatedUndo, redoStack: const []);
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    final updatedUndo = List<List<CellType>>.from(state.undoStack.map((l) => List<CellType>.from(l)));
    final prev = updatedUndo.removeLast();
    final updatedRedo = List<List<CellType>>.from(state.redoStack.map((l) => List<CellType>.from(l)));
    updatedRedo.add(List<CellType>.from(state.grid));
    state = state.copyWith(grid: prev, undoStack: updatedUndo, redoStack: updatedRedo);
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final updatedRedo = List<List<CellType>>.from(state.redoStack.map((l) => List<CellType>.from(l)));
    final next = updatedRedo.removeLast();
    final updatedUndo = List<List<CellType>>.from(state.undoStack.map((l) => List<CellType>.from(l)));
    updatedUndo.add(List<CellType>.from(state.grid));
    state = state.copyWith(grid: next, undoStack: updatedUndo, redoStack: updatedRedo);
  }

  // ── SITE PARAMETERS ──

  void updateLatitude(double value) {
    state = state.copyWith(latitude: value, locationError: null);
    _debouncer.run(recalculate);
  }

  void updateLongitude(double value) {
    state = state.copyWith(longitude: value);
  }

  void updateFacingPreference(FacingDirectionPreference value) {
    state = state.copyWith(facingPreference: value);
    _debouncer.run(recalculate);
  }

  void updateMountType(MountType value) {
    state = state.copyWith(mountType: value);
    _debouncer.run(recalculate);
  }

  Future<bool> useCurrentLocation() async {
    state = state.copyWith(isLocationLoading: true, locationError: null);
    try {
      final location = await _locationService.getCurrentLocation();
      state = state.copyWith(latitude: location.latitude, longitude: location.longitude, isLocationLoading: false);
      _debouncer.run(recalculate);
      return true;
    } on LocationException catch (e) {
      state = state.copyWith(isLocationLoading: false, locationError: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLocationLoading: false, locationError: 'Failed to get location: $e');
      return false;
    }
  }

  // ── ROOF CONFIGURATION ──

  void updateRoofDimensions(double width, double length) {
    state = state.copyWith(roofWidthM: width, roofLengthM: length);
    updateGridFromDimensions();
  }

  void updateWallSetback(double setback) {
    state = state.copyWith(wallSetbackM: setback);
  }

  void updateWallToggles({bool? north, bool? south, bool? east, bool? west}) {
    state = state.copyWith(
      hasNorthWall: north ?? state.hasNorthWall,
      hasSouthWall: south ?? state.hasSouthWall,
      hasEastWall: east ?? state.hasEastWall,
      hasWestWall: west ?? state.hasWestWall,
    );
  }

  void updateWallHeights({double? north, double? south, double? east, double? west}) {
    state = state.copyWith(
      northWallHeight: north ?? state.northWallHeight,
      southWallHeight: south ?? state.southWallHeight,
      eastWallHeight: east ?? state.eastWallHeight,
      westWallHeight: west ?? state.westWallHeight,
    );
  }

  // ── PANEL SPECIFICATIONS ──

  void updatePanelSpec({double? powerW, double? lengthM, double? widthM, double? weightKg, double? thicknessM}) {
    state = state.copyWith(
      panelPowerW: powerW ?? state.panelPowerW,
      panelLengthM: lengthM ?? state.panelLengthM,
      panelWidthM: widthM ?? state.panelWidthM,
      panelWeightKg: weightKg ?? state.panelWeightKg,
      panelThicknessM: thicknessM ?? state.panelThicknessM,
    );
    updateGridFromDimensions();
  }

  void updatePortrait(bool isPortrait) {
    state = state.copyWith(isPortrait: isPortrait);
    updateGridFromDimensions();
  }

  void updatePanelOrientation(String orientation) {
    state = state.copyWith(panelOrientation: orientation);
  }

  // ── STRUCTURE CLEARANCES ──

  void updateFrontClearance(double value) {
    state = state.copyWith(frontClearanceM: value);
    _debouncer.run(recalculate);
  }

  void updateRearClearance(double value) {
    state = state.copyWith(rearClearanceM: value);
    _debouncer.run(recalculate);
  }

  void updateSideClearance(double value) {
    state = state.copyWith(sideClearanceM: value);
    _debouncer.run(recalculate);
  }

  void updateFrontLegClearance(double value) {
    state = state.copyWith(frontLegClearanceM: value);
    _debouncer.run(recalculate);
  }

  void updateInterRowGap(double value) {
    state = state.copyWith(interRowGapM: value);
    _debouncer.run(recalculate);
  }

  void updateHorizontalGap(double value) {
    state = state.copyWith(horizontalGapM: value);
    _debouncer.run(recalculate);
  }

  void updateVerticalGap(double value) {
    state = state.copyWith(verticalGapM: value);
    _debouncer.run(recalculate);
  }

  void updateRowMode(RowMode value) {
    state = state.copyWith(rowMode: value);
    _debouncer.run(recalculate);
  }

  void updateRowBaseOffset(int index, double value) {
    final offsets = List<double>.from(state.rowBaseOffsetsM);
    while (offsets.length <= index) {
      offsets.add(0);
    }
    offsets[index] = value;
    state = state.copyWith(rowBaseOffsetsM: offsets);
    _debouncer.run(recalculate);
  }

  void incrementRows() {
    final maxRows = _frameResult?.maxRows ?? 0;
    final current = state.manualRows ?? _frameResult?.rows ?? 0;
    if (current >= maxRows) return;
    state = state.copyWith(manualRows: current + 1);
    recalculate();
  }

  void decrementRows() {
    final current = state.manualRows ?? _frameResult?.rows ?? 0;
    if (current <= 1) return;
    state = state.copyWith(manualRows: current - 1);
    recalculate();
  }

  void incrementColumns() {
    final maxColumns = _frameResult?.maxColumns ?? 0;
    final current = state.manualColumns ?? _frameResult?.columns ?? 0;
    if (current >= maxColumns) return;
    state = state.copyWith(manualColumns: current + 1);
    recalculate();
  }

  void decrementColumns() {
    final current = state.manualColumns ?? _frameResult?.columns ?? 0;
    if (current <= 1) return;
    state = state.copyWith(manualColumns: current - 1);
    recalculate();
  }

  void resetAutoLayout() {
    state = state.copyWith(clearManualRows: true, clearManualColumns: true);
    recalculate();
  }

  // ── GRID OPERATIONS ──

  void updateGridFromDimensions() {
    final cellW = state.isPortrait ? state.panelWidthM : state.panelLengthM;
    final cellH = state.isPortrait ? state.panelLengthM : state.panelWidthM;
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
      state = state.copyWith(cols: computedCols, rows: computedRows, grid: newGrid);
    }
  }

  void handleCellTap(int index) {
    saveStateToHistory();
    final newGrid = List<CellType>.from(state.grid);
    final targetType = newGrid[index];
    switch (state.activeTool) {
      case ToolMode.placePanel:
        newGrid[index] = (targetType == CellType.panel) ? CellType.empty : CellType.panel;
      case ToolMode.placeObstacle:
        newGrid[index] = (targetType == CellType.obstacle) ? CellType.empty : CellType.obstacle;
      case ToolMode.placeShadow:
        newGrid[index] = (targetType == CellType.shadow) ? CellType.empty : CellType.shadow;
      case ToolMode.placeTree:
        newGrid[index] = (targetType == CellType.tree) ? CellType.empty : CellType.tree;
      case ToolMode.excludeRoof:
        newGrid[index] = (targetType == CellType.excluded) ? CellType.empty : CellType.excluded;
      case ToolMode.erase:
        newGrid[index] = CellType.empty;
    }
    state = state.copyWith(grid: newGrid);
  }

  void clearGrid() {
    saveStateToHistory();
    state = state.copyWith(grid: List<CellType>.filled(state.cols * state.rows, CellType.empty));
  }

  void autofillRoof({bool avoidShade = true}) {
    saveStateToHistory();
    final newGrid = List<CellType>.from(state.grid);
    for (int i = 0; i < newGrid.length; i++) {
      if (newGrid[i] == CellType.empty) {
        final r = i ~/ state.cols;
        final c = i % state.cols;
        if (_shadowCalc.isInSetbackZone(
          r: r, c: c, rows: state.rows, cols: state.cols,
          wallSetbackM: state.wallSetbackM, panelWidthM: state.panelWidthM,
          panelLengthM: state.panelLengthM, isPortrait: state.isPortrait,
          hasNorthWall: state.hasNorthWall, hasSouthWall: state.hasSouthWall,
          hasEastWall: state.hasEastWall, hasWestWall: state.hasWestWall,
        )) {
          continue;
        }
        if (avoidShade && _isCellShaded(i)) {
          continue;
        }
        newGrid[i] = CellType.panel;
      }
    }
    state = state.copyWith(grid: newGrid);
  }

  void rotateGrid90Clockwise() {
    saveStateToHistory();
    final oldRows = state.rows;
    final oldCols = state.cols;
    final newRows = oldCols;
    final newCols = oldRows;
    final newGrid = List.filled(newRows * newCols, CellType.empty);
    for (int r = 0; r < oldRows; r++) {
      for (int c = 0; c < oldCols; c++) {
        final oldIndex = r * oldCols + c;
        final newRow = c;
        final newCol = oldRows - 1 - r;
        newGrid[newRow * newCols + newCol] = state.grid[oldIndex];
      }
    }
    final newHasNorth = state.hasWestWall;
    final newHasEast = state.hasNorthWall;
    final newHasSouth = state.hasEastWall;
    final newHasWest = state.hasSouthWall;
    state = state.copyWith(
      rows: newRows, cols: newCols, grid: newGrid,
      hasNorthWall: newHasNorth, hasEastWall: newHasEast,
      hasSouthWall: newHasSouth, hasWestWall: newHasWest,
      northWallHeight: state.westWallHeight, eastWallHeight: state.northWallHeight,
      southWallHeight: state.eastWallHeight, westWallHeight: state.southWallHeight,
    );
  }

  void alignLayoutToSouth() {
    saveStateToHistory();
    state = state.copyWith(panelOrientation: 'South');
  }

  // ── POLYGON SKETCHING ──

  void togglePolygonSketchMode() {
    state = state.copyWith(isPolygonSketchMode: !state.isPolygonSketchMode, polygonVertices: const []);
  }

  void addPolygonVertex(Offset vertex) {
    if (!state.isPolygonSketchMode) return;
    state = state.copyWith(polygonVertices: List<Offset>.from(state.polygonVertices)..add(vertex));
  }

  void removeLastPolygonVertex() {
    if (!state.isPolygonSketchMode || state.polygonVertices.isEmpty) return;
    state = state.copyWith(polygonVertices: List<Offset>.from(state.polygonVertices)..removeLast());
  }

  void clearPolygonVertices() {
    state = state.copyWith(polygonVertices: const []);
  }

  void updatePolygonVertex(int index, Offset newOffset) {
    if (index < 0 || index >= state.polygonVertices.length) return;
    final updated = List<Offset>.from(state.polygonVertices);
    updated[index] = newOffset;
    state = state.copyWith(polygonVertices: updated);
  }

  void applyPolygonSketch() {
    if (state.polygonVertices.length < 3) return;
    saveStateToHistory();
    final newGrid = List<CellType>.from(state.grid);
    for (int r = 0; r < state.rows; r++) {
      for (int c = 0; c < state.cols; c++) {
        final index = r * state.cols + c;
        final inside = _shadowCalc.isPointInPolygon(c.toDouble(), r.toDouble(), state.polygonVertices);
        if (!inside) {
          newGrid[index] = CellType.excluded;
        } else if (newGrid[index] == CellType.excluded) {
          newGrid[index] = CellType.empty;
        }
      }
    }
    state = state.copyWith(grid: newGrid, isPolygonSketchMode: false, polygonVertices: const []);
  }

  // ── SHADOW & SIMULATION ──

  void toggleSafeOverlay() {
    state = state.copyWith(isSafeOverlayActive: !state.isSafeOverlayActive);
  }

  void updateSimulationTime(double hour) {
    state = state.copyWith(simulationTime: hour);
  }

  void selectTool(ToolMode tool) {
    state = state.copyWith(activeTool: tool);
  }

  bool isInSetbackZone(int r, int c) {
    return _shadowCalc.isInSetbackZone(
      r: r, c: c, rows: state.rows, cols: state.cols,
      wallSetbackM: state.wallSetbackM, panelWidthM: state.panelWidthM,
      panelLengthM: state.panelLengthM, isPortrait: state.isPortrait,
      hasNorthWall: state.hasNorthWall, hasSouthWall: state.hasSouthWall,
      hasEastWall: state.hasEastWall, hasWestWall: state.hasWestWall,
    );
  }

  CellType? shadingSourceCell(int index) {
    return _shadowCalc.shadingSourceCell(
      index: index, grid: state.grid, rows: state.rows, cols: state.cols,
      isPortrait: state.isPortrait, panelWidthM: state.panelWidthM,
      panelLengthM: state.panelLengthM, panelOrientation: state.panelOrientation,
      simulationTime: state.simulationTime,
      hasNorthWall: state.hasNorthWall, hasSouthWall: state.hasSouthWall,
      hasEastWall: state.hasEastWall, hasWestWall: state.hasWestWall,
      northWallHeight: state.northWallHeight, southWallHeight: state.southWallHeight,
      eastWallHeight: state.eastWallHeight, westWallHeight: state.westWallHeight,
    );
  }

  bool _isCellShaded(int index) => shadingSourceCell(index) != null;

  // ── COMPUTED METRICS ──

  double get peakPower {
    return _shadowCalc.peakPower(
      grid: state.grid, panelPowerW: state.panelPowerW,
      cols: state.cols, rows: state.rows,
      isPortrait: state.isPortrait, panelWidthM: state.panelWidthM,
      panelLengthM: state.panelLengthM, panelOrientation: state.panelOrientation,
      simulationTime: state.simulationTime,
      hasNorthWall: state.hasNorthWall, hasSouthWall: state.hasSouthWall,
      hasEastWall: state.hasEastWall, hasWestWall: state.hasWestWall,
      northWallHeight: state.northWallHeight, southWallHeight: state.southWallHeight,
      eastWallHeight: state.eastWallHeight, westWallHeight: state.westWallHeight,
    );
  }

  int get panelsCount => _shadowCalc.panelsCount(state.grid);
  int get obstaclesCount => _shadowCalc.obstaclesCount(state.grid);
  double get panelAreaM2 => _shadowCalc.panelAreaM2(state.panelLengthM, state.panelWidthM);
  double get totalArea => _shadowCalc.totalArea(state.grid, state.panelLengthM, state.panelWidthM);
  double get totalWeight => panelsCount * state.panelWeightKg;

  // ── RECALCULATE ──

  void recalculate() {
    _frameResult = _structureCalc.calculate(state);
    final pp = peakPower;
    _energyEstimate = _energyEstimator.estimate(
      peakPowerKwp: pp,
      latitude: state.latitude,
      systemLossesPercent: EnergyEstimate.defaultSystemLossesPercent,
    );
    state = state;
  }

  // ── PERSISTENCE ──

  Future<void> saveDesign(String name) async {
    final box = GetStorage();
    final data = {'name': name, 'date': DateTime.now().toIso8601String(), 'state': state.toJson()};
    List<Map<String, dynamic>> designs = [];
    final existing = box.read('saved_pv_designs');
    if (existing != null) {
      designs = List<Map<String, dynamic>>.from(existing);
    }
    designs.add(data);
    await box.write('saved_pv_designs', designs);
  }

  List<Map<String, dynamic>> getSavedDesigns() {
    final box = GetStorage();
    final existing = box.read('saved_pv_designs');
    if (existing != null) {
      return List<Map<String, dynamic>>.from(existing);
    }
    return [];
  }

  void loadDesign(Map<String, dynamic> design) {
    final stateJson = design['state'] as Map<String, dynamic>;
    state = PvSystemDesignState.fromJson(stateJson);
    recalculate();
  }

  Future<void> deleteDesign(String key) async {
    final box = GetStorage();
    List<Map<String, dynamic>> designs = getSavedDesigns();
    designs.removeWhere((d) => d['state'].toString() == key);
    await box.write('saved_pv_designs', designs);
  }
}
