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

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            children: [
              // ── Hero gradient card ─────────────────────────────────────
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
                      color: Color(0x6600BFA5), // primaryColor @ 40%
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Title
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
                                  l10n.recommended_system,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppTheme.fontFamily,
                                  ),
                                ),
                                Text(
                                  '${c.dailyUsageKWh.toStringAsFixed(1)} kWh/day',
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

                    // Main items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                  '${c.recommendedInverterSize.toStringAsFixed(1)} kVA',
                              icon: Iconsax.flash_bold,
                            ),
                          ),
                          Expanded(
                            child: ResultItem(
                              label: l10n.battery_bank,
                              value: '${c.recommendedBatteries}',
                              icon: Iconsax.battery_charging_bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
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

                    // Capacity row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ResultItem(
                              label: l10n.total_pv_power,
                              value:
                                  '${c.totalPanelCapacityKw.toStringAsFixed(1)} kW',
                              icon: Icons.solar_power_rounded,
                            ),
                          ),
                          Expanded(
                            child: ResultItem(
                              label: l10n.total_battery,
                              value: c.totalBatteryCapacityAh,
                              icon: Icons.battery_std_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Controller footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0x26000000), // black @ 15%
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
                            '${l10n.charge_controller}: ${c.recommendedControllerSize}A',
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

              // ── Detail cards ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: DetailCard(
                      icon: Icons.bolt_rounded,
                      label: l10n.system_voltage,
                      value: '${c.systemVoltage.toStringAsFixed(0)}V',
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DetailCard(
                      icon: Icons.wb_sunny_rounded,
                      label: l10n.peak_sun_hours,
                      value: '${c.sunPeakHours.toStringAsFixed(1)}h',
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
                      label: l10n.autonomy,
                      value: '${c.autonomyHours.toStringAsFixed(1)}h',
                      color: const Color(0xFF42A5F5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DetailCard(
                      icon: Icons.solar_power_rounded,
                      label: l10n.panel_wattage,
                      value: '${c.selectedPanelWattage}W',
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
