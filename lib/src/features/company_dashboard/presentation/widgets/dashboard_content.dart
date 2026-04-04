import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/nav_item.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summery_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/overview_content.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class DashboardContent extends ConsumerWidget {
  final int index;
  final List<NavItem> navItems;

  const DashboardContent({
    super.key,
    required this.index,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companySummeryProvider);
    final l10n = AppLocalizations.of(context)!;

    if (state.isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.info_circle_bold,
              color: AppTheme.errorColor,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.error_loading_data,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 16.sp,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
      );
    }

    // Protection against out of bounds index
    final currentIndex = index >= navItems.length ? 0 : index;
    final currentItem = navItems[currentIndex];
    final companyId = ref.watch(authProvider).company?.id;

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header (only on Desktop since Mobile has AppBar)
                if (MediaQuery.of(context).size.shortestSide >= 600) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentItem.label,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                          Text(
                            l10n.company_dashboard_subtitle,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Iconsax.notification_bing_bold),
                            onPressed: () {},
                          ),
                          SizedBox(width: 12.w),
                          IconButton(
                            icon: const Icon(Iconsax.setting_2_bold),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                ],
                // Content Area
                if (currentItem.label == l10n.overview)
                  OverviewContent(state: state)
                else if (currentItem.serviceCode == 'storefront_b2b' &&
                    companyId != null)
                  StorefrontScreen(
                    audience: StorefrontAudience.b2b,
                    companyId: companyId,
                    embedded: true,
                  )
                else if (currentItem.serviceCode == 'storefront_b2c')
                  const StorefrontScreen(
                    audience: StorefrontAudience.b2c,
                    embedded: true,
                  )
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100.h),
                      child: Column(
                        children: [
                          Icon(
                            currentItem.icon,
                            size: 64.sp,
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            l10n.section_label(currentItem.label),
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
        ),

        if (state.isLoading)
          Center(child: LoadingWidget.widget(context: context)),
      ],
    );
  }
}
