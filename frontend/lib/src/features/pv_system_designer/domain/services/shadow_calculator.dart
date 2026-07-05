import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/solar_position_calculator.dart';

/// Determines which grid cells are shaded, using the sun's real position
/// (elevation + azimuth) rather than the previous arbitrary
/// `0.5 + |hour-12|/4.5 * 2.0` formula, which had no physical relationship
/// to where the sun actually is for the site's latitude/longitude/date.
///
/// Two shading sources are modeled differently, reflecting what data is
/// actually available:
///  - **Boundary walls** (N/S/E/W, each with a real height) get a proper
///    geometric shadow-length projection: `length = height / tan(elevation)`,
///    projected along the sun's azimuth, compared against each cell's
///    distance to that wall.
///  - **Obstacles/trees/manually-marked shadow cells** on the grid don't
///    carry a height value in this model, so — as before — blocking is
///    approximated by checking the neighboring cell in the sun's direction
///    (i.e. "is something standing between this panel and the sun?"),
///    just now driven by the real sun azimuth instead of a fixed
///    panel-orientation lookup. This is still a simplification (documented
///    here rather than hidden) — a future improvement would let users
///    assign a height to obstacle/tree cells for a true shadow-length
///    projection like the walls get.
class ShadowCalculator {
  const ShadowCalculator({SolarPositionCalculator? sunCalculator}) : _sunCalculator = sunCalculator ?? const SolarPositionCalculator();

  final SolarPositionCalculator _sunCalculator;

  SolarPositionCalculator get sunCalculator => _sunCalculator;

  /// Convenience wrapper so callers (the controller) don't need to import
  /// [SolarPositionCalculator] directly just to get a sun position for a
  /// given wall-clock date/time + site.
  SunPosition sunPositionFor({required DateTime date, required double latitude, required double longitude}) {
    return _sunCalculator.calculate(date: date, latitude: latitude, longitude: longitude);
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
    required SunPosition sunPosition,
    required bool hasNorthWall,
    required bool hasSouthWall,
    required bool hasEastWall,
    required bool hasWestWall,
    required double northWallHeight,
    required double southWallHeight,
    required double eastWallHeight,
    required double westWallHeight,
  }) {
    if (!sunPosition.isDaylight) {
      // Sun below horizon: nothing productive is happening anyway, but we
      // don't have a dedicated "night" cell type, so treat as unshaded
      // rather than mislabel it as an obstacle/tree/wall shadow.
      return null;
    }

    final row = index ~/ cols;
    final col = index % cols;
    final cellW = isPortrait ? panelWidthM : panelLengthM;
    final cellH = isPortrait ? panelLengthM : panelWidthM;
    final distToNorth = (row + 0.5) * cellH;
    final distToSouth = (rows - 0.5 - row) * cellH;
    final distToWest = (col + 0.5) * cellW;
    final distToEast = (cols - 0.5 - col) * cellW;

    final shadowLengthPerMeter = _shadowLengthPerMeterHeight(sunPosition);
    if (shadowLengthPerMeter != null) {
      // North-component and east-component of the shadow's throw per
      // metre of object height, from the sun's azimuth (shadow points
      // opposite the sun).
      final shadowAzimuthRad = ((sunPosition.azimuthDeg + 180) % 360) * (math.pi / 180.0);
      final northComponentPerM = shadowLengthPerMeter * _cos(shadowAzimuthRad);
      final eastComponentPerM = shadowLengthPerMeter * _sin(shadowAzimuthRad);

      if (hasSouthWall) {
        final reachNorth = southWallHeight * northComponentPerM;
        if (reachNorth > distToSouth) return CellType.shadow;
      }
      if (hasNorthWall) {
        final reachSouth = northWallHeight * -northComponentPerM;
        if (reachSouth > distToNorth) return CellType.shadow;
      }
      if (hasEastWall) {
        final reachWest = eastWallHeight * -eastComponentPerM;
        if (reachWest > distToEast) return CellType.shadow;
      }
      if (hasWestWall) {
        final reachEast = westWallHeight * eastComponentPerM;
        if (reachEast > distToWest) return CellType.shadow;
      }
    }

    // Obstacle/tree/manual-shadow adjacency check, looking toward the sun
    // (an object between this cell and the sun blocks it). See class doc
    // for why this remains an adjacency approximation rather than a full
    // shadow-length projection.
    CellType? getBlockerType(int r, int c) {
      if (r < 0 || r >= rows || c < 0 || c >= cols) return null;
      final type = grid[r * cols + c];
      if (type == CellType.obstacle || type == CellType.shadow || type == CellType.tree) return type;
      return null;
    }

    final lookDirection = _compassOctantTowardSun(sunPosition.azimuthDeg);
    switch (lookDirection) {
      case _Octant.north:
        return getBlockerType(row - 1, col) ?? getBlockerType(row - 1, col - 1) ?? getBlockerType(row - 1, col + 1);
      case _Octant.south:
        return getBlockerType(row + 1, col) ?? getBlockerType(row + 1, col - 1) ?? getBlockerType(row + 1, col + 1);
      case _Octant.east:
        return getBlockerType(row, col + 1) ?? getBlockerType(row - 1, col + 1) ?? getBlockerType(row + 1, col + 1);
      case _Octant.west:
        return getBlockerType(row, col - 1) ?? getBlockerType(row - 1, col - 1) ?? getBlockerType(row + 1, col - 1);
    }
  }

  bool isCellShaded({
    required int index,
    required List<CellType> grid,
    required int rows,
    required int cols,
    required bool isPortrait,
    required double panelWidthM,
    required double panelLengthM,
    required SunPosition sunPosition,
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
          sunPosition: sunPosition,
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
    required SunPosition sunPosition,
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
          sunPosition: sunPosition,
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

  /// Shadow length cast per 1 metre of object height, for the given sun
  /// elevation. Null when the sun is at/below the horizon.
  double? _shadowLengthPerMeterHeight(SunPosition sunPosition) {
    if (!sunPosition.isDaylight) return null;
    return sunPosition.shadowLengthFor(1.0);
  }

  double _cos(double radians) => math.cos(radians);
  double _sin(double radians) => math.sin(radians);

  _Octant _compassOctantTowardSun(double sunAzimuthDeg) {
    // Which grid direction to look in to find something standing between
    // the panel and the sun — i.e. roughly the sun's own compass
    // direction, bucketed into the four cardinal directions this grid
    // model supports.
    final a = sunAzimuthDeg % 360;
    if (a >= 45 && a < 135) return _Octant.east;
    if (a >= 135 && a < 225) return _Octant.south;
    if (a >= 225 && a < 315) return _Octant.west;
    return _Octant.north;
  }
}

enum _Octant { north, south, east, west }
