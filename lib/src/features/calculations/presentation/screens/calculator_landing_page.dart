import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/offer_request_wizard.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/system_calculator_wizard.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/battery_calculator_page.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/inverter_calculator_page.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/panel_calculator_page.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/wires_calculator_page.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/pump_calculator.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';

class CalculatorLandingPage extends ConsumerWidget {
  const CalculatorLandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calculator_tools),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Wizards
              _buildWizardCard(
                context,
                title: AppLocalizations.of(context)!.system_wizard,
                description: AppLocalizations.of(context)!.system_wizard_desc,
                icon: Iconsax.calculator_bold,
                color: Colors.orange,
                onTap: () {
                  ref.read(calculatorProvider).currentSystemId = null; 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SystemCalculatorWizard()));
                },
              ),
              if (isEnabled(ref, 'offers')) ...[
                const SizedBox(height: 16),
                _buildWizardCard(
                  context,
                  title: AppLocalizations.of(context)!.request_offer_wizard,
                  description: AppLocalizations.of(context)!.request_offer_desc,
                  icon: Iconsax.document_text_bold,
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OfferRequestWizard())),
                ),
              ],

              const SizedBox(height: 32),
              Text(AppLocalizations.of(context)!.quick_tools, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                  _buildToolCard(
                    context,
                    AppLocalizations.of(context)!.panels_calc,
                    Iconsax.sun_1_bold,
                    Colors.amber,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PanelCalculatorPage())),
                    'panel_hero',
                  ),
                  _buildToolCard(
                    context,
                    AppLocalizations.of(context)!.inverter_calc,
                    Iconsax.flash_bold,
                    Colors.red,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InverterCalculatorPage())),
                    'inverter_hero',
                  ),
                  _buildToolCard(
                    context,
                    AppLocalizations.of(context)!.battery_calc,
                    Iconsax.battery_charging_bold,
                    Colors.green,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BatteryCalculatorPage())),
                    'battery_hero',
                  ),
                  _buildToolCard(
                    context,
                    AppLocalizations.of(context)!.wires_calc,
                    Icons.cable,
                    Colors.grey,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WiresCalculatorPage())),
                    'wires_hero',
                  ),
                  _buildToolCard(
                    context,
                    AppLocalizations.of(context)!.pump_calc,
                    Icons.water_drop,
                    Colors.blueAccent,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => PumpCalculator())),
                    'pump_hero',
                  ),
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
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, [String? heroTag]) {
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
            if (heroTag != null)
              Hero(tag: heroTag, child: Icon(icon, color: color, size: 32))
            else
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
