import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_step_checkout/simple_step_checkout.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_design_providers.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/panel_layout_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/proposal_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/roof_obstacles_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/shadow_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/site_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/steps/structure_step.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/wizard/pv_design_wizard_bottom_bar.dart';
import 'package:solar_hub/src/features/structure_design/presentation/widgets/wizard/stepper_shell.dart';

class PvSystemDesignerScreen extends ConsumerStatefulWidget {
  const PvSystemDesignerScreen({super.key});

  @override
  ConsumerState<PvSystemDesignerScreen> createState() => _PvSystemDesignerScreenState();
}

class _PvSystemDesignerScreenState extends ConsumerState<PvSystemDesignerScreen>
    with SingleTickerProviderStateMixin {
  static const _stepCount = 6;

  late final TabController _tabController;
  SimpleCheckoutStepperController? _stepperController;

  List<String> _stepTitles(BuildContext context) => [
    AppLocalizations.of(context)!.pv_design_step_site,
    AppLocalizations.of(context)!.pv_design_step_roof,
    AppLocalizations.of(context)!.pv_design_step_panels,
    AppLocalizations.of(context)!.pv_design_step_shadows,
    AppLocalizations.of(context)!.pv_design_step_structure,
    AppLocalizations.of(context)!.pv_design_step_proposal,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _stepCount, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _stepperController?.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      ref.read(pvSystemDesignControllerProvider.notifier).setCurrentStep(_tabController.index);
      _syncStepper();
      setState(() {});
    }
  }

  void _syncStepper() {
    final stepper = _stepperController;
    if (stepper == null) return;
    final target = _tabController.index;
    while (stepper.index < target && stepper.index < _stepCount - 1) {
      stepper.next();
    }
    while (stepper.index > target && stepper.index > 0) {
      stepper.previous();
    }
  }

  Future<void> _handleNext() async {
    final controller = ref.read(pvSystemDesignControllerProvider.notifier);
    final index = _tabController.index;

    if (index == 0 && !(SiteStep.formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (index == 2) {
      await controller.computeFullShading();
    }

    if (index == 4) {
      await controller.calculateStructureAndEnergy();
    }

    if (index < _stepCount - 1) {
      _tabController.animateTo(index + 1);
    }
  }

  void _handleBack() {
    if (_tabController.index == 0) {
      context.pop();
      return;
    }
    _tabController.animateTo(_tabController.index - 1);
  }

  void _handleFinish() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    _stepperController ??= SimpleCheckoutStepperController(
      steps: _stepCount,
      showTitles: true,
      stepsList: _stepTitles(context),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PreScaffold(
        title: l10n.pv_system_designer_title,
        bottomNavigationBar: PvDesignWizardBottomBar(
          stepIndex: _tabController.index,
          stepCount: _stepCount,
          isLastStep: _tabController.index == _stepCount - 1,
          canProceed: true,
          l10n: l10n,
          theme: theme,
          onBack: _handleBack,
          onNext: _handleNext,
          onFinish: _handleFinish,
        ),
        child: Column(
          children: [
            StepperShell(stepperController: _stepperController!, isDark: isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  SiteStep(),
                  RoofObstaclesStep(),
                  PanelLayoutStep(),
                  ShadowStep(),
                  StructureStep(),
                  ProposalStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
