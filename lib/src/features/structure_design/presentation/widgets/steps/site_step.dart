import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/section_card.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/features/structure_design/presentation/providers/structure_design_controller.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/inputs/number_field.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/wizard/intro_card.dart';

import 'package:solar_hub/src/utils/app_explanations.dart';

class SiteStep extends StatelessWidget {
  const SiteStep({
    super.key,
    required this.formKey,
    required this.l10n,
    required this.explanations,
    required this.controller,
    required this.siteWidthController,
    required this.siteDepthController,
    required this.latitudeController,
    required this.onUseLocation,
    required this.directionLabel,
  });

  final GlobalKey<FormState> formKey;
  final AppLocalizations l10n;
  final List<ExplanationItem> explanations;
  final StructureDesignController controller;
  final TextEditingController siteWidthController;
  final TextEditingController siteDepthController;
  final TextEditingController latitudeController;
  final VoidCallback onUseLocation;
  final String Function(AppLocalizations, FacingDirectionPreference) directionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            IntroCard(l10n: l10n, title: l10n.structure_design_title, description: l10n.structure_design_intro),
            SizedBox(height: 16.h),
            SectionCard(
              icon: Iconsax.map_1,
              title: l10n.structure_site_inputs,
              explanation: explanations[0],
              child: Column(
                children: [
                  NumberField(
                    key: const Key('site_width_field'),
                    controller: siteWidthController,
                    label: l10n.structure_site_width,
                    suffix: l10n.metres,
                    minValue: 0.01,
                    onChanged: controller.updateSiteWidth,
                  ),
                  NumberField(
                    key: const Key('site_depth_field'),
                    controller: siteDepthController,
                    label: l10n.structure_site_depth,
                    suffix: l10n.metres,
                    minValue: 0.01,
                    onChanged: controller.updateSiteDepth,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SectionCard(
              icon: Iconsax.location,
              title: l10n.structure_direction_preference,
              explanation: explanations[1],
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: NumberField(
                          key: const Key('latitude_field'),
                          controller: latitudeController,
                          label: l10n.structure_latitude,
                          suffix: 'deg',
                          allowAnyNumeric: true,
                          onChanged: controller.updateLatitude,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      FilledButton.icon(
                        onPressed: controller.isLocating ? null : onUseLocation,
                        icon: controller.isLocating
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location),
                        label: Text(l10n.structure_use_location),
                      ),
                    ],
                  ),
                  if (controller.locationMessage != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      controller.locationMessage!,
                      key: const Key('location_message'),
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange[800]),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<FacingDirectionPreference>(
                    initialValue: controller.input.facingPreference,
                    decoration: InputDecoration(
                      labelText: l10n.structure_direction_preference,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                    items: FacingDirectionPreference.values.map((value) {
                      return DropdownMenuItem(value: value, child: Text(directionLabel(l10n, value)));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateFacingPreference(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
