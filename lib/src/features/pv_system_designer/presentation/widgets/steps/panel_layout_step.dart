import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_design_providers.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/canvas/pv_design_canvas.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/inputs/pv_number_field.dart';

class PanelLayoutStep extends ConsumerStatefulWidget {
  const PanelLayoutStep({super.key});

  @override
  ConsumerState<PanelLayoutStep> createState() => _PanelLayoutStepState();
}

class _PanelLayoutStepState extends ConsumerState<PanelLayoutStep> {
  late final TextEditingController _powerController;
  late final TextEditingController _lengthController;
  late final TextEditingController _widthController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    final spec = ref.read(pvSystemDesignControllerProvider).panelSpec;
    _powerController = TextEditingController(text: spec.powerW.toString());
    _lengthController = TextEditingController(text: spec.lengthM.toString());
    _widthController = TextEditingController(text: spec.widthM.toString());
    _weightController = TextEditingController(text: spec.weightKg.toString());
  }

  @override
  void dispose() {
    _powerController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _commit() {
    final notifier = ref.read(pvSystemDesignControllerProvider.notifier);
    final current = ref.read(pvSystemDesignControllerProvider).panelSpec;
    notifier.updatePanelSpec(
      current.copyWith(
        powerW: double.tryParse(_powerController.text) ?? current.powerW,
        lengthM: double.tryParse(_lengthController.text) ?? current.lengthM,
        widthM: double.tryParse(_widthController.text) ?? current.widthM,
        weightKg: double.tryParse(_weightController.text) ?? current.weightKg,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(pvSystemDesignControllerProvider);
    final notifier = ref.read(pvSystemDesignControllerProvider.notifier);

    return Column(
      children: [
        Expanded(child: PvDesignCanvas(state: state, showShadows: false)),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: PvNumberField(
                      label: l10n.pv_design_panel_power,
                      controller: _powerController,
                      suffix: 'W',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: PvNumberField(
                      label: l10n.pv_design_panel_length,
                      controller: _lengthController,
                      suffix: 'm',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: PvNumberField(
                      label: l10n.pv_design_panel_width,
                      controller: _widthController,
                      suffix: 'm',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: PvNumberField(
                      label: l10n.pv_design_panel_weight,
                      controller: _weightController,
                      suffix: 'kg',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        _commit();
                        notifier.autoPlacePanels();
                      },
                      child: Text(l10n.pv_design_auto_place),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _commit();
                        notifier.clearPanels();
                      },
                      child: Text(l10n.pv_design_clear_panels),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
