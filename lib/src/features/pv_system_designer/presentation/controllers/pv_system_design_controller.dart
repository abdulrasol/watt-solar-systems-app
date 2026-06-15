import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/obstacle.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/energy_estimate.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/panel_layout.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_panel_spec.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/site_profile.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/pv_system_calculator.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_design_providers.dart';

class PvSystemDesignController extends Notifier<PvSystemDesignState> {
  static const _storageKey = 'pv_system_designer_projects';
  static const _currentKey = 'pv_system_designer_current';

  PvSystemCalculator get _calculator => ref.read(pvSystemCalculatorProvider);
  GetStorage get _storage => GetStorage();

  @override
  PvSystemDesignState build() {
    final saved = _storage.read(_currentKey);
    if (saved is Map<String, dynamic>) {
      try {
        return PvSystemDesignState.fromJson(saved);
      } catch (_) {
        // Fall through to initial state.
      }
    }
    return PvSystemDesignState.initial();
  }

  void _pushUndo() {
    final undo = List<PvSystemDesignState>.from(state.undoStack)
      ..add(state.copyWith(undoStack: const [], redoStack: const []));
    if (undo.length > 20) undo.removeAt(0);
    state = state.copyWith(undoStack: undo, redoStack: const []);
  }

  void updateSite(SiteProfile site) {
    _pushUndo();
    final newLayout = _calculator.rebuildGrid(
      site: site,
      panelSpec: state.panelSpec,
      previous: state.layout,
    );
    state = state.copyWith(
      site: site,
      layout: newLayout,
      structure: null,
      energy: const EnergyEstimate(),
    );
    _persistCurrent();
  }

  void updatePanelSpec(PvPanelSpec spec) {
    _pushUndo();
    final newLayout = _calculator.rebuildGrid(
      site: state.site,
      panelSpec: spec,
      previous: state.layout,
    );
    state = state.copyWith(
      panelSpec: spec,
      layout: newLayout,
      structure: null,
      energy: const EnergyEstimate(),
    );
    _persistCurrent();
  }

  void updateProjectName(String name) {
    state = state.copyWith(projectName: name);
    _persistCurrent();
  }

  void updateTariff(double tariff) {
    state = state.copyWith(avgTariffPerKwh: tariff);
    _persistCurrent();
  }

  void setCurrentStep(int step) {
    state = state.copyWith(currentStep: step);
    _persistCurrent();
  }

  void setActiveTool(PvToolMode tool) {
    state = state.copyWith(activeTool: tool);
  }

  void toggleStructureOverlay() {
    state = state.copyWith(showStructureOverlay: !state.showStructureOverlay);
  }

  void setCell(int index, PvCellType type) {
    if (index < 0 || index >= state.layout.cells.length) return;
    _pushUndo();
    final cells = List<PvCellType>.from(state.layout.cells);
    cells[index] = type;
    state = state.copyWith(
      layout: state.layout.copyWith(cells: cells),
      structure: null,
      energy: const EnergyEstimate(),
    );
    _persistCurrent();
  }

  void addObstacle(Obstacle obstacle) {
    _pushUndo();
    state = state.copyWith(
      obstacles: [...state.obstacles, obstacle],
      structure: null,
      energy: const EnergyEstimate(),
    );
    _persistCurrent();
  }

  void updateObstacle(String id, Obstacle updated) {
    _pushUndo();
    state = state.copyWith(
      obstacles: state.obstacles
          .map((o) => o.id == id ? updated : o)
          .toList(),
      structure: null,
      energy: const EnergyEstimate(),
    );
    _persistCurrent();
  }

  void removeObstacle(String id) {
    _pushUndo();
    state = state.copyWith(
      obstacles: state.obstacles.where((o) => o.id != id).toList(),
      structure: null,
      energy: const EnergyEstimate(),
    );
    _persistCurrent();
  }

