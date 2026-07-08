import 'package:flutter/material.dart';
import 'package:watt/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/sketch/technical_drawings_sheet.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/technical_sketch/enhanced_technical_sketch_painter.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/technical_sketch/technical_view_mode.dart';

/// Container widget for sketch views with zoom/pan functionality
class SketchViewContainer extends StatelessWidget {
  final TechnicalViewMode viewMode;
  final TransformationController transformationController;
  final double currentScale;
  final ValueChanged<double> onScaleChanged;
  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final TechnicalDrawingsLabels labels;
  final bool showDimensions;
  final bool showGrid;
  final bool showAnnotations;

  const SketchViewContainer({
    super.key,
    required this.viewMode,
    required this.transformationController,
    required this.currentScale,
    required this.onScaleChanged,
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.labels,
    required this.showDimensions,
    required this.showGrid,
    required this.showAnnotations,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the full available space so the drawing fills phone screens.
        // On the side view we favour landscape proportions; all others are portrait.
        final maxW = constraints.maxWidth == double.infinity
            ? 900.0
            : constraints.maxWidth * 0.92;
        final maxH = constraints.maxHeight == double.infinity
            ? 900.0
            : constraints.maxHeight * 0.92;

        return InteractiveViewer(
          transformationController: transformationController,
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.5,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,
          onInteractionUpdate: (details) {
            final scale = transformationController.value.getMaxScaleOnAxis();
            if ((scale - currentScale).abs() > 0.01) {
              onScaleChanged(scale);
            }
          },
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxWidth: viewMode == TechnicalViewMode.side
                    ? maxW
                    : maxW.clamp(300, 900),
                maxHeight: viewMode == TechnicalViewMode.side
                    ? (maxH * 0.7).clamp(300, 700)
                    : maxH.clamp(400, 1200),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CustomPaint(
                  painter: EnhancedTechnicalSketchPainter(
                    result: result,
                    siteWidthMeters: siteWidthMeters,
                    siteDepthMeters: siteDepthMeters,
                    labels: labels,
                    viewMode: viewMode,
                    showAllDimensions: showDimensions,
                    showGrid: showGrid,
                    showAnnotations: showAnnotations,
                    scale: 1.0,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
