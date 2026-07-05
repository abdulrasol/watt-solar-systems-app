import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/shared/domain/company/company_public_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Card widget displaying a single public service offered by the company.
class PublicServiceCard extends ConsumerWidget {
  final CompanyPublicService service;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PublicServiceCard({super.key, required this.service, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Iconsax.briefcase, color: colors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
                ),
                if (service.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: colors.textSecondary),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  service.price == null ? '-' : '${service.price}',
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: colors.primary),
                ),
              ],
            ),
          ),
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onEdit != null) IconButton(onPressed: onEdit, icon: Icon(Iconsax.edit, size: 20, color: colors.textSecondary)),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Iconsax.trash, color: colors.error, size: 20),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
