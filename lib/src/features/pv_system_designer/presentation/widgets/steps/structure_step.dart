import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_design_providers.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/bom_item.dart';

class StructureStep extends ConsumerWidget {
  const StructureStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(pvSystemDesignControllerProvider);
    final result = state.structure;

    if (result == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(l10n.pv_design_calculating_structure),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        _buildCard(
          context,
          title: l10n.pv_design_layout_summary,
          children: [
            _metric(l10n.pv_design_rows, '${result.rows}'),
            _metric(l10n.pv_design_columns, '${result.columns}'),
            _metric(l10n.pv_design_panel_count, '${result.panelCount}'),
            _metric(l10n.pv_design_frame_width, '${result.frameWidthMeters.toStringAsFixed(2)} m'),
            _metric(l10n.pv_design_row_spacing, '${result.rowSpacingMeters.toStringAsFixed(2)} m'),
          ],
        ),
        SizedBox(height: 12.h),
        _buildCard(
          context,
          title: l10n.pv_design_leg_heights,
          children: [
            _metric(l10n.pv_design_front_leg, '${result.frontLegHeightMeters.toStringAsFixed(2)} m'),
            _metric(l10n.pv_design_rear_leg, '${result.rearLegHeightMeters.toStringAsFixed(2)} m'),
          ],
        ),
        SizedBox(height: 12.h),
        _buildCard(
          context,
          title: l10n.pv_design_bom,
          children: result.bomItems.map((item) => _bomRow(item)).toList(),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _bomRow(BomItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text('${item.name} (${item.unit})')),
          Text(item.quantity.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
