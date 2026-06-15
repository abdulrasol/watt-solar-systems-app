import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_design_controller.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_design_providers.dart';

class ProposalStep extends ConsumerWidget {
  const ProposalStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(pvSystemDesignControllerProvider);
    final notifier = ref.read(pvSystemDesignControllerProvider.notifier);
    final energy = state.energy;

    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        _buildCard(
          context,
          title: l10n.pv_design_system_summary,
          children: [
            _metric(l10n.pv_design_peak_power, '${energy.peakKw.toStringAsFixed(2)} kWp'),
            _metric(l10n.pv_design_panel_count, '${state.layout.panelCount}'),
            _metric(l10n.pv_design_total_area, '${(state.layout.panelCount * state.panelSpec.areaM2).toStringAsFixed(2)} m²'),
            _metric(l10n.pv_design_total_weight, '${(state.layout.panelCount * state.panelSpec.weightKg).toStringAsFixed(0)} kg'),
          ],
        ),
        SizedBox(height: 12.h),
        _buildCard(
          context,
          title: l10n.pv_design_energy_estimate,
          children: [
            _metric(l10n.pv_design_yearly_energy, '${energy.yearlyKwh.toStringAsFixed(0)} kWh'),
            _metric(l10n.pv_design_capacity_factor, '${(energy.capacityFactor * 100).toStringAsFixed(1)}%'),
            _metric(l10n.pv_design_co2_offset, '${energy.co2OffsetKg.toStringAsFixed(0)} kg'),
            _metric(l10n.pv_design_estimated_savings, '\$${energy.estimatedSavings.toStringAsFixed(0)}'),
            _metric(l10n.pv_design_data_source, energy.dataSource),
          ],
        ),
        SizedBox(height: 12.h),
        _buildCard(
          context,
          title: l10n.pv_design_monthly_energy,
          children: energy.monthlyKwh.entries.isEmpty
              ? [const Text('-')]
              : energy.monthlyKwh.entries
                  .map((e) => _metric(_monthName(e.key), '${e.value.toStringAsFixed(0)} kWh'))
                  .toList(),
        ),
        SizedBox(height: 20.h),
        FilledButton.icon(
          onPressed: () => _showSaveDialog(context, notifier),
          icon: const Icon(Icons.save),
          label: Text(l10n.pv_design_save_project),
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

  String _monthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }

  void _showSaveDialog(BuildContext context, PvSystemDesignController notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Project'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Project name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              notifier.saveProject(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
