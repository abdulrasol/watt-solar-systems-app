import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/energy_estimate.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/solar_irradiance_data.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/system_losses.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/inverter_spec.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/financial_estimate.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/shadow_calculator.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/structure_design_calculator.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/energy_estimator.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/inverter_sizing_calculator.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/financial_calculator.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/solar_position_calculator.dart';
import 'package:solar_hub/src/features/pv_system_designer/data/location_service.dart';
import 'package:solar_hub/src/features/pv_system_designer/data/open_meteo_solar_data_source.dart';
import 'package:solar_hub/src/features/pv_system_designer/data/inverter_catalog.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/utils/debounce_util.dart';

final pvSystemDesignerProvider = NotifierProvider<PvSystemDesignerController, PvSystemDesignState>(() {
  return PvSystemDesignerController();
});

class PvSystemDesignerController extends Notifier<PvSystemDesignState> {
  final _shadowCalc = ShadowCalculator();
  final _structureCalc = StructureDesignCalculator();
  final _energyEstimator = const EnergyEstimator();
  final _inverterSizingCalc = const InverterSizingCalculator();
  final _financialCalc = const FinancialCalculator();
  final _locationService = GeolocatorLocationService();
  final _weatherDataSource = OpenMeteoSolarDataSource();
  final _debouncer = Debouncer(milliseconds: 300);
  final _weatherDebouncer = Debouncer(milliseconds: 800);

  FrameResult? _frameResult;
  EnergyEstimate? _energyEstimate;
  SolarIrradianceData? _irradianceData;
  StringSizingResult? _stringSizingResult;
  FinancialEstimate? _financialEstimate;
  bool _isFetchingWeather = false;

  FrameResult? get frameResult => _frameResult;
  EnergyEstimate? get energyEstimate => _energyEstimate;
  SolarIrradianceData? get irradianceData => _irradianceData;
  StringSizingResult? get stringSizingResult => _stringSizingResult;
  FinancialEstimate? get financialEstimate => _financialEstimate;
  bool get isFetchingWeather => _isFetchingWeather;
  bool get isUsingRealWeatherData => _irradianceData?.isRealData ?? false;

  @override
  PvSystemDesignState build() => PvSystemDesignState.initial();

  void cleanup() {
    _debouncer.dispose();
    _weatherDebouncer.dispose();
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
    _debouncer.run(recalculate);
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final updatedRedo = List<List<CellType>>.from(state.redoStack.map((l) => List<CellType>.from(l)));
    final next = updatedRedo.removeLast();
    final updatedUndo = List<List<CellType>>.from(state.undoStack.map((l) => List<CellType>.from(l)));
    updatedUndo.add(List<CellType>.from(state.grid));
    state = state.copyWith(grid: next, undoStack: updatedUndo, redoStack: updatedRedo);
    _debouncer.run(recalculate);
  }

  // ── SITE PARAMETERS ──

  void updateLatitude(double value) {
    state = state.copyWith(latitude: value, locationError: null);
    _debouncer.run(recalculate);
    _weatherDebouncer.run(refreshIrradianceData);
  }

