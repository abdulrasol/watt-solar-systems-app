import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:simple_step_checkout/simple_step_checkout.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_dialog.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/drawing/watt_drawing_document.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/features/structure_design/presentation/providers/structure_design_controller.dart';
import 'package:solar_hub/src/features/structure_design/presentation/screens/technical_sketch_page.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/sketch/sketch_viewer_page.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/sketch/technical_drawings_sheet.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/steps/panels_step.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/steps/results_step.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/steps/site_step.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/wizard/stepper_shell.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/wizard/structure_wizard_bottom_bar.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/wizard/wizard_scroll.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';

class StructureDesignScreen extends ConsumerStatefulWidget {
  const StructureDesignScreen({super.key});

  @override
  ConsumerState<StructureDesignScreen> createState() => _StructureDesignScreenState();
}

class _StructureDesignScreenState extends ConsumerState<StructureDesignScreen> with SingleTickerProviderStateMixin {
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
    _siteWidthController = TextEditingController(text: input.siteWidthMeters.toString());
    _siteDepthController = TextEditingController(text: input.siteDepthMeters.toString());
    _latitudeController = TextEditingController(text: input.latitude.toString());
    _frontClearanceController = TextEditingController(text: input.frontClearanceMeters.toString());
    _rearClearanceController = TextEditingController(text: input.rearClearanceMeters.toString());
    _sideClearanceController = TextEditingController(text: input.sideClearanceMeters.toString());
    _frontLegClearanceController = TextEditingController(text: input.frontLegClearanceMeters.toString());
    _interRowGapController = TextEditingController(text: input.interRowGapMeters.toString());
    _panelLengthController = TextEditingController(text: input.panelSpec.lengthMeters.toString());
    _panelWidthController = TextEditingController(text: input.panelSpec.widthMeters.toString());
    _panelThicknessController = TextEditingController(text: input.panelSpec.thicknessMeters.toString());
    _horizontalGapController = TextEditingController(text: input.panelSpec.horizontalGapMeters.toString());
    _verticalGapController = TextEditingController(text: input.panelSpec.verticalGapMeters.toString());

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
      final document = await ref.read(wattDrawingFileServiceProvider).pickAndDecode();
      if (document == null) {
        return;
      }
      ref.read(structureDesignControllerProvider).loadWattDrawing(document);
      _syncControllersFromInput(document.input);
      _tabController.animateTo(2);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.structure_drawing_opened(document.title))));
    } on WattDrawingFileException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.structure_drawing_open_failed(error.message))));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.structure_drawing_open_failed('$error'))));
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
      final file = await service.saveStructureDesignToAppDocuments(title: title, input: controller.input, result: result);
      await service.shareWattDrawing(file, subject: title);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.structure_drawing_saved(file.path))));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.structure_drawing_save_failed('$error'))));
    }
  }

  void _syncControllersFromInput(StructureDesignInput input) {
    _siteWidthController.text = input.siteWidthMeters.toString();
    _siteDepthController.text = input.siteDepthMeters.toString();
    _latitudeController.text = input.latitude.toString();
    _frontClearanceController.text = input.frontClearanceMeters.toString();
    _rearClearanceController.text = input.rearClearanceMeters.toString();
    _sideClearanceController.text = input.sideClearanceMeters.toString();
    _frontLegClearanceController.text = input.frontLegClearanceMeters.toString();
    _interRowGapController.text = input.interRowGapMeters.toString();
    _panelLengthController.text = input.panelSpec.lengthMeters.toString();
    _panelWidthController.text = input.panelSpec.widthMeters.toString();
    _panelThicknessController.text = input.panelSpec.thicknessMeters.toString();
    _horizontalGapController.text = input.panelSpec.horizontalGapMeters.toString();
    _verticalGapController.text = input.panelSpec.verticalGapMeters.toString();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(structureDesignControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final explanations = AppExplanations(context).getStructureDesignExplanations();

    if (!_stepperReady) {
      _stepperController = SimpleCheckoutStepperController(
        steps: 3,
        showTitles: true,
        stepsList: [l10n.structure_step_site, l10n.structure_step_panels, l10n.structure_step_results],
      );
      _stepperReady = true;
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PreScaffold(
        title: l10n.structure_design_title,
        actions: [
          IconButton(
            key: const Key('open_watt_drawing_button'),
            onPressed: _openWattDrawing,
            icon: const Icon(Icons.history_rounded),
            tooltip: l10n.structure_recents_tooltip,
          ),
          IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline_rounded), tooltip: l10n.guide),
        ],
        bottomNavigationBar: StructureWizardBottomBar(
          tabIndex: _tabController.index,
          onBack: _handleBack,
          l10n: l10n,
          theme: theme,

          onNext: _handleNext,
          onSave: () {},
          // onShare: _saveWattDrawing,
        ),
        child: Column(
          children: [
            StepperShell(stepperController: _stepperController, isDark: theme.brightness == Brightness.dark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  WizardScroll(
                    child: Column(
                      children: [
                        SiteStep(
                          formKey: _siteFormKey,
                          controller: controller,
                          l10n: l10n,
                          explanations: explanations,
                          siteWidthController: _siteWidthController,
                          siteDepthController: _siteDepthController,
                          latitudeController: _latitudeController,
                          onUseLocation: _onUseLocation,
                          directionLabel: _getFacingDirectionLabel,
                        ),
                      ],
                    ),
                  ),
                  WizardScroll(
                    child: PanelsStep(
                      formKey: _panelsFormKey,
                      controller: controller,
                      l10n: l10n,
                      explanations: explanations,
                      panelLengthController: _panelLengthController,
                      panelWidthController: _panelWidthController,
                      panelThicknessController: _panelThicknessController,
                      horizontalGapController: _horizontalGapController,
                      verticalGapController: _verticalGapController,
                      frontClearanceController: _frontClearanceController,
                      rearClearanceController: _rearClearanceController,
                      sideClearanceController: _sideClearanceController,
                      frontLegClearanceController: _frontLegClearanceController,
                      interRowGapController: _interRowGapController,
                      rowModeLabel: _getRowModeLabel,
                    ),
                  ),
                  ResultsStep(
                    controller: controller,
                    l10n: l10n,
                    explanations: explanations,
                    onSaveWattDrawing: _saveWattDrawing,
                    onViewTechnicalDrawings: () {
                      final result = controller.result;
                      if (result == null) {
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TechnicalSketchPage(
                            result: result,
                            siteWidthMeters: controller.input.siteWidthMeters,
                            siteDepthMeters: controller.input.siteDepthMeters,
                            labels: _createLabels(l10n),
                          ),
                        ),
                      );
                    },
                    onViewFullSketch: () {
                      final result = controller.result;
                      if (result == null) {
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StructureSketchViewerPage(
                            result: result,
                            siteWidthMeters: controller.input.siteWidthMeters,
                            siteDepthMeters: controller.input.siteDepthMeters,
                          ),
                        ),
                      );
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

  TechnicalDrawingsLabels _createLabels(AppLocalizations l10n) {
    return TechnicalDrawingsLabels(
      topView: l10n.structure_top_view,
      sideView: l10n.structure_side_view,
      frontView: l10n.structure_front_view,
      isometricView: l10n.structure_isometric_view,
      detailView: l10n.structure_detail_view,
      rows: l10n.structure_rows,
      columns: l10n.structure_columns,
      panels: l10n.structure_panels,
      offset: l10n.structure_offset,
      totalDepth: l10n.structure_total_depth,
      groundLevel: l10n.structure_ground_level,
      scale: l10n.structure_scale,
      date: l10n.date,
      basePlateDetail: l10n.structure_base_plate_detail,
      legDetail: l10n.structure_leg_detail,
      technicalDrawings: l10n.structure_full_sketch_title,
      dimensions: l10n.structure_geometry_dimensions,
      copyDimensions: l10n.structure_copy_dimensions,
      print: l10n.structure_print,
      share: l10n.share,
      siteDimensions: l10n.structure_site_inputs,
      siteWidth: l10n.structure_site_width,
      siteDepth: l10n.structure_site_depth,
      usableWidth: l10n.structure_usable_width,
      usableDepth: l10n.structure_usable_depth,
      panelLayout: l10n.structure_panel_layout,
      totalPanels: l10n.structure_total_panels,
      panelOrientation: l10n.structure_panel_orientation,
      structureDimensions: l10n.structure_geometry_dimensions,
      frameWidth: l10n.structure_frame_width,
      frameSlopeLength: l10n.structure_frame_length,
      projectedRowDepth: l10n.structure_frame_depth,
      rowSpacing: l10n.structure_row_spacing,
      legHeights: l10n.structure_leg_heights,
      frontLegHeight: l10n.structure_front_leg_height,
      rearLegHeight: l10n.structure_rear_leg_height,
      minFrontLegHeight: l10n.structure_min_front_leg_height,
      maxFrontLegHeight: l10n.structure_max_front_leg,
      minRearLegHeight: l10n.structure_min_rear_leg,
      maxRearLegHeight: l10n.structure_max_rear_leg,
      supportStructure: l10n.structure_support_structure,
      supportStationCount: l10n.structure_support_station_count,
      supportSpacing: l10n.structure_support_spacing,
      railLength: l10n.structure_rail_length,
      braceLength: l10n.structure_brace_length,
      angles: l10n.structure_angles,
      appliedTilt: l10n.structure_applied_tilt,
      idealTilt: l10n.structure_ideal_tilt,
      appliedAzimuth: l10n.structure_applied_azimuth,
      idealAzimuth: l10n.structure_ideal_azimuth,
      materials: l10n.structure_materials,
      totalSteelLength: l10n.structure_total_steel_length,
      frontLegCount: l10n.structure_front_leg_count,
      rearLegCount: l10n.structure_rear_leg_count,
      anchorCount: l10n.structure_anchor_count,
      rowDetails: l10n.structure_row_details,
      row: l10n.structure_row,
      baseOffset: l10n.structure_base_offset,
      localFootprint: l10n.structure_local_footprint,
      layout: l10n.structure_layout,
      structureDimensionsReport: l10n.structure_dimensions_report,
      dimensionsCopied: l10n.structure_dimensions_copied,
      totalFootprintDepth: l10n.structure_total_footprint_depth,
      tilt: l10n.structure_tilt,
      resetView: l10n.reset,
      showGrid: l10n.structure_show_grid,
      showDimensions: l10n.structure_show_dimensions,
      showAnnotations: l10n.structure_show_annotations,
      front: l10n.structure_front_label,
      rear: l10n.structure_rear_label,
      brace: l10n.structure_brace_label,
      printFeatureComingSoon: l10n.structure_print_feature_coming_soon,
      close: l10n.close,
      supports: l10n.structure_supports,
    );
  }

  void _showHelpDialog() {
    final explanations = AppExplanations(context).getStructureDesignExplanations();
    ExplanationDialog.show(context, explanations: explanations, showDontShowAgain: true, storageKey: _helpStorageKey);
  }

  void _onUseLocation() {
    ref.read(structureDesignControllerProvider).useCurrentLocation();
  }

  String _getFacingDirectionLabel(AppLocalizations l10n, FacingDirectionPreference value) {
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

  String _getRowModeLabel(AppLocalizations l10n, RowMode value) {
    return switch (value) {
      RowMode.independent => l10n.structure_row_mode_independent,
      RowMode.stepped => l10n.structure_row_mode_stepped,
    };
  }
}
