import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/offer_request_wizard.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/system_calculator_wizard.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/battery_calculator_page.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/inverter_calculator_page.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/panel_calculator_page.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/wires_calculator_page.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/pump_calculator.dart';

class CalculatorLandingPage extends ConsumerWidget {
  const CalculatorLandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'calculator_tools',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ), // AppLocalizations.of(context)?.calculatorTools ??
              const SizedBox(height: 20),

              // Main Wizards
              _buildWizardCard(
                context,
                title: 'system_wizard', //  TODO : add translation
                description: 'system_wizard_desc', //  TODO : add translation
                icon: Iconsax.calculator_bold,
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SystemCalculatorWizard())),
              ),

              const SizedBox(height: 16),
              _buildWizardCard(
                context,
                title: 'request_offer_wizard', //  TODO : add translation
                description: 'request_offer_desc', //  TODO : add translation
                icon: Iconsax.document_text_bold,
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OfferRequestWizard())),
              ),

              const SizedBox(height: 32),
              Text(
                'quick_tools',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ), // AppLocalizations.of(context)?.quickTools ??
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
                    'panels_calc',
                    Iconsax.sun_1_bold,
                    Colors.amber,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PanelCalculatorPage())),
                  ), // TODO add translation
                  _buildToolCard(
                    context,
                    'inverter_calc',
                    Iconsax.flash_bold,
                    Colors.red,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InverterCalculatorPage())),
                  ), // TODO add translation
                  _buildToolCard(
                    context,
                    'battery_calc',
                    Iconsax.battery_charging_bold,
                    Colors.green,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BatteryCalculatorPage())),
                  ), // TODO add translation
                  _buildToolCard(
                    context,
                    'wires_calc',
                    Icons.cable,
                    Colors.grey,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WiresCalculatorPage())),
                  ), // TODO add translation
                  _buildToolCard(
                    context,
                    'pump_calc',
                    Icons.water_drop,
                    Colors.blueAccent,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => PumpCalculator())),
                  ), // TODO add translation
                  // _buildToolCard(
                  //   context,
                  //   'orientation_calc',
                  //   Icons.explore,
                  //   Colors.teal,
                  //   () => Navigator.push(context, MaterialPageRoute(builder: (context) => DirectionCalculator())),
                  // ), // TODO add translation
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
