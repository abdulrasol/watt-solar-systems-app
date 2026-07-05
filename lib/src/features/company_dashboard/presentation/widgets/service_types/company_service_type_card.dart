import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Card widget for toggling a service type the company serves.
class CompanyServiceTypeCard extends ConsumerWidget {
  final ServiceType item;
  final bool isBusy;
  final VoidCallback onToggle;

  const CompanyServiceTypeCard({super.key, required this.item, required this.isBusy, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isServed ? colors.primary.withValues(alpha: 0.28) : colors.border,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              height: 64,
              color: colors.primary.withValues(alpha: 0.08),
              child: item.image?.isNotEmpty == true
                  ? CachedNetworkImage(
                      imageUrl: item.image!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(Icons.layers_outlined, color: colors.primary),
                    )
                  : Icon(Icons.layers_outlined, color: colors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800, color: colors.textPrimary),
                ),
                if ((item.description ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.service_types_companies_count(item.companiesCount),
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          isBusy
              ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary))
              : FilledButton.tonal(
                  onPressed: onToggle,
                  child: Text(item.isServed ? l10n.service_types_served : l10n.service_types_mark_served),
                ),
        ],
      ),
    );
  }
}
