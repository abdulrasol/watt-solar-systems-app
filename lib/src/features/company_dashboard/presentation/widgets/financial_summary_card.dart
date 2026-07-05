import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/accounting/presentation/providers/accounting_providers.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class FinancialSummaryCard extends ConsumerWidget {
  const FinancialSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final companyId = ref.watch(authProvider).company?.id;
    if (companyId == null) return const SizedBox.shrink();

    final accountingState = ref.watch(accountingDashboardProvider(companyId));
    final overview = accountingState.overview;

    if (accountingState.error != null && isServiceUnavailableForCompanyType(accountingState.error)) {
      return _UnavailableCard(message: l10n.service_unavailable_message);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.financial_overview,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: AppTheme.fontFamily),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  context,
                  label: l10n.invoices,
                  value: _formatAmount(overview?.invoicesTotal ?? 0),
                  icon: Iconsax.receipt_1,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(context, label: l10n.bills, value: _formatAmount(overview?.billsTotal ?? 0), icon: Iconsax.document, color: Colors.orange),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  context,
                  label: l10n.payments,
                  value: _formatAmount(overview?.paymentsTotal ?? 0),
                  icon: Iconsax.money_2,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, {required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: AppTheme.fontFamily),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }

  String _formatAmount(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }
}

class _UnavailableCard extends StatelessWidget {
  final String message;

  const _UnavailableCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.lock, size: 20, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], fontFamily: AppTheme.fontFamily),
            ),
          ),
        ],
      ),
    );
  }
}
