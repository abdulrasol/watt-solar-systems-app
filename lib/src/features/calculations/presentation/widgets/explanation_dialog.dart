import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:get_storage/get_storage.dart';

class ExplanationDialog extends StatefulWidget {
  const ExplanationDialog({super.key, required this.explanations, this.showDontShowAgain = false, this.storageKey});

  final List<ExplanationItem> explanations;
  final bool showDontShowAgain;
  final String? storageKey;

  static void show(BuildContext context, {required List<ExplanationItem> explanations, bool showDontShowAgain = false, String? storageKey}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) =>
          ExplanationDialog(explanations: explanations, showDontShowAgain: showDontShowAgain, storageKey: storageKey),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ExplanationDialog> createState() => _ExplanationDialogState();
}

class _ExplanationDialogState extends State<ExplanationDialog> {
  late final ValueNotifier<bool> _dontShowAgain;

  @override
  void initState() {
    super.initState();
    bool initialValue = true;
    if (widget.storageKey != null) {
      initialValue = GetStorage().read(widget.storageKey!) ?? true;
    }
    _dontShowAgain = ValueNotifier<bool>(initialValue);
  }

  @override
  void dispose() {
    _dontShowAgain.dispose();
    super.dispose();
  }

  void _handleClose(BuildContext context) {
    if (widget.showDontShowAgain && widget.storageKey != null) {
      GetStorage().write(widget.storageKey!, _dontShowAgain.value);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(l10n.guide, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: theme.hintColor),
                      style: IconButton.styleFrom(backgroundColor: theme.hintColor.withValues(alpha: 0.1)),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // Content
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  shrinkWrap: true,
                  itemCount: widget.explanations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final item = widget.explanations[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryColor),
                              ),
                              const SizedBox(height: 6),
                              Text(item.description, style: TextStyle(fontSize: 13.5, color: theme.colorScheme.onSurface.withValues(alpha: 0.75), height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05, end: 0);
                  },
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.showDontShowAgain) ...[
                      ValueListenableBuilder<bool>(
                        valueListenable: _dontShowAgain,
                        builder: (context, isChecked, child) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _dontShowAgain.value = !isChecked,
                              borderRadius: BorderRadius.circular(12),
                              highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                              splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: isChecked,
                                        onChanged: (v) => _dontShowAgain.value = v ?? false,
                                        activeColor: AppTheme.primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        l10n.dont_show_again,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    FilledButton(
                      onPressed: () => _handleClose(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(l10n.close, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
