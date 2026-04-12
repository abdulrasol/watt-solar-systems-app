import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/section_card.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/slider_tile.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/voltage_chips.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class SystemPreferencesTab extends ConsumerStatefulWidget {
  const SystemPreferencesTab({super.key, required this.controller});

  final CalculatorNotifier controller;

  @override
  ConsumerState<SystemPreferencesTab> createState() =>
      _SystemPreferencesTabState();
}

class _SystemPreferencesTabState extends ConsumerState<SystemPreferencesTab> {
  late final TextEditingController _directLoadController;
  late final TextEditingController _gridOnController;
  late final TextEditingController _gridOffController;
  late final TextEditingController _panelWattController;
  late final TextEditingController _batteryAhController;

  @override
  void initState() {
    super.initState();
    final controller = widget.controller;
    _directLoadController = TextEditingController();
    _gridOnController = TextEditingController();
    _gridOffController = TextEditingController();
    _panelWattController = TextEditingController();
    _batteryAhController = TextEditingController();
    _syncControllers(controller, force: true);
  }

  @override
  void didUpdateWidget(covariant SystemPreferencesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers(widget.controller);
  }

  @override
  void dispose() {
    _directLoadController.dispose();
    _gridOnController.dispose();
    _gridOffController.dispose();
    _panelWattController.dispose();
    _batteryAhController.dispose();
    super.dispose();
  }

  void _syncControllers(CalculatorNotifier controller, {bool force = false}) {
    _syncText(
      _directLoadController,
      _formatEditable(controller.directAcLoadInput),
      force: force,
    );
    _syncText(
      _gridOnController,
      _formatEditable(controller.gridOnHours),
      force: force,
    );
    _syncText(
      _gridOffController,
      _formatEditable(controller.gridOffHours),
      force: force,
    );
    _syncText(
      _panelWattController,
      controller.selectedPanelWattage.toString(),
      force: force,
    );
    _syncText(
      _batteryAhController,
      _formatEditable(controller.batteryUnitCapacityAh),
      force: force,
    );
  }

  void _syncText(
    TextEditingController controller,
    String value, {
    bool force = false,
  }) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  String _formatEditable(num value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
  }

  String _tr(BuildContext context, String en, String ar) {
    return Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
  }

  String _acVoltageLabel(AppLocalizations l10n, double voltage) {
    if (voltage == 380) return l10n.voltage_380_three_phase;
    return '${voltage.toStringAsFixed(0)}V';
  }

