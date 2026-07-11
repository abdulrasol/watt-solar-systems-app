import 'package:watt/src/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/layout/app_breakpoints.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:watt/src/utils/app_strings.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/company_header_card.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/stat_card.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/dashboard_charts.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/order_distribution_chart.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/financial_summary_card.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/recent_activity_list.dart';
import 'package:watt/src/features/inventory/presentation/providers/inventory_provider.dart';

class OverviewContent extends ConsumerWidget {
  final int? companyId;

  const OverviewContent({super.key, this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final company = user?.company;
    final statsGridCount = AppBreakpoints.adaptiveGridCount(context, mobile: 2, tablet: 2, desktop: 4);
    final l10n = AppLocalizations.of(context)!;
    

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Header
        if (company != null) ...[CompanyHeaderCard(company: company), SizedBox(height: 30)],

        // Stats Grid
        Text(
          l10n.quick_stats,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: AppTheme.fontFamily),
        ),
        SizedBox(height: 16),
        Consumer(
          builder: (context, ref, child) {
            final stats = ref.watch(companyStatsProvider);
            final summaryState = ref.watch(companySummaryProvider);
            final cards = <Widget>[
              StatCard(label: l10n.members, value: '${stats?.members ?? 0}', icon: Iconsax.people, color: Colors.blue),
              if (summaryState.hasReadPermission(AppStrings.ordersPermission))
                StatCard(label: l10n.orders, value: '${stats?.orders ?? 0}', icon: Iconsax.shopping_cart, color: Colors.green),
              if (summaryState.hasReadPermission('offers'))
                StatCard(label: l10n.offers, value: '${stats?.offers ?? 0}', icon: Iconsax.document, color: Colors.orange),
              if (summaryState.hasReadPermission('contacts'))
                StatCard(label: l10n.contacts, value: '${stats?.contacts ?? 0}', icon: Iconsax.call, color: Colors.purple),
              if (summaryState.hasReadPermission('customers'))
                StatCard(label: l10n.customers, value: '${stats?.customers ?? 0}', icon: Iconsax.profile_2user, color: Colors.teal),
              if (summaryState.hasReadPermission('inventory'))
                StatCard(label: l10n.inventory, value: '${stats?.products ?? 0}', icon: Iconsax.box, color: Colors.indigo),
            ];
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: statsGridCount,
              childAspectRatio: AppBreakpoints.isMobile(context) ? 1.15 : 1.35,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: cards,
            );
          },
        ),
        SizedBox(height: 30),

        // Financial Summary
        const FinancialSummaryCard(),
        SizedBox(height: 30),

        // Low Stock Alerts
        _buildLowStockAlerts(context, ref),
        SizedBox(height: 30),

        // Charts Section
        Text(
          l10n.analytics,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: AppTheme.fontFamily),
        ),
        SizedBox(height: 16),
        if (AppBreakpoints.isDesktop(context))
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 2, child: RevenueChart()),
              SizedBox(width: 16),
              const Expanded(flex: 1, child: OrderDistributionChart()),
            ],
          )
        else ...[
          const RevenueChart(),
          SizedBox(height: 16),
          const OrderDistributionChart(),
        ],
        SizedBox(height: 30),

        // Recent Activity
        const RecentActivityList(),
        SizedBox(height: 30),

        
        // Help Center / Call to action
        _buildCTA(context),
      ],
    );
  }

  Widget _buildLowStockAlerts(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lowStock = ref.watch(lowStockProductsProvider);
    if (lowStock.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.warning_2, color: Colors.red, size: 24),
              SizedBox(width: 12),
              Text(
                l10n.low_stock_alerts,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.red, fontFamily: AppTheme.fontFamily),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${lowStock.length} ${l10n.items_count}',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lowStock.length > 3 ? 3 : lowStock.length,
            separatorBuilder: (_, index) => Divider(color: Colors.red.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final product = lowStock[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(l10n.formatUnitsLeft(product.stockQuantity)),
                trailing: TextButton(
                  // Opens the product's own page so the owner can update
                  // stock from the existing edit flow — there's no separate
                  // "quick restock" endpoint/dialog, so this reuses the real
                  // product editing screen rather than being a no-op.
                  onPressed: () => context.push('${AppRoutes.companyInventoryProductDetails}/${product.id}', extra: product),
                  child: Text(l10n.restock),
                ),
              );
            },
          ),
          if (lowStock.length > 3) ...[
            SizedBox(height: 8),
            Center(
              child: TextButton(
                // The inventory list screen doesn't yet support a
                // low-stock-only filter/query param, so this opens the full
                // inventory list rather than doing nothing — see the
                // company dashboard linking plan for adding a proper filter.
                onPressed: () => context.push(AppRoutes.companyInventoryProducts),
                child: Text(l10n.view_all_alerts),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Iconsax.chart_2, color: AppTheme.primaryColor, size: 48),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.ready_to_scale_business,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, fontFamily: AppTheme.fontFamily),
          ),
          Text(
            AppLocalizations.of(context)!.monitor_growth_subscriptions,
            style: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: AppTheme.fontFamily),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
