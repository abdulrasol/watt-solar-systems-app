import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/shared/domain/company/company_category.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Chip widget displaying a single company category with an optional delete action.
class CategoryChip extends ConsumerWidget {
  final CompanyCategory category;
  final VoidCallback? onDelete;

  const CategoryChip({super.key, required this.category, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.name,
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, color: colors.textPrimary),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: onDelete,
            child: Icon(Iconsax.close_circle, color: colors.error),
          ),
        ],
      ),
    );
  }
}
