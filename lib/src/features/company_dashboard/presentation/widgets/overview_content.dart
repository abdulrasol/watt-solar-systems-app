import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/service.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:solar_hub/src/utils/app_strings.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_header_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/service_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/stat_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/dashboard_charts.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/order_distribution_chart.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/financial_summary_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/recent_activity_list.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/inventory_provider.dart';

class OverviewContent extends ConsumerWidget {
  final int? companyId;

  const OverviewContent({super.key, this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final company = user?.company;
    final rawServices = ref.watch(companyServicesProvider);
    final statsGridCount = AppBreakpoints.adaptiveGridCount(context, mobile: 2, tablet: 2, desktop: 4);
    final servicesGridCount = AppBreakpoints.adaptiveGridCount(context, mobile: 2, tablet: 3, desktop: 4);
    final l10n = AppLocalizations.of(context)!;
    final services = [...rawServices];
    final summaryState = ref.watch(companySummaryProvider);
    final hasProjectsRead = summaryState.hasReadPermission(AppStrings.projectsPermission);
    if (!hasProjectsRead) {
      services.removeWhere((s) => s.serviceCode == 'company_work');
    }

    final hasActiveOffers = services.any((service) => service.serviceCode == 'offers' && service.isActive);
    if (hasActiveOffers) {
      services.add(
        CompanyService(
          serviceCode: 'offers_catalog',
          serviceName: l10n.offers_catalog,
          status: 'active',
          isAutoEnabled: true,
          autoEnabledBy: const [],
          meta: const {},
          route: '/offers/catalog',
        ),
      );
    }

    for (var index = 0; index < services.length; index++) {
      final service = services[index];
      if (service.serviceCode == 'company_work') {
        services[index] = CompanyService(
          serviceCode: service.serviceCode,
          serviceName: service.serviceName.isEmpty ? l10n.company_work_title : service.serviceName,
          status: service.status,
          isAutoEnabled: service.isAutoEnabled,
          autoEnabledBy: service.autoEnabledBy,
          meta: service.meta,
          route: '/company-work',
          icon: service.icon,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Header
        if (company != null) ...[CompanyHeaderCard(company: company), SizedBox(height: 30.h)],

        // Stats Grid
        Text(
          l10n.quick_stats,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, fontFamily: AppTheme.fontFamily),
        ),
        SizedBox(height: 16.h),
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
              crossAxisSpacing: 16.r,
              mainAxisSpacing: 16.r,
              children: cards,
            );
          },
        ),
        SizedBox(height: 30.h),

        // Financial Summary
        const FinancialSummaryCard(),
        SizedBox(height: 30.h),

        // Low Stock Alerts
        _buildLowStockAlerts(context, ref),
        SizedBox(height: 30.h),

        // Charts Section
        Text(
          l10n.analytics,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, fontFamily: AppTheme.fontFamily),
        ),
        SizedBox(height: 16.h),
        if (AppBreakpoints.isDesktop(context))
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 2, child: RevenueChart()),
              SizedBox(width: 16.w),
              const Expanded(flex: 1, child: OrderDistributionChart()),
            ],
          )
        else ...[
          const RevenueChart(),
          SizedBox(height: 16.h),
          const OrderDistributionChart(),
        ],
        SizedBox(height: 30.h),

        // Recent Activity
        const RecentActivityList(),
        SizedBox(height: 30.h),

        // Services Grid
        Text(
          l10n.services,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, fontFamily: AppTheme.fontFamily),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: servicesGridCount,
            childAspectRatio: AppBreakpoints.isDesktop(context) ? 1.18 : 1.02,
            crossAxisSpacing: 16.r,
            mainAxisSpacing: 16.r,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceCard(service: service, companyId: companyId);
          },
        ),
        SizedBox(height: 30.h),

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
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.warning_2, color: Colors.red, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                l10n.low_stock_alerts,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.red, fontFamily: AppTheme.fontFamily),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20.r)),
                child: Text(
                  '${lowStock.length} ${l10n.items_count}',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                ),
                subtitle: Text(l10n.formatUnitsLeft(product.stockQuantity)),
                trailing: TextButton(
                  // Opens the product's own page so the owner can update
                  // stock from the existing edit flow — there's no separate
                  // "quick restock" endpoint/dialog, so this reuses the real
                  // product editing screen rather than being a no-op.
                  onPressed: () => context.push('/inventory/product/${product.id}', extra: product),
                  child: Text(l10n.restock),
                ),
              );
            },
          ),
          if (lowStock.length > 3) ...[
            SizedBox(height: 8.h),
            Center(
              child: TextButton(
                // The inventory list screen doesn't yet support a
                // low-stock-only filter/query param, so this opens the full
                // inventory list rather than doing nothing — see the
                // company dashboard linking plan for adding a proper filter.
                onPressed: () => context.push('/inventory'),
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
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Iconsax.chart_2, color: AppTheme.primaryColor, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context)!.ready_to_scale_business,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18.sp, fontFamily: AppTheme.fontFamily),
          ),
          Text(
            AppLocalizations.of(context)!.monitor_growth_subscriptions,
            style: TextStyle(color: Colors.grey, fontSize: 13.sp, fontFamily: AppTheme.fontFamily),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
