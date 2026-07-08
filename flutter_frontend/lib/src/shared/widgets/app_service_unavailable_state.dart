import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/utils/app_theme.dart';

/// A friendly empty state shown when a backend service is not available for
/// the current company's type (e.g. accounting or expenses disabled).
class AppServiceUnavailableState extends ConsumerWidget {
  const AppServiceUnavailableState({
    super.key,
    this.serviceName,
    this.message,
  });

  final String? serviceName;
  final String? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);
    final title = serviceName != null
        ? l10n.service_unavailable_for_company_type(serviceName!)
        : l10n.service_unavailable_title;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Iconsax.lock,
                size: 36,
                color: colors.warning,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? l10n.service_unavailable_message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