  void updateLongitude(double value) {
    state = state.copyWith(longitude: value);
    _debouncer.run(recalculate);
    _weatherDebouncer.run(refreshIrradianceData);
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
      unawaited(refreshIrradianceData());
      return true;
    } on LocationException catch (e) {
      state = state.copyWith(isLocationLoading: false, locationError: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLocationLoading: false, locationError: 'Failed to get location: $e');
      return false;
    }
  }

  /// Fetches real historical irradiance/temperature data for the current
  /// site from Open-Meteo and re-runs the energy estimate once it arrives.
  /// Safe to call repeatedly — failures fall back silently (the estimator
  /// already has a synthetic fallback), and this never throws.
  Future<void> refreshIrradianceData() async {
    _isFetchingWeather = true;
    state = state;
    try {
      final data = await _weatherDataSource.fetchSolarData(latitude: state.latitude, longitude: state.longitude);
      _irradianceData = data;
    } catch (_) {
      // EnergyEstimator already falls back to a synthetic estimate when
      // _irradianceData is null, so there's nothing else to do here.
    } finally {
      _isFetchingWeather = false;
      recalculate();
    }
  }

  // ── ROOF CONFIGURATION ──

  void updateRoofDimensions(double width, double length) {
    state = state.copyWith(roofWidthM: width, roofLengthM: length);
    updateGridFromDimensions();
    _debouncer.run(recalculate);
  }

  void updateWallSetback(double setback) {
    state = state.copyWith(wallSetbackM: setback);
    _debouncer.run(recalculate);
  }

  void updateWallToggles({bool? north, bool? south, bool? east, bool? west}) {
    state = state.copyWith(
      hasNorthWall: north ?? state.hasNorthWall,
      hasSouthWall: south ?? state.hasSouthWall,
      hasEastWall: east ?? state.hasEastWall,
      hasWestWall: west ?? state.hasWestWall,
    );
    _debouncer.run(recalculate);
  }

  void updateWallHeights({double? north, double? south, double? east, double? west}) {
    state = state.copyWith(
      northWallHeight: north ?? state.northWallHeight,
      southWallHeight: south ?? state.southWallHeight,
      eastWallHeight: east ?? state.eastWallHeight,
      westWallHeight: west ?? state.westWallHeight,
    );
    _debouncer.run(recalculate);
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
    _debouncer.run(recalculate);
  }

  void updatePanelElectricalSpec({double? vocV, double? vmpV, double? iscA}) {
    state = state.copyWith(panelVocV: vocV, panelVmpV: vmpV, panelIscA: iscA);
    _debouncer.run(recalculate);
  }

  void updatePortrait(bool isPortrait) {
    state = state.copyWith(isPortrait: isPortrait);
    updateGridFromDimensions();
    _debouncer.run(recalculate);
  }

  void updatePanelOrientation(String orientation) {
    state = state.copyWith(panelOrientation: orientation);
    _debouncer.run(recalculate);
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
    _debouncer.run(recalculate);
  }

  void clearGrid() {
    saveStateToHistory();
    state = state.copyWith(grid: List<CellType>.filled(state.cols * state.rows, CellType.empty));
    _debouncer.run(recalculate);
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
    _debouncer.run(recalculate);
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
    _debouncer.run(recalculate);
  }

  void alignLayoutToSouth() {
    saveStateToHistory();
    state = state.copyWith(panelOrientation: 'South');
    _debouncer.run(recalculate);
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
    _debouncer.run(recalculate);
  }

  // ── SHADOW & SIMULATION ──

  void toggleSafeOverlay() {
    state = state.copyWith(isSafeOverlayActive: !state.isSafeOverlayActive);
  }

  void updateSimulationTime(double hour) {
    state = state.copyWith(simulationTime: hour);
    _debouncer.run(recalculate);
  }

  void updateSimulationDate(DateTime date) {
    state = state.copyWith(simulationDate: date);
    _debouncer.run(recalculate);
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

  /// Combines [PvSystemDesignState.simulationDate] and `simulationTime`
  /// into one `DateTime` for sun-position math.
  DateTime get simulationDateTime {
    final d = state.simulationDate;
    final hour = state.simulationTime.floor();
    final minute = ((state.simulationTime - hour) * 60).round();
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  /// The sun's real position (elevation/azimuth) for the currently
  /// selected simulation date+time and site — replaces the old arbitrary
  /// `simulationTime`-only heuristic used throughout the shading UI.
  SunPosition get sunPosition => _shadowCalc.sunPositionFor(date: simulationDateTime, latitude: state.latitude, longitude: state.longitude);

  /// Approximate sunrise/sunset (decimal hours) for the selected date and
  /// site, used to size the simulation-time slider realistically instead
  /// of a fixed 8:00–17:00 range.
  ({double sunrise, double sunset}) get sunriseSunset =>
      _shadowCalc.sunCalculator.sunriseSunset(date: state.simulationDate, latitude: state.latitude, longitude: state.longitude);

  CellType? shadingSourceCell(int index) {
    return _shadowCalc.shadingSourceCell(
      index: index, grid: state.grid, rows: state.rows, cols: state.cols,
      isPortrait: state.isPortrait, panelWidthM: state.panelWidthM,
      panelLengthM: state.panelLengthM,
      sunPosition: sunPosition,
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
      panelLengthM: state.panelLengthM,
      sunPosition: sunPosition,
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

  // ── SYSTEM LOSSES / FINANCIAL / INVERTER ──

  void updateSystemLosses(SystemLosses losses) {
    state = state.copyWith(systemLosses: losses);
    _debouncer.run(recalculate);
  }

  void selectInverter(String? inverterId) {
    state = state.copyWith(selectedInverterId: inverterId, clearSelectedInverterId: inverterId == null);
    recalculate();
  }

  void updateFinancialInputs({double? costPerWatt, double? electricityRate}) {
    state = state.copyWith(installedCostPerWatt: costPerWatt, electricityRatePerKwh: electricityRate);
    _debouncer.run(recalculate);
  }

  // ── RECALCULATE ──

  void recalculate() {
    _frameResult = _structureCalc.calculate(state);
    final pp = peakPower;

    final double tiltDegrees = _frameResult?.appliedTiltDegrees ?? state.latitude.abs().clamp(10.0, 40.0).toDouble();
    final azimuthDegrees = _frameResult?.appliedAzimuthDegrees ?? (state.latitude >= 0 ? 180.0 : 0.0);

    _energyEstimate = _energyEstimator.estimate(
      peakPowerKwp: pp,
      latitude: state.latitude,
      longitude: state.longitude,
      tiltDegrees: tiltDegrees,
      azimuthDegrees: azimuthDegrees,
      irradianceData: _irradianceData,
      losses: state.systemLosses,
    );

    final inverter = state.selectedInverterId != null ? InverterCatalog.byId(state.selectedInverterId!) : InverterCatalog.suggestFor(pp);
    final coldTemp = _irradianceData?.approxMinTempC ?? (state.latitude.abs() < 30 ? 5.0 : -5.0);
    final hotTemp = _irradianceData?.approxMaxTempC ?? 45.0;
    if (panelsCount > 0) {
      _stringSizingResult = _inverterSizingCalc.calculate(
        inverter: inverter,
        panelCount: panelsCount,
        panelVocV: state.panelVocV,
        panelVmpV: state.panelVmpV,
        panelIscA: state.panelIscA,
        coldDesignTempC: coldTemp,
        hotDesignTempC: hotTemp,
        dcArrayKw: panelsCount * state.panelPowerW / 1000.0,
      );
    } else {
      _stringSizingResult = null;
    }

    final totalCost = state.installedCostPerWatt * pp * 1000;
    _financialEstimate = _financialCalc.estimate(
      firstYearKwh: _energyEstimate?.yearlyKwh ?? 0,
      annualDegradationPercent: state.systemLosses.annualDegradationPercent,
      systemCost: totalCost,
      electricityRatePerKwh: state.electricityRatePerKwh,
    );

    // ignore: no-op reassignment to notify listeners that cached
    // (non-state) derived fields above have changed.
    state = state;
  }

  // ── PERSISTENCE ──

  Future<void> saveDesign(String name) async {
    final box = GetStorage();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final data = {'id': id, 'name': name, 'date': DateTime.now().toIso8601String(), 'state': state.toJson()};
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
    unawaited(refreshIrradianceData());
  }

  Future<void> deleteDesign(String id) async {
    final box = GetStorage();
    List<Map<String, dynamic>> designs = getSavedDesigns();
    designs.removeWhere((d) => (d['id']?.toString() ?? d['state'].toString()) == id);
    await box.write('saved_pv_designs', designs);
  }

  // ── MARKETPLACE HANDOFF ──

  /// Builds the request payload for the app's existing offers/marketplace
  /// flow (`OffersRepository.createRequest` / `POST offers/requests`),
  /// summarizing this design so "Share & Request Quotes" sends a real
  /// request to companies instead of only showing a success toast.
  Map<String, dynamic> buildOfferRequestData() {
    final pp = peakPower;
    final note = StringBuffer('PV System Designer request — ')
      ..write('$panelsCount panels')
      ..write(_frameResult != null ? ', ${_frameResult!.rows}×${_frameResult!.columns} layout' : '')
      ..write(_frameResult != null ? ', tilt ${_frameResult!.appliedTiltDegrees.toStringAsFixed(0)}°' : '')
      ..write(_frameResult != null ? ', azimuth ${_frameResult!.appliedAzimuthDegrees.toStringAsFixed(0)}°' : '')
      ..write(_energyEstimate != null ? ', est. annual production ${_energyEstimate!.yearlyKwh.toStringAsFixed(0)} kWh' : '')
      ..write(', location ${state.latitude.toStringAsFixed(4)}, ${state.longitude.toStringAsFixed(4)}.');

    return {
      'all_cities': true,
      'total_panel_power': (pp * 1000).round(),
      'panel_power': state.panelPowerW.round(),
      'panel_count': panelsCount,
      'panel_note': note.toString(),
    };
  }
}
