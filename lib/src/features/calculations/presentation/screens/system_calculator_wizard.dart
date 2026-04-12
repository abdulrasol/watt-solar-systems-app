import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_step_checkout/simple_step_checkout.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_dialog.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/tabs/appliances_tab.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/tabs/preferences_tab.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/tabs/results_tab.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/wizard_bottom_bar.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/solar_request_form.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:get_storage/get_storage.dart';

// ════════════════════════════════════════════════════════════════════════════
// Main Wizard Screen
// ════════════════════════════════════════════════════════════════════════════
class SystemCalculatorWizard extends ConsumerStatefulWidget {
  const SystemCalculatorWizard({super.key});

  @override
  ConsumerState<SystemCalculatorWizard> createState() => _SystemCalculatorWizardState();
}

class _SystemCalculatorWizardState extends ConsumerState<SystemCalculatorWizard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SimpleCheckoutStepperController _stepperController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (GetStorage().read('system_calculator_wizard_help_viewed') != true) {
        _showHelpDialog();
      }
    });
  }

  void _onTabChanged() {
    // Avoid rebuilding twice per animation frame.
    if (!_tabController.indexIsChanging) {
      final targetIndex = _tabController.index;
      if (_stepperController.index < targetIndex) {
        for (int i = _stepperController.index; i < targetIndex; i++) {
          _stepperController.next();
        }
      } else if (_stepperController.index > targetIndex) {
        for (int i = _stepperController.index; i > targetIndex; i--) {
          _stepperController.previous();
        }
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _stepperController.dispose();
    super.dispose();
  }

  void _nextTab() {
    if (_tabController.index < 2) {
      if (_tabController.index == 1) {
        ref.read(calculatorProvider).calculateSystem();
      }
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch only what changes the whole scaffold (tab index drives bottom bar).
    final controller = ref.watch(calculatorProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tabIdx = _tabController.index;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PreScaffold(
        title: l10n.system_wizard,
        actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline_rounded), tooltip: l10n.guide)],
        // backgroundColor: theme.scaffoldBackgroundColor,
        // appBar: AppBar(
        //   title: Text(l10n.system_wizard),
        //   actions: [
        //     IconButton(
        //       onPressed: _showHelpDialog,
        //       icon: const Icon(Icons.help_outline_rounded),
        //       tooltip: l10n.guide,
        //     ),
        //   ],
        // ),
        child: Column(
          children: [
            // ── Simple Checkout Stepper ───────────────────────────────────────
            Builder(
              builder: (context) {
                // Initialize stepper controller once we have context for l10n
                try {
                  _stepperController.index;
                } catch (_) {
                  _stepperController = SimpleCheckoutStepperController(
                    steps: 3,
                    showTitles: true,
                    stepsList: [l10n.step_appliances, l10n.step_usage, l10n.step_results],
                  );
                }

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor, width: 0.5.w),
                    ),
                  ),
                  child: SimpleCheckoutStepper(
                    controller: _stepperController,
                    doneColor: AppTheme.primaryColor,
                    unDoneColor: isDark ? Colors.white24 : Colors.grey.shade300,
                    lineSize: 1.5.h,
                    stepTitleStyle: TextStyle(fontSize: 11.sp, fontFamily: AppTheme.fontFamily, color: isDark ? Colors.white70 : Colors.grey.shade700),
                    stepNumberStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily, color: Colors.white),
                    titlePaddingTop: 18.h,
                  ),
                );
              },
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Each tab is a const-constructible ConsumerWidget —
                  // Riverpod rebuilds only the affected tab on state change.
                  SystemAppliancesTab(controller: controller),
                  SystemPreferencesTab(controller: controller),
                  SystemResultsTab(controller: controller),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: WizardBottomBar(
          tabIndex: tabIdx,
          isDark: isDark,
          l10n: l10n,
          theme: theme,
          onBack: () {
            if (tabIdx > 0) {
              _tabController.animateTo(tabIdx - 1);
            } else {
              Navigator.pop(context);
            }
          },
          onNext: _nextTab,
          onRequest: () {
            final prefill = _buildRequestPrefill(controller);
            context.push('/user-requests/new', extra: prefill);
          },
        ),
      ),
    );
  }

  // ── Help Dialog ──────────────────────────────────────────────────────────
  void _showHelpDialog() {
    final explanations = AppExplanations(context).getExplanations();
    ExplanationDialog.show(context, explanations: explanations, showDontShowAgain: true, storageKey: 'system_calculator_wizard_help_viewed');
  }

  SolarRequestFormPrefill _buildRequestPrefill(CalculatorNotifier controller) {
    final panelPower = controller.selectedPanelWattage;
    final panelCount = controller.recommendedPanels;
    final totalPanelPower = panelPower * panelCount;

    final batterySize = controller.batteryUnitCapacityAh;
    final batteryCount = controller.recommendedBatteries;
    final totalBatteryPower = batterySize * batteryCount;

    final inverterSize = controller.recommendedInverterSize;
    final inverterCount = 1;
    final totalInvertersPower = inverterSize * inverterCount;

    final phaseNote = controller.isThreePhase ? 'Three-phase' : 'Single-phase';
    final modeNote = controller.isPracticalHybridMode ? 'Practical Hybrid mode using direct AC load.' : 'Full Energy mode using appliance list.';
    final panelNote = controller.isPracticalHybridMode
        ? 'Mode: practical hybrid. Direct load ${controller.directAcLoadWatts.toStringAsFixed(0)}W, grid ${controller.gridOnHours.toStringAsFixed(0)}h on / ${controller.gridOffHours.toStringAsFixed(0)}h off, panel size ${controller.selectedPanelWattage}W.'
        : 'Mode: full energy. Daily energy ${controller.dailyUsageKWh.toStringAsFixed(2)} kWh, grid coverage ${(controller.gridCoverageFactor * 100).toStringAsFixed(0)}%, PV derating ${(controller.pvDerating * 100).toStringAsFixed(0)}%.';
    final batteryNote =
        'System ${controller.systemVoltage.toStringAsFixed(0)}V, unit ${controller.systemCalcSingleBatteryVoltage.toStringAsFixed(1)}V ${controller.batteryUnitCapacityAh.toStringAsFixed(0)}Ah, topology ${controller.batterySeriesCount}S${controller.batteryParallelCount}P, required ${controller.requiredBatteryKWh.toStringAsFixed(2)} kWh, recharge ${controller.rechargePercentage.toStringAsFixed(0)}%, reserve ${controller.batteryReservePercent.toStringAsFixed(0)}%.';
    final inverterNote =
        '$phaseNote AC ${controller.acSystemVoltage.toStringAsFixed(0)}V, peak load ${controller.peakLoadW.toStringAsFixed(0)}W, design current ${controller.acLoadCurrent.toStringAsFixed(1)}A, reserve x${controller.inverterSafetyFactor.toStringAsFixed(2)}.';
    final note =
        'Generated from system calculator wizard. $modeNote Grid cycle ${controller.gridOnHours.toStringAsFixed(0)}h on / ${controller.gridOffHours.toStringAsFixed(0)}h off, recharge ${controller.rechargePercentage.toStringAsFixed(0)}%, reserve ${controller.batteryReservePercent.toStringAsFixed(0)}%.';

    return SolarRequestFormPrefill(
      panelPower: panelPower,
      panelCount: panelCount,
      totalPanelPower: totalPanelPower,
      batterySize: batterySize,
      batteryCount: batteryCount,
      totalBatteryPower: totalBatteryPower,
      inverterSize: inverterSize,
      inverterCount: inverterCount,
      totalInvertersPower: totalInvertersPower,
      batteryType: controller.systemBatteryType,
      inverterType: InverterType.hybrid,
      panelNote: panelNote,
      batteryNote: batteryNote,
      inverterNote: inverterNote,
      note: note,
    );
  }
}

// keep the legacy schema map
final requestSystem = {
  'user': 'user_id',
  'pv': 'total pv => panel count * panel capacity',
  'battery': 'total battery => battery count * battery capacity',
  'inverter': 'total inverter => inverter count * inverter capacity',
  'notes': 'notes',
  'specs': {
    'panels': {'count': 'int', 'capacity': 'int', 'note': 'text'},
    'battery': {
      'count': 'int',
      'capacity': 'double',
      'type': 'battery_type led/acid or lithium',
      'voltage_type': 'LV or HV',
      'note': 'text',
      'system_voltage': 'double',
    },
    'inverter': {
      'count': 'int',
      'capacity': 'double',
      'note': 'text',
      'voltage_type': 'LV or HV',
      'type': 'off-grid or on-grid or hybrid',
      'phase': 'single or three',
    },
  },
};
