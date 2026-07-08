import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/sketch/technical_drawings_sheet.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/technical_sketch/dimensions_list_view.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/technical_sketch/sketch_view_container.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/technical_sketch/technical_view_mode.dart';

/// Full-screen technical sketch page with zoom/pan and comprehensive dimensions
class TechnicalSketchPage extends StatefulWidget {
  const TechnicalSketchPage({
    super.key,
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.labels,
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final TechnicalDrawingsLabels labels;

  @override
  State<TechnicalSketchPage> createState() => _TechnicalSketchPageState();
}

class _TechnicalSketchPageState extends State<TechnicalSketchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;
  bool _showGrid = true;
  bool _showDimensions = true;
  bool _showAnnotations = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _resetZoom();
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() => _currentScale = 1.0);
  }

  void _zoomIn() {
    final newScale = (_currentScale * 1.25).clamp(0.5, 5.0);
    _applyScale(newScale);
  }

  void _zoomOut() {
    final newScale = (_currentScale / 1.25).clamp(0.5, 5.0);
    _applyScale(newScale);
  }

  void _applyScale(double scale) {
    final center = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );
    final matrix = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(scale / _currentScale, scale / _currentScale, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
    _transformationController.value = matrix * _transformationController.value;
    setState(() => _currentScale = scale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.labels.technicalDrawings),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          _ZoomControls(
            currentScale: _currentScale,
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
          ),
          _MenuButton(
            labels: widget.labels,
            showGrid: _showGrid,
            showDimensions: _showDimensions,
            showAnnotations: _showAnnotations,
            onResetZoom: _resetZoom,
            onToggleGrid: () => setState(() => _showGrid = !_showGrid),
            onToggleDimensions: () =>
                setState(() => _showDimensions = !_showDimensions),
            onToggleAnnotations: () =>
                setState(() => _showAnnotations = !_showAnnotations),
            onCopyDimensions: _copyDimensionsToClipboard,
            onPrint: _showPrintDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(icon: const Icon(Icons.grid_on), text: widget.labels.topView),
            Tab(
              icon: const Icon(Icons.view_sidebar),
              text: widget.labels.sideView,
            ),
            Tab(
              icon: const Icon(Icons.view_column),
              text: widget.labels.frontView,
            ),
            Tab(
              icon: const Icon(Icons.view_in_ar),
              text: widget.labels.isometricView,
            ),
            Tab(
              icon: const Icon(Icons.format_list_numbered),
              text: widget.labels.dimensions,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _InfoBar(result: widget.result, labels: widget.labels),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SketchViewContainer(
                  viewMode: TechnicalViewMode.top,
                  transformationController: _transformationController,
                  currentScale: _currentScale,
                  onScaleChanged: (scale) =>
                      setState(() => _currentScale = scale),
                  result: widget.result,
                  siteWidthMeters: widget.siteWidthMeters,
                  siteDepthMeters: widget.siteDepthMeters,
                  labels: widget.labels,
                  showDimensions: _showDimensions,
                  showGrid: _showGrid,
                  showAnnotations: _showAnnotations,
                ),
                SketchViewContainer(
                  viewMode: TechnicalViewMode.side,
                  transformationController: _transformationController,
                  currentScale: _currentScale,
                  onScaleChanged: (scale) =>
                      setState(() => _currentScale = scale),
                  result: widget.result,
                  siteWidthMeters: widget.siteWidthMeters,
                  siteDepthMeters: widget.siteDepthMeters,
                  labels: widget.labels,
                  showDimensions: _showDimensions,
                  showGrid: _showGrid,
                  showAnnotations: _showAnnotations,
                ),
                SketchViewContainer(
                  viewMode: TechnicalViewMode.front,
                  transformationController: _transformationController,
                  currentScale: _currentScale,
                  onScaleChanged: (scale) =>
                      setState(() => _currentScale = scale),
                  result: widget.result,
                  siteWidthMeters: widget.siteWidthMeters,
                  siteDepthMeters: widget.siteDepthMeters,
                  labels: widget.labels,
                  showDimensions: _showDimensions,
                  showGrid: _showGrid,
                  showAnnotations: _showAnnotations,
                ),
                SketchViewContainer(
                  viewMode: TechnicalViewMode.isometric,
                  transformationController: _transformationController,
                  currentScale: _currentScale,
                  onScaleChanged: (scale) =>
                      setState(() => _currentScale = scale),
                  result: widget.result,
                  siteWidthMeters: widget.siteWidthMeters,
                  siteDepthMeters: widget.siteDepthMeters,
                  labels: widget.labels,
                  showDimensions: _showDimensions,
                  showGrid: _showGrid,
                  showAnnotations: _showAnnotations,
                ),
                DimensionsListView(
                  result: widget.result,
                  siteWidthMeters: widget.siteWidthMeters,
                  siteDepthMeters: widget.siteDepthMeters,
                  labels: widget.labels,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _FloatingControls(
        onZoomIn: _zoomIn,
        onZoomOut: _zoomOut,
        onResetZoom: _resetZoom,
      ),
    );
  }

  void _copyDimensionsToClipboard() {
    final buffer = StringBuffer();
    buffer.writeln('=== ${widget.labels.structureDimensionsReport} ===');
    buffer.writeln('');
    buffer.writeln(
      '${widget.labels.siteWidth}: ${widget.siteWidthMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln(
      '${widget.labels.siteDepth}: ${widget.siteDepthMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln(
      '${widget.labels.usableWidth}: ${widget.result.usableWidthMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln(
      '${widget.labels.usableDepth}: ${widget.result.usableDepthMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln('');
    buffer.writeln('${widget.labels.totalPanels}: ${widget.result.panelCount}');
    buffer.writeln(
      '${widget.labels.layout}: ${widget.result.rows} ${widget.labels.rows} × ${widget.result.columns} ${widget.labels.columns}',
    );
    buffer.writeln('');
    buffer.writeln(
      '${widget.labels.frameWidth}: ${widget.result.frameWidthMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln(
      '${widget.labels.frameSlopeLength}: ${widget.result.frameSlopeLengthMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln(
      '${widget.labels.projectedRowDepth}: ${widget.result.projectedRowDepthMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln(
      '${widget.labels.rowSpacing}: ${widget.result.rowSpacingMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln(
      '${widget.labels.totalFootprintDepth}: ${widget.result.totalFootprintDepthMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln('');
    buffer.writeln(
      '${widget.labels.frontLegHeight}: ${widget.result.frontLegHeightMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln(
      '${widget.labels.rearLegHeight}: ${widget.result.rearLegHeightMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln(
      '${widget.labels.supportStationCount}: ${widget.result.supportStationCount}',
    );
    buffer.writeln(
      '${widget.labels.supportSpacing}: ${widget.result.supportSpacingMeters.toStringAsFixed(2)} m',
    );
    buffer.writeln('');
    buffer.writeln(
      '${widget.labels.appliedTilt}: ${widget.result.appliedTiltDegrees.toStringAsFixed(1)}°',
    );
    buffer.writeln(
      '${widget.labels.appliedAzimuth}: ${widget.result.appliedAzimuthDegrees.toStringAsFixed(1)}°',
    );

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(widget.labels.dimensionsCopied)));
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.labels.print),
        content: Text(widget.labels.printFeatureComingSoon),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.labels.close),
          ),
        ],
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  final double currentScale;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _ZoomControls({
    required this.currentScale,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.zoom_out),
          tooltip: 'Zoom Out',
          onPressed: onZoomOut,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${(currentScale * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.zoom_in),
          tooltip: 'Zoom In',
          onPressed: onZoomIn,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final TechnicalDrawingsLabels labels;
  final bool showGrid;
  final bool showDimensions;
  final bool showAnnotations;
  final VoidCallback onResetZoom;
  final VoidCallback onToggleGrid;
  final VoidCallback onToggleDimensions;
  final VoidCallback onToggleAnnotations;
  final VoidCallback onCopyDimensions;
  final VoidCallback onPrint;

  const _MenuButton({
    required this.labels,
    required this.showGrid,
    required this.showDimensions,
    required this.showAnnotations,
    required this.onResetZoom,
    required this.onToggleGrid,
    required this.onToggleDimensions,
    required this.onToggleAnnotations,
    required this.onCopyDimensions,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'reset':
            onResetZoom();
          case 'grid':
            onToggleGrid();
          case 'dimensions':
            onToggleDimensions();
          case 'annotations':
            onToggleAnnotations();
          case 'copy':
            onCopyDimensions();
          case 'print':
            onPrint();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'reset',
          child: Row(
            children: [
              const Icon(Icons.fit_screen, size: 20),
              const SizedBox(width: 12),
              Text(labels.resetView),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'grid',
          child: Row(
            children: [
              Icon(
                showGrid ? Icons.grid_on : Icons.grid_off,
                size: 20,
                color: showGrid ? Theme.of(context).primaryColor : null,
              ),
              const SizedBox(width: 12),
              Text(labels.showGrid),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'dimensions',
          child: Row(
            children: [
              Icon(
                showDimensions ? Icons.straighten : Icons.straighten_outlined,
                size: 20,
                color: showDimensions ? Theme.of(context).primaryColor : null,
              ),
              const SizedBox(width: 12),
              Text(labels.showDimensions),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'annotations',
          child: Row(
            children: [
              Icon(
                showAnnotations ? Icons.label : Icons.label_outlined,
                size: 20,
                color: showAnnotations ? Theme.of(context).primaryColor : null,
              ),
              const SizedBox(width: 12),
              Text(labels.showAnnotations),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              const Icon(Icons.copy, size: 20),
              const SizedBox(width: 12),
              Text(labels.copyDimensions),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'print',
          child: Row(
            children: [
              const Icon(Icons.print, size: 20),
              const SizedBox(width: 12),
              Text(labels.print),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoBar extends StatelessWidget {
  final FrameResult result;
  final TechnicalDrawingsLabels labels;

  const _InfoBar({required this.result, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _buildInfoItem(
                  Icons.solar_power,
                  '${result.panelCount} ${labels.panels}',
                ),
                _buildInfoItem(
                  Icons.grid_view,
                  '${result.rows} ${labels.rows} × ${result.columns} ${labels.columns}',
                ),
                _buildInfoItem(
                  Icons.straighten,
                  '${result.frameWidthMeters.toStringAsFixed(2)}m × ${result.totalFootprintDepthMeters.toStringAsFixed(2)}m',
                ),
                _buildInfoItem(
                  Icons.rotate_right,
                  '${result.appliedTiltDegrees.toStringAsFixed(1)}° ${labels.tilt}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FloatingControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  const _FloatingControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'zoom_in',
          onPressed: onZoomIn,
          child: const Icon(Icons.zoom_in),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'zoom_out',
          onPressed: onZoomOut,
          child: const Icon(Icons.zoom_out),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'reset',
          onPressed: onResetZoom,
          child: const Icon(Icons.fit_screen),
        ),
      ],
    );
  }
}
