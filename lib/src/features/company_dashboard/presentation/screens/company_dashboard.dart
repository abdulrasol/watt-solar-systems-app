import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/nav_item.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/dashboard_content.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/sidebar_content.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

import 'package:solar_hub/src/utils/app_strings.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/sidebar_controller.dart';

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
      () => ref.read(companySummaryProvider.notifier).getSummary(),
    );
  }

  List<NavItem> _getNavItems(CompanySummaryState state) {
    final l10n = AppLocalizations.of(context)!;
    final List<NavItem> items = [
      NavItem(id: 'overview', label: l10n.overview, icon: Iconsax.grid_1_bold),
      NavItem(id: 'services', label: l10n.services, icon: Iconsax.crown_bold),
      NavItem(
        id: 'service_types',
        label: l10n.service_types,
        icon: Iconsax.gallery_edit_bold,
        route: '/companies/dashboard/service-types',
      ),
      NavItem(
        id: 'orders',
        label: l10n.orders,
        icon: Iconsax.receipt_1_bold,
        route: '/companies/dashboard/orders',
      ),
      NavItem(
        id: 'customers',
        label: l10n.customers,
        icon: Iconsax.people_bold,
        route: '/companies/dashboard/customers',
      ),
      NavItem(
        id: 'suppliers',
        label: l10n.suppliers,
        icon: Iconsax.buildings_2_bold,
        route: '/companies/dashboard/suppliers',
      ),
      NavItem(
        id: 'leads',
        label: l10n.leads,
        icon: Iconsax.status_up_bold,
        route: '/companies/dashboard/leads',
      ),
      NavItem(
        id: 'contacts',
        label: l10n.contacts,
        icon: Iconsax.call_bold,
        route: '/companies/dashboard/contacts',
      ),
      NavItem(
        id: 'public_services',
        label: l10n.company_public_services,
        icon: Iconsax.briefcase_bold,
        route: '/companies/dashboard/public-services',
      ),
      NavItem(
        id: 'categories',
        label: l10n.categories,
        icon: Iconsax.tag_bold,
        route: '/companies/dashboard/categories',
      ),
    ];
    bool hasActiveOffers = false;

    if (state.summary != null) {
      for (final service in state.summary!.services) {
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
                id: 'offers',
                label: l10n.offers,
                icon: Iconsax.document_bold,
                serviceCode: 'offers',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'inventory':
              item = NavItem(
                id: 'inventory',
                label: l10n.inventory,
                icon: Iconsax.box_bold,
                serviceCode: 'inventory',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'company_work':
              if (state.hasReadPermission(AppStrings.projectsPermission)) {
                item = NavItem(
                  id: 'company_work',
                  label: l10n.company_work_title,
                  icon: Iconsax.gallery_bold,
                  serviceCode: 'company_work',
                  iconUrl: service.icon,
                  route: '/company-work',
                );
              }
              break;
            case 'multi_member':
              item = NavItem(
                id: 'multi_member',
                label: l10n.members,
                icon: Iconsax.people_bold,
                serviceCode: 'multi_member',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'accounting':
              item = NavItem(
                id: 'accounting',
                label: l10n.accounting,
                icon: Iconsax.money_2_bold,
                serviceCode: 'accounting',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'analytics':
              item = NavItem(
                id: 'analytics',
                label: l10n.analytics,
                icon: Iconsax.chart_2_bold,
                serviceCode: 'analytics',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'storefront_b2b':
              item = NavItem(
                id: 'storefront_b2b',
                label: l10n.b2b_storefront,
                icon: Iconsax.building_3_bold,
                serviceCode: 'storefront_b2b',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'storefront_b2c':
              item = NavItem(
                id: 'storefront_b2c',
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
          id: 'offers_catalog',
          label: l10n.offers_catalog,
          icon: Iconsax.receipt_item_bold,
          serviceCode: 'offers_catalog',
          route: '/offers/catalog',
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companySummaryProvider);
    final isCollapsed = ref.watch(sidebarControllerProvider);
    final navItems = _getNavItems(state);
    final isMobile = AppBreakpoints.isMobile(context);
    final isTablet = AppBreakpoints.isTablet(context);
    final sidebarFullWidth = isTablet ? 220.0 : 260.0;
    final sidebarWidth = isCollapsed ? 80.0 : sidebarFullWidth;

    // Ensure selected index is valid
    if (_selectedIndex >= navItems.length) {
      _selectedIndex = 0;
    }

    final sidebar = SidebarContent(
      navItems: navItems,
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        final item = navItems[index];
        if (item.route != null &&
            item.route!.isNotEmpty &&
            item.route != 'null') {
          final extra = item.route == 'storefront'
              ? StorefrontAudience.b2b
              : null;
          context.push(item.route!, extra: extra);

          dPrint('item.route! ${item.route}');
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showQuickCreate(context),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Iconsax.add_bold, color: Colors.white),
        ),
        body: DashboardContent(index: _selectedIndex, navItems: navItems),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: 300.ms,
            width: sidebarWidth.w,
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
          Expanded(
            child: DashboardContent(index: _selectedIndex, navItems: navItems),
          ),
        ],
      ),
    );
  }

  void _showQuickCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Create',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            SizedBox(height: 24.h),
            _buildActionItem(
              context,
              icon: Iconsax.box_bold,
              label: 'Add Product',
              onTap: () {
                Navigator.pop(context);
                context.push('/inventory/add');
              },
            ),
            _buildActionItem(
              context,
              icon: Iconsax.people_bold,
              label: 'Invite Member',
              onTap: () {
                Navigator.pop(context);
                context.push('/companies/dashboard/members');
              },
            ),
            _buildActionItem(
              context,
              icon: Iconsax.document_bold,
              label: 'Create Offer',
              onTap: () {
                Navigator.pop(context);
                context.push('/offers');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
      onTap: onTap,
    );
  }
}
