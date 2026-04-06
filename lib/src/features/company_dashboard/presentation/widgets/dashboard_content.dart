import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/nav_item.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summery_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/dashboard_header.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/overview_content.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_screen.dart';
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
    final companyId = ref.watch(authProvider).company?.id;

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

    final currentIndex = index >= navItems.length ? 0 : index;
    final currentItem = navItems[currentIndex];
    final bool showHeader = !AppBreakpoints.isMobile(context);

    return Stack(
      children: [
        Column(
          children: [
            if (showHeader)
              Padding(
                padding: AppBreakpoints.pagePadding(
                  context,
                ).copyWith(bottom: 0),
                child: DashboardHeader(title: currentItem.label),
              ),
            Expanded(
              child: _buildSectionContent(
                context: context,
                currentItem: currentItem,
                state: state,
                companyId: companyId,
                l10n: l10n,
              ),
            ),
          ],
        ),
        if (state.isLoading)
          Center(child: LoadingWidget.widget(context: context)),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSectionContent({
    required BuildContext context,
    required NavItem currentItem,
    required CompanySummeryState state,
    required int? companyId,
    required AppLocalizations l10n,
  }) {
    final contentPadding = AppBreakpoints.pagePadding(context);
    final maxWidth = AppBreakpoints.contentMaxWidth(context);

    if (currentItem.label == l10n.overview) {
      return SingleChildScrollView(
        padding: contentPadding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: OverviewContent(state: state, companyId: companyId),
          ),
        ),
      );
    }

    if (currentItem.serviceCode == 'storefront_b2b' && companyId != null) {
      return StorefrontScreen(
        audience: StorefrontAudience.b2b,
        companyId: companyId,
        embedded: true,
      );
    }

    if (currentItem.serviceCode == 'storefront_b2c') {
      return const StorefrontScreen(
        audience: StorefrontAudience.b2c,
        embedded: true,
      );
    }

    // Default Placeholder for other sections
    return SingleChildScrollView(
      padding: contentPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.only(top: 60.h),
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
      ),
    );
  }
}
