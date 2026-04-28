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
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/panel_spec.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/row_frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/features/structure_design/presentation/providers/structure_design_controller.dart';
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
  });

  final int tabIndex;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: FilledButton.icon(
              onPressed: onNext,
              icon: Icon(
                tabIndex == 0
                    ? Icons.arrow_forward_rounded
                    : tabIndex == 1
                    ? Iconsax.calculator_bold
                    : Icons.check_rounded,
                size: 18,
              ),
              label: Text(
                tabIndex == 0
                    ? l10n.next
                    : tabIndex == 1
                    ? l10n.calculate
                    : l10n.close,
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
  });

  final StructureDesignController controller;
  final AppLocalizations l10n;
  final List<ExplanationItem> explanations;

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
              Align(
                alignment: Alignment.centerRight,
                child: LayoutBuilder(
                  builder: (context, constraints) => FilledButton.tonalIcon(
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
                ),
              ),
              SizedBox(height: 12.h),
              AspectRatio(
                aspectRatio: 1.7,
                child: CustomPaint(
                  key: const Key('structure_sketch'),
                  painter: _StructureSketchPainter(
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
                    detailLevel: _SketchDetailLevel.preview,
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
    final useWideLayout =
        media.orientation == Orientation.landscape && media.size.width > 900;
    final sketchColumn = Column(
      children: [
        _SketchViewCard(
          key: const Key('full_structure_sketch'),
          title: l10n.structure_top_view,
          height: math.min(media.size.height * 0.38, 340.0),
          painter: _StructureSketchPainter(
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
            detailLevel: _SketchDetailLevel.detailed,
            repeatedRowLabel: l10n.structure_repeated_frame,
            rowOffsetLabel: l10n.structure_base_offset,
            viewMode: _StructureSketchView.top,
          ),
        ),
        SizedBox(height: 14.h),
        _SketchViewCard(
          title: l10n.structure_side_view,
          height: math.min(media.size.height * 0.40, 360.0),
          painter: _StructureSketchPainter(
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
            detailLevel: _SketchDetailLevel.detailed,
            repeatedRowLabel: l10n.structure_repeated_frame,
            rowOffsetLabel: l10n.structure_base_offset,
            viewMode: _StructureSketchView.side,
          ),
        ),
        SizedBox(height: 14.h),
        _SketchViewCard(
          title: l10n.structure_front_view,
          height: math.min(media.size.height * 0.28, 250.0),
          painter: _StructureSketchPainter(
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
            detailLevel: _SketchDetailLevel.detailed,
            repeatedRowLabel: l10n.structure_repeated_frame,
            rowOffsetLabel: l10n.structure_base_offset,
            viewMode: _StructureSketchView.front,
          ),
        ),
        SizedBox(height: 14.h),
        _SketchViewCard(
          title: l10n.structure_isometric_view,
          height: math.min(media.size.height * 0.28, 250.0),
          painter: _StructureSketchPainter(
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
            detailLevel: _SketchDetailLevel.detailed,
            repeatedRowLabel: l10n.structure_repeated_frame,
            rowOffsetLabel: l10n.structure_base_offset,
            viewMode: _StructureSketchView.isometric,
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

class _StructureSketchPainter extends CustomPainter {
  _StructureSketchPainter({
    required this.result,
    required this.siteWidthMeters,
    required this.siteDepthMeters,
    required this.topViewLabel,
    required this.sideViewLabel,
    required this.frontViewLabel,
    required this.isometricViewLabel,
    required this.frontLabel,
    required this.rearLabel,
    required this.braceLabel,
    this.detailLevel = _SketchDetailLevel.preview,
    this.repeatedRowLabel,
    this.rowOffsetLabel,
    this.viewMode,
  });

  final FrameResult result;
  final double siteWidthMeters;
  final double siteDepthMeters;
  final String topViewLabel;
  final String sideViewLabel;
  final String frontViewLabel;
  final String isometricViewLabel;
  final String frontLabel;
  final String rearLabel;
  final String braceLabel;
  final _SketchDetailLevel detailLevel;
  final String? repeatedRowLabel;
  final String? rowOffsetLabel;
  final _StructureSketchView? viewMode;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFF9FBFC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
      background,
    );

    final border = Paint()
      ..color = const Color(0xFFDDE5EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
      border,
    );

    if (viewMode != null) {
      final viewRect = Rect.fromLTWH(16, 16, size.width - 32, size.height - 32);
      if (viewMode == _StructureSketchView.top) {
        _paintTopView(canvas, viewRect, showTitle: false);
      } else if (viewMode == _StructureSketchView.side) {
        _paintSideView(canvas, viewRect, showTitle: false);
      } else if (viewMode == _StructureSketchView.front) {
        _paintFrontView(canvas, viewRect, showTitle: false);
      } else {
        _paintIsometricView(canvas, viewRect, showTitle: false);
      }
      return;
    }

    final contentRect = Rect.fromLTWH(
      16,
      16,
      size.width - 32,
      size.height - 32,
    );
    final gap = detailLevel == _SketchDetailLevel.detailed ? 14.0 : 10.0;
    final topHeight = detailLevel == _SketchDetailLevel.detailed
        ? contentRect.height * 0.42
        : contentRect.height * 0.46;
    final topRect = Rect.fromLTWH(
      contentRect.left,
      contentRect.top,
      contentRect.width,
      topHeight,
    );
    final lowerTop = topRect.bottom + gap;
    final lowerHeight = contentRect.bottom - lowerTop;
    final halfWidth = (contentRect.width - gap) / 2;
    final sideRect = Rect.fromLTWH(
      contentRect.left,
      lowerTop,
      halfWidth,
      lowerHeight,
    );
    final rightRect = Rect.fromLTWH(
      contentRect.left + halfWidth + gap,
      lowerTop,
      halfWidth,
      lowerHeight,
    );
    final rightGap = detailLevel == _SketchDetailLevel.detailed ? 12.0 : 8.0;
    final frontHeight = (rightRect.height - rightGap) / 2;
    final frontRect = Rect.fromLTWH(
      rightRect.left,
      rightRect.top,
      rightRect.width,
      frontHeight,
    );
    final isoRect = Rect.fromLTWH(
      rightRect.left,
      rightRect.top + frontHeight + rightGap,
      rightRect.width,
      frontHeight,
    );

    _paintTopView(canvas, topRect);
    _paintSideView(canvas, sideRect);
    _paintFrontView(canvas, frontRect);
    _paintIsometricView(canvas, isoRect);
  }

  void _paintTopView(Canvas canvas, Rect rect, {bool showTitle = true}) {
    if (showTitle) {
      _paintTitle(canvas, topViewLabel, Offset(rect.left, rect.top));
    }
    final frameTop = rect.top + (showTitle ? 22 : 0);
    final drawingRect = Rect.fromLTWH(
      rect.left,
      frameTop,
      rect.width,
      rect.height - (showTitle ? 22 : 0),
    );
    final workRect = Rect.fromLTWH(
      drawingRect.left + 8,
      drawingRect.top + 8,
      drawingRect.width - 16,
      drawingRect.height - 16,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(workRect, const Radius.circular(12)),
      Paint()..color = const Color(0xFFEAF4F8),
    );

    final usableWidthRatio = siteWidthMeters <= 0
        ? 0.0
        : result.usableWidthMeters / siteWidthMeters;
    final usableDepthRatio = siteDepthMeters <= 0
        ? 0.0
        : result.usableDepthMeters / siteDepthMeters;
    final usableRect = Rect.fromLTWH(
      workRect.left + (workRect.width * (1 - usableWidthRatio) / 2),
      workRect.top + (workRect.height * (1 - usableDepthRatio) / 2),
      workRect.width * usableWidthRatio,
      workRect.height * usableDepthRatio,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(usableRect, const Radius.circular(10)),
      Paint()..color = const Color(0xFFDCEFD8),
    );

    if (result.rows == 0 || result.columns == 0) {
      return;
    }

    final cellWidth = usableRect.width / result.columns;
    final cellHeight = usableRect.height / result.rows;
    final panelPaint = Paint()..color = const Color(0xFFFFB347);

    for (var row = 0; row < result.rows; row++) {
      for (var col = 0; col < result.columns; col++) {
        final panelRect = Rect.fromLTWH(
          usableRect.left + (col * cellWidth) + 2,
          usableRect.top + (row * cellHeight) + 2,
          math.max(4, cellWidth - 4),
          math.max(4, cellHeight - 4),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(panelRect, const Radius.circular(4)),
          panelPaint,
        );
      }
    }

    if (detailLevel == _SketchDetailLevel.detailed) {
      _paintDimensionLine(
        canvas,
        start: Offset(usableRect.left, usableRect.bottom + 10),
        end: Offset(usableRect.right, usableRect.bottom + 10),
        label: '${result.frameWidthMeters.toStringAsFixed(2)} m',
      );
      _paintVerticalDimension(
        canvas,
        x: usableRect.right + 12,
        baseY: usableRect.bottom,
        topY: usableRect.top,
        label: '${result.totalFootprintDepthMeters.toStringAsFixed(2)} m',
      );
      if (result.rows > 1) {
        final rowPitch = usableRect.height / result.rows;
        _paintSmallLabel(
          canvas,
          '${result.rows} rows',
          Offset(usableRect.left + 4, usableRect.top + 4),
        );
        _paintSmallLabel(
          canvas,
          '${result.rowSpacingMeters.toStringAsFixed(2)} m gap',
          Offset(usableRect.left + 4, usableRect.top + rowPitch - 18),
        );
      }
    }
  }

  void _paintSideView(Canvas canvas, Rect rect, {bool showTitle = true}) {
    if (showTitle) {
      _paintTitle(canvas, sideViewLabel, Offset(rect.left, rect.top));
    }
    final contentTop = rect.top + (showTitle ? 22 : 0);
    final bottomReserve = detailLevel == _SketchDetailLevel.detailed
        ? (result.rows > 1 ? 66.0 : 52.0)
        : 12.0;
    final baseY = rect.bottom - bottomReserve;
    final startX = rect.left + 20;
    final width = rect.width - 40;
    final depthScale =
        width / math.max(result.totalFootprintDepthMeters - 0.5, 1.0);
    final heightScale =
        (baseY - contentTop - 10) /
        math.max(
          result.maxRearLegHeightMeters,
          result.rearLegHeightMeters + 0.1,
        );

    final linePaint = Paint()
      ..color = const Color(0xFF365A6B)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final bracePaint = Paint()
      ..color = const Color(0xFF6C8A96)
      ..strokeWidth = 2;

    final rowsToRender =
        result.isUniformLegDesign && result.rowResults.isNotEmpty
        ? <RowFrameResult>[result.rowResults.first]
        : result.rowResults;

    var currentX = startX;
    for (final row in rowsToRender) {
      final frontTopY = baseY - (row.frontLegHeightMeters * heightScale);
      final rearTopY = baseY - (row.rearLegHeightMeters * heightScale);
      final rearX = currentX + (result.projectedRowDepthMeters * depthScale);

      canvas.drawLine(
        Offset(currentX, baseY),
        Offset(currentX, frontTopY),
        linePaint,
      );
      canvas.drawLine(Offset(rearX, baseY), Offset(rearX, rearTopY), linePaint);
      canvas.drawLine(
        Offset(currentX, frontTopY),
        Offset(rearX, rearTopY),
        linePaint,
      );
      canvas.drawLine(
        Offset(currentX, baseY),
        Offset(rearX - 10, rearTopY),
        bracePaint,
      );

      if (row.rowIndex == 0) {
        _paintSmallLabel(
          canvas,
          frontLabel,
          Offset(currentX - 16, frontTopY - 26),
        );
        _paintSmallLabel(canvas, rearLabel, Offset(rearX - 18, rearTopY - 28));
        _paintSmallLabel(
          canvas,
          braceLabel,
          Offset((currentX + rearX) / 2 - 12, rearTopY - 10),
        );
      } else if (!result.isUniformLegDesign) {
        _paintSmallLabel(
          canvas,
          '${row.rowIndex + 1}',
          Offset(currentX + 4, frontTopY - 16),
        );
      }

      if (detailLevel == _SketchDetailLevel.detailed) {
        _paintVerticalDimension(
          canvas,
          x: currentX - 12,
          baseY: baseY,
          topY: frontTopY,
          label: '${row.frontLegHeightMeters.toStringAsFixed(2)} m',
        );
        _paintVerticalDimension(
          canvas,
          x: rearX + 12,
          baseY: baseY,
          topY: rearTopY,
          label: '${row.rearLegHeightMeters.toStringAsFixed(2)} m',
        );
        _paintSmallLabel(
          canvas,
          '${result.frameSlopeLengthMeters.toStringAsFixed(2)} m',
          Offset(
            ((currentX + rearX) / 2) - 20,
            ((frontTopY + rearTopY) / 2) - 28,
          ),
        );
        if (!result.isUniformLegDesign) {
          _paintSmallLabel(
            canvas,
            '${rowOffsetLabel ?? 'Offset'} ${row.baseOffsetMeters.toStringAsFixed(2)} m',
            Offset(currentX, baseY + 4),
          );
        }
      }

      currentX = rearX + (result.rowSpacingMeters * depthScale);
    }

    canvas.drawLine(
      Offset(startX, baseY),
      Offset(rect.right - 12, baseY),
      bracePaint,
    );

    if (detailLevel == _SketchDetailLevel.detailed &&
        result.rowResults.isNotEmpty) {
      final firstFrontX = startX;
      final firstRearX = startX + (result.projectedRowDepthMeters * depthScale);
      _paintDimensionLine(
        canvas,
        start: Offset(firstFrontX, baseY + 24),
        end: Offset(firstRearX, baseY + 24),
        label: '${result.projectedRowDepthMeters.toStringAsFixed(2)} m',
      );
      if (result.rows > 1 && !result.isUniformLegDesign) {
        _paintDimensionLine(
          canvas,
          start: Offset(firstRearX, baseY + 40),
          end: Offset(
            firstRearX + (result.rowSpacingMeters * depthScale),
            baseY + 40,
          ),
          label: '${result.rowSpacingMeters.toStringAsFixed(2)} m',
        );
        _paintDimensionLine(
          canvas,
          start: Offset(firstFrontX, baseY + 56),
          end: Offset(
            firstFrontX + (result.totalFootprintDepthMeters * depthScale),
            baseY + 56,
          ),
          label: '${result.totalFootprintDepthMeters.toStringAsFixed(2)} m',
        );
      }
    }
  }

  void _paintFrontView(Canvas canvas, Rect rect, {bool showTitle = true}) {
    if (showTitle) {
      _paintTitle(canvas, frontViewLabel, Offset(rect.left, rect.top));
    }
    final drawingRect = Rect.fromLTWH(
      rect.left,
      rect.top + (showTitle ? 22 : 0),
      rect.width,
      rect.height - (showTitle ? 22 : 0),
    );
    final baseY = drawingRect.bottom - 10;
    final leftX = drawingRect.left + 18;
    final rightX = drawingRect.right - 18;
    final width = rightX - leftX;
    final maxHeight = math.max(
      result.maxRearLegHeightMeters,
      result.rearLegHeightMeters,
    );
    final heightScale = (drawingRect.height - 18) / math.max(maxHeight, 0.5);
    final frontHeight = result.isUniformLegDesign
        ? result.frontLegHeightMeters
        : ((result.minFrontLegHeightMeters + result.maxFrontLegHeightMeters) /
              2);
    final rearHeight = result.isUniformLegDesign
        ? result.rearLegHeightMeters
        : ((result.minRearLegHeightMeters + result.maxRearLegHeightMeters) / 2);
    final topY = baseY - (rearHeight * heightScale);
    final frontTopY = baseY - (frontHeight * heightScale);
    final linePaint = Paint()
      ..color = const Color(0xFF365A6B)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final panelPaint = Paint()
      ..color = const Color(0xFFFFB347)
      ..style = PaintingStyle.fill;

    canvas.drawLine(Offset(leftX, baseY), Offset(leftX, frontTopY), linePaint);
    canvas.drawLine(Offset(rightX, baseY), Offset(rightX, topY), linePaint);
    canvas.drawLine(Offset(leftX, frontTopY), Offset(rightX, topY), linePaint);
    canvas.drawLine(
      Offset(leftX, baseY),
      Offset(rightX, baseY),
      Paint()
        ..color = const Color(0xFF6C8A96)
        ..strokeWidth = 2,
    );

    final columns = math.max(result.columns, 1);
    final panelGap = 4.0;
    final panelWidth = math.max(
      8.0,
      (width - ((columns - 1) * panelGap)) / columns,
    );
    for (var col = 0; col < columns; col++) {
      final panelLeft = leftX + (col * (panelWidth + panelGap));
      final panelRect = Rect.fromLTWH(
        panelLeft,
        topY + 4,
        panelWidth,
        math.max(8.0, (baseY - topY) * 0.32),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(panelRect, const Radius.circular(3)),
        panelPaint,
      );
    }

    if (detailLevel == _SketchDetailLevel.detailed) {
      _paintDimensionLine(
        canvas,
        start: Offset(leftX, baseY + 12),
        end: Offset(rightX, baseY + 12),
        label: '${result.frameWidthMeters.toStringAsFixed(2)} m',
      );
      _paintVerticalDimension(
        canvas,
        x: rightX + 10,
        baseY: baseY,
        topY: topY,
        label: '${rearHeight.toStringAsFixed(2)} m',
      );
    }
  }

  void _paintIsometricView(Canvas canvas, Rect rect, {bool showTitle = true}) {
    if (showTitle) {
      _paintTitle(canvas, isometricViewLabel, Offset(rect.left, rect.top));
    }
    final drawingRect = Rect.fromLTWH(
      rect.left,
      rect.top + (showTitle ? 22 : 0),
      rect.width,
      rect.height - (showTitle ? 22 : 0),
    );
    final origin = Offset(drawingRect.left + 34, drawingRect.bottom - 28);
    final isoWidth = math.max(drawingRect.width - 88, 48.0);
    final isoDepth = math.max(drawingRect.height * 0.28, 20.0);
    final maxLegHeight = math.max(
      result.maxRearLegHeightMeters,
      result.rearLegHeightMeters,
    );
    final heightScale = (drawingRect.height * 0.46) / math.max(maxLegHeight, 1);
    final frontLegHeight = result.isUniformLegDesign
        ? result.frontLegHeightMeters
        : result.minFrontLegHeightMeters;
    final rearLegHeight = result.isUniformLegDesign
        ? result.rearLegHeightMeters
        : result.maxRearLegHeightMeters;
    final cols = math.max(result.columns, 1);
    final rows = math.max(result.rows, 1);
    final xAxis = Offset(isoWidth * 0.76, -isoDepth);
    final yAxis = Offset(isoWidth * 0.34, isoDepth * 0.7);
    final frontZ = Offset(0, -(frontLegHeight * heightScale));
    final rearZ = Offset(0, -(rearLegHeight * heightScale));
    final supportStations = math.max(result.supportStationCount, 2);
    final framePaint = Paint()
      ..color = const Color(0xFF365A6B)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    final legPaint = Paint()
      ..color = const Color(0xFF365A6B)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final bracePaint = Paint()
      ..color = const Color(0xFF6C8A96)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final panelFill = Paint()
      ..color = const Color(0xFFFFB347).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final frontLeft = origin;
    final frontRight = origin + xAxis;
    final backLeft = origin + yAxis;
    final backRight = origin + xAxis + yAxis;
    final topFrontLeft = frontLeft + frontZ;
    final topFrontRight = frontRight + frontZ;
    final topBackLeft = backLeft + rearZ;
    final topBackRight = backRight + rearZ;

    final topPath = Path()
      ..moveTo(topFrontLeft.dx, topFrontLeft.dy)
      ..lineTo(topFrontRight.dx, topFrontRight.dy)
      ..lineTo(topBackRight.dx, topBackRight.dy)
      ..lineTo(topBackLeft.dx, topBackLeft.dy)
      ..close();
    canvas.drawPath(topPath, panelFill);
    canvas.drawPath(topPath, framePaint);

    for (var i = 0; i <= cols; i++) {
      final t = i / cols;
      final start = topFrontLeft + (xAxis * t);
      final end = topBackLeft + (xAxis * t);
      canvas.drawLine(start, end, framePaint);
    }
    for (var i = 0; i <= rows; i++) {
      final t = i / rows;
      final start = topFrontLeft + (yAxis * t);
      final end = topFrontRight + (yAxis * t);
      canvas.drawLine(start, end, framePaint);
    }

    canvas.drawLine(frontLeft, frontRight, framePaint);
    canvas.drawLine(frontLeft, backLeft, framePaint);
    canvas.drawLine(frontRight, backRight, framePaint);
    canvas.drawLine(backLeft, backRight, framePaint);
    for (var i = 0; i < supportStations; i++) {
      final t = supportStations == 1 ? 0.0 : i / (supportStations - 1);
      final baseFront = frontLeft + (xAxis * t);
      final baseRear = backLeft + (xAxis * t);
      final topFront = baseFront + frontZ;
      final topRear = baseRear + rearZ;

      canvas.drawLine(baseFront, topFront, legPaint);
      canvas.drawLine(baseRear, topRear, legPaint);
      canvas.drawLine(topFront, topRear, framePaint);
      canvas.drawLine(baseFront, topRear, bracePaint);

      if (i == 0 || i == supportStations - 1) {
        canvas.drawLine(baseRear, topFront, bracePaint);
      }
    }

    if (detailLevel == _SketchDetailLevel.detailed) {
      _paintSmallLabel(
        canvas,
        '${result.rows} x ${result.columns}',
        Offset(drawingRect.left + 4, drawingRect.top + 4),
      );
      _paintSmallLabel(
        canvas,
        '${frontLegHeight.toStringAsFixed(2)} m',
        Offset(frontLeft.dx - 10, (frontLeft.dy + topFrontLeft.dy) / 2 - 6),
      );
      _paintSmallLabel(
        canvas,
        '${rearLegHeight.toStringAsFixed(2)} m',
        Offset(backRight.dx - 30, (backRight.dy + topBackRight.dy) / 2 - 6),
      );
      _paintSmallLabel(
        canvas,
        '${result.frameSlopeLengthMeters.toStringAsFixed(2)} m',
        Offset(
          ((topFrontRight.dx + topBackRight.dx) / 2) - 26,
          ((topFrontRight.dy + topBackRight.dy) / 2) - 18,
        ),
      );
    }
  }

  void _paintTitle(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF38515E),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _paintSmallLabel(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF466977),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _paintDimensionLine(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required String label,
  }) {
    final paint = Paint()
      ..color = const Color(0xFF7D98A5)
      ..strokeWidth = 1.2;
    canvas.drawLine(start, end, paint);
    canvas.drawLine(
      Offset(start.dx, start.dy - 4),
      Offset(start.dx, start.dy + 4),
      paint,
    );
    canvas.drawLine(
      Offset(end.dx, end.dy - 4),
      Offset(end.dx, end.dy + 4),
      paint,
    );
    _paintSmallLabel(
      canvas,
      label,
      Offset(((start.dx + end.dx) / 2) - 30, start.dy - 20),
    );
  }

  void _paintVerticalDimension(
    Canvas canvas, {
    required double x,
    required double baseY,
    required double topY,
    required String label,
  }) {
    final paint = Paint()
      ..color = const Color(0xFF7D98A5)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(x, baseY), Offset(x, topY), paint);
    canvas.drawLine(Offset(x - 4, baseY), Offset(x + 4, baseY), paint);
    canvas.drawLine(Offset(x - 4, topY), Offset(x + 4, topY), paint);
    _paintSmallLabel(canvas, label, Offset(x - 22, ((baseY + topY) / 2) - 12));
  }

  @override
  bool shouldRepaint(covariant _StructureSketchPainter oldDelegate) {
    return oldDelegate.result != result ||
        oldDelegate.siteWidthMeters != siteWidthMeters ||
        oldDelegate.siteDepthMeters != siteDepthMeters ||
        oldDelegate.topViewLabel != topViewLabel ||
        oldDelegate.sideViewLabel != sideViewLabel ||
        oldDelegate.frontViewLabel != frontViewLabel ||
        oldDelegate.isometricViewLabel != isometricViewLabel ||
        oldDelegate.detailLevel != detailLevel ||
        oldDelegate.repeatedRowLabel != repeatedRowLabel ||
        oldDelegate.rowOffsetLabel != rowOffsetLabel ||
        oldDelegate.viewMode != viewMode;
  }
}

enum _SketchDetailLevel { preview, detailed }

enum _StructureSketchView { top, side, front, isometric }
