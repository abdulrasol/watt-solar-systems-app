import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:watt/src/features/offers/presentation/providers/offers_provider.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:toastification/toastification.dart';

class SystemRequestConfirmationSheet extends ConsumerWidget {
  const SystemRequestConfirmationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(calculatorProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(bottom: 24),
            ),
          ),
          Text(
            l10n.confirm_request_details,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildSummaryRow(
            l10n.total_pv_power,
            "${(controller.panelCount * controller.selectedPanelWattage / 1000).toStringAsFixed(1)} kW",
          ),
          _buildSummaryRow(
            l10n.total_inverters_power_label,
            "${(controller.inverterCount * controller.selectedInverterKva).toStringAsFixed(1)} kW",
          ),
          _buildSummaryRow(
            l10n.total_battery,
            "${(controller.batteryCount * controller.selectedBatteryAmp).toStringAsFixed(0)} Ah",
          ),

          const SizedBox(height: 16),
          TextField(
            onChanged: (val) => controller.requestNotes = val,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.request_notes_hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isSubmitting 
                ? null 
                : () async {
                  controller.updateField(() => controller.isSubmitting = true);
                  
                  final cityId = authState.user?.city?.id;
                  final data = controller.toRequestMap(cityId: cityId);
                  
                  final success = await ref.read(offersProvider.notifier).createRequest(data);
                  
                  controller.updateField(() => controller.isSubmitting = false);

                  if (context.mounted) {
                    if (success) {
                      toastification.show(
                        context: context,
                        type: ToastificationType.success,
                        style: ToastificationStyle.flatColored,
                        title: Text(l10n.request_submitted_success),
                        autoCloseDuration: const Duration(seconds: 3),
                      );
                      Navigator.pop(context);
                    } else {
                      toastification.show(
                        context: context,
                        type: ToastificationType.error,
                        style: ToastificationStyle.flatColored,
                        title: Text(l10n.request_failed),
                        autoCloseDuration: const Duration(seconds: 3),
                      );
                    }
                  }
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(l10n.submit_request),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
