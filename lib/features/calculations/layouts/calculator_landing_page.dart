import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/admin/controllers/app_config_controller.dart';
import 'package:solar_hub/features/calculations/layouts/offer_request_wizard.dart';
import 'package:solar_hub/features/calculations/layouts/system_calculator_wizard.dart';
import 'package:solar_hub/features/calculations/layouts/tools/battery_calculator_page.dart';
import 'package:solar_hub/features/calculations/layouts/tools/inverter_calculator_page.dart';
import 'package:solar_hub/features/calculations/layouts/tools/panel_calculator_page.dart';
import 'package:solar_hub/features/calculations/layouts/tools/wires_calculator_page.dart';
import 'package:solar_hub/features/calculations/layouts/tools/pump_calculator.dart';
import 'package:solar_hub/features/calculations/layouts/tools/direction_calculator.dart';

class CalculatorLandingPage extends StatelessWidget {
  const CalculatorLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfigController = Get.find<AppConfigController>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("calculator_tools".tr, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Main Wizards
              if (appConfigController.isEnabled('show_system_wizard')) ...[
                _buildWizardCard(
                  context,
                  title: "system_wizard".tr,
                  description: "system_wizard_desc".tr,
                  icon: Iconsax.calculator_bold,
                  color: Colors.orange,
                  onTap: () => Get.to(() => const SystemCalculatorWizard()),
                ),
              ],
              if (appConfigController.isEnabled('show_request_offer_wizard')) ...[
                const SizedBox(height: 16),
                _buildWizardCard(
                  context,
                  title: "request_offer_wizard".tr,
                  description: "request_offer_desc".tr,
                  icon: Iconsax.document_text_bold,
                  color: Colors.blue,
                  onTap: () => Get.to(() => const OfferRequestWizard()),
                ),
              ],

              const SizedBox(height: 32),
              Text("quick_tools".tr, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Quick Tools Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildToolCard(context, "panels_calc".tr, Iconsax.sun_1_bold, Colors.amber, () => Get.to(() => const PanelCalculatorPage())),
                  _buildToolCard(context, "inverter_calc".tr, Iconsax.flash_bold, Colors.red, () => Get.to(() => const InverterCalculatorPage())),
                  _buildToolCard(context, "battery_calc".tr, Iconsax.battery_charging_bold, Colors.green, () => Get.to(() => const BatteryCalculatorPage())),
                  _buildToolCard(context, "wires_calc".tr, Icons.cable, Colors.grey, () => Get.to(() => const WiresCalculatorPage())),
                  _buildToolCard(context, "pump_calc".tr, Icons.water_drop, Colors.blueAccent, () => Get.to(() => PumpCalculator())),
                  _buildToolCard(context, "orientation_calc".tr, Icons.explore, Colors.teal, () => Get.to(() => DirectionCalculator())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWizardCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
