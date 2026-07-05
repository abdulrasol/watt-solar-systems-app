import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Card displaying the total amount of company expenses.
class ExpenseTotalCard extends ConsumerWidget {
  final double total;

  const ExpenseTotalCard({super.key, required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: colors.primary),
          const SizedBox(width: 10),
          Text(
            l10n.amount,
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: colors.textPrimary),
          ),
          const Spacer(),
          Text(
            total.toStringAsFixed(2),
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w900, fontSize: 16, color: colors.primary),
          ),
        ],
      ),
    );
  }
}
