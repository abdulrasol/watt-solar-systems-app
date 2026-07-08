import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/shared/domain/company/company_expense.dart';
import 'package:watt/src/utils/app_theme.dart';

/// Card widget displaying a single company expense.
class ExpenseCard extends ConsumerWidget {
  final CompanyExpense expense;
  final VoidCallback? onDelete;

  const ExpenseCard({super.key, required this.expense, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);

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
                child: Icon(Iconsax.money_2, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  expense.category,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
                ),
              ),
              Text(
                expense.amount.toStringAsFixed(2),
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w800, color: colors.primary),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Iconsax.trash, color: colors.error),
              ),
            ],
          ),
          if (expense.date != null) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.date}: ${expense.date!.year}-${expense.date!.month.toString().padLeft(2, '0')}-${expense.date!.day.toString().padLeft(2, '0')}',
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: colors.textSecondary),
            ),
          ],
          if ((expense.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              expense.description!,
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
