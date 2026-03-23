import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/company_dashboard_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class _SideItem {
  final String title;
  final IconData icon;
  final int targetIndex;
  final String targetRouteName;
  final bool isHeader;

  const _SideItem({
    required this.title,
    this.icon = Icons.error,
    this.targetIndex = -1,
    this.targetRouteName = '',
    this.isHeader = false,
  });

  factory _SideItem.header(String title) {
    return _SideItem(title: title, isHeader: true);
  }
}

class DashboardSidebar extends ConsumerWidget {
  final bool isDesktop;

  const DashboardSidebar({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(companyDashboardIndexProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final hasManageBusiness = isEnabled(ref, 'company_orders', defaultValue: false) ||
        isEnabled(ref, 'company_pos', defaultValue: false) ||
        isEnabled(ref, 'company_invoices', defaultValue: false) ||
        isEnabled(ref, 'company_accounting', defaultValue: false) ||
        isEnabled(ref, 'company_inventory', defaultValue: false) ||
        isEnabled(ref, 'company_offers', defaultValue: false);

    final hasPeople = isEnabled(ref, 'company_members', defaultValue: false) ||
        isEnabled(ref, 'company_customers', defaultValue: false) ||
        isEnabled(ref, 'company_suppliers', defaultValue: false) ||
        isEnabled(ref, 'company_my_purchases', defaultValue: false);

    final hasTools = isEnabled(ref, 'company_analytics', defaultValue: false) ||
        isEnabled(ref, 'company_systems', defaultValue: false) ||
        isEnabled(ref, 'company_delivery', defaultValue: false);

    final items = <_SideItem>[
      _SideItem(title: l10n.dashboard, icon: Iconsax.category_bold, targetIndex: 0, targetRouteName: 'dashboard'),

      if (hasManageBusiness) _SideItem.header(l10n.manage_business),
      if (isEnabled(ref, 'company_orders', defaultValue: false))
        _SideItem(title: l10n.orders, icon: Iconsax.box_bold, targetIndex: 6, targetRouteName: 'orders'),
      if (isEnabled(ref, 'company_pos', defaultValue: false))
        _SideItem(title: l10n.pos, icon: FontAwesomeIcons.cashRegister, targetIndex: 5, targetRouteName: 'pos'),
      if (isEnabled(ref, 'company_invoices', defaultValue: false))
        _SideItem(title: l10n.invoices, icon: FontAwesomeIcons.fileInvoiceDollar, targetIndex: 7, targetRouteName: 'invoices'),
      if (isEnabled(ref, 'company_accounting', defaultValue: false))
        _SideItem(title: l10n.accounting, icon: FontAwesomeIcons.calculator, targetIndex: 8, targetRouteName: 'accounting'),
      if (isEnabled(ref, 'company_inventory', defaultValue: false))
        _SideItem(title: l10n.inventory, icon: FontAwesomeIcons.boxesStacked, targetIndex: 4, targetRouteName: 'inventory'),
      if (isEnabled(ref, 'company_offers', defaultValue: false))
        _SideItem(title: l10n.offers, icon: FontAwesomeIcons.bullhorn, targetIndex: 3, targetRouteName: 'offers'),

      if (hasPeople) _SideItem.header(l10n.people),
      if (isEnabled(ref, 'company_members', defaultValue: false))
        _SideItem(title: l10n.members, icon: Iconsax.people_bold, targetIndex: 10, targetRouteName: 'members'),
      if (isEnabled(ref, 'company_customers', defaultValue: false))
        _SideItem(title: l10n.customers, icon: Iconsax.user_tag_bold, targetIndex: 12, targetRouteName: 'customers'),
      if (isEnabled(ref, 'company_suppliers', defaultValue: false))
        _SideItem(title: l10n.suppliers, icon: Iconsax.shop_bold, targetIndex: 13, targetRouteName: 'suppliers'),
      if (isEnabled(ref, 'company_my_purchases', defaultValue: false))
        _SideItem(title: l10n.my_purchases, icon: FontAwesomeIcons.bagShopping, targetIndex: 14, targetRouteName: 'my_purchases'),

      if (hasTools) _SideItem.header(l10n.tools),
      if (isEnabled(ref, 'company_analytics', defaultValue: false))
        _SideItem(title: l10n.analytics, icon: Iconsax.chart_2_bold, targetIndex: 9, targetRouteName: 'analytics'),
      if (isEnabled(ref, 'company_systems', defaultValue: false))
        _SideItem(title: l10n.systems, icon: Iconsax.sun_1_bold, targetIndex: 11, targetRouteName: 'systems'),
      if (isEnabled(ref, 'company_delivery', defaultValue: false))
        _SideItem(title: l10n.delivery, icon: Icons.local_shipping_outlined, targetIndex: 15, targetRouteName: 'delivery'),

      _SideItem.header(l10n.settings),
      _SideItem(title: l10n.company_profile, icon: Iconsax.building_bold, targetIndex: 1, targetRouteName: 'profile'),
      _SideItem(title: l10n.subscription, icon: FontAwesomeIcons.star, targetIndex: 2, targetRouteName: 'subscription'),
    ];

    final bgColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

    return Container(
      width: isDesktop ? 280.w : double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
           right: BorderSide(color: dividerColor, width: 1.w),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            _buildLogoArea(context, l10n, isDark),
            SizedBox(height: 16.h),
            Divider(color: dividerColor, height: 1.h),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item.isHeader) {
                    return _buildHeader(item.title, isDark);
                  }
                  return _buildNavItem(
                    context,
                    ref,
                    item.title,
                    item.icon,
                    item.targetIndex,
                    item.targetRouteName,
                    currentIndex == item.targetIndex,
                    colorScheme,
                    isDark,
                  );
                },
              ),
            ),
            Divider(color: dividerColor, height: 1.h),
            _buildBottomActions(context, l10n, colorScheme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoArea(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLightColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Icon(Icons.solar_power, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              l10n.solar_hub,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, top: 28.h, bottom: 12.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          fontFamily: AppTheme.fontFamily,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    String title,
    IconData icon,
    int targetIndex,
    String targetRouteName,
    bool isSelected,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final activeColor = colorScheme.primary;
    final inactiveColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final textColor = isSelected ? activeColor : inactiveColor;
    
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      child: InkWell(
        onTap: () {
          ref.read(companyDashboardControllerProvider.notifier).changePage(targetIndex, targetRouteName, isSubscriptionActive: true);
          if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
            Navigator.of(context).pop();
          }
        },
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20.sp),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? activeColor : (isDark ? Colors.grey[300] : Colors.black87),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          _buildActionButton(context, l10n.switch_to_user_view, Iconsax.user_square_bold, () => context.go('/home'), isDark),
          _buildActionButton(context, l10n.settings, Iconsax.setting_2_bold, () => context.push('/settings'), isDark),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, VoidCallback onTap, bool isDark) {
    final inactiveColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, color: inactiveColor, size: 20.sp),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
