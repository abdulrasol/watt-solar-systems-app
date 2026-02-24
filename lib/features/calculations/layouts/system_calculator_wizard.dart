import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/calculations/controllers/calculator_controller.dart';
import 'package:solar_hub/features/admin/controllers/app_config_controller.dart';
import 'package:solar_hub/features/calculations/widgets/home_appliance_row.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';

class SystemCalculatorWizard extends StatefulWidget {
  const SystemCalculatorWizard({super.key});

  @override
  State<SystemCalculatorWizard> createState() => _SystemCalculatorWizardState();
}

class _SystemCalculatorWizardState extends State<SystemCalculatorWizard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.put(CalculatorController()); // Ensure controller exists

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Refresh buttons when tab changes
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = GetStorage();
      if (box.read('system_calculator_wizard_help_viewed') != true) {
        _showHelpDialog();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _nextTab() {
    if (_tabController.index < 2) {
      if (_tabController.index == 1) {
        controller.calculateSystem(); // Trigger calculation before showing results
      }
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("system_wizard".tr),
        actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline))],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: AbsorbPointer(
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
              tabs: [
                Tab(text: "step_appliances".tr),
                Tab(text: "step_usage".tr),
                Tab(text: "step_results".tr),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Step 1: Appliances
          _buildAppliancesTab(),

          // Step 2: Usage / Preferences
          _buildPreferencesTab(),

          // Step 3: Results
          _buildResultsTab(),
        ],
      ),
      floatingActionButton: null,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _tabController.index > 0 ? _tabController.animateTo(_tabController.index - 1) : Get.back(),
              child: Text(_tabController.index == 0 ? "close".tr : "back".tr),
            ),
            if (_tabController.index < 2)
              ElevatedButton(
                onPressed: _nextTab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_tabController.index == 1 ? "calculate".tr : "next".tr),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliancesTab() {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.addAppliance,
                icon: const Icon(Icons.add),
                label: Text("add_appliance".tr),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.appliances.length,
                itemBuilder: (context, index) {
                  final app = controller.appliances[index];
                  return HomeApplianceRow(key: ValueKey(app), app: app, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("system_wizard_desc".tr, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),

          _buildSliderParam("autonomy_hours".tr, controller.autonomyHours, min: 0, max: 24, suffix: "h"),
          _buildSliderParam("sun_hours".tr, controller.sunPeakHours, min: 2, max: 10, suffix: "h"),

          const SizedBox(height: 16),
          _buildIntInputField(context, label: "panel_wattage".tr, value: controller.selectedPanelWattage, suffix: "W"),

          const SizedBox(height: 16),
          Text("single_battery_voltage".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [12.0, 12.8, 25.6, 51.2].map((v) {
                bool isSelected = controller.systemCalcSingleBatteryVoltage.value == v;
                return ChoiceChip(
                  label: Text("${v.toString().replaceAll('.0', '')}V"),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.systemCalcSingleBatteryVoltage.value = v;
                      if (v == 25.6) {
                        controller.systemVoltage.value = 24.0;
                      } else if (v == 51.2) {
                        controller.systemVoltage.value = 48.0;
                      }
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          Text("battery_type_hint".tr, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),

          const SizedBox(height: 16),
          Text("system_voltage".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() {
            double selectedBattV = controller.systemCalcSingleBatteryVoltage.value;
            List<double> options = [12.0, 24.0, 48.0];

            if (selectedBattV == 25.6) {
              options = [24.0];
            } else if (selectedBattV == 51.2) {
              options = [48.0];
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((v) {
                bool isSelected = controller.systemVoltage.value == v;
                return ChoiceChip(
                  label: Text("${v.toString().replaceAll('.0', '')}V"),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) controller.systemVoltage.value = v;
                  },
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIntInputField(BuildContext context, {required String label, required RxInt value, required String suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value.value.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (val) => value.value = int.tryParse(val) ?? value.value,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSliderParam(String title, RxDouble value, {required double min, required double max, required String suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Obx(
              () => Text(
                "${value.value.toStringAsFixed(1)} $suffix",
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Obx(() => Slider(value: value.value, min: min, max: max, activeColor: AppTheme.primaryColor, onChanged: (val) => value.value = val)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResultsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Iconsax.verify_bold, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    "recommended_system".tr,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildResultItem("panel_count".tr, "${controller.recommendedPanels.value}", Iconsax.sun_1_bold),
                      _buildResultItem("inverter_size".tr, "${controller.recommendedInverterSize.value.toStringAsFixed(1)} kVA", Iconsax.flash_bold),
                      _buildResultItem("battery_bank".tr, "${controller.recommendedBatteries.value}", Iconsax.battery_charging_bold),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  // New Total Capacities
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildResultItem("Total PV Power", "${controller.totalPanelCapacityKw.value.toStringAsFixed(1)} kW", Icons.solar_power),
                      _buildResultItem("Total Battery", controller.totalBatteryCapacityAh.value, Icons.battery_std),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Charge Controller: ${controller.recommendedControllerSize.value}A", style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (Get.find<AppConfigController>().isEnabled('request_offer')) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.prepareRequestFromCalculation();
                  },
                  icon: const Icon(Iconsax.send_2_bold),
                  label: Text("request_this_system".tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "request_description".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildResultItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  void _showHelpDialog() {
    final explanations = AppExplanations.getExplanations();
    RxBool dontShowAgain = true.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 600,
          child: Column(
            children: [
              Text("guide".tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: explanations.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = explanations[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        Text(item.description, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Obx(() => Checkbox(value: dontShowAgain.value, onChanged: (val) => dontShowAgain.value = val ?? false, activeColor: AppTheme.primaryColor)),
                  Text("dont_show_again".tr),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (dontShowAgain.value) {
                      GetStorage().write('system_calculator_wizard_help_viewed', true);
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("close".tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final requestSystem = {
  'user': 'user_id',
  'pv': 'total pv => panel count * panel capacity', // type double,
  'battery': 'total battery => battery count * battery capacity', // type double,
  'inverter': 'total inverter => inverter count * inverter capacity', // type double,
  'notes': 'notes', // type text
  'specs': // type jsonb
  {
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
      'count': ' int',
      'capacity': ' double',
      'note': 'text',
      'voltage_type': 'LV or HV',
      'type': 'off-grid or on-grid or hybrid',
      'phase': 'single or three',
    },
  },
};
// {
// 'id': uuid,
// "user": user_id,
// request: request_id,
// compnay: company_id,
// pv: {count: int, capacity: int in watt, mark: string (optional)},
// battery: {count: int (optional), capacity: double in kw or Ah if not lithium, mark: string (optional)},
// inverter: {count: int (optional), capacity: double in kw mark: string (optional), phase: string (optional)},
// involves : list of string [wires, frames, moves, installations, etc] as checkboxes (all optional)
// notes: text,
// price: double,
// status: string (pending, accepted, rejected)
// expires_at: datetime (optional),
// }

// systems
// {
// id: uuid,
// user:(optional) public.profiles.phone_number (if system add by company need user to approve to show to his profile and system will be hidden to public until approved),
// user_status: string (pending, accepted, rejected),
// installed_by:(optional) company_id, if system add by user need company to approve to show to his profile and system will be hidden to public until approved),
// company_status: string (pending, accepted, rejected),
// pv: {count: int, capacity: int in watt, mark: string (optional)},
// battery: {count: int (optional), capacity: double in kw or Ah if not lithium, mark: string (optional)},
// inverter: {count: int (optional), capacity: double in kw mark: string (optional), phase: string (optional)},
// notes: text,
// lat: double,
// lan: double,
// address:(optional) string,
// city:(optional) string,
// country:(optional) string,
// installed_at: datetime,
// order_id: (optional) uuid,
// }