  void setPolygonVertices(List<Offset> vertices) {
    _pushUndo();
    state = state.copyWith(polygonVertices: vertices);
    _persistCurrent();
  }

  void applyPolygonExclusion() {
    _pushUndo();
    final layout = _calculator.applyPolygonExclusion(
      layout: state.layout,
      vertices: state.polygonVertices,
      roofWidthM: state.site.roofWidthM,
      roofLengthM: state.site.roofLengthM,
    );
    state = state.copyWith(
      layout: layout,
      structure: null,
      energy: const EnergyEstimate(),
    );
    _persistCurrent();
  }

  void autoPlacePanels() {
    _pushUndo();
    final layout = _calculator.autoPlacePanels(
      layout: state.layout,
      site: state.site,
      obstacles: state.obstacles,
    );
    state = state.copyWith(
      layout: layout,
      structure: null,
      energy: const EnergyEstimate(),
    );
    _persistCurrent();
  }

  void clearPanels() {
    _pushUndo();
    final cells = List<PvCellType>.filled(
      state.layout.rows * state.layout.cols,
      PvCellType.empty,
    );
    state = state.copyWith(
      layout: state.layout.copyWith(cells: cells),
      structure: null,
      energy: const EnergyEstimate(),
    );
    _persistCurrent();
  }

  void updateMomentShading(DateTime date, double hour) async {
    final shading = _calculator.computeMomentShading(
      state: state,
      date: date,
      hour: hour,
    );
    state = state.copyWith(shading: shading);
  }

  Future<void> computeFullShading() async {
    final shading = await _calculator.computeMonthlyShading(state);
    state = state.copyWith(shading: shading);
  }

  Future<void> calculateStructureAndEnergy() async {
    final structure = _calculator.calculateStructure(state);
    state = state.copyWith(structure: structure);

    final energy = await _calculator.estimateEnergy(state);
    state = state.copyWith(energy: energy);
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    final previous = state.undoStack.last;
    final newUndo = List<PvSystemDesignState>.from(state.undoStack)..removeLast();
    final newRedo = List<PvSystemDesignState>.from(state.redoStack)
      ..add(state.copyWith(undoStack: const [], redoStack: const []));
    state = previous.copyWith(undoStack: newUndo, redoStack: newRedo);
    _persistCurrent();
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final next = state.redoStack.last;
    final newRedo = List<PvSystemDesignState>.from(state.redoStack)..removeLast();
    final newUndo = List<PvSystemDesignState>.from(state.undoStack)
      ..add(state.copyWith(undoStack: const [], redoStack: const []));
    state = next.copyWith(undoStack: newUndo, redoStack: newRedo);
    _persistCurrent();
  }

  void reset() {
    _pushUndo();
    state = PvSystemDesignState.initial();
    _persistCurrent();
  }

  Future<void> saveProject(String title) async {
    final projects = _loadProjects();
    final key = DateTime.now().millisecondsSinceEpoch.toString();
    projects[key] = {
      'title': title.isEmpty ? 'Untitled Project' : title,
      'savedAt': DateTime.now().toIso8601String(),
      'state': state.toJson(),
    };
    await _storage.write(_storageKey, projects);
  }

  Future<void> loadProject(String key) async {
    final projects = _loadProjects();
    final data = projects[key];
    if (data is! Map<String, dynamic>) return;
    final stateJson = data['state'] as Map<String, dynamic>?;
    if (stateJson == null) return;
    _pushUndo();
    state = PvSystemDesignState.fromJson(stateJson);
    _persistCurrent();
  }

  Future<void> deleteProject(String key) async {
    final projects = _loadProjects();
    projects.remove(key);
    await _storage.write(_storageKey, projects);
  }

  Map<String, dynamic> _loadProjects() {
    final raw = _storage.read(_storageKey);
    if (raw is Map<String, dynamic>) return raw;
    return {};
  }

  void _persistCurrent() {
    _storage.write(_currentKey, state.toJson());
  }
}
