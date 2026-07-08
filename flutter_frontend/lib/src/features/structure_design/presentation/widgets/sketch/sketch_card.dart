import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/sketch/structure_sketch_painter.dart';

/// A card widget that displays a single sketch view with title and optional actions
class SketchCard extends StatelessWidget {
  const SketchCard({
    super.key,
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.title,
    required this.viewMode,
    this.detailLevel = SketchDetailLevel.detailed,
    this.onTap,
    this.height,
    this.width,
    this.frontLabel = 'Front',
    this.rearLabel = 'Rear',
    this.braceLabel = 'Brace',
    this.topViewLabel = 'Top View',
    this.sideViewLabel = 'Side View',
    this.frontViewLabel = 'Front View',
    this.isometricViewLabel = 'Isometric',
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final String title;
  final StructureSketchView viewMode;
  final SketchDetailLevel detailLevel;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final String frontLabel;
  final String rearLabel;
  final String braceLabel;
  final String topViewLabel;
  final String sideViewLabel;
  final String frontViewLabel;
  final String isometricViewLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: width ?? double.infinity,
          height: height ?? 200.h,
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Icon(
                    _getIconForView(viewMode),
                    size: 18.sp,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (onTap != null) ...[
                    const Spacer(),
                    Icon(
                      Icons.fullscreen,
                      size: 18.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8.h),
              // Sketch
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: StructureSketchPainter(
                      result: result,
                      siteWidthMeters: siteWidthMeters,
                      siteDepthMeters: siteDepthMeters,
                      topViewLabel: topViewLabel,
                      sideViewLabel: sideViewLabel,
                      frontViewLabel: frontViewLabel,
                      isometricViewLabel: isometricViewLabel,
                      frontLabel: frontLabel,
                      rearLabel: rearLabel,
                      braceLabel: braceLabel,
                      detailLevel: detailLevel,
                      viewMode: viewMode,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForView(StructureSketchView view) {
    return switch (view) {
      StructureSketchView.top => Icons.grid_on,
      StructureSketchView.side => Icons.view_sidebar,
      StructureSketchView.front => Icons.view_column,
      StructureSketchView.isometric => Icons.view_in_ar,
    };
  }
}

/// A widget that displays all four sketch views in a gallery layout
class SketchGallery extends StatelessWidget {
  const SketchGallery({
    super.key,
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.topViewLabel,
    required this.sideViewLabel,
    required this.frontViewLabel,
    required this.isometricViewLabel,
    required this.frontLabel,
    required this.rearLabel,
    required this.braceLabel,
    this.onSketchTap,
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final String topViewLabel;
  final String sideViewLabel;
  final String frontViewLabel;
  final String isometricViewLabel;
  final String frontLabel;
  final String rearLabel;
  final String braceLabel;
  final Function(StructureSketchView view)? onSketchTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          // 2x2 grid for wide screens
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SketchCard(
                      result: result,
                      siteWidthMeters: siteWidthMeters,
                      siteDepthMeters: siteDepthMeters,
                      title: topViewLabel,
                      viewMode: StructureSketchView.top,
                      topViewLabel: topViewLabel,
                      sideViewLabel: sideViewLabel,
                      frontViewLabel: frontViewLabel,
                      isometricViewLabel: isometricViewLabel,
                      frontLabel: frontLabel,
                      rearLabel: rearLabel,
                      braceLabel: braceLabel,
                      onTap: onSketchTap != null
                          ? () => onSketchTap!(StructureSketchView.top)
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SketchCard(
                      result: result,
                      siteWidthMeters: siteWidthMeters,
                      siteDepthMeters: siteDepthMeters,
                      title: sideViewLabel,
                      viewMode: StructureSketchView.side,
                      topViewLabel: topViewLabel,
                      sideViewLabel: sideViewLabel,
                      frontViewLabel: frontViewLabel,
                      isometricViewLabel: isometricViewLabel,
                      frontLabel: frontLabel,
                      rearLabel: rearLabel,
                      braceLabel: braceLabel,
                      onTap: onSketchTap != null
                          ? () => onSketchTap!(StructureSketchView.side)
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: SketchCard(
                      result: result,
                      siteWidthMeters: siteWidthMeters,
                      siteDepthMeters: siteDepthMeters,
                      title: frontViewLabel,
                      viewMode: StructureSketchView.front,
                      topViewLabel: topViewLabel,
                      sideViewLabel: sideViewLabel,
                      frontViewLabel: frontViewLabel,
                      isometricViewLabel: isometricViewLabel,
                      frontLabel: frontLabel,
                      rearLabel: rearLabel,
                      braceLabel: braceLabel,
                      onTap: onSketchTap != null
                          ? () => onSketchTap!(StructureSketchView.front)
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SketchCard(
                      result: result,
                      siteWidthMeters: siteWidthMeters,
                      siteDepthMeters: siteDepthMeters,
                      title: isometricViewLabel,
                      viewMode: StructureSketchView.isometric,
                      topViewLabel: topViewLabel,
                      sideViewLabel: sideViewLabel,
                      frontViewLabel: frontViewLabel,
                      isometricViewLabel: isometricViewLabel,
                      frontLabel: frontLabel,
                      rearLabel: rearLabel,
                      braceLabel: braceLabel,
                      onTap: onSketchTap != null
                          ? () => onSketchTap!(StructureSketchView.isometric)
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // Vertical scroll for narrow screens
        return Column(
          children: [
            SketchCard(
              result: result,
              siteWidthMeters: siteWidthMeters,
              siteDepthMeters: siteDepthMeters,
              title: topViewLabel,
              viewMode: StructureSketchView.top,
              height: 180.h,
              topViewLabel: topViewLabel,
              sideViewLabel: sideViewLabel,
              frontViewLabel: frontViewLabel,
              isometricViewLabel: isometricViewLabel,
              frontLabel: frontLabel,
              rearLabel: rearLabel,
              braceLabel: braceLabel,
              onTap: onSketchTap != null
                  ? () => onSketchTap!(StructureSketchView.top)
                  : null,
            ),
            SizedBox(height: 12.h),
            SketchCard(
              result: result,
              siteWidthMeters: siteWidthMeters,
              siteDepthMeters: siteDepthMeters,
              title: sideViewLabel,
              viewMode: StructureSketchView.side,
              height: 180.h,
              topViewLabel: topViewLabel,
              sideViewLabel: sideViewLabel,
              frontViewLabel: frontViewLabel,
              isometricViewLabel: isometricViewLabel,
              frontLabel: frontLabel,
              rearLabel: rearLabel,
              braceLabel: braceLabel,
              onTap: onSketchTap != null
                  ? () => onSketchTap!(StructureSketchView.side)
                  : null,
            ),
            SizedBox(height: 12.h),
            SketchCard(
              result: result,
              siteWidthMeters: siteWidthMeters,
              siteDepthMeters: siteDepthMeters,
              title: frontViewLabel,
              viewMode: StructureSketchView.front,
              height: 180.h,
              topViewLabel: topViewLabel,
              sideViewLabel: sideViewLabel,
              frontViewLabel: frontViewLabel,
              isometricViewLabel: isometricViewLabel,
              frontLabel: frontLabel,
              rearLabel: rearLabel,
              braceLabel: braceLabel,
              onTap: onSketchTap != null
                  ? () => onSketchTap!(StructureSketchView.front)
                  : null,
            ),
            SizedBox(height: 12.h),
            SketchCard(
              result: result,
              siteWidthMeters: siteWidthMeters,
              siteDepthMeters: siteDepthMeters,
              title: isometricViewLabel,
              viewMode: StructureSketchView.isometric,
              height: 180.h,
              topViewLabel: topViewLabel,
              sideViewLabel: sideViewLabel,
              frontViewLabel: frontViewLabel,
              isometricViewLabel: isometricViewLabel,
              frontLabel: frontLabel,
              rearLabel: rearLabel,
              braceLabel: braceLabel,
              onTap: onSketchTap != null
                  ? () => onSketchTap!(StructureSketchView.isometric)
                  : null,
            ),
          ],
        );
      },
    );
  }
}

/// Full-screen sketch viewer with zoom capabilities
class FullScreenSketchViewer extends StatelessWidget {
  const FullScreenSketchViewer({
    super.key,
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.viewMode,
    required this.title,
    this.topViewLabel = 'Top View',
    this.sideViewLabel = 'Side View',
    this.frontViewLabel = 'Front View',
    this.isometricViewLabel = 'Isometric',
    this.frontLabel = 'Front',
    this.rearLabel = 'Rear',
    this.braceLabel = 'Brace',
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final StructureSketchView viewMode;
  final String title;
  final String topViewLabel;
  final String sideViewLabel;
  final String frontViewLabel;
  final String isometricViewLabel;
  final String frontLabel;
  final String rearLabel;
  final String braceLabel;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 4,
        child: Center(
          child: AspectRatio(
            aspectRatio: _getAspectRatioForView(viewMode),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: CustomPaint(
                size: Size.infinite,
                painter: StructureSketchPainter(
                  result: result,
                  siteWidthMeters: siteWidthMeters,
                  siteDepthMeters: siteDepthMeters,
                  topViewLabel: topViewLabel,
                  sideViewLabel: sideViewLabel,
                  frontViewLabel: frontViewLabel,
                  isometricViewLabel: isometricViewLabel,
                  frontLabel: frontLabel,
                  rearLabel: rearLabel,
                  braceLabel: braceLabel,
                  detailLevel: SketchDetailLevel.detailed,
                  viewMode: viewMode,
                  showShadows: true,
                  showGradients: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getAspectRatioForView(StructureSketchView view) {
    return switch (view) {
      StructureSketchView.top => 16 / 9,
      StructureSketchView.side => 16 / 9,
      StructureSketchView.front => 16 / 9,
      StructureSketchView.isometric => 1,
    };
  }
}
