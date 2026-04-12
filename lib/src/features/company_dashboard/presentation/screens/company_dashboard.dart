import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/nav_item.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summery_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/dashboard_content.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/sidebar_content.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

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
    Future.microtask(() => ref.read(companySummeryProvider.notifier).getSummery());
  }

  List<NavItem> _getNavItems(CompanySummeryState state) {
    final l10n = AppLocalizations.of(context)!;
    final List<NavItem> items = [NavItem(label: l10n.overview, icon: Iconsax.grid_1_bold), NavItem(label: l10n.services, icon: Iconsax.crown_bold)];
    bool hasActiveOffers = false;

    if (state.summery != null) {
      for (final service in state.summery!.services) {
        final bool isAvailable =
            service.status != null &&
            (service.status!.toLowerCase() == 'active' || service.status!.toLowerCase() == 'approved' || service.status!.toLowerCase() == 'string');

        if (isAvailable) {
          if (service.serviceCode == 'offers') {
            hasActiveOffers = true;
          }
          NavItem? item;
          switch (service.serviceCode) {
            case 'offers':
              item = NavItem(label: l10n.offers, icon: Iconsax.document_bold, serviceCode: 'offers', iconUrl: service.icon, route: service.route);
              break;
            case 'inventory':
              item = NavItem(label: l10n.inventory, icon: Iconsax.box_bold, serviceCode: 'inventory', iconUrl: service.icon, route: service.route);
              break;
            case 'multi_member':
              item = NavItem(label: l10n.members, icon: Iconsax.people_bold, serviceCode: 'multi_member', iconUrl: service.icon, route: service.route);
              break;
            case 'accounting':
              item = NavItem(label: l10n.accounting, icon: Iconsax.money_2_bold, serviceCode: 'accounting', iconUrl: service.icon, route: service.route);
              break;
            case 'analytics':
              item = NavItem(label: l10n.analytics, icon: Iconsax.chart_2_bold, serviceCode: 'analytics', iconUrl: service.icon, route: service.route);
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
              item = NavItem(label: l10n.b2c_storefront, icon: Iconsax.shop_bold, serviceCode: 'storefront_b2c', iconUrl: service.icon, route: service.route);
              break;
          }
          if (item != null) items.add(item);
        }
      }
    }
    if (hasActiveOffers) {
      items.add(NavItem(label: l10n.offers_catalog, icon: Iconsax.receipt_item_bold, serviceCode: 'offers_catalog', route: '/offers/catalog'));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companySummeryProvider);
    final navItems = _getNavItems(state);
    final isMobile = AppBreakpoints.isMobile(context);
    final isTablet = AppBreakpoints.isTablet(context);
    final sidebarWidth = isTablet ? 220.0 : 280.0;

    // Ensure selected index is valid
    if (_selectedIndex >= navItems.length) {
      _selectedIndex = 0;
    }

    final sidebar = SidebarContent(
      navItems: navItems,
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        final item = navItems[index];
        if (item.route != null && item.route!.isNotEmpty && item.route != 'null') {
          final extra = item.route == 'storefront' ? StorefrontAudience.b2b : null;
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
            builder: (context) => IconButton(icon: const Icon(Iconsax.menu_1_bold), onPressed: () => Scaffold.of(context).openDrawer()),
          ),
          actions: [
            if (state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
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
          Container(
            width: sidebarWidth.w,
            decoration: BoxDecoration(
              color: AppTheme.lightSurface,
              border: Border(right: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(4, 0))],
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
}
