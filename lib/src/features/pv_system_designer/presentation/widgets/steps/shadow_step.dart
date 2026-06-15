import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_design_providers.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/canvas/pv_design_canvas.dart';

class ShadowStep extends ConsumerStatefulWidget {
  const ShadowStep({super.key});

  @override
  ConsumerState<ShadowStep> createState() => _ShadowStepState();
}

class _ShadowStepState extends ConsumerState<ShadowStep> {
  final DateTime _date = DateTime.now();
  double _hour = 12.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(pvSystemDesignControllerProvider);
    final notifier = ref.read(pvSystemDesignControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.pv_design_shadow_time(_hour.toStringAsFixed(1)),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _hour,
                min: 5,
                max: 20,
                divisions: 30,
                label: _hour.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() => _hour = value);
                  notifier.updateMomentShading(_date, value);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.pv_design_winter_solstice),
                  Text(l10n.pv_design_summer_solstice),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: PvDesignCanvas(state: state)),
      ],
    );
  }
}
