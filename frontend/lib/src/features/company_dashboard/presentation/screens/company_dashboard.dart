import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/nav_item.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/dashboard_content.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/sidebar_content.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/quick_create_actions.dart';
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
    Future.microtask(() => ref.read(companySummaryProvider.notifier).getSummary());
  }

  List<NavItem> _getNavItems(CompanySummaryState state) {
    final l10n = AppLocalizations.of(context)!;
    final List<NavItem> items = [
      NavItem(id: 'overview', label: l10n.overview, icon: Iconsax.grid_1),
      NavItem(id: 'services', label: l10n.services, icon: Iconsax.crown),
      NavItem(id: 'service_types', label: l10n.service_types, icon: Iconsax.gallery_edit, route: '/companies/dashboard/service-types'),
      NavItem(id: 'orders', label: l10n.orders, icon: Iconsax.receipt_1, route: '/companies/dashboard/orders'),
      NavItem(id: 'customers', label: l10n.customers, icon: Iconsax.people, route: '/companies/dashboard/customers'),
      NavItem(id: 'suppliers', label: l10n.suppliers, icon: Iconsax.buildings_2, route: '/companies/dashboard/suppliers'),
      NavItem(id: 'leads', label: l10n.leads, icon: Iconsax.status_up, route: '/companies/dashboard/leads'),
      NavItem(id: 'contacts', label: l10n.contacts, icon: Iconsax.call, route: '/companies/dashboard/contacts'),
      NavItem(id: 'public_services', label: l10n.company_public_services, icon: Iconsax.briefcase, route: '/companies/dashboard/public-services'),
      NavItem(id: 'categories', label: l10n.categories, icon: Iconsax.tag, route: '/companies/dashboard/categories'),
    ];
    bool hasActiveOffers = false;

    if (state.summary != null) {
      for (final service in state.summary!.services) {
        if (service.isActive) {
          if (service.serviceCode == 'offers') {
            hasActiveOffers = true;
          }
          NavItem? item;
          switch (service.serviceCode) {
            case 'offers':
              item = NavItem(id: 'offers', label: l10n.offers, icon: Iconsax.document, serviceCode: 'offers', iconUrl: service.icon, route: service.route);
              break;
            case 'inventory':
              item = NavItem(id: 'inventory', label: l10n.inventory, icon: Iconsax.box, serviceCode: 'inventory', iconUrl: service.icon, route: service.route);
              break;
            case 'company_work':
              if (state.hasReadPermission(AppStrings.projectsPermission)) {
                item = NavItem(
                  id: 'company_work',
                  label: l10n.company_work_title,
                  icon: Iconsax.gallery,
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
                icon: Iconsax.people,
                serviceCode: 'multi_member',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'accounting':
              item = NavItem(
                id: 'accounting',
                label: l10n.accounting,
                icon: Iconsax.money_2,
                serviceCode: 'accounting',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'analytics':
              item = NavItem(
                id: 'analytics',
                label: l10n.analytics,
                icon: Iconsax.chart_2,
                serviceCode: 'analytics',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'storefront_b2b':
              item = NavItem(
                id: 'storefront_b2b',
                label: l10n.b2b_storefront,
                icon: Iconsax.building_3,
                serviceCode: 'storefront_b2b',
                iconUrl: service.icon,
                route: service.route,
              );
              break;
            case 'storefront_b2c':
              item = NavItem(
                id: 'storefront_b2c',
                label: l10n.b2c_storefront,
                icon: Iconsax.shop,
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
      items.add(NavItem(id: 'offers_catalog', label: l10n.offers_catalog, icon: Iconsax.receipt_item, serviceCode: 'offers_catalog', route: '/offers/catalog'));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companySummaryProvider);
    final l10n = AppLocalizations.of(context)!;
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
            builder: (context) => IconButton(icon: const Icon(Iconsax.menu_1), onPressed: () => Scaffold.of(context).openDrawer()),
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
        drawer: Drawer(width: MediaQuery.of(context).size.width * 0.75, child: sidebar),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showQuickCreateSheet(context, state, l10n),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Iconsax.add, color: Colors.white),
        ),
        body: DashboardContent(index: _selectedIndex, navItems: navItems),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: 300.ms,
            width: sidebarWidth,
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
