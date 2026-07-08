import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/calculations/presentation/widgets/section_card.dart';
import 'package:watt/src/features/structure_design/domain/entities/panel_spec.dart';
import 'package:watt/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:watt/src/features/structure_design/presentation/providers/structure_design_controller.dart';
import 'package:watt/src/features/structure_design/presentation/widgets/inputs/number_field.dart';
import 'package:watt/src/utils/app_explanations.dart';

class PanelsStep extends StatelessWidget {
  const PanelsStep({
    super.key,
    required this.formKey,
    required this.l10n,
    required this.explanations,
    required this.controller,
    required this.panelLengthController,
    required this.panelWidthController,
    required this.panelThicknessController,
    required this.horizontalGapController,
    required this.verticalGapController,
    required this.frontClearanceController,
    required this.rearClearanceController,
    required this.sideClearanceController,
    required this.frontLegClearanceController,
    required this.interRowGapController,
    required this.rowModeLabel,
  });

  final GlobalKey<FormState> formKey;
  final AppLocalizations l10n;
  final List<ExplanationItem> explanations;
  final StructureDesignController controller;
  final TextEditingController panelLengthController;
  final TextEditingController panelWidthController;
  final TextEditingController panelThicknessController;
  final TextEditingController horizontalGapController;
  final TextEditingController verticalGapController;
  final TextEditingController frontClearanceController;
  final TextEditingController rearClearanceController;
  final TextEditingController sideClearanceController;
  final TextEditingController frontLegClearanceController;
  final TextEditingController interRowGapController;
  final String Function(AppLocalizations, RowMode) rowModeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = controller; // Note: controller is used to access input and methods

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SectionCard(
              icon: Iconsax.sun_1,
              title: l10n.structure_panel_dimensions,
              explanation: explanations[4],
              child: Column(
                children: [
                  DropdownButtonFormField<PanelOrientation>(
                    initialValue: state.input.panelSpec.orientation,
                    decoration: InputDecoration(
                      labelText: l10n.structure_panel_orientation,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                    items: PanelOrientation.values.map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value == PanelOrientation.portrait ? l10n.structure_orientation_portrait : l10n.structure_orientation_landscape),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        state.updatePanelOrientation(value);
                      }
                    },
                  ),
                  SizedBox(height: 12.h),
                  NumberField(
                    controller: panelLengthController,
                    label: l10n.structure_panel_length,
                    suffix: l10n.metres,
                    minValue: 0.01,
                    onChanged: state.updatePanelLength,
                  ),
                  NumberField(
                    controller: panelWidthController,
                    label: l10n.structure_panel_width,
                    suffix: l10n.metres,
                    minValue: 0.01,
                    onChanged: state.updatePanelWidth,
                  ),
                  NumberField(
                    controller: panelThicknessController,
                    label: l10n.structure_panel_thickness,
                    suffix: l10n.metres,
                    minValue: 0.0,
                    allowZero: true,
                    onChanged: state.updatePanelThickness,
                  ),
                  NumberField(
                    controller: horizontalGapController,
                    label: l10n.structure_horizontal_gap,
                    suffix: l10n.metres,
                    minValue: 0.0,
                    allowZero: true,
                    onChanged: state.updateHorizontalGap,
                  ),
                  NumberField(
                    controller: verticalGapController,
                    label: l10n.structure_vertical_gap,
                    suffix: l10n.metres,
                    minValue: 0.0,
                    allowZero: true,
                    onChanged: state.updateVerticalGap,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SectionCard(
              icon: Iconsax.buildings_2,
              title: l10n.structure_row_mode,
              explanation: explanations[5],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<RowMode>(
                    key: const Key('row_mode_field'),
                    initialValue: state.input.rowMode,
                    decoration: InputDecoration(
                      labelText: l10n.structure_row_mode,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                    items: RowMode.values.map((value) {
                      return DropdownMenuItem(value: value, child: Text(rowModeLabel(l10n, value)));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        state.updateRowMode(value);
                      }
                    },
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    state.input.rowMode == RowMode.independent ? l10n.structure_independent_rows_hint : l10n.structure_stepped_rows_hint,
                    key: const Key('row_mode_hint'),
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700], height: 1.4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SectionCard(
              icon: Iconsax.ruler,
              title: l10n.structure_clearances,
              explanation: explanations[6],
              child: Column(
                children: [
                  NumberField(
                    controller: frontClearanceController,
                    label: l10n.structure_front_clearance,
                    suffix: l10n.metres,
                    minValue: 0.0,
                    allowZero: true,
                    onChanged: state.updateFrontClearance,
                  ),
                  NumberField(
                    controller: rearClearanceController,
                    label: l10n.structure_rear_clearance,
                    suffix: l10n.metres,
                    minValue: 0.0,
                    allowZero: true,
                    onChanged: state.updateRearClearance,
                  ),
                  NumberField(
                    controller: sideClearanceController,
                    label: l10n.structure_side_clearance,
                    suffix: l10n.metres,
                    minValue: 0.0,
                    allowZero: true,
                    onChanged: state.updateSideClearance,
                  ),
                  NumberField(
                    controller: frontLegClearanceController,
                    label: l10n.structure_front_leg_height,
                    suffix: l10n.metres,
                    minValue: 0.0,
                    allowZero: true,
                    onChanged: state.updateFrontLegClearance,
                  ),
                  NumberField(
                    controller: interRowGapController,
                    label: l10n.structure_inter_row_gap,
                    suffix: l10n.metres,
                    minValue: 0.0,
                    allowZero: true,
                    onChanged: state.updateInterRowGap,
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
