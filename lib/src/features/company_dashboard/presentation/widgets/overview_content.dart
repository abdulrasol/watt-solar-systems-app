import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/service.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summery_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_header_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/service_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/stat_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class OverviewContent extends ConsumerWidget {
  final CompanySummeryState state;
  final int? companyId;

  const OverviewContent({super.key, required this.state, this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = state.summery;
    final user = ref.watch(authProvider).user;
    final company = user?.company;
    final statsGridCount = AppBreakpoints.adaptiveGridCount(
      context,
      mobile: 2,
      tablet: 2,
      desktop: 4,
    );
    final servicesGridCount = AppBreakpoints.adaptiveGridCount(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
    final l10n = AppLocalizations.of(context)!;
    final services = [...?s?.services];
    final hasActiveOffers = services.any(
      (service) =>
          service.serviceCode == 'offers' &&
          service.status != null &&
          (service.status!.toLowerCase() == 'active' ||
              service.status!.toLowerCase() == 'approved' ||
              service.status!.toLowerCase() == 'string'),
    );
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Header
        if (company != null) ...[
          CompanyHeaderCard(company: company),
          SizedBox(height: 30.h),
        ],

        // Stats Grid
        Text(
          l10n.quick_stats,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: statsGridCount,
          childAspectRatio: AppBreakpoints.isMobile(context) ? 1.15 : 1.35,
          crossAxisSpacing: 16.r,
          mainAxisSpacing: 16.r,
          children: [
            StatCard(
              label: l10n.members,
              value: '${s?.members ?? 0}',
              icon: Iconsax.people_bold,
              color: Colors.blue,
            ),
            StatCard(
              label: l10n.orders,
              value: '${s?.orders ?? 0}',
              icon: Iconsax.shopping_cart_bold,
              color: Colors.green,
            ),
            StatCard(
              label: l10n.offers,
              value: '${s?.offers ?? 0}',
              icon: Iconsax.document_bold,
              color: Colors.orange,
            ),
            StatCard(
              label: l10n.contacts,
              value: '${s?.contacts ?? 0}',
              icon: Iconsax.call_bold,
              color: Colors.purple,
            ),
          ],
        ),
        SizedBox(height: 30.h),

        // Services Grid
        Text(
          l10n.services,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            fontFamily: AppTheme.fontFamily,
          ),
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
          Icon(Iconsax.chart_2_bold, color: AppTheme.primaryColor, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context)!.ready_to_scale_business,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.monitor_growth_subscriptions,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13.sp,
              fontFamily: AppTheme.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
