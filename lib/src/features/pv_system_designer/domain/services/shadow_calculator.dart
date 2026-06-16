import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';

class ShadowCalculator {
  double shadowMultiplier(double simulationTime) {
    final distanceFromNoon = (simulationTime - 12.0).abs();
    return 0.5 + (distanceFromNoon / 4.5) * 2.0;
  }

  bool isInSetbackZone({
    required int r,
    required int c,
    required int rows,
    required int cols,
    required double wallSetbackM,
    required double panelWidthM,
    required double panelLengthM,
    required bool isPortrait,
    required bool hasNorthWall,
    required bool hasSouthWall,
    required bool hasEastWall,
    required bool hasWestWall,
  }) {
    if (wallSetbackM <= 0) return false;
    final cellW = isPortrait ? panelWidthM : panelLengthM;
    final cellH = isPortrait ? panelLengthM : panelWidthM;
    final distLeft = c * cellW;
    final distRight = (cols - 1 - c) * cellW;
    final distTop = r * cellH;
    final distBottom = (rows - 1 - r) * cellH;
    return (hasWestWall && distLeft < wallSetbackM) ||
        (hasEastWall && distRight < wallSetbackM) ||
        (hasNorthWall && distTop < wallSetbackM) ||
        (hasSouthWall && distBottom < wallSetbackM);
  }

  CellType? shadingSourceCell({
    required int index,
    required List<CellType> grid,
    required int rows,
    required int cols,
    required bool isPortrait,
    required double panelWidthM,
    required double panelLengthM,
    required String panelOrientation,
    required double simulationTime,
    required bool hasNorthWall,
    required bool hasSouthWall,
    required bool hasEastWall,
    required bool hasWestWall,
    required double northWallHeight,
    required double southWallHeight,
    required double eastWallHeight,
    required double westWallHeight,
  }) {
    final row = index ~/ cols;
    final col = index % cols;
    final cellW = isPortrait ? panelWidthM : panelLengthM;
    final cellH = isPortrait ? panelLengthM : panelWidthM;
    final distToNorth = (row + 0.5) * cellH;
    final distToSouth = (rows - 0.5 - row) * cellH;
    final distToWest = (col + 0.5) * cellW;
    final distToEast = (cols - 0.5 - col) * cellW;
    final factor = shadowMultiplier(simulationTime);

    bool isShadedByWall = false;
    if (panelOrientation == 'South') {
      if (hasSouthWall && distToSouth < southWallHeight * factor) isShadedByWall = true;
      if (hasEastWall && distToEast < eastWallHeight * factor) isShadedByWall = true;
      if (hasWestWall && distToWest < westWallHeight * factor) isShadedByWall = true;
    } else if (panelOrientation == 'North') {
      if (hasNorthWall && distToNorth < northWallHeight * factor) isShadedByWall = true;
      if (hasEastWall && distToEast < eastWallHeight * factor) isShadedByWall = true;
      if (hasWestWall && distToWest < westWallHeight * factor) isShadedByWall = true;
    } else if (panelOrientation == 'East') {
      if (hasEastWall && distToEast < eastWallHeight * factor) isShadedByWall = true;
      if (hasNorthWall && distToNorth < northWallHeight * factor) isShadedByWall = true;
      if (hasSouthWall && distToSouth < southWallHeight * factor) isShadedByWall = true;
    } else if (panelOrientation == 'West') {
      if (hasWestWall && distToWest < westWallHeight * factor) isShadedByWall = true;
      if (hasNorthWall && distToNorth < northWallHeight * factor) isShadedByWall = true;
      if (hasSouthWall && distToSouth < southWallHeight * factor) isShadedByWall = true;
    }
    if (isShadedByWall) return CellType.shadow;

    CellType? getBlockerType(int r, int c) {
      if (r < 0 || r >= rows || c < 0 || c >= cols) return null;
      final type = grid[r * cols + c];
      if (type == CellType.obstacle || type == CellType.shadow || type == CellType.tree) return type;
      return null;
    }

    if (panelOrientation == 'South') {
      return getBlockerType(row + 1, col) ?? getBlockerType(row + 1, col - 1) ?? getBlockerType(row + 1, col + 1);
    } else if (panelOrientation == 'North') {
      return getBlockerType(row - 1, col) ?? getBlockerType(row - 1, col - 1) ?? getBlockerType(row - 1, col + 1);
    } else if (panelOrientation == 'East') {
      return getBlockerType(row, col + 1) ?? getBlockerType(row - 1, col + 1) ?? getBlockerType(row + 1, col + 1);
    } else if (panelOrientation == 'West') {
      return getBlockerType(row, col - 1) ?? getBlockerType(row - 1, col - 1) ?? getBlockerType(row + 1, col - 1);
    }
    return null;
  }

