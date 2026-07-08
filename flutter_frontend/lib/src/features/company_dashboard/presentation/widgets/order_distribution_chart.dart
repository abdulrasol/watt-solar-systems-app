import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/accounting/presentation/providers/accounting_providers.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/utils/app_theme.dart';

class OrderDistributionChart extends ConsumerWidget {
  const OrderDistributionChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final companyId = ref.watch(authProvider).company?.id;
    if (companyId == null) return const SizedBox.shrink();

    final accountingState = ref.watch(accountingDashboardProvider(companyId));
    final overview = accountingState.overview;

    // Previously this fell back to hardcoded 40/30/15 whenever `overview`
    // was null/loading, so a brand-new company with zero real activity saw
    // a populated-looking pie chart with fake numbers. Now we show an
    // explicit empty state instead of inventing data.
    final invoices = overview?.invoicesTotal.toDouble() ?? 0.0;
    final bills = overview?.billsTotal.toDouble() ?? 0.0;
    final payments = overview?.paymentsTotal.toDouble() ?? 0.0;
    final total = invoices + bills + payments;

    if (accountingState.isLoading && overview == null) {
      return Container(
        height: 300,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (total <= 0) {
      return Container(
        height: 300,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.order_status,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: AppTheme.fontFamily),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pie_chart_outline_rounded, size: 40, color: Colors.grey.withValues(alpha: 0.4)),
                    SizedBox(height: 8),
                    Text(l10n.no_data_available, style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.order_status,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.blue,
                    value: invoices,
                    title: total > 0 ? '${(invoices / total * 100).toStringAsFixed(0)}%' : '0%',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: bills,
                    title: total > 0 ? '${(bills / total * 100).toStringAsFixed(0)}%' : '0%',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: payments,
                    title: total > 0 ? '${(payments / total * 100).toStringAsFixed(0)}%' : '0%',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 16,
            children: [
              _buildLegend(l10n.invoices, Colors.blue),
              _buildLegend(l10n.bills, Colors.green),
              _buildLegend(l10n.payments, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
