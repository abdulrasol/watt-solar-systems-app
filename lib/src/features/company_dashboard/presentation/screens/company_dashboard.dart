import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/nav_item.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summery_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/dashboard_content.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyDashboard extends ConsumerStatefulWidget {
  const CompanyDashboard({super.key});

  @override
  ConsumerState<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends ConsumerState<CompanyDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch data on init
    Future.microtask(
      () => ref.read(companySummeryProvider.notifier).getSummery(),
    );
  }

  List<NavItem> _getNavItems(CompanySummeryState state) {
    final l10n = AppLocalizations.of(context)!;
    final List<NavItem> items = [
      NavItem(label: l10n.overview, icon: Iconsax.grid_1_bold),
      NavItem(label: l10n.services, icon: Iconsax.crown_bold),
    ];
    bool hasActiveOffers = false;

    if (state.summery != null) {
      for (final service in state.summery!.services) {
        final bool isAvailable =
            service.status != null &&
            (service.status!.toLowerCase() == 'active' ||
                service.status!.toLowerCase() == 'approved' ||
                service.status!.toLowerCase() == 'string');

        if (isAvailable) {
          if (service.serviceCode == 'offers') {
            hasActiveOffers = true;
          }
          NavItem? item;
          switch (service.serviceCode) {
            case 'offers':
              item = NavItem(
                label: l10n.offers,
                icon: Iconsax.document_bold,
                serviceCode: 'offers',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'inventory':
              item = NavItem(
                label: l10n.inventory,
                icon: Iconsax.box_bold,
                serviceCode: 'inventory',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'multi_member':
              item = NavItem(
                label: l10n.members,
                icon: Iconsax.people_bold,
                serviceCode: 'multi_member',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'accounting':
              item = NavItem(
                label: l10n.accounting,
                icon: Iconsax.money_2_bold,
                serviceCode: 'accounting',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'analytics':
              item = NavItem(
                label: l10n.analytics,
                icon: Iconsax.chart_2_bold,
                serviceCode: 'analytics',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'storefront_b2b':
              item = NavItem(
                label: l10n.b2b_storefront,
                icon: Iconsax.building_3_bold,
                serviceCode: 'storefront_b2b',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'storefront_b2c':
              item = NavItem(
                label: l10n.b2c_storefront,
                icon: Iconsax.shop_bold,
                serviceCode: 'storefront_b2c',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
          }
          if (item != null) items.add(item);
        }
      }
    }
    if (hasActiveOffers) {
      items.add(
        NavItem(
          label: _isArabic(context) ? 'كتالوج الرسوم' : 'Offers Catalog',
          icon: Iconsax.receipt_item_bold,
          serviceCode: 'offers_catalog',
          route: '/offers/catalog',
        ),
      );
    }
    return items;
  }

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companySummeryProvider);
    final navItems = _getNavItems(state);
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isMobile = shortestSide < 600;

    // Ensure selected index is valid
    if (_selectedIndex >= navItems.length) {
      _selectedIndex = 0;
    }

    final sidebar = _SidebarContent(
      navItems: navItems,
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        final item = navItems[index];
        if (item.route != null &&
            item.route!.isNotEmpty &&
            item.route != 'null') {
          context.push(item.route!);
          if (isMobile) Navigator.pop(context);
        } else {
          setState(() => _selectedIndex = index);
          if (isMobile) Navigator.pop(context);
        }
      },
    );

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(navItems[_selectedIndex].label),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Iconsax.menu_1_bold),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            if (state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        drawer: Drawer(width: 0.75.sw, child: sidebar),
        body: DashboardContent(index: _selectedIndex, navItems: navItems),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Persistent Sidebar
          Container(
            width: 250.w,
            decoration: BoxDecoration(
              color: AppTheme.lightSurface,
              border: Border(
                right: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: sidebar,
          ),
          // Main content
          Expanded(
            child: DashboardContent(index: _selectedIndex, navItems: navItems),
          ),
        ],
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final List<NavItem> navItems;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const _SidebarContent({
    required this.navItems,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 50.h),
        // Branding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Iconsax.sun_1_bold,
                  color: AppTheme.primaryColor,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Solar Hub',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryDarkColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40.h),
        // Nav Items
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: navItems.length,
            itemBuilder: (context, index) {
              final item = navItems[index];
              final isSelected = selectedIndex == index;
              final bool hasCustomIcon =
                  item.iconUrl != null &&
                  item.iconUrl!.isNotEmpty &&
                  item.iconUrl != 'null';

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: InkWell(
                  onTap: () => onItemSelected(index),
                  borderRadius: BorderRadius.circular(12.r),
                  child: AnimatedContainer(
                    duration: 300.ms,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        hasCustomIcon
                            ? WdImagePreview(
                                imageUrl: item.iconUrl!,
                                size: 18,
                                shape: BoxShape.circle,
                              )
                            : Icon(
                                item.icon,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                size: 20.sp,
                              ),
                        SizedBox(width: 12.w),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // User Profile (Bottom)
        Padding(
          padding: EdgeInsets.all(20.r),
          child: InkWell(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.go('/home');
            },
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppTheme.lightBackground,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.2,
                    ),
                    child: Icon(
                      Iconsax.user_bold,
                      size: 18.sp,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.admin_user,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.super_admin,
                          style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Iconsax.logout_1_bold,
                    size: 18.sp,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
