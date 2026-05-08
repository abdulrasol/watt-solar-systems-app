import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:simple_step_checkout/simple_step_checkout.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_dialog.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/section_card.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/bom_item.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/drawing/watt_drawing_document.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/panel_spec.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/row_frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/features/structure_design/presentation/providers/structure_design_controller.dart';
import 'package:solar_hub/src/features/structure_design/presentation/screens/technical_sketch_page.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/sketch/structure_sketch_painter.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/sketch/technical_drawings_sheet.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StructureDesignScreen extends ConsumerStatefulWidget {
  const StructureDesignScreen({super.key});

  @override
  ConsumerState<StructureDesignScreen> createState() =>
      _StructureDesignScreenState();
}

class _StructureDesignScreenState extends ConsumerState<StructureDesignScreen>
    with SingleTickerProviderStateMixin {
  static const _helpStorageKey = 'structure_design_wizard_help_viewed';

  final _siteFormKey = GlobalKey<FormState>();
  final _panelsFormKey = GlobalKey<FormState>();
  late final TabController _tabController;
  late final TextEditingController _siteWidthController;
  late final TextEditingController _siteDepthController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _frontClearanceController;
  late final TextEditingController _rearClearanceController;
  late final TextEditingController _sideClearanceController;
  late final TextEditingController _frontLegClearanceController;
  late final TextEditingController _interRowGapController;
  late final TextEditingController _panelLengthController;
  late final TextEditingController _panelWidthController;
  late final TextEditingController _panelThicknessController;
  late final TextEditingController _horizontalGapController;
  late final TextEditingController _verticalGapController;
  late SimpleCheckoutStepperController _stepperController;
  bool _stepperReady = false;

  @override
  void initState() {
    super.initState();
    final input = ref.read(structureDesignControllerProvider).input;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _siteWidthController = TextEditingController(
      text: input.siteWidthMeters.toString(),
    );
    _siteDepthController = TextEditingController(
      text: input.siteDepthMeters.toString(),
    );
    _latitudeController = TextEditingController(
      text: input.latitude.toString(),
    );
    _frontClearanceController = TextEditingController(
      text: input.frontClearanceMeters.toString(),
    );
    _rearClearanceController = TextEditingController(
      text: input.rearClearanceMeters.toString(),
    );
    _sideClearanceController = TextEditingController(
      text: input.sideClearanceMeters.toString(),
    );
    _frontLegClearanceController = TextEditingController(
      text: input.frontLegClearanceMeters.toString(),
    );
    _interRowGapController = TextEditingController(
      text: input.interRowGapMeters.toString(),
    );
    _panelLengthController = TextEditingController(
      text: input.panelSpec.lengthMeters.toString(),
    );
    _panelWidthController = TextEditingController(
      text: input.panelSpec.widthMeters.toString(),
    );
    _panelThicknessController = TextEditingController(
      text: input.panelSpec.thicknessMeters.toString(),
    );
    _horizontalGapController = TextEditingController(
      text: input.panelSpec.horizontalGapMeters.toString(),
    );
    _verticalGapController = TextEditingController(
      text: input.panelSpec.verticalGapMeters.toString(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = GetStorage();
      if (box.read(_helpStorageKey) != true) {
        _showHelpDialog();
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    if (_stepperReady) {
      _stepperController.dispose();
    }
    _siteWidthController.dispose();
    _siteDepthController.dispose();
    _latitudeController.dispose();
    _frontClearanceController.dispose();
    _rearClearanceController.dispose();
    _sideClearanceController.dispose();
    _frontLegClearanceController.dispose();
    _interRowGapController.dispose();
    _panelLengthController.dispose();
    _panelWidthController.dispose();
    _panelThicknessController.dispose();
    _horizontalGapController.dispose();
    _verticalGapController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging || !_stepperReady) {
      return;
    }
    final targetIndex = _tabController.index;
    if (_stepperController.index < targetIndex) {
      for (var i = _stepperController.index; i < targetIndex; i++) {
        _stepperController.next();
      }
    } else if (_stepperController.index > targetIndex) {
      for (var i = _stepperController.index; i > targetIndex; i--) {
        _stepperController.previous();
      }
    }
    setState(() {});
  }

  Future<void> _handleNext() async {
    final isValid = switch (_tabController.index) {
      0 => _siteFormKey.currentState?.validate() ?? false,
      1 => _panelsFormKey.currentState?.validate() ?? false,
      _ => true,
    };
    if (!isValid) {
      return;
    }
    if (_tabController.index == 1) {
      ref.read(structureDesignControllerProvider).recalculate();
    }
    if (_tabController.index < 2) {
      _tabController.animateTo(_tabController.index + 1);
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleBack() {
    if (_tabController.index == 0) {
      Navigator.of(context).pop();
      return;
    }
    _tabController.animateTo(_tabController.index - 1);
  }

  Future<void> _openWattDrawing() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final document = await ref
          .read(wattDrawingFileServiceProvider)
          .pickAndDecode();
      if (document == null) {
        return;
      }
      ref.read(structureDesignControllerProvider).loadWattDrawing(document);
      _syncControllersFromInput(document.input);
      _tabController.animateTo(2);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.structure_drawing_opened(document.title))),
      );
    } on WattDrawingFileException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.structure_drawing_open_failed(error.message)),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.structure_drawing_open_failed('$error'))),
      );
    }
  }

  Future<void> _saveWattDrawing() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(structureDesignControllerProvider);
    final result = controller.result;
    if (result == null) {
      return;
    }
    final title = l10n.structure_drawing_default_title;
    try {
      final service = ref.read(wattDrawingFileServiceProvider);
      final file = await service.saveStructureDesignToAppDocuments(
        title: title,
        input: controller.input,
        result: result,
      );
      await service.shareWattDrawing(file, subject: title);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.structure_drawing_saved(file.path))),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.structure_drawing_save_failed('$error'))),
      );
    }
  }

  void _syncControllersFromInput(StructureDesignInput input) {
    _siteWidthController.text = input.siteWidthMeters.toString();
    _siteDepthController.text = input.siteDepthMeters.toString();
    _latitudeController.text = input.latitude.toString();
    _frontClearanceController.text = input.frontClearanceMeters.toString();
    _rearClearanceController.text = input.rearClearanceMeters.toString();
    _sideClearanceController.text = input.sideClearanceMeters.toString();
    _frontLegClearanceController.text = input.frontLegClearanceMeters
        .toString();
    _interRowGapController.text = input.interRowGapMeters.toString();
    _panelLengthController.text = input.panelSpec.lengthMeters.toString();
    _panelWidthController.text = input.panelSpec.widthMeters.toString();
    _panelThicknessController.text = input.panelSpec.thicknessMeters.toString();
    _horizontalGapController.text = input.panelSpec.horizontalGapMeters
        .toString();
    _verticalGapController.text = input.panelSpec.verticalGapMeters.toString();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(structureDesignControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final explanations = AppExplanations(
      context,
    ).getStructureDesignExplanations();

    if (!_stepperReady) {
      _stepperController = SimpleCheckoutStepperController(
        steps: 3,
        showTitles: true,
        stepsList: [
          l10n.structure_step_site,
          l10n.structure_step_panels,
          l10n.structure_step_results,
        ],
      );
      _stepperReady = true;
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PreScaffold(
        title: l10n.structure_design_title,
        actions: [
          IconButton(
            key: const Key('recent_structures_button'),
            onPressed: _openWattDrawing,
            icon: const Icon(Icons.history_rounded),
            tooltip: l10n.structure_open_watt_drawing,
          ),
          IconButton(
            key: const Key('open_watt_drawing_button'),
            onPressed: _openWattDrawing,
            icon: const Icon(Icons.folder_open_rounded),
            tooltip: l10n.structure_open_watt_drawing,
          ),
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: l10n.guide,
          ),
        ],
         bottomNavigationBar: _StructureWizardBottomBar(
           tabIndex: _tabController.index,
           l10n: l10n,
           theme: theme,
           onBack: _handleBack,
           onNext: _handleNext,
           onSave: _saveWattDrawing,
         ),
        child: Column(
          children: [
             _StepperShell(
               stepperController: _stepperController,
               isDark: theme.brightness == Brightness.dark,
             ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                 children: [
                   Form(
                     key: _siteFormKey,
                     child: _WizardScroll(
                       child: Column(
                         children: [
                           _IntroCard(
                             title: l10n.structure_design_title,
                             description: l10n.structure_design_intro,
                           ),
                           SizedBox(height: 16.h),
                           SectionCard(
                             icon: Iconsax.map_1_bold,
                             title: l10n.structure_site_inputs,
                             explanation: explanations[0],
                             child: Column(
                               children: [
                                 _NumberField(
                                   key: const Key('site_width_field'),
                                   controller: _siteWidthController,
                                   label: l10n.structure_site_width,
                                   suffix: l10n.metres,
                                   minValue: 0.01,
                                   onChanged: controller.updateSiteWidth,
                                 ),
                                 _NumberField(
                                   key: const Key('site_depth_field'),
                                   controller: _siteDepthController,
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
                             icon: Iconsax.location_bold,
                             title: l10n.structure_direction_preference,
                             explanation: explanations[1],
                             child: Column(
                               children: [
                                 Row(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Expanded(
                                       child: _NumberField(
                                         key: const Key('latitude_field'),
                                         controller: _latitudeController,
                                         label: l10n.structure_latitude,
                                         suffix: 'deg',
                                         allowAnyNumeric: true,
                                         onChanged: controller.updateLatitude,
                                       ),
                                     ),
                                     SizedBox(width: 12.w),
                                     FilledButton.icon(
                                       onPressed: controller.isLocating
                                           ? null
                                           : () async {
                                               if (!(_siteFormKey.currentState
                                                       ?.validate() ??
                                                   false)) {
                                                 return;
                                               }
                                               await ref
                                                   .read(
                                                     structureDesignControllerProvider,
                                                   )
                                                   .useCurrentLocation();
                                               final updated = ref
                                                   .read(
                                                     structureDesignControllerProvider,
                                                   )
                                                   .input;
                                               _latitudeController.text = updated
                                                   .latitude
                                                   .toStringAsFixed(4);
                                             },
                                       icon: controller.isLocating
                                           ? const SizedBox(
                                               width: 16,
                                               height: 16,
                                               child: CircularProgressIndicator(
                                                 strokeWidth: 2,
                                               ),
                                             )
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
                                     style: theme.textTheme.bodySmall?.copyWith(
                                       color: Colors.orange[800],
                                     ),
                                   ),
                                 ],
                                 SizedBox(height: 12.h),
                                 DropdownButtonFormField<
                                   FacingDirectionPreference
                                 >(
                                   initialValue:
                                       controller.input.facingPreference,
                                   decoration: _inputDecoration(
                                     context,
                                     l10n.structure_direction_preference,
                                   ),
                                   items: FacingDirectionPreference.values.map((
                                     value,
                                   ) {
                                     return DropdownMenuItem(
                                       value: value,
                                       child: Text(_directionLabel(l10n, value)),
                                     );
                                   }).toList(),
                                   onChanged: (value) {
                                     if (value != null) {
                                       controller.updateFacingPreference(value);
                                     }
                                   },
                                 ),
                                 SizedBox(height: 12.h),
                                 DropdownButtonFormField<MountType>(
                                   initialValue: controller.input.mountType,
                                   decoration: _inputDecoration(
                                     context,
                                     l10n.structure_mount_type,
                                   ),
                                   items: MountType.values.map((value) {
                                     final enabled = value == MountType.ground;
                                     return DropdownMenuItem(
                                       value: value,
                                       enabled: enabled,
                                       child: Text(
                                         enabled
                                             ? _mountTypeLabel(l10n, value)
                                             : '${_mountTypeLabel(l10n, value)} (${l10n.structure_coming_soon})',
                                       ),
                                     );
                                   }).toList(),
                                   onChanged: (value) {
                                     if (value != null) {
                                       controller.updateMountType(value);
                                     }
                                   },
                                 ),
                               ],
                             ),
                           ),
                        ],
                      ),
                    ),
                  ),
                   Form(
                     key: _panelsFormKey,
                     child: _WizardScroll(
                       child: Column(
                         children: [
                           SectionCard(
                             icon: Iconsax.sun_1_bold,
                             title: l10n.structure_panel_dimensions,
                             explanation: explanations[4],
                             child: Column(
                               children: [
                                 DropdownButtonFormField<PanelOrientation>(
                                   initialValue:
                                       controller.input.panelSpec.orientation,
                                   decoration: _inputDecoration(
                                     context,
                                     l10n.structure_panel_orientation,
                                   ),
                                   items: PanelOrientation.values.map((value) {
                                     return DropdownMenuItem(
                                       value: value,
                                       child: Text(
                                         value == PanelOrientation.portrait
                                             ? l10n.structure_orientation_portrait
                                             : l10n.structure_orientation_landscape,
                                       ),
                                     );
                                   }).toList(),
                                   onChanged: (value) {
                                     if (value != null) {
                                       controller.updatePanelOrientation(value);
                                     }
                                   },
                                 ),
                                 SizedBox(height: 12.h),
                                 _NumberField(
                                   controller: _panelLengthController,
                                   label: l10n.structure_panel_length,
                                   suffix: l10n.metres,
                                   minValue: 0.01,
                                   onChanged: controller.updatePanelLength,
                                 ),
                                 _NumberField(
                                   controller: _panelWidthController,
                                   label: l10n.structure_panel_width,
                                   suffix: l10n.metres,
                                   minValue: 0.01,
                                   onChanged: controller.updatePanelWidth,
                                 ),
                                 _NumberField(
                                   controller: _panelThicknessController,
                                   label: l10n.structure_panel_thickness,
                                   suffix: l10n.metres,
                                   minValue: 0.0,
                                   allowZero: true,
                                   onChanged: controller.updatePanelThickness,
                                 ),
                                 _NumberField(
                                   controller: _horizontalGapController,
                                   label: l10n.structure_horizontal_gap,
                                   suffix: l10n.metres,
                                   minValue: 0.0,
                                   allowZero: true,
                                   onChanged: controller.updateHorizontalGap,
                                 ),
                                 _NumberField(
                                   controller: _verticalGapController,
                                   label: l10n.structure_vertical_gap,
                                   suffix: l10n.metres,
                                   minValue: 0.0,
                                   allowZero: true,
                                   onChanged: controller.updateVerticalGap,
                                 ),
                               ],
                             ),
                           ),
                           SizedBox(height: 16.h),
                           SectionCard(
                             icon: Iconsax.buildings_2_bold,
                             title: l10n.structure_row_mode,
                             explanation: explanations[5],
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 DropdownButtonFormField<RowMode>(
                                   key: const Key('row_mode_field'),
                                   initialValue: controller.input.rowMode,
                                   decoration: _inputDecoration(
                                     context,
                                     l10n.structure_row_mode,
                                   ),
                                   items: RowMode.values.map((value) {
                                     return DropdownMenuItem(
                                       value: value,
                                       child: Text(_rowModeLabel(l10n, value)),
                                     );
                                   }).toList(),
                                   onChanged: (value) {
                                     if (value != null) {
                                       controller.updateRowMode(value);
                                     }
                                   },
                                 ),
                                 SizedBox(height: 12.h),
                                 Text(
                                   controller.input.rowMode ==
                                           RowMode.independent
                                       ? l10n.structure_independent_rows_hint
                                       : l10n.structure_stepped_rows_hint,
                                   key: const Key('row_mode_hint'),
                                   style: theme.textTheme.bodySmall?.copyWith(
                                     color: Colors.grey[700],
                                     height: 1.4,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                           SizedBox(height: 16.h),
                           SectionCard(
                             icon: Iconsax.ruler_bold,
                             title: l10n.structure_clearances,
                             explanation: explanations[6],
                             child: Column(
                               children: [
                                 _NumberField(
                                   controller: _frontClearanceController,
                                   label: l10n.structure_front_clearance,
                                   suffix: l10n.metres,
                                   minValue: 0.0,
                                   allowZero: true,
                                   onChanged: controller.updateFrontClearance,
                                 ),
                                 _NumberField(
                                   controller: _rearClearanceController,
                                   label: l10n.structure_rear_clearance,
                                   suffix: l10n.metres,
                                   minValue: 0.0,
                                   allowZero: true,
                                   onChanged: controller.updateRearClearance,
                                 ),
                                 _NumberField(
                                   controller: _sideClearanceController,
                                   label: l10n.structure_side_clearance,
                                   suffix: l10n.metres,
                                   minValue: 0.0,
                                   allowZero: true,
                                   onChanged: controller.updateSideClearance,
                                 ),
                                 _NumberField(
                                   controller: _frontLegClearanceController,
                                   label: l10n.structure_front_leg_height,
                                   suffix: l10n.metres,
                                   minValue: 0.0,
                                   allowZero: true,
                                   onChanged: controller.updateFrontLegClearance,
                                 ),
                                 _NumberField(
                                   controller: _interRowGapController,
                                   label: l10n.structure_inter_row_gap,
                                   suffix: l10n.metres,
                                   minValue: 0.0,
                                   allowZero: true,
                                   onChanged: controller.updateInterRowGap,
                                 ),
                               ],
                             ),
                           ),
                           if (!controller.supportsSelectedMountType) ...[
                             SizedBox(height: 12.h),
                             Text(
                               l10n.structure_ground_mount_only_hint,
                               style: theme.textTheme.bodyMedium?.copyWith(
                                 color: Colors.orange[800],
                               ),
                             ),
                           ],
                         ],
                       ),
                     ),
                   ),
                  _WizardScroll(
                    child: _ResultsStep(
                      controller: controller,
                      l10n: l10n,
                      explanations: explanations,
                      onSaveWattDrawing: _saveWattDrawing,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    final explanations = AppExplanations(
      context,
    ).getStructureDesignExplanations();
    ExplanationDialog.show(
      context,
      explanations: explanations,
      showDontShowAgain: true,
      storageKey: _helpStorageKey,
    );
  }

  String _directionLabel(
    AppLocalizations l10n,
    FacingDirectionPreference value,
  ) {
    return switch (value) {
      FacingDirectionPreference.any => l10n.structure_direction_any,
      FacingDirectionPreference.north => l10n.structure_direction_north,
      FacingDirectionPreference.northEast => l10n.structure_direction_northeast,
      FacingDirectionPreference.east => l10n.structure_direction_east,
      FacingDirectionPreference.southEast => l10n.structure_direction_southeast,
      FacingDirectionPreference.south => l10n.structure_direction_south,
      FacingDirectionPreference.southWest => l10n.structure_direction_southwest,
      FacingDirectionPreference.west => l10n.structure_direction_west,
      FacingDirectionPreference.northWest => l10n.structure_direction_northwest,
    };
  }

  String _mountTypeLabel(AppLocalizations l10n, MountType value) {
    return switch (value) {
      MountType.ground => l10n.structure_mount_ground,
      MountType.flatRoof => l10n.structure_mount_flat_roof,
      MountType.pitchedRoof => l10n.structure_mount_pitched_roof,
      MountType.custom => l10n.structure_mount_custom,
    };
  }

  String _rowModeLabel(AppLocalizations l10n, RowMode value) {
    return value == RowMode.independent
        ? l10n.structure_row_mode_independent
        : l10n.structure_row_mode_stepped;
  }
}

class _StepperShell extends StatelessWidget {
  const _StepperShell({required this.stepperController, required this.isDark});

  final SimpleCheckoutStepperController stepperController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5.w,
          ),
        ),
      ),
      child: SimpleCheckoutStepper(
        controller: stepperController,
        doneColor: AppTheme.primaryColor,
        unDoneColor: isDark ? Colors.white24 : Colors.grey.shade300,
        lineSize: 1.5.h,
        stepTitleStyle: TextStyle(
          fontSize: 11.sp,
          fontFamily: AppTheme.fontFamily,
          color: isDark ? Colors.white70 : Colors.grey.shade700,
        ),
        stepNumberStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          fontFamily: AppTheme.fontFamily,
          color: Colors.white,
        ),
        titlePaddingTop: 18.h,
      ),
    );
  }
}

class _StructureWizardBottomBar extends StatelessWidget {
  const _StructureWizardBottomBar({
    required this.tabIndex,
    required this.l10n,
    required this.theme,
    required this.onBack,
    required this.onNext,
    this.onSave,
  });

  final int tabIndex;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onBack;
  final VoidCallback onNext;
  /// Called when the user taps Share / Save on the final step.
  final Future<void> Function()? onSave;

  @override
  Widget build(BuildContext context) {
    final isLastStep = tabIndex == 2;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        12.h + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.4 : 0.08,
            ),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            child: Text(tabIndex == 0 ? l10n.close : l10n.back),
          ),
          const SizedBox(width: 12),
          // On the final step show Share/Save + a separate Close button
          if (isLastStep) ...[
            Expanded(
              child: FilledButton.icon(
                key: const Key('share_save_button'),
                onPressed: onSave,
                icon: const Icon(Icons.share_rounded, size: 18),
                label: Text(l10n.structure_save_watt_drawing),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: const Key('close_wizard_button'),
              onPressed: onNext,
              tooltip: l10n.close,
              icon: const Icon(Icons.close_rounded),
              style: IconButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ] else
            Expanded(
              child: FilledButton.icon(
                onPressed: onNext,
                icon: Icon(
                  tabIndex == 0
                      ? Icons.arrow_forward_rounded
                      : Iconsax.calculator_bold,
                  size: 18,
                ),
                label: Text(
                  tabIndex == 0 ? l10n.next : l10n.calculate,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WizardScroll extends StatelessWidget {
  const _WizardScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 28.h),
      child: child,
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5E8), Color(0xFFF8FBFF)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: const Icon(Iconsax.buildings_2_bold),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6.h),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsStep extends ConsumerWidget {
  const _ResultsStep({
    required this.controller,
    required this.l10n,
    required this.explanations,
    required this.onSaveWattDrawing,
  });

  final StructureDesignController controller;
  final AppLocalizations l10n;
  final List<ExplanationItem> explanations;
  final Future<void> Function() onSaveWattDrawing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = controller.result;
    if (result == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);

    return Column(
      children: [
        SectionCard(
          icon: Iconsax.grid_1_bold,
          title: l10n.structure_layout_editor,
          explanation: explanations[7],
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StepperTile(
                      title: l10n.structure_rows,
                      value: '${result.rows}',
                      onAdd: controller.incrementRows,
                      onRemove: controller.decrementRows,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StepperTile(
                      title: l10n.structure_columns,
                      value: '${result.columns}',
                      onAdd: controller.incrementColumns,
                      onRemove: controller.decrementColumns,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: controller.resetAutoLayout,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(l10n.structure_reset_auto_layout),
                ),
              ),
              if (controller.input.rowMode == RowMode.stepped) ...[
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.structure_row_offsets,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                for (var index = 0; index < result.rows; index++)
                  _OffsetField(
                    key: Key('row_offset_$index'),
                    label: l10n.structure_row_offset_value(index + 1),
                    initialValue: index < controller.rowBaseOffsetsMeters.length
                        ? controller.rowBaseOffsetsMeters[index]
                        : 0.0,
                    onChanged: (value) =>
                        controller.updateRowBaseOffset(index, value),
                  ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _ResultSummaryCard(result: result, l10n: l10n),
        SizedBox(height: 16.h),
        SectionCard(
          icon: Icons.straighten,
          title: l10n.structure_geometry_results,
          explanation: explanations[8],
          child: Column(
            children: [
              _MetricRow(
                label: l10n.structure_panel_count,
                value: '${result.panelCount}',
              ),
              _MetricRow(
                label: l10n.structure_frame_width,
                value: _meters(result.frameWidthMeters),
              ),
              _MetricRow(
                label: l10n.structure_frame_length,
                value: _meters(result.frameSlopeLengthMeters),
              ),
              _MetricRow(
                label: l10n.structure_row_spacing,
                value: _meters(result.rowSpacingMeters),
              ),
              _MetricRow(
                label: l10n.structure_total_footprint_depth,
                value: _meters(result.totalFootprintDepthMeters),
              ),
              _MetricRow(
                label: l10n.structure_front_leg_height,
                value: _meters(result.frontLegHeightMeters),
              ),
              _MetricRow(
                label: l10n.structure_rear_leg_height,
                value: _meters(result.rearLegHeightMeters),
              ),
              _MetricRow(
                label: l10n.structure_rail_length,
                value: _meters(result.railLengthMeters),
              ),
              _MetricRow(
                label: l10n.structure_brace_length,
                value: _meters(result.braceLengthMeters),
              ),
              _MetricRow(
                label: l10n.structure_total_steel_length,
                value: _meters(result.totalSteelLengthMeters),
              ),
              SizedBox(height: 4.h),
              Text(
                l10n.structure_total_steel_breakdown(
                  _meters(result.railLengthMeters),
                  _meters(result.totalFrontLegLengthMeters),
                  _meters(result.totalRearLegLengthMeters),
                  _meters(result.totalBraceLengthMeters),
                ),
                key: const Key('main_total_steel_breakdown'),
                style: theme.textTheme.bodySmall,
              ),
              if (result.rowMode == RowMode.stepped) ...[
                _MetricRow(
                  label: l10n.structure_min_front_leg,
                  value: _meters(result.minFrontLegHeightMeters),
                ),
                _MetricRow(
                  label: l10n.structure_max_front_leg,
                  value: _meters(result.maxFrontLegHeightMeters),
                ),
                _MetricRow(
                  label: l10n.structure_min_rear_leg,
                  value: _meters(result.minRearLegHeightMeters),
                ),
                _MetricRow(
                  label: l10n.structure_max_rear_leg,
                  value: _meters(result.maxRearLegHeightMeters),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16.h),
        SectionCard(
          icon: Iconsax.document_text_bold,
          title: l10n.structure_bom_title,
          explanation: explanations[9],
          child: Column(
            children: result.bomItems
                .map((item) => _BomRow(item: item))
                .toList(),
          ),
        ),
        SizedBox(height: 16.h),
        SectionCard(
          icon: Iconsax.activity_bold,
          title: result.rowMode == RowMode.independent
              ? l10n.structure_repeated_frame
              : l10n.structure_per_row_legs,
          explanation: explanations[7],
          child: result.rowMode == RowMode.independent
              ? Text(
                  l10n.structure_equal_legs_explanation,
                  key: const Key('uniform_leg_explanation'),
                )
              : Column(
                  key: const Key('stepped_row_results'),
                  children: result.rowResults
                      .map((row) => _RowResultCard(row: row, l10n: l10n))
                      .toList(),
                ),
        ),
        SizedBox(height: 16.h),
        SectionCard(
          icon: Iconsax.gallery_bold,
          title: l10n.structure_sketch_title,
          explanation: explanations[8],
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  FilledButton.tonalIcon(
                    key: const Key('save_watt_drawing_button'),
                    onPressed: onSaveWattDrawing,
                    icon: const Icon(Icons.save_alt_rounded),
                    label: Text(l10n.structure_save_watt_drawing),
                  ),
                  FilledButton.tonalIcon(
                    key: const Key('view_technical_drawings_button'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _TechnicalDrawingsPage(
                            result: result,
                            siteWidthMeters: controller.input.siteWidthMeters,
                            siteDepthMeters: controller.input.siteDepthMeters,
                            l10n: l10n,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.architecture),
                    label: const Text('Technical Drawings'),
                  ),
                  FilledButton.tonalIcon(
                    key: const Key('view_full_sketch_button'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _StructureSketchViewerPage(
                            result: result,
                            siteWidthMeters: controller.input.siteWidthMeters,
                            siteDepthMeters: controller.input.siteDepthMeters,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_full_rounded),
                    label: Text(l10n.view),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              AspectRatio(
                aspectRatio: 1.7,
                child: CustomPaint(
                  key: const Key('structure_sketch'),
                  painter: StructureSketchPainter(
                    result: result,
                    siteWidthMeters: controller.input.siteWidthMeters,
                    siteDepthMeters: controller.input.siteDepthMeters,
                    topViewLabel: l10n.structure_top_view,
                    sideViewLabel: l10n.structure_side_view,
                    frontViewLabel: l10n.structure_front_view,
                    isometricViewLabel: l10n.structure_isometric_view,
                    frontLabel: l10n.structure_front_label,
                    rearLabel: l10n.structure_rear_label,
                    braceLabel: l10n.structure_brace_label,
                    viewMode: StructureSketchView.top,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.structure_sketch_hint,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _meters(double value) => '${value.toStringAsFixed(2)} m';
}

class _ResultSummaryCard extends StatelessWidget {
  const _ResultSummaryCard({required this.result, required this.l10n});

  final FrameResult result;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.structure_results_title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(
                label:
                    '${l10n.structure_ideal_tilt}: ${result.idealTiltDegrees.toStringAsFixed(1)} deg',
              ),
              _MiniChip(
                label:
                    '${l10n.structure_applied_tilt}: ${result.appliedTiltDegrees.toStringAsFixed(1)} deg',
              ),
              _MiniChip(
                label:
                    '${l10n.structure_applied_azimuth}: ${result.appliedAzimuthDegrees.toStringAsFixed(0)} deg',
              ),
              _MiniChip(
                label: result.rowMode == RowMode.independent
                    ? l10n.structure_row_mode_independent
                    : l10n.structure_row_mode_stepped,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            result.isUniformLegDesign
                ? l10n.structure_equal_legs_explanation
                : l10n.structure_stepped_legs_explanation,
            key: result.isUniformLegDesign
                ? const Key('uniform_leg_explanation')
                : const Key('stepped_leg_explanation'),
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.title,
    required this.value,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final String value;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.remove)),
          IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 300;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label),
                    SizedBox(height: 4.h),
                    Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 3, child: Text(label)),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: Text(
                        value,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _BomRow extends StatelessWidget {
  const _BomRow({required this.item});

  final BomItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (item.note != null)
                  Text(
                    item.note!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Text('${item.quantity.toStringAsFixed(1)} ${item.unit}'),
        ],
      ),
    );
  }
}

class _RowResultCard extends StatelessWidget {
  const _RowResultCard({required this.row, required this.l10n});

  final RowFrameResult row;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.structure_row_offset_value(row.rowIndex + 1),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          _MetricRow(
            label: l10n.structure_base_offset,
            value: '${row.baseOffsetMeters.toStringAsFixed(2)} m',
          ),
          _MetricRow(
            label: l10n.structure_front_leg_height,
            value: '${row.frontLegHeightMeters.toStringAsFixed(2)} m',
          ),
          _MetricRow(
            label: l10n.structure_rear_leg_height,
            value: '${row.rearLegHeightMeters.toStringAsFixed(2)} m',
          ),
        ],
      ),
    );
  }
}

class _OffsetField extends StatelessWidget {
  const _OffsetField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final double initialValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue.toStringAsFixed(2),
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: _inputDecoration(
          context,
          label,
          suffixText: AppLocalizations.of(context)!.metres,
        ),
        onChanged: (value) => onChanged(double.tryParse(value) ?? 0.0),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    required this.onChanged,
    this.minValue,
    this.allowZero = false,
    this.allowAnyNumeric = false,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final ValueChanged<double> onChanged;
  final double? minValue;
  final bool allowZero;
  final bool allowAnyNumeric;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: _inputDecoration(context, label, suffixText: suffix),
        validator: (value) {
          final parsed = double.tryParse(value ?? '');
          if (parsed == null) {
            return AppLocalizations.of(context)!.structure_validation_positive;
          }
          if (allowAnyNumeric) {
            return null;
          }
          if (!allowZero && parsed == 0) {
            return AppLocalizations.of(context)!.structure_validation_positive;
          }
          if (minValue != null && parsed < minValue!) {
            return AppLocalizations.of(context)!.structure_validation_positive;
          }
          return null;
        },
        onChanged: (value) => onChanged(double.tryParse(value) ?? 0.0),
      ),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context,
  String label, {
  String? suffixText,
}) {
  return InputDecoration(
    labelText: label,
    suffixText: suffixText,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Theme.of(context).cardColor,
  );
}

class _StructureSketchViewerPage extends StatelessWidget {
  const _StructureSketchViewerPage({
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    // Responsive breakpoints: >=900 → desktop wide-layout, >=600 → tablet, <600 → mobile
    final screenWidth = media.size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final useWideLayout = isDesktop;
    // On tablet/desktop we give more vertical space to each sketch card
    final sketchHeightFactor = isDesktop ? 0.45 : (isTablet ? 0.38 : 0.32);
    final sideHeightFactor = isDesktop ? 0.50 : (isTablet ? 0.42 : 0.36);
    final smallHeightFactor = isDesktop ? 0.35 : (isTablet ? 0.30 : 0.26);
    final sketchColumn = Column(
      children: [
        _SketchViewCard(
          key: const Key('full_structure_sketch'),
          title: l10n.structure_top_view,
          height: math.min(media.size.height * sketchHeightFactor, 400.0),
          painter: StructureSketchPainter(
            result: result,
            siteWidthMeters: siteWidthMeters,
            siteDepthMeters: siteDepthMeters,
            topViewLabel: l10n.structure_top_view,
            sideViewLabel: l10n.structure_side_view,
            frontViewLabel: l10n.structure_front_view,
            isometricViewLabel: l10n.structure_isometric_view,
            frontLabel: l10n.structure_front_label,
            rearLabel: l10n.structure_rear_label,
            braceLabel: l10n.structure_brace_label,
            viewMode: StructureSketchView.top,
            detailLevel: SketchDetailLevel.detailed,
          ),
        ),
        SizedBox(height: 14.h),
        _SketchViewCard(
          title: l10n.structure_side_view,
          height: math.min(media.size.height * sideHeightFactor, 420.0),
          painter: StructureSketchPainter(
            result: result,
            siteWidthMeters: siteWidthMeters,
            siteDepthMeters: siteDepthMeters,
            topViewLabel: l10n.structure_top_view,
            sideViewLabel: l10n.structure_side_view,
            frontViewLabel: l10n.structure_front_view,
            isometricViewLabel: l10n.structure_isometric_view,
            frontLabel: l10n.structure_front_label,
            rearLabel: l10n.structure_rear_label,
            braceLabel: l10n.structure_brace_label,
            viewMode: StructureSketchView.side,
            detailLevel: SketchDetailLevel.detailed,
          ),
        ),
        SizedBox(height: 14.h),
        _SketchViewCard(
          title: l10n.structure_front_view,
          height: math.min(media.size.height * smallHeightFactor, 320.0),
          painter: StructureSketchPainter(
            result: result,
            siteWidthMeters: siteWidthMeters,
            siteDepthMeters: siteDepthMeters,
            topViewLabel: l10n.structure_top_view,
            sideViewLabel: l10n.structure_side_view,
            frontViewLabel: l10n.structure_front_view,
            isometricViewLabel: l10n.structure_isometric_view,
            frontLabel: l10n.structure_front_label,
            rearLabel: l10n.structure_rear_label,
            braceLabel: l10n.structure_brace_label,
            viewMode: StructureSketchView.front,
            detailLevel: SketchDetailLevel.detailed,
          ),
        ),
        SizedBox(height: 14.h),
        _SketchViewCard(
          title: l10n.structure_isometric_view,
          height: math.min(media.size.height * smallHeightFactor, 320.0),
          painter: StructureSketchPainter(
            result: result,
            siteWidthMeters: siteWidthMeters,
            siteDepthMeters: siteDepthMeters,
            topViewLabel: l10n.structure_top_view,
            sideViewLabel: l10n.structure_side_view,
            frontViewLabel: l10n.structure_front_view,
            isometricViewLabel: l10n.structure_isometric_view,
            frontLabel: l10n.structure_front_label,
            rearLabel: l10n.structure_rear_label,
            braceLabel: l10n.structure_brace_label,
            viewMode: StructureSketchView.isometric,
            detailLevel: SketchDetailLevel.detailed,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          l10n.structure_sketch_hint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );

    final dimensionsCard = Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.structure_geometry_dimensions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          _MetricRow(
            label: l10n.structure_frame_width,
            value: _meters(result.frameWidthMeters),
          ),
          _MetricRow(
            label: l10n.structure_frame_length,
            value: _meters(result.frameSlopeLengthMeters),
          ),
          _MetricRow(
            label: l10n.structure_row_spacing,
            value: _meters(result.rowSpacingMeters),
          ),
          _MetricRow(
            label: l10n.structure_total_footprint_depth,
            value: _meters(result.totalFootprintDepthMeters),
          ),
          _MetricRow(
            label: l10n.structure_front_leg_height,
            value: _meters(result.frontLegHeightMeters),
          ),
          _MetricRow(
            label: l10n.structure_rear_leg_height,
            value: _meters(result.rearLegHeightMeters),
          ),
          _MetricRow(
            label: l10n.structure_rail_length,
            value: _meters(result.railLengthMeters),
          ),
          _MetricRow(
            label: l10n.structure_brace_length,
            value: _meters(result.braceLengthMeters),
          ),
          _MetricRow(
            label: l10n.structure_total_front_legs_length,
            value: _meters(result.totalFrontLegLengthMeters),
          ),
          _MetricRow(
            label: l10n.structure_total_rear_legs_length,
            value: _meters(result.totalRearLegLengthMeters),
          ),
          _MetricRow(
            label: l10n.structure_total_braces_length,
            value: _meters(result.totalBraceLengthMeters),
          ),
          _MetricRow(
            label: l10n.structure_total_steel_length,
            value: _meters(result.totalSteelLengthMeters),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.structure_total_steel_breakdown(
              _meters(result.railLengthMeters),
              _meters(result.totalFrontLegLengthMeters),
              _meters(result.totalRearLegLengthMeters),
              _meters(result.totalBraceLengthMeters),
            ),
            key: const Key('total_steel_breakdown'),
            style: theme.textTheme.bodySmall,
          ),
          if (result.rowMode == RowMode.stepped) ...[
            SizedBox(height: 8.h),
            for (final row in result.rowResults)
              _MetricRow(
                label: l10n.structure_row_offset_value(row.rowIndex + 1),
                value:
                    '${_meters(row.frontLegHeightMeters)} / ${_meters(row.rearLegHeightMeters)}',
              ),
          ] else ...[
            SizedBox(height: 8.h),
            Text(
              l10n.structure_equal_legs_explanation,
              key: const Key('full_sketch_repeated_note'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.structure_full_sketch_title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
          child: useWideLayout
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: sketchColumn),
                    SizedBox(width: 16.w),
                    Expanded(flex: 2, child: dimensionsCard),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sketchColumn,
                    SizedBox(height: 16.h),
                    dimensionsCard,
                  ],
                ),
        ),
      ),
    );
  }

  String _meters(double value) => '${value.toStringAsFixed(2)} m';
}

class _SketchViewCard extends StatelessWidget {
  const _SketchViewCard({
    super.key,
    required this.title,
    required this.height,
    required this.painter,
  });

  final String title;
  final double height;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              height: height,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 3,
                boundaryMargin: const EdgeInsets.all(24),
                child: CustomPaint(
                  painter: painter,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen technical drawings page for construction use
class _TechnicalDrawingsPage extends StatelessWidget {
  const _TechnicalDrawingsPage({
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.l10n,
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final labels = _createLabels();

    return TechnicalSketchPage(
      result: result,
      siteWidthMeters: siteWidthMeters,
      siteDepthMeters: siteDepthMeters,
      labels: labels,
    );
  }

  TechnicalDrawingsLabels _createLabels() {
    return TechnicalDrawingsLabels(
      topView: l10n.structure_top_view,
      sideView: l10n.structure_side_view,
      frontView: l10n.structure_front_view,
      isometricView: l10n.structure_isometric_view,
      detailView: 'Detail View',
      rows: 'Rows',
      columns: 'Columns',
      panels: 'Panels',
      offset: 'Offset',
      totalDepth: 'Total Depth',
      groundLevel: 'Ground Level',
      scale: 'Scale',
      date: 'Date',
      basePlateDetail: 'Base Plate',
      legDetail: 'Leg Connection',
      technicalDrawings: 'Technical Drawings',
      dimensions: 'Dimensions',
      copyDimensions: 'Copy Dimensions',
      print: 'Print',
      share: 'Share',
      siteDimensions: 'Site Dimensions',
      siteWidth: l10n.structure_site_width,
      siteDepth: l10n.structure_site_depth,
      usableWidth: 'Usable Width',
      usableDepth: 'Usable Depth',
      panelLayout: 'Panel Layout',
      totalPanels: 'Total Panels',
      panelOrientation: 'Orientation',
      structureDimensions: 'Structure Dimensions',
      frameWidth: l10n.structure_frame_width,
      frameSlopeLength: 'Frame Slope Length',
      projectedRowDepth: 'Projected Row Depth',
      rowSpacing: l10n.structure_row_spacing,
      legHeights: 'Leg Heights',
      frontLegHeight: l10n.structure_front_leg_height,
      rearLegHeight: l10n.structure_rear_leg_height,
      minFrontLegHeight: 'Min Front Leg',
      maxFrontLegHeight: 'Max Front Leg',
      minRearLegHeight: 'Min Rear Leg',
      maxRearLegHeight: 'Max Rear Leg',
      supportStructure: 'Support Structure',
      supportStationCount: 'Support Stations',
      supportSpacing: 'Support Spacing',
      railLength: l10n.structure_rail_length,
      braceLength: l10n.structure_brace_length,
      angles: 'Angles',
      appliedTilt: l10n.structure_applied_tilt,
      idealTilt: l10n.structure_ideal_tilt,
      appliedAzimuth: l10n.structure_applied_azimuth,
      idealAzimuth: 'Ideal Azimuth',
      materials: 'Materials',
      totalSteelLength: l10n.structure_total_steel_length,
      frontLegCount: 'Front Legs',
      rearLegCount: 'Rear Legs',
      anchorCount: 'Anchors',
      rowDetails: 'Row Details',
      row: 'Row',
      baseOffset: 'Base Offset',
      localFootprint: 'Local Footprint',
      layout: 'Layout',
      structureDimensionsReport: 'Structure Dimensions Report',
      dimensionsCopied: 'Dimensions copied to clipboard',
      totalFootprintDepth: 'Total Footprint Depth',
      tilt: 'Tilt',
      resetView: 'Reset View',
      showGrid: 'Show Grid',
      showDimensions: 'Show Dimensions',
      showAnnotations: 'Show Annotations',
      front: 'Front',
      rear: 'Rear',
      brace: 'Brace',
      printFeatureComingSoon: 'Print feature coming soon',
      close: 'Close',
      supports: 'Supports',
    );
  }
}
