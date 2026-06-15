import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/energy_estimate.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/obstacle.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/panel_layout.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_panel_spec.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/shading_analysis.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/site_profile.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';

@immutable
class PvSystemDesignState {
  const PvSystemDesignState({
    required this.site,
    required this.panelSpec,
    required this.layout,
    required this.obstacles,
    required this.polygonVertices,
    required this.shading,
    required this.structure,
    required this.energy,
    required this.currentStep,
    required this.activeTool,
    required this.showStructureOverlay,
    required this.projectName,
    required this.avgTariffPerKwh,
    required this.undoStack,
    required this.redoStack,
  });

  final SiteProfile site;
  final PvPanelSpec panelSpec;
  final PanelLayout layout;
  final List<Obstacle> obstacles;
  final List<Offset> polygonVertices;
  final ShadingAnalysis shading;
  final FrameResult? structure;
  final EnergyEstimate energy;
  final int currentStep;
  final PvToolMode activeTool;
  final bool showStructureOverlay;
  final String projectName;
  final double avgTariffPerKwh;
  final List<PvSystemDesignState> undoStack;
  final List<PvSystemDesignState> redoStack;

  factory PvSystemDesignState.initial() {
    return PvSystemDesignState(
      site: const SiteProfile(),
      panelSpec: const PvPanelSpec(),
      layout: PanelLayout(
        rows: 3,
        cols: 9,
        cells: List<PvCellType>.filled(27, PvCellType.empty),
      ),
      obstacles: const [],
      polygonVertices: const [],
      shading: const ShadingAnalysis(),
      structure: null,
      energy: const EnergyEstimate(),
      currentStep: 0,
      activeTool: PvToolMode.placePanel,
      showStructureOverlay: false,
      projectName: '',
      avgTariffPerKwh: 0.18,
      undoStack: const [],
      redoStack: const [],
    );
  }

  PvSystemDesignState copyWith({
    SiteProfile? site,
    PvPanelSpec? panelSpec,
    PanelLayout? layout,
    List<Obstacle>? obstacles,
    List<Offset>? polygonVertices,
    ShadingAnalysis? shading,
    FrameResult? structure,
    EnergyEstimate? energy,
    int? currentStep,
    PvToolMode? activeTool,
    bool? showStructureOverlay,
    String? projectName,
    double? avgTariffPerKwh,
    List<PvSystemDesignState>? undoStack,
    List<PvSystemDesignState>? redoStack,
  }) {
    return PvSystemDesignState(
      site: site ?? this.site,
      panelSpec: panelSpec ?? this.panelSpec,
      layout: layout ?? this.layout,
      obstacles: obstacles ?? List<Obstacle>.from(this.obstacles),
      polygonVertices:
          polygonVertices ?? List<Offset>.from(this.polygonVertices),
      shading: shading ?? this.shading,
      structure: structure ?? this.structure,
      energy: energy ?? this.energy,
      currentStep: currentStep ?? this.currentStep,
      activeTool: activeTool ?? this.activeTool,
      showStructureOverlay: showStructureOverlay ?? this.showStructureOverlay,
      projectName: projectName ?? this.projectName,
      avgTariffPerKwh: avgTariffPerKwh ?? this.avgTariffPerKwh,
      undoStack: undoStack ?? List<PvSystemDesignState>.from(this.undoStack),
      redoStack: redoStack ?? List<PvSystemDesignState>.from(this.redoStack),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'site': site.toJson(),
      'panelSpec': panelSpec.toJson(),
      'layout': layout.toJson(),
      'obstacles': obstacles.map((e) => e.toJson()).toList(),
      'polygonVertices': polygonVertices
          .map((v) => {'dx': v.dx, 'dy': v.dy})
          .toList(),
      'currentStep': currentStep,
      'activeTool': activeTool.name,
      'showStructureOverlay': showStructureOverlay,
      'projectName': projectName,
      'avgTariffPerKwh': avgTariffPerKwh,
    };
  }

  factory PvSystemDesignState.fromJson(Map<String, dynamic> json) {
    return PvSystemDesignState(
      site: SiteProfile.fromJson(json['site'] as Map<String, dynamic>? ?? {}),
      panelSpec:
          PvPanelSpec.fromJson(json['panelSpec'] as Map<String, dynamic>? ?? {}),
      layout:
          PanelLayout.fromJson(json['layout'] as Map<String, dynamic>? ?? {}),
      obstacles: (json['obstacles'] as List<dynamic>? ?? [])
          .map((e) => Obstacle.fromJson(e as Map<String, dynamic>))
          .toList(),
      polygonVertices: (json['polygonVertices'] as List<dynamic>? ?? [])
          .map((v) {
            final m = v as Map<String, dynamic>;
            return Offset(
              (m['dx'] as num? ?? 0.0).toDouble(),
              (m['dy'] as num? ?? 0.0).toDouble(),
            );
          })
          .toList(),
      shading: const ShadingAnalysis(),
      structure: null,
      energy: const EnergyEstimate(),
      currentStep: json['currentStep'] as int? ?? 0,
      activeTool: PvToolMode.values.firstWhere(
        (e) => e.name == json['activeTool'],
        orElse: () => PvToolMode.placePanel,
      ),
      showStructureOverlay: json['showStructureOverlay'] as bool? ?? false,
      projectName: json['projectName'] as String? ?? '',
      avgTariffPerKwh: (json['avgTariffPerKwh'] as num? ?? 0.18).toDouble(),
      undoStack: const [],
      redoStack: const [],
    );
  }
}

enum PvToolMode {
  placePanel,
  placeObstacle,
  placeTree,
  placeWall,
  placeChimney,
  placeVent,
  excludeRoof,
  erase,
  sketchPolygon,
}
