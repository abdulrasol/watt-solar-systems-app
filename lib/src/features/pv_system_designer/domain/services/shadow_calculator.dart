import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/obstacle.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/panel_layout.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/site_profile.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/solar_position_calculator.dart';

/// Shading result for a single moment in time.
class MomentaryShadow {
  const MomentaryShadow({
    required this.shadedCells,
    required this.shadowPolygons,
    required this.shadingFactor,
  });

  final Set<int> shadedCells;
  final List<List<Offset>> shadowPolygons;
  final double shadingFactor;
}

/// Projects obstacle shadows onto the roof grid using solar position.
class ShadowCalculator {
  const ShadowCalculator();

  MomentaryShadow calculate({
    required SiteProfile site,
    required PanelLayout layout,
    required List<Obstacle> obstacles,
    required SolarPosition sun,
  }) {
    if (sun.elevationDeg <= 0 || obstacles.isEmpty) {
      return const MomentaryShadow(
        shadedCells: {},
        shadowPolygons: [],
        shadingFactor: 1.0,
      );
    }

    final cellW = site.roofWidthM / layout.cols;
    final cellH = site.roofLengthM / layout.rows;
    final polygons = <List<Offset>>[];

    for (final obstacle in obstacles) {
      final polygon = _projectShadow(obstacle, sun, site);
      if (polygon.length >= 3) {
        polygons.add(polygon);
      }
    }

    final shaded = <int>{};
    for (var row = 0; row < layout.rows; row++) {
      for (var col = 0; col < layout.cols; col++) {
        final index = row * layout.cols + col;
        if (layout.cells[index] != PvCellType.panel) continue;

        final cx = (col + 0.5) * cellW;
        final cy = (row + 0.5) * cellH;
        final center = Offset(cx, cy);

        for (final polygon in polygons) {
          if (_pointInPolygon(center, polygon)) {
            shaded.add(index);
            break;
          }
        }
      }
    }

    final panelCount = layout.panelCount;
    final factor = panelCount == 0
        ? 1.0
        : 1.0 - (shaded.length / panelCount) * 0.75;

    return MomentaryShadow(
      shadedCells: shaded,
      shadowPolygons: polygons,
      shadingFactor: factor.clamp(0.0, 1.0),
    );
  }

  List<Offset> _projectShadow(Obstacle obstacle, SolarPosition sun, SiteProfile site) {
    final shadowLen = obstacle.heightM / max(tan(_degToRad(sun.elevationDeg)), 0.01);
    final shadowAz = _radToDeg(atan2(
      -sin(_degToRad(sun.azimuthDeg)),
      -cos(_degToRad(sun.azimuthDeg)),
    ));
    final azRad = _degToRad(shadowAz);
    final dx = shadowLen * sin(azRad);
    final dy = shadowLen * cos(azRad);

    final halfW = obstacle.size.width / 2.0;
    final halfH = obstacle.size.height / 2.0;
    final cx = obstacle.position.dx;
    final cy = obstacle.position.dy;

    // Rectangle corners in meters (x=width, y=depth).
    final base = <Offset>[
      Offset(cx - halfW, cy - halfH),
      Offset(cx + halfW, cy - halfH),
      Offset(cx + halfW, cy + halfH),
      Offset(cx - halfW, cy + halfH),
    ];

    // Project each corner to the tip of its shadow.
    final tips = base.map((p) => Offset(p.dx + dx, p.dy + dy)).toList();

    // Combine and clip to roof bounds.
    final combined = [...base, ...tips];
    final clipped = combined
        .map(
          (p) => Offset(
            p.dx.clamp(0.0, site.roofWidthM),
            p.dy.clamp(0.0, site.roofLengthM),
          ),
        )
        .toList();

    return _convexHull(clipped);
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

  List<Offset> _convexHull(List<Offset> points) {
    if (points.length <= 3) return points;

    final sorted = List<Offset>.from(points)
      ..sort((a, b) => a.dx == b.dx ? a.dy.compareTo(b.dy) : a.dx.compareTo(b.dx));

    List<Offset> buildHull(List<Offset> pts) {
      final hull = <Offset>[];
      for (final p in pts) {
        while (hull.length > 1 &&
            _cross(hull[hull.length - 2], hull.last, p) <= 0) {
          hull.removeLast();
        }
        hull.add(p);
      }
      return hull;
    }

    final lower = buildHull(sorted);
    final upper = buildHull(sorted.reversed.toList());
    lower.removeLast();
    upper.removeLast();
    return [...lower, ...upper];
  }

  double _cross(Offset o, Offset a, Offset b) {
    return (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
  static double _radToDeg(double rad) => rad * 180.0 / pi;
}