  void _update(void Function(CalculatorNotifier controller) update) {
    ref.read(calculatorProvider).updateField(() {
      update(ref.read(calculatorProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final explanations = AppExplanations(context).getExplanations();
    final battV = controller.systemCalcSingleBatteryVoltage;
    final voltageOptions = battV == 25.6
        ? const [24.0]
        : battV == 51.2
        ? const [48.0]
        : const [12.0, 24.0, 48.0];

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.accentColor,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    controller.isPracticalHybridMode
                        ? _tr(
                            context,
                            'Hybrid practical mode sizes the system from the live AC load and repeated grid on/off cycle.',
                            'الوضع العملي الهجين يحسب النظام من الحمل المتناوب المباشر ودورة تشغيل/انقطاع الشبكة المتكررة.',
                          )
                        : _tr(
                            context,
                            'Full energy mode uses your appliance list and extends it with grid timing to reduce battery and PV sizing.',
                            'وضع الطاقة الكامل يعتمد على قائمة الأجهزة ويضيف توقيت الشبكة لتقليل حجم البطاريات والألواح.',
                          ),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            icon: Iconsax.chart_2_bold,
            title: _tr(context, 'Calculation mode', 'وضع الحساب'),
            explanation: explanations[6],
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ChoiceChip(
                  label: Text(_tr(context, 'Practical Hybrid', 'هجين عملي')),
                  selected:
                      controller.calculationMode ==
                      SystemCalculationMode.practicalHybrid,
                  onSelected: (_) {
                    _update((c) {
                      c.calculationMode = SystemCalculationMode.practicalHybrid;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text(_tr(context, 'Full Energy', 'طاقة كاملة')),
                  selected:
                      controller.calculationMode ==
                      SystemCalculationMode.fullEnergy,
                  onSelected: (_) {
                    _update((c) {
                      c.calculationMode = SystemCalculationMode.fullEnergy;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (controller.isPracticalHybridMode) ...[
            SectionCard(
              icon: Iconsax.flash_1_bold,
              title: _tr(context, 'Direct AC load', 'الحمل المتناوب المباشر'),
              explanation: explanations[7],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ChoiceChip(
                        label: Text(_tr(context, 'Ampere', 'أمبير')),
                        selected:
                            controller.loadInputUnit ==
                            SystemLoadInputUnit.ampere,
                        onSelected: (_) {
                          _update((c) {
                            c.loadInputUnit = SystemLoadInputUnit.ampere;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text(_tr(context, 'Watt', 'واط')),
                        selected:
                            controller.loadInputUnit ==
                            SystemLoadInputUnit.watt,
                        onSelected: (_) {
                          _update((c) {
                            c.loadInputUnit = SystemLoadInputUnit.watt;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _directLoadController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      suffixText:
                          controller.loadInputUnit == SystemLoadInputUnit.ampere
                          ? _tr(context, 'A', 'أمبير')
                          : _tr(context, 'W', 'واط'),
                      hintText:
                          controller.loadInputUnit == SystemLoadInputUnit.ampere
                          ? '10'
                          : '2300',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        _update((c) {
                          c.directAcLoadInput = parsed;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _tr(
                      context,
                      'This value is used directly for PV, inverter, and battery sizing in practical mode.',
                      'تستخدم هذه القيمة مباشرةً في حساب الألواح والعاكس والبطارية في الوضع العملي.',
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          SectionCard(
            icon: Icons.bolt_rounded,
            title: l10n.ac_system_voltage,
            explanation: explanations[8],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.acVoltageOptions.map((voltage) {
                    return ChoiceChip(
                      label: Text(_acVoltageLabel(l10n, voltage)),
                      selected: controller.acSystemVoltage == voltage,
                      onSelected: (_) {
                        _update((c) {
                          c.acSystemVoltage = voltage;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    controller.isThreePhase
                        ? _tr(
                            context,
                            '380V is handled as three-phase and current uses P / (sqrt(3) × V).',
                            'يتم التعامل مع 380 فولت كنظام ثلاثي الأطوار والتيار يحسب بمعادلة P / (√3 × V).',
                          )
                        : _tr(
                            context,
                            '110V and 230V are handled as single-phase and current uses P / V.',
                            'يتم التعامل مع 110 و230 فولت كنظام أحادي الطور والتيار يحسب بمعادلة P / V.',
                          ),
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Iconsax.timer_bold,
            title: _tr(context, 'Grid cycle', 'دورة الشبكة'),
            explanation: explanations[9],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gridOnController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: _tr(context, 'Grid on', 'تشغيل الشبكة'),
                          suffixText: _tr(context, 'h', 'ساعة'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) {
                            _update((c) {
                              c.gridOnHours = parsed;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _gridOffController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: _tr(context, 'Grid off', 'انقطاع الشبكة'),
                          suffixText: _tr(context, 'h', 'ساعة'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) {
                            _update((c) {
                              c.gridOffHours = parsed;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _tr(
                    context,
                    'Example: 2h on / 4h off. In practical mode, battery sizing is based on the off block.',
                    'مثال: ساعتان تشغيل / 4 ساعات انقطاع. في الوضع العملي يتم حساب البطارية على زمن الانقطاع.',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Iconsax.battery_full_bold,
            title: _tr(context, 'Recharge percentage', 'نسبة إعادة الشحن'),
            explanation: explanations[10],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTile(
                  label: _tr(
                    context,
                    'Grid/PV recharge during on-time',
                    'إعادة الشحن أثناء وقت تشغيل الشبكة',
                  ),
                  value: controller.rechargePercentage,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  suffix: '%',
                  onChanged: (value) {
                    _update((c) {
                      c.rechargePercentage = value;
                    });
                  },
                ),
                Text(
                  _tr(
                    context,
                    'Keep about 20% battery reserve to reduce damage and improve lifetime.',
                    'احتفظ بحوالي 20% داخل البطارية لتقليل الضرر وإطالة العمر.',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!controller.isPracticalHybridMode) ...[
            SectionCard(
              icon: Icons.tune_rounded,
              title: l10n.system_parameters,
              child: Column(
                children: [
                  SliderTile(
                    label: l10n.autonomy_hours,
                    value: controller.autonomyHours,
                    explanation: explanations[1],
                    min: 0,
                    max: 24,
                    divisions: 24,
                    suffix: 'h',
                    onChanged: (v) {
                      _update((c) {
                        c.autonomyHours = v;
                      });
                    },
                  ),
                  const Divider(height: 24),
                  SliderTile(
                    label: l10n.sun_hours,
                    value: controller.sunPeakHours,
                    explanation: explanations[2],
                    min: 2,
                    max: 10,
                    divisions: 16,
                    suffix: 'h',
                    onChanged: (v) {
                      _update((c) {
                        c.sunPeakHours = v;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          SectionCard(
            icon: Iconsax.sun_1_bold,
            title: l10n.panel_wattage,
            explanation: explanations[3],
            child: TextFormField(
              controller: _panelWattController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: 'W',
                hintText: '600',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (val) {
                final parsed = int.tryParse(val);
                if (parsed != null) {
                  _update((c) {
                    c.selectedPanelWattage = parsed;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Iconsax.battery_charging_bold,
            title: l10n.single_battery_voltage,
            explanation: explanations[4],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VoltageChips(
                  options: const [12.0, 12.8, 25.6, 51.2],
                  selected: controller.systemCalcSingleBatteryVoltage,
                  onSelected: (v) {
                    _update((c) {
                      c.systemCalcSingleBatteryVoltage = v;
                      if (v == 25.6) c.systemVoltage = 24.0;
                      if (v == 51.2) c.systemVoltage = 48.0;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.battery_type_hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Iconsax.battery_full_bold,
            title: l10n.battery_capacity_ah,
            explanation: explanations[11],
            child: TextFormField(
              controller: _batteryAhController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                suffixText: 'Ah',
                hintText: '200',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null) {
                  _update((c) {
                    c.batteryUnitCapacityAh = parsed;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Iconsax.box_bold,
            title: l10n.battery_type_label,
            explanation: explanations[12],
            child: DropdownButtonFormField<BatteryType>(
              initialValue: controller.systemBatteryType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: BatteryType.lithium,
                  child: Text(BatteryType.lithium.localizedLabel(l10n)),
                ),
                DropdownMenuItem(
                  value: BatteryType.gel,
                  child: Text(
                    _tr(context, 'Gel / Lead-Acid', 'جل / رصاص حمضي'),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                _update((c) {
                  c.systemBatteryType = value;
                  if (value == BatteryType.gel &&
                      c.systemCalcSingleBatteryVoltage != 12.0) {
                    c.systemCalcSingleBatteryVoltage = 12.0;
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.flash_on_rounded,
            title: l10n.system_voltage,
            explanation: explanations[5],
            child: VoltageChips(
              options: voltageOptions,
              selected: controller.systemVoltage,
              onSelected: (v) {
                _update((c) {
                  c.systemVoltage = v;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          if (!controller.isPracticalHybridMode) ...[
            SectionCard(
              icon: Iconsax.sun_fog_bold,
              title: _tr(context, 'PV Derating', 'معامل فواقد المنظومة'),
              explanation: explanations[13],
              child: SliderTile(
                label: _tr(
                  context,
                  'Effective PV performance',
                  'الأداء الفعلي للألواح',
                ),
                value: controller.pvDerating,
                min: 0.55,
                max: 0.95,
                divisions: 8,
                suffix: '%',
                onChanged: (value) {
                  _update((c) {
                    c.pvDerating = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          SectionCard(
            icon: Iconsax.flash_bold,
            title: _tr(context, 'Inverter Reserve', 'هامش أمان العاكس'),
            explanation: explanations[14],
            child: SliderTile(
              label: _tr(context, 'Safety factor', 'معامل الأمان'),
              value: controller.inverterSafetyFactor,
              min: 1.05,
              max: 1.8,
              divisions: 15,
              suffix: 'x',
              onChanged: (value) {
                _update((c) {
                  c.inverterSafetyFactor = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
