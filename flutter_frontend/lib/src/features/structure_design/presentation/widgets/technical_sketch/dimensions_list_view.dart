import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/sketch/technical_drawings_sheet.dart';

/// Widget displaying a comprehensive list of all dimensions
class DimensionsListView extends StatelessWidget {
  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final TechnicalDrawingsLabels labels;

  const DimensionsListView({
    super.key,
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
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
          if (!result.isUniformLegDesign && result.rowResults.isNotEmpty)
            _buildRowDetailsSection(),
        ],
      ),
    );
  }

  Widget _buildDimensionSection(String title, List<_DimensionItem> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace', fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDetailsSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(labels.rowDetails, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
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
}

class _DimensionItem {
  final String label;
  final String value;

  _DimensionItem(this.label, this.value);
}
