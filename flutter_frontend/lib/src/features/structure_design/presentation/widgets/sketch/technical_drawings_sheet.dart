import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watt/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/sketch/technical_structure_sketch_painter.dart';

/// A comprehensive technical drawings sheet for construction use
/// Displays all views with complete dimensions that technicians need
class TechnicalDrawingsSheet extends StatelessWidget {
  const TechnicalDrawingsSheet({super.key, required this.result, required this.siteWidthMeters, required this.siteDepthMeters, required this.labels});

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final TechnicalDrawingsLabels labels;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(child: TabBarView(children: [_buildTopView(), _buildSideView(), _buildFrontView(), _buildIsometricView(), _buildDimensionsList()])),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(labels.technicalDrawings, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${result.panelCount} ${labels.panels} • ${result.rows} ${labels.rows} × ${result.columns} ${labels.columns}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.copy), tooltip: labels.copyDimensions, onPressed: () => _copyDimensionsToClipboard(context)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        isScrollable: true,
        tabs: [
          Tab(icon: const Icon(Icons.grid_on), text: labels.topView),
          Tab(icon: const Icon(Icons.view_sidebar), text: labels.sideView),
          Tab(icon: const Icon(Icons.view_column), text: labels.frontView),
          Tab(icon: const Icon(Icons.view_in_ar), text: labels.isometricView),
          Tab(icon: const Icon(Icons.format_list_numbered), text: labels.dimensions),
        ],
      ),
    );
  }

  Widget _buildTopView() {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 3.0,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1.3,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: TechnicalStructureSketchPainter(
                result: result,
                siteWidthMeters: siteWidthMeters,
                siteDepthMeters: siteDepthMeters,
                labels: labels,
                viewMode: TechnicalViewMode.top,
                showAllDimensions: true,
                scale: 1.0,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideView() {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 3.0,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: TechnicalStructureSketchPainter(
                result: result,
                siteWidthMeters: siteWidthMeters,
                siteDepthMeters: siteDepthMeters,
                labels: labels,
                viewMode: TechnicalViewMode.side,
                showAllDimensions: true,
                scale: 1.0,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontView() {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 3.0,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1.2,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: TechnicalStructureSketchPainter(
                result: result,
                siteWidthMeters: siteWidthMeters,
                siteDepthMeters: siteDepthMeters,
                labels: labels,
                viewMode: TechnicalViewMode.front,
                showAllDimensions: true,
                scale: 1.0,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIsometricView() {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 3.0,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1.3,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: TechnicalStructureSketchPainter(
                result: result,
                siteWidthMeters: siteWidthMeters,
                siteDepthMeters: siteDepthMeters,
                labels: labels,
                viewMode: TechnicalViewMode.isometric,
                showAllDimensions: true,
                scale: 1.0,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDimensionSection(labels.siteDimensions, [
            _DimensionItem(labels.siteWidth, '${siteWidthMeters.toStringAsFixed(2)} m'),
            _DimensionItem(labels.siteDepth, '${siteDepthMeters.toStringAsFixed(2)} m'),
            _DimensionItem(labels.usableWidth, '${result.usableWidthMeters.toStringAsFixed(2)} m'),
            _DimensionItem(labels.usableDepth, '${result.usableDepthMeters.toStringAsFixed(2)} m'),
          ]),
          _buildDimensionSection(labels.panelLayout, [
            _DimensionItem(labels.totalPanels, '${result.panelCount}'),
            _DimensionItem(labels.rows, '${result.rows}'),
            _DimensionItem(labels.columns, '${result.columns}'),
            _DimensionItem(labels.panelOrientation, _getOrientationText()),
          ]),
          _buildDimensionSection(labels.structureDimensions, [
            _DimensionItem(labels.frameWidth, '${result.frameWidthMeters.toStringAsFixed(2)} m'),
            _DimensionItem(labels.frameSlopeLength, '${result.frameSlopeLengthMeters.toStringAsFixed(2)} m'),
            _DimensionItem(labels.projectedRowDepth, '${result.projectedRowDepthMeters.toStringAsFixed(2)} m'),
            _DimensionItem(labels.rowSpacing, '${result.rowSpacingMeters.toStringAsFixed(2)} m'),
            _DimensionItem(labels.totalFootprintDepth, '${result.totalFootprintDepthMeters.toStringAsFixed(2)} m'),
          ]),
          _buildDimensionSection(labels.legHeights, [
            _DimensionItem(labels.frontLegHeight, '${result.frontLegHeightMeters.toStringAsFixed(2)} m'),
            _DimensionItem(labels.rearLegHeight, '${result.rearLegHeightMeters.toStringAsFixed(2)} m'),
            if (!result.isUniformLegDesign) ...[
              _DimensionItem(labels.minFrontLegHeight, '${result.minFrontLegHeightMeters.toStringAsFixed(2)} m'),
              _DimensionItem(labels.maxFrontLegHeight, '${result.maxFrontLegHeightMeters.toStringAsFixed(2)} m'),
              _DimensionItem(labels.minRearLegHeight, '${result.minRearLegHeightMeters.toStringAsFixed(2)} m'),
              _DimensionItem(labels.maxRearLegHeight, '${result.maxRearLegHeightMeters.toStringAsFixed(2)} m'),
            ],
          ]),
          _buildDimensionSection(labels.supportStructure, [
            _DimensionItem(labels.supportStationCount, '${result.supportStationCount}'),
            _DimensionItem(labels.supportSpacing, '${result.supportSpacingMeters.toStringAsFixed(2)} m'),
            _DimensionItem(labels.railLength, '${result.railLengthMeters.toStringAsFixed(2)} m'),
            _DimensionItem(labels.braceLength, '${result.braceLengthMeters.toStringAsFixed(2)} m'),
          ]),
          _buildDimensionSection(labels.angles, [
            _DimensionItem(labels.appliedTilt, '${result.appliedTiltDegrees.toStringAsFixed(1)}°'),
            _DimensionItem(labels.idealTilt, '${result.idealTiltDegrees.toStringAsFixed(1)}°'),
            _DimensionItem(labels.appliedAzimuth, '${result.appliedAzimuthDegrees.toStringAsFixed(1)}°'),
            _DimensionItem(labels.idealAzimuth, '${result.idealAzimuthDegrees.toStringAsFixed(1)}°'),
          ]),
          _buildDimensionSection(labels.materials, [
            _DimensionItem(labels.totalSteelLength, '${result.totalSteelLengthMeters.toStringAsFixed(2)} m'),
            _DimensionItem(labels.frontLegCount, '${result.frontLegCount}'),
            _DimensionItem(labels.rearLegCount, '${result.rearLegCount}'),
            _DimensionItem(labels.anchorCount, '${result.anchorCount}'),
          ]),
          if (!result.isUniformLegDesign && result.rowResults.isNotEmpty) _buildRowDetailsSection(),
        ],
      ),
    );
  }

  Widget _buildDimensionSection(String title, List<_DimensionItem> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            ...items.map((item) => _buildDimensionRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionRow(_DimensionItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(item.label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDetailsSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(labels.rowDetails, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            ...result.rowResults.map((row) => _buildRowDetailItem(row)),
          ],
        ),
      ),
    );
  }

  Widget _buildRowDetailItem(dynamic row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${labels.row} ${row.rowIndex + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: [
                _buildSubDimension(labels.baseOffset, '${row.baseOffsetMeters.toStringAsFixed(2)} m'),
                _buildSubDimension(labels.frontLegHeight, '${row.frontLegHeightMeters.toStringAsFixed(2)} m'),
                _buildSubDimension(labels.rearLegHeight, '${row.rearLegHeightMeters.toStringAsFixed(2)} m'),
                _buildSubDimension(labels.localFootprint, '${row.localFootprintDepthMeters.toStringAsFixed(2)} m'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubDimension(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  String _getOrientationText() {
    return result.panelOrientation.toString().split('.').last;
  }

  void _copyDimensionsToClipboard(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('=== ${labels.structureDimensionsReport} ===');
    buffer.writeln('');
    buffer.writeln('${labels.siteWidth}: ${siteWidthMeters.toStringAsFixed(2)} m');
    buffer.writeln('${labels.siteDepth}: ${siteDepthMeters.toStringAsFixed(2)} m');
    buffer.writeln('${labels.usableWidth}: ${result.usableWidthMeters.toStringAsFixed(2)} m');
    buffer.writeln('${labels.usableDepth}: ${result.usableDepthMeters.toStringAsFixed(2)} m');
    buffer.writeln('');
    buffer.writeln('${labels.totalPanels}: ${result.panelCount}');
    buffer.writeln('${labels.layout}: ${result.rows} ${labels.rows} × ${result.columns} ${labels.columns}');
    buffer.writeln('');
    buffer.writeln('${labels.frameWidth}: ${result.frameWidthMeters.toStringAsFixed(2)} m');
    buffer.writeln('${labels.frameSlopeLength}: ${result.frameSlopeLengthMeters.toStringAsFixed(2)} m');
    buffer.writeln('${labels.projectedRowDepth}: ${result.projectedRowDepthMeters.toStringAsFixed(2)} m');
    buffer.writeln('${labels.rowSpacing}: ${result.rowSpacingMeters.toStringAsFixed(2)} m');
    buffer.writeln('${labels.totalFootprintDepth}: ${result.totalFootprintDepthMeters.toStringAsFixed(2)} m');
    buffer.writeln('');
    buffer.writeln('${labels.frontLegHeight}: ${result.frontLegHeightMeters.toStringAsFixed(2)} m');
    buffer.writeln('${labels.rearLegHeight}: ${result.rearLegHeightMeters.toStringAsFixed(2)} m');
    buffer.writeln('${labels.supportStationCount}: ${result.supportStationCount}');
    buffer.writeln('${labels.supportSpacing}: ${result.supportSpacingMeters.toStringAsFixed(2)} m');
    buffer.writeln('');
    buffer.writeln('${labels.appliedTilt}: ${result.appliedTiltDegrees.toStringAsFixed(1)}°');
    buffer.writeln('${labels.appliedAzimuth}: ${result.appliedAzimuthDegrees.toStringAsFixed(1)}°');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(labels.dimensionsCopied)));
  }
}

class _DimensionItem {
  final String label;
  final String value;

  _DimensionItem(this.label, this.value);
}

/// Extended labels for technical drawings sheet
class TechnicalDrawingsLabels extends TechnicalLabels {
  const TechnicalDrawingsLabels({
    required super.topView,
    required super.sideView,
    required super.frontView,
    required super.isometricView,
    required super.detailView,
    required super.rows,
    required super.columns,
    required super.panels,
    required super.offset,
    required super.totalDepth,
    required super.groundLevel,
    required super.scale,
    required super.date,
    required super.basePlateDetail,
    required super.legDetail,
    required this.technicalDrawings,
    required this.dimensions,
    required this.copyDimensions,
    required this.print,
    required this.share,
    required this.siteDimensions,
    required this.siteWidth,
    required this.siteDepth,
    required this.usableWidth,
    required this.usableDepth,
    required this.panelLayout,
    required this.totalPanels,
    required this.panelOrientation,
    required this.structureDimensions,
    required this.frameWidth,
    required this.frameSlopeLength,
    required this.projectedRowDepth,
    required this.rowSpacing,
    required this.legHeights,
    required this.frontLegHeight,
    required this.rearLegHeight,
    required this.minFrontLegHeight,
    required this.maxFrontLegHeight,
    required this.minRearLegHeight,
    required this.maxRearLegHeight,
    required this.supportStructure,
    required this.supportStationCount,
    required this.supportSpacing,
    required this.railLength,
    required this.braceLength,
    required this.angles,
    required this.appliedTilt,
    required this.idealTilt,
    required this.appliedAzimuth,
    required this.idealAzimuth,
    required this.materials,
    required this.totalSteelLength,
    required this.frontLegCount,
    required this.rearLegCount,
    required this.anchorCount,
    required this.rowDetails,
    required this.row,
    required this.baseOffset,
    required this.localFootprint,
    required this.layout,
    required this.structureDimensionsReport,
    required this.dimensionsCopied,
    required this.totalFootprintDepth,
    required this.tilt,
    required this.resetView,
    required this.showGrid,
    required this.showDimensions,
    required this.showAnnotations,
    required this.front,
    required this.rear,
    required this.brace,
    required this.printFeatureComingSoon,
    required this.close,
    required this.supports,
  });

  final String technicalDrawings;
  final String dimensions;
  final String copyDimensions;
  final String print;
  final String share;
  final String siteDimensions;
  final String siteWidth;
  final String siteDepth;
  final String usableWidth;
  final String usableDepth;
  final String panelLayout;
  final String totalPanels;
  final String panelOrientation;
  final String structureDimensions;
  final String frameWidth;
  final String frameSlopeLength;
  final String projectedRowDepth;
  final String rowSpacing;
  final String legHeights;
  final String frontLegHeight;
  final String rearLegHeight;
  final String minFrontLegHeight;
  final String maxFrontLegHeight;
  final String minRearLegHeight;
  final String maxRearLegHeight;
  final String supportStructure;
  final String supportStationCount;
  final String supportSpacing;
  final String railLength;
  final String braceLength;
  final String angles;
  final String appliedTilt;
  final String idealTilt;
  final String appliedAzimuth;
  final String idealAzimuth;
  final String materials;
  final String totalSteelLength;
  final String frontLegCount;
  final String rearLegCount;
  final String anchorCount;
  final String rowDetails;
  final String row;
  final String baseOffset;
  final String localFootprint;
  final String layout;
  final String structureDimensionsReport;
  final String dimensionsCopied;
  final String totalFootprintDepth;
  final String tilt;
  final String resetView;
  final String showGrid;
  final String showDimensions;
  final String showAnnotations;
  final String front;
  final String rear;
  final String brace;
  final String printFeatureComingSoon;
  final String close;
  final String supports;
}
