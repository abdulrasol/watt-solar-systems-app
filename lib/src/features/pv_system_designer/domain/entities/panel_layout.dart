import 'package:flutter/material.dart';

@immutable
class PanelLayout {
  const PanelLayout({
    required this.rows,
    required this.cols,
    required this.cells,
    this.isPortrait = true,
    this.panelOrientation = 'South',
  });

  final int rows;
  final int cols;
  final List<PvCellType> cells;
  final bool isPortrait;
  final String panelOrientation;

  int get panelCount => cells.where((c) => c == PvCellType.panel).length;
  int get obstacleCount => cells.where((c) => c == PvCellType.obstacle).length;
  int get treeCount => cells.where((c) => c == PvCellType.tree).length;

  PanelLayout copyWith({
    int? rows,
    int? cols,
    List<PvCellType>? cells,
    bool? isPortrait,
    String? panelOrientation,
  }) {
    return PanelLayout(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      cells: cells ?? List<PvCellType>.from(this.cells),
      isPortrait: isPortrait ?? this.isPortrait,
      panelOrientation: panelOrientation ?? this.panelOrientation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rows': rows,
      'cols': cols,
      'cells': cells.map((e) => e.name).toList(),
      'isPortrait': isPortrait,
      'panelOrientation': panelOrientation,
    };
  }

  factory PanelLayout.fromJson(Map<String, dynamic> json) {
    final cellsJson = json['cells'] as List<dynamic>? ?? [];
    return PanelLayout(
      rows: json['rows'] as int? ?? 0,
      cols: json['cols'] as int? ?? 0,
      cells: cellsJson.map((e) {
        return PvCellType.values.firstWhere(
          (v) => v.name == e,
          orElse: () => PvCellType.empty,
        );
      }).toList(),
      isPortrait: json['isPortrait'] as bool? ?? true,
      panelOrientation: json['panelOrientation'] as String? ?? 'South',
    );
  }
}

enum PvCellType {
  empty,
  panel,
  obstacle,
  shadow,
  tree,
  excluded,
}
