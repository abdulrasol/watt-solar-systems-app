import 'package:flutter/material.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:get_storage/get_storage.dart';

class ExplanationDialog extends StatefulWidget {
  const ExplanationDialog({
    super.key,
    required this.explanations,
    this.showDontShowAgain = false,
  });

  final List<ExplanationItem> explanations;
  final bool showDontShowAgain;

  static void show(
    BuildContext context, {
    required List<ExplanationItem> explanations,
    bool showDontShowAgain = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => ExplanationDialog(
        explanations: explanations,
        showDontShowAgain: showDontShowAgain,
      ),
    );
  }

  @override
  State<ExplanationDialog> createState() => _ExplanationDialogState();
}

class _ExplanationDialogState extends State<ExplanationDialog> {
  bool dontShowAgain = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.guide,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.explanations.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (_, i) {
                  final item = widget.explanations[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (widget.showDontShowAgain) ...[
              InkWell(
                onTap: () => setState(() => dontShowAgain = !dontShowAgain),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Checkbox(
                      value: dontShowAgain,
                      onChanged: (v) =>
                          setState(() => dontShowAgain = v ?? false),
                      activeColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Text(l10n.dont_show_again),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (widget.showDontShowAgain && dontShowAgain) {
                    GetStorage().write(
                      'system_calculator_wizard_help_viewed',
                      true,
                    );
                  }
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
