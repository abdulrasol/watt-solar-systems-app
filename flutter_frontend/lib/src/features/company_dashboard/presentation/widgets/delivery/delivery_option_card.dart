import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/shared/domain/company/delivery_option.dart';
import 'package:watt/src/utils/app_theme.dart';

/// Card widget displaying a single delivery option.
class DeliveryOptionCard extends ConsumerWidget {
  final DeliveryOption option;
  final VoidCallback? onDelete;

  const DeliveryOptionCard({super.key, required this.option, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);
    final hasDaysRange = option.estimatedDaysMin != null || option.estimatedDaysMax != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.local_shipping_outlined, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.name,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
                ),
              ),
              if (!option.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.textTertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.status,
                    style: TextStyle(fontSize: 10, color: colors.textSecondary),
                  ),
                ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Iconsax.trash, color: colors.error),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.cost}: ${option.cost.toStringAsFixed(2)}',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: colors.textSecondary),
          ),
          if (hasDaysRange) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.company_delivery_estimated_days_min}: ${option.estimatedDaysMin ?? '-'}   ${l10n.company_delivery_estimated_days_max}: ${option.estimatedDaysMax ?? '-'}',
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: colors.textSecondary),
            ),
          ],
          if ((option.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              option.description!,
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
