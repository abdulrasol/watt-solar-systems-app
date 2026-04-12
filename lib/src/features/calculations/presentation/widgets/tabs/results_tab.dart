import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/detail_card.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/result_item.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class SystemResultsTab extends StatefulWidget {
  const SystemResultsTab({super.key, required this.controller});

  final CalculatorNotifier controller;

  @override
  State<SystemResultsTab> createState() => _SystemResultsTabState();
}

class _SystemResultsTabState extends State<SystemResultsTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    String tr(String en, String ar) => isAr ? ar : en;
    String unit(String en, String ar) => isAr ? ar : en;

    final modeTitle = c.isPracticalHybridMode
        ? tr('Practical Hybrid Result', 'نتيجة الهجين العملي')
        : l10n.recommended_system;
    final modeSubtitle = c.isPracticalHybridMode
        ? tr(
            'Direct load ${c.directAcLoadWatts.toStringAsFixed(0)} ${unit('W', 'واط')} | Grid ${c.gridOnHours.toStringAsFixed(0)}/${c.gridOffHours.toStringAsFixed(0)} ${unit('h', 'ساعة')}',
            'الحمل المباشر ${c.directAcLoadWatts.toStringAsFixed(0)} ${unit('واط', 'واط')} | الشبكة ${c.gridOnHours.toStringAsFixed(0)}/${c.gridOffHours.toStringAsFixed(0)} ${unit('ساعة', 'ساعة')}',
          )
        : '${c.dailyUsageKWh.toStringAsFixed(1)} ${unit('kWh/day', 'كيلوواط ساعة/يوم')}';

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryDarkColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x6600BFA5),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Iconsax.verify_bold,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  modeTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppTheme.fontFamily,
                                  ),
                                ),
                                Text(
                                  modeSubtitle,
                                  style: const TextStyle(
                                    color: Color(0xBFFFFFFF),
                                    fontSize: 13,
                                    fontFamily: AppTheme.fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ResultItem(
                              label: c.isPracticalHybridMode
                                  ? tr('AC Load', 'الحمل المتناوب')
                                  : l10n.total_daily_usage,
                              value: c.isPracticalHybridMode
                                  ? '${c.directAcLoadWatts.toStringAsFixed(0)} ${unit('W', 'واط')}'
                                  : '${c.dailyUsageKWh.toStringAsFixed(1)} ${unit('kWh', 'كيلوواط ساعة')}',
                              icon: Iconsax.flash_1_bold,
                            ),
                          ),
                          Expanded(
                            child: ResultItem(
                              label: c.isPracticalHybridMode
                                  ? tr('Grid Cycle', 'دورة الشبكة')
                                  : tr('Peak Load', 'الحمل الأقصى'),
                              value: c.isPracticalHybridMode
                                  ? '${c.gridOnHours.toStringAsFixed(0)}/${c.gridOffHours.toStringAsFixed(0)} ${unit('h', 'ساعة')}'
                                  : '${c.peakLoadW.toStringAsFixed(0)} ${unit('W', 'واط')}',
                              icon: c.isPracticalHybridMode
                                  ? Iconsax.timer_bold
                                  : Iconsax.activity_bold,
                            ),
                          ),
                          Expanded(
                            child: ResultItem(
                              label: c.isThreePhase
                                  ? l10n.ac_three_phase
                                  : l10n.ac_single_phase,
                              value:
                                  '${c.acLoadCurrent.toStringAsFixed(1)} ${unit('A', 'أمبير')}',
                              icon: Iconsax.electricity_bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ResultItem(
                              label: l10n.panel_count,
                              value: '${c.recommendedPanels}',
                              icon: Iconsax.sun_1_bold,
                            ),
                          ),
                          Expanded(
                            child: ResultItem(
                              label: l10n.inverter_size,
                              value:
                                  '${c.recommendedInverterSize.toStringAsFixed(0)} ${unit('kW', 'كيلوواط')}',
                              icon: Iconsax.flash_bold,
                            ),
                          ),
                          Expanded(
                            child: ResultItem(
                              label: c.isPracticalHybridMode
                                  ? tr('Battery Need', 'احتياج البطارية')
                                  : l10n.battery_bank,
                              value: c.isPracticalHybridMode
                                  ? '${c.practicalBatteryNeedKWh.toStringAsFixed(1)} ${unit('kWh', 'كيلوواط ساعة')}'
                                  : '${c.recommendedBatteries}',
                              icon: Iconsax.battery_charging_bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.25),
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ResultItem(
                              label: l10n.total_pv_power,
                              value:
                                  '${c.totalPanelCapacityKw.toStringAsFixed(1)} ${unit('kW', 'كيلوواط')}',
                              icon: Icons.solar_power_rounded,
                            ),
                          ),
                          Expanded(
                            child: ResultItem(
                              label: c.isPracticalHybridMode
                                  ? tr('After recharge', 'بعد إعادة الشحن')
                                  : tr('Battery Need', 'احتياج البطارية'),
                              value:
                                  '${c.requiredBatteryKWh.toStringAsFixed(1)} ${unit('kWh', 'كيلوواط ساعة')}',
                              icon: Icons.battery_std_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0x26000000),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.settings_input_component_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${l10n.charge_controller}: ${c.recommendedControllerSize}${unit('A', ' أمبير')}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DetailCard(
                      icon: Icons.bolt_rounded,
                      label: tr('AC / Battery', 'المتناوب / البطارية'),
                      value:
                          '${c.acSystemVoltage.toStringAsFixed(0)}/${c.systemVoltage.toStringAsFixed(0)} ${unit('V', 'فولت')}',
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DetailCard(
                      icon: c.isPracticalHybridMode
                          ? Iconsax.timer_bold
                          : Icons.wb_sunny_rounded,
                      label: c.isPracticalHybridMode
                          ? tr('Recharge', 'إعادة الشحن')
                          : l10n.peak_sun_hours,
                      value: c.isPracticalHybridMode
                          ? '${c.rechargePercentage.toStringAsFixed(0)}%'
                          : '${c.sunPeakHours.toStringAsFixed(1)} ${unit('h', 'ساعة')}',
                      color: const Color(0xFFFF7043),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DetailCard(
                      icon: Icons.battery_charging_full_rounded,
                      label: c.isPracticalHybridMode
                          ? tr('Grid coverage', 'تغطية الشبكة')
                          : l10n.autonomy,
                      value: c.isPracticalHybridMode
                          ? '${(c.gridCoverageFactor * 100).toStringAsFixed(0)}%'
                          : '${c.autonomyHours.toStringAsFixed(1)} ${unit('h', 'ساعة')}',
                      color: const Color(0xFF42A5F5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DetailCard(
                      icon: Icons.solar_power_rounded,
                      label: c.isPracticalHybridMode
                          ? tr('Panel size', 'قدرة اللوح')
                          : tr('Panel / derating', 'اللوح / الفواقد'),
                      value: c.isPracticalHybridMode
                          ? '${c.selectedPanelWattage}${unit('W', ' واط')}'
                          : '${c.selectedPanelWattage}${unit('W', ' واط')} • ${(c.pvDerating * 100).toStringAsFixed(0)}%',
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DetailCard(
                      icon: Iconsax.battery_charging_bold,
                      label: tr('Battery topology', 'ترتيب البطاريات'),
                      value: c.recommendedBatteries == 0
                          ? '--'
                          : '${c.batterySeriesCount}S${c.batteryParallelCount}P',
                      color: const Color(0xFF7E57C2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DetailCard(
                      icon: Iconsax.layer_bold,
                      label: tr('Battery bank', 'بنك البطاريات'),
                      value: c.totalBatteryCapacityAh,
                      color: const Color(0xFF26A69A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DetailCard(
                icon: c.isThreePhase
                    ? Iconsax.hierarchy_2_bold
                    : Iconsax.path_2_bold,
                label: tr('Design note', 'ملاحظة التصميم'),
                value: c.isPracticalHybridMode
                    ? tr(
                        'Practical mode sizes PV and inverter from the live AC load, sizes battery from grid-off time, and shows a 20% reserve note for battery protection.',
                        'الوضع العملي يحسب الألواح والعاكس من الحمل المباشر، ويحسب البطارية من وقت انقطاع الشبكة، ويعرض تذكيراً بترك 20% احتياطياً لحماية البطارية.',
                      )
                    : c.isThreePhase
                    ? tr(
                        '380V is sized as a three-phase AC system. PV is reduced by the grid cycle share and battery sizing uses the outage block.',
                        'يتم اعتماد 380 فولت كنظام ثلاثي الأطوار. يتم تقليل الألواح حسب حصة الشبكة وتحديد البطارية على زمن الانقطاع.',
                      )
                    : tr(
                        '110V and 230V are sized as single-phase AC systems. PV is reduced by the grid cycle share and battery sizing uses the outage block.',
                        'يتم اعتماد 110 و230 فولت كنظام أحادي الطور. يتم تقليل الألواح حسب حصة الشبكة وتحديد البطارية على زمن الانقطاع.',
                      ),
                color: const Color(0xFF5C6BC0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