  bool isCellShaded({
    required int index,
    required List<CellType> grid,
    required int rows,
    required int cols,
    required bool isPortrait,
    required double panelWidthM,
    required double panelLengthM,
    required String panelOrientation,
    required double simulationTime,
    required bool hasNorthWall,
    required bool hasSouthWall,
    required bool hasEastWall,
    required bool hasWestWall,
    required double northWallHeight,
    required double southWallHeight,
    required double eastWallHeight,
    required double westWallHeight,
  }) {
    return shadingSourceCell(
          index: index,
          grid: grid,
          rows: rows,
          cols: cols,
          isPortrait: isPortrait,
          panelWidthM: panelWidthM,
          panelLengthM: panelLengthM,
          panelOrientation: panelOrientation,
          simulationTime: simulationTime,
          hasNorthWall: hasNorthWall,
          hasSouthWall: hasSouthWall,
          hasEastWall: hasEastWall,
          hasWestWall: hasWestWall,
          northWallHeight: northWallHeight,
          southWallHeight: southWallHeight,
          eastWallHeight: eastWallHeight,
          westWallHeight: westWallHeight,
        ) !=
        null;
  }

  double peakPower({
    required List<CellType> grid,
    required double panelPowerW,
    required int cols,
    required int rows,
    required bool isPortrait,
    required double panelWidthM,
    required double panelLengthM,
    required String panelOrientation,
    required double simulationTime,
    required bool hasNorthWall,
    required bool hasSouthWall,
    required bool hasEastWall,
    required bool hasWestWall,
    required double northWallHeight,
    required double southWallHeight,
    required double eastWallHeight,
    required double westWallHeight,
  }) {
    double total = 0.0;
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == CellType.panel) {
        final shadeSource = shadingSourceCell(
          index: i,
          grid: grid,
          rows: rows,
          cols: cols,
          isPortrait: isPortrait,
          panelWidthM: panelWidthM,
          panelLengthM: panelLengthM,
          panelOrientation: panelOrientation,
          simulationTime: simulationTime,
          hasNorthWall: hasNorthWall,
          hasSouthWall: hasSouthWall,
          hasEastWall: hasEastWall,
          hasWestWall: hasWestWall,
          northWallHeight: northWallHeight,
          southWallHeight: southWallHeight,
          eastWallHeight: eastWallHeight,
          westWallHeight: westWallHeight,
        );
        if (shadeSource != null) {
          double factor = 1.0;
          if (shadeSource == CellType.tree) {
            factor = 0.60;
          } else if (shadeSource == CellType.shadow) {
            factor = 0.25;
          } else if (shadeSource == CellType.obstacle) {
            factor = 0.10;
          }
          total += (panelPowerW * factor) / 1000.0;
        } else {
          total += panelPowerW / 1000.0;
        }
      }
    }
    return total;
  }

  int panelsCount(List<CellType> grid) => grid.where((c) => c == CellType.panel).length;

  int obstaclesCount(List<CellType> grid) => grid.where((c) => c == CellType.obstacle || c == CellType.shadow || c == CellType.tree).length;

  double panelAreaM2(double panelLengthM, double panelWidthM) => panelLengthM * panelWidthM;

  double totalArea(List<CellType> grid, double panelLengthM, double panelWidthM) =>
      panelsCount(grid) * panelAreaM2(panelLengthM, panelWidthM);

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
}
