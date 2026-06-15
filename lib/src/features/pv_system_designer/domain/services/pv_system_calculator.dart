import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/energy_estimate.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/obstacle.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/panel_layout.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_panel_spec.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/shading_analysis.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/site_profile.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/repositories/solar_data_repository.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/energy_estimator.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/shadow_calculator.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/solar_position_calculator.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/panel_spec.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/features/structure_design/domain/services/structure_design_calculator.dart';

class PvSystemCalculator {
  PvSystemCalculator({
    required SolarDataRepository solarDataRepository,
    SolarPositionCalculator? solarCalculator,
    ShadowCalculator? shadowCalculator,
    EnergyEstimator? energyEstimator,
    StructureDesignCalculator? structureCalculator,
  })  : _solarDataRepository = solarDataRepository,
        _solarCalculator = solarCalculator ?? const SolarPositionCalculator(),
        _shadowCalculator = shadowCalculator ?? const ShadowCalculator(),
        _energyEstimator = energyEstimator ?? const EnergyEstimator(),
        _structureCalculator = structureCalculator ?? StructureDesignCalculator();

  final SolarDataRepository _solarDataRepository;
  final SolarPositionCalculator _solarCalculator;
  final ShadowCalculator _shadowCalculator;
  final EnergyEstimator _energyEstimator;
  final StructureDesignCalculator _structureCalculator;

  /// Rebuilds the grid when site or panel dimensions change, preserving
  /// non-empty cells where possible.
  PanelLayout rebuildGrid({
    required SiteProfile site,
    required PvPanelSpec panelSpec,
    required PanelLayout? previous,
  }) {
    final cellW = panelSpec.orientation == PvPanelOrientation.portrait
        ? panelSpec.widthM
        : panelSpec.lengthM;
    final cellH = panelSpec.orientation == PvPanelOrientation.portrait
        ? panelSpec.lengthM
        : panelSpec.widthM;

    final cols = (site.roofWidthM / cellW).floor().clamp(2, 25);
    final rows = (site.roofLengthM / cellH).floor().clamp(2, 25);

    final newCells = List<PvCellType>.filled(rows * cols, PvCellType.empty);

    if (previous != null && previous.rows > 0 && previous.cols > 0) {
      for (var r = 0; r < min(rows, previous.rows); r++) {
        for (var c = 0; c < min(cols, previous.cols); c++) {
          newCells[r * cols + c] = previous.cells[r * previous.cols + c];
        }
      }
    }

    return PanelLayout(
      rows: rows,
      cols: cols,
      cells: newCells,
      isPortrait: panelSpec.orientation == PvPanelOrientation.portrait,
      panelOrientation: previous?.panelOrientation ?? 'South',
    );
  }

  /// Marks cells outside the roof polygon as excluded.
  PanelLayout applyPolygonExclusion({
    required PanelLayout layout,
    required List<Offset> vertices,
    required double roofWidthM,
    required double roofLengthM,
  }) {
    if (vertices.length < 3) return layout;

    final cellW = roofWidthM / layout.cols;
    final cellH = roofLengthM / layout.rows;
    final newCells = List<PvCellType>.from(layout.cells);

    for (var r = 0; r < layout.rows; r++) {
      for (var c = 0; c < layout.cols; c++) {
        final idx = r * layout.cols + c;
        final cx = (c + 0.5) * cellW;
        final cy = (r + 0.5) * cellH;
        if (!_pointInPolygon(Offset(cx, cy), vertices)) {
          if (newCells[idx] != PvCellType.panel) {
            newCells[idx] = PvCellType.excluded;
          }
        }
      }
    }

    return layout.copyWith(cells: newCells);
  }

  /// Auto-fills panels within usable area (setbacks + exclusions + obstacles).
  PanelLayout autoPlacePanels({
    required PanelLayout layout,
    required SiteProfile site,
    required List<Obstacle> obstacles,
  }) {
    final cellW = site.roofWidthM / layout.cols;
    final cellH = site.roofLengthM / layout.rows;
    final newCells = List<PvCellType>.from(layout.cells);

    for (var r = 0; r < layout.rows; r++) {
      for (var c = 0; c < layout.cols; c++) {
        final idx = r * layout.cols + c;
        if (newCells[idx] == PvCellType.excluded) continue;

        final cx = (c + 0.5) * cellW;
        final cy = (r + 0.5) * cellH;

        final inSetback = cx < site.wallSetbackM ||
            cx > site.roofWidthM - site.wallSetbackM ||
            cy < site.wallSetbackM ||
            cy > site.roofLengthM - site.wallSetbackM;

        final inObstacle = obstacles.any((obs) {
          final halfW = obs.size.width / 2.0;
          final halfH = obs.size.height / 2.0;
          return cx >= obs.position.dx - halfW &&
              cx <= obs.position.dx + halfW &&
              cy >= obs.position.dy - halfH &&
              cy <= obs.position.dy + halfH;
        });

        if (!inSetback && !inObstacle) {
          newCells[idx] = PvCellType.panel;
        } else if (newCells[idx] == PvCellType.panel) {
          newCells[idx] = PvCellType.empty;
        }
      }
    }

    return layout.copyWith(cells: newCells);
  }

  /// Computes the shadow map for a single moment.
  ShadingAnalysis computeMomentShading({
    required PvSystemDesignState state,
    required DateTime date,
    required double hour,
  }) {
    final sun = _solarCalculator.forHour(
      date: date,
      hour: hour,
      latitude: state.site.latitude,
      longitude: state.site.longitude,
    );

    final moment = _shadowCalculator.calculate(
      site: state.site,
      layout: state.layout,
      obstacles: state.obstacles,
      sun: sun,
    );

    return state.shading.copyWith(
      shadedCells: moment.shadedCells,
      simulationDate: date,
      simulationHour: hour,
    );
  }

