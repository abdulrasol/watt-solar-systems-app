import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_dialog.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/home_appliance_row.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class SystemAppliancesTab extends StatelessWidget {
  const SystemAppliancesTab({super.key, required this.controller});
  final CalculatorNotifier controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalLoad = controller.appliances.fold(
      0.0,
      (sum, a) => sum + a.power * a.quantity,
    );

    return Column(
      children: [
        // Summary badge — only shown when there are appliances
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: controller.appliances.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.electricity_bold,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.appliances_count_label(
                          controller.appliances.length,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.total_load_watts_label(
                          totalLoad.toStringAsFixed(0),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            itemCount: controller.appliances.length,
            itemBuilder: (context, index) {
              final app = controller.appliances[index];
              return HomeApplianceRow(
                key: ValueKey(app),
                app: app,
                controller: controller,
              );
            },
          ),
        ),

        // Add appliance
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.addAppliance,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.add_appliance),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: AppTheme.primaryColor),
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  onPressed: () {
                    ExplanationDialog.show(
                      context,
                      explanations: [AppExplanations(context).getExplanations()[0]],
                    );
                  },
                  icon: const Icon(Icons.help_outline_rounded),
                  color: AppTheme.primaryColor,
                  tooltip: 'Explanation',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