  /// Computes average monthly shading factors using representative days.
  Future<ShadingAnalysis> computeMonthlyShading(PvSystemDesignState state) async {
    final monthlyFactors = <int, double>{};
    final panelCount = state.layout.panelCount;

    if (panelCount == 0 || state.obstacles.isEmpty) {
      for (var m = 1; m <= 12; m++) {
        monthlyFactors[m] = 1.0;
      }
      return state.shading.copyWith(monthlyShadingFactors: monthlyFactors);
    }

    final now = DateTime.now();

    for (var month = 1; month <= 12; month++) {
      final day = _representativeDay(month, now.year);
      final sunPositions = _solarCalculator.hourlyForDay(
        date: day,
        latitude: state.site.latitude,
        longitude: state.site.longitude,
      );

      var weightedSum = 0.0;
      var weightSum = 0.0;

      for (final sun in sunPositions) {
        if (sun.elevationDeg <= 5) continue;
        final moment = _shadowCalculator.calculate(
          site: state.site,
          layout: state.layout,
          obstacles: state.obstacles,
          sun: sun,
        );
        final weight = sin(_degToRad(sun.elevationDeg));
        weightedSum += moment.shadingFactor * weight;
        weightSum += weight;
      }

      monthlyFactors[month] =
          weightSum > 0 ? (weightedSum / weightSum).clamp(0.0, 1.0) : 1.0;
    }

    return state.shading.copyWith(monthlyShadingFactors: monthlyFactors);
  }

  /// Calculates the structural frame result.
  FrameResult? calculateStructure(PvSystemDesignState state) {
    final panelCount = state.layout.panelCount;
    if (panelCount == 0) return null;

    final input = StructureDesignInput(
      siteWidthMeters: state.site.roofWidthM,
      siteDepthMeters: state.site.roofLengthM,
      latitude: state.site.latitude,
      facingPreference: _facingPreferenceFromString(state.layout.panelOrientation),
      mountType: state.site.mountType,
      frontClearanceMeters: state.site.frontClearanceM,
      rearClearanceMeters: state.site.rearClearanceM,
      sideClearanceMeters: state.site.sideClearanceM,
      frontLegClearanceMeters: state.site.frontLegClearanceM,
      interRowGapMeters: state.site.interRowGapM,
      panelSpec: _toStructurePanelSpec(state.panelSpec),
      rowMode: RowMode.independent,
      rowBaseOffsetsMeters: const [],
      targetPanelCount: panelCount,
    );

    return _structureCalculator.calculate(input);
  }

  /// Estimates yearly energy production.
  Future<EnergyEstimate> estimateEnergy(PvSystemDesignState state) async {
    final shading = state.shading.monthlyShadingFactors.isEmpty
        ? await computeMonthlyShading(state)
        : state.shading;

    final tilt = _effectiveTilt(state.site);

    try {
      final data = await _solarDataRepository.fetchHistoricalTiltedIrradiance(
        latitude: state.site.latitude,
        longitude: state.site.longitude,
        tiltDeg: tilt,
        azimuthDeg: state.site.roofAzimuthDeg,
      );

      if (!data.isEmpty) {
        return _energyEstimator.estimateFromIrradiance(
          site: state.site,
          panelSpec: state.panelSpec,
          layout: state.layout,
          shading: shading,
          data: data,
          avgTariffPerKwh: state.avgTariffPerKwh,
        );
      }
    } catch (_) {
      // Fall through to offline estimate.
    }

    return _energyEstimator.estimateFallback(
      site: state.site,
      panelSpec: state.panelSpec,
      layout: state.layout,
      shading: shading,
      avgTariffPerKwh: state.avgTariffPerKwh,
    );
  }

  PanelSpec _toStructurePanelSpec(PvPanelSpec spec) {
    return PanelSpec(
      lengthMeters: spec.lengthM,
      widthMeters: spec.widthM,
      thicknessMeters: spec.thicknessM,
      orientation: spec.orientation == PvPanelOrientation.portrait
          ? PanelOrientation.portrait
          : PanelOrientation.landscape,
      horizontalGapMeters: spec.horizontalGapM,
      verticalGapMeters: spec.verticalGapM,
    );
  }

  FacingDirectionPreference _facingPreferenceFromString(String orientation) {
    return switch (orientation.toLowerCase()) {
      'north' => FacingDirectionPreference.north,
      'northeast' => FacingDirectionPreference.northEast,
      'east' => FacingDirectionPreference.east,
      'southeast' => FacingDirectionPreference.southEast,
      'south' => FacingDirectionPreference.south,
      'southwest' => FacingDirectionPreference.southWest,
      'west' => FacingDirectionPreference.west,
      'northwest' => FacingDirectionPreference.northWest,
      _ => FacingDirectionPreference.any,
    };
  }

  double _effectiveTilt(SiteProfile site) {
    return switch (site.mountType) {
      _ => site.roofPitchDeg,
    };
  }

  DateTime _representativeDay(int month, int year) {
    final day = [15, 14, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15][month - 1];
    return DateTime(year, month, day);
  }

  bool _pointInPolygon(Offset point, List<Offset> polygon) {
    var inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final pi = polygon[i];
      final pj = polygon[j];
      final intersect = ((pi.dy > point.dy) != (pj.dy > point.dy)) &&
          (point.dx <
              (pj.dx - pi.dx) * (point.dy - pi.dy) / (pj.dy - pi.dy + 1e-10) +
                  pi.dx);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
}
