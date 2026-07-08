import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/company_dashboard/domain/entities/service.dart';
import 'package:watt/src/utils/app_strings.dart';
import 'package:watt/src/features/company_dashboard/presentation/models/company_workspace_item.dart';
import 'package:watt/src/features/company_dashboard/presentation/providers/summary_provider.dart';

class CompanyWorkspaceModules {
  static CompanyWorkspaceItem overview(AppLocalizations l10n) =>
      CompanyWorkspaceItem(id: 'overview', label: l10n.overview, subtitle: l10n.quick_stats, route: '/companies/dashboard', icon: Iconsax.grid_1);

  static CompanyWorkspaceItem profile(AppLocalizations l10n) => CompanyWorkspaceItem(
    id: 'profile',
    label: l10n.company_profile,
    subtitle: l10n.company_profile_subtitle,
    route: '/auth/company_registration',
    icon: Iconsax.edit_2,
    externalRoute: '/auth/company_registration',
  );

  static CompanyWorkspaceItem services(AppLocalizations l10n) => CompanyWorkspaceItem(
    id: 'services',
    label: l10n.services,
    subtitle: l10n.section_label(l10n.services),
    route: '/companies/dashboard/services',
    icon: Iconsax.category_2,
  );

  static CompanyWorkspaceItem serviceTypes(AppLocalizations l10n) => CompanyWorkspaceItem(
    id: 'service_types',
    label: l10n.service_types,
    subtitle: l10n.service_types_company_subtitle,
    route: '/companies/dashboard/service-types',
    icon: Iconsax.gallery_edit,
  );

  static CompanyWorkspaceItem contacts(AppLocalizations l10n) => CompanyWorkspaceItem(
    id: 'contacts',
    label: l10n.contacts,
    subtitle: l10n.company_contacts_subtitle,
    route: '/companies/dashboard/contacts',
    icon: Iconsax.call,
  );

  static CompanyWorkspaceItem orders(AppLocalizations l10n) => CompanyWorkspaceItem(
    id: 'orders',
    label: l10n.orders,
    subtitle: l10n.manage_orders_subtitle,
    route: '/companies/dashboard/orders',
    icon: Iconsax.receipt_1,
  );

  static CompanyWorkspaceItem customers(AppLocalizations l10n) => CompanyWorkspaceItem(
    id: 'customers',
    label: l10n.customers,
    subtitle: l10n.manage_customers_subtitle,
    route: '/companies/dashboard/customers',
    icon: Iconsax.people,
  );

  static CompanyWorkspaceItem suppliers(AppLocalizations l10n) => CompanyWorkspaceItem(
    id: 'suppliers',
    label: l10n.suppliers,
    subtitle: l10n.manage_suppliers_subtitle,
    route: '/companies/dashboard/suppliers',
    icon: Iconsax.buildings_2,
  );

  static CompanyWorkspaceItem publicServices(AppLocalizations l10n) => CompanyWorkspaceItem(
    id: 'public_services',
    label: l10n.company_public_services,
    subtitle: l10n.company_public_services_subtitle,
    route: '/companies/dashboard/public-services',
    icon: Iconsax.briefcase,
  );

  static CompanyWorkspaceItem categories(AppLocalizations l10n) => CompanyWorkspaceItem(
    id: 'categories',
    label: l10n.categories,
    subtitle: l10n.company_categories_subtitle,
    route: '/companies/dashboard/categories',
    icon: Iconsax.tag,
  );

  static List<CompanyWorkspaceItem> build(AppLocalizations l10n, CompanySummaryState state) {
    final items = <CompanyWorkspaceItem>[
      overview(l10n),
      profile(l10n),
      services(l10n),
      serviceTypes(l10n),
      orders(l10n),
      customers(l10n),
      suppliers(l10n),
      contacts(l10n),
      publicServices(l10n),
      categories(l10n),
    ];

    final servicesList = [...?state.summary?.services];
    final hasActiveOffers = servicesList.any((service) => service.serviceCode == 'offers' && _isServiceActive(service.status));
    final hasActiveInventory = servicesList.any((service) => service.serviceCode == 'inventory' && _isServiceActive(service.status));
    final hasActiveAccounting = servicesList.any((service) => service.serviceCode == 'accounting' && _isServiceActive(service.status));

    for (final service in servicesList) {
      if (!_isServiceActive(service.status)) continue;
      if (service.serviceCode == 'company_work' && !state.hasReadPermission(AppStrings.projectsPermission)) {
        continue;
      }
      final item = fromService(l10n, service);
      if (item != null) items.add(item);
    }

    if (hasActiveOffers) {
      items.add(
        CompanyWorkspaceItem(
          id: 'offers_catalog',
          label: l10n.offers_catalog,
          subtitle: l10n.section_label(l10n.offers_catalog),
          route: '/companies/dashboard/services',
          icon: Iconsax.receipt_item,
          serviceCode: 'offers_catalog',
          externalRoute: '/offers/catalog',
        ),
      );
    }

    // Delivery and Expenses aren't their own services (see the comment in
    // `fromService()`), so they're surfaced here instead, gated on the
    // parent service being active AND the member's role having read access
    // to that specific sub-resource — matching how `overview_content.dart`
    // already gates its stat tiles (e.g. `hasReadPermission('contacts')`).
    if (hasActiveInventory && state.hasReadPermission(AppStrings.deliveryPermission)) {
      items.add(
        CompanyWorkspaceItem(
          id: 'delivery',
          label: l10n.delivery,
          subtitle: l10n.section_label(l10n.delivery),
          route: '/companies/dashboard/delivery',
          icon: Icons.local_shipping_outlined,
          serviceCode: 'delivery',
          externalRoute: '/companies/dashboard/delivery',
        ),
      );
    }
    if (hasActiveAccounting && state.hasReadPermission(AppStrings.accountantPermission)) {
      items.add(
        CompanyWorkspaceItem(
          id: 'expenses',
          label: l10n.expenses,
          subtitle: l10n.section_label(l10n.expenses),
          route: '/companies/dashboard/expenses',
          icon: Iconsax.money_2,
          serviceCode: 'expenses',
          externalRoute: '/companies/dashboard/expenses',
        ),
      );
    }

    return items;
  }

  static CompanyWorkspaceItem activeForLocation(String location, AppLocalizations l10n) {
    if (location.startsWith('/auth/company_registration')) {
      return profile(l10n);
    }
    if (location.startsWith('/companies/dashboard/services')) {
      return services(l10n);
    }
    if (location.startsWith('/companies/dashboard/service-types')) {
      return serviceTypes(l10n);
    }
    if (location.startsWith('/companies/dashboard/members') || location.startsWith('/members')) {
      return CompanyWorkspaceItem(
        id: 'members',
        label: l10n.members,
        subtitle: l10n.section_label(l10n.members),
        route: '/companies/dashboard/services',
        icon: Iconsax.people,
        serviceCode: 'multi_member',
        externalRoute: '/members',
      );
    }
    if (location.startsWith('/companies/dashboard/contacts')) {
      return contacts(l10n);
    }
    if (location.startsWith('/companies/dashboard/orders')) {
      return orders(l10n);
    }
    if (location.startsWith('/companies/dashboard/customers')) {
      return customers(l10n);
    }
    if (location.startsWith('/companies/dashboard/suppliers')) {
      return suppliers(l10n);
    }
    if (location.startsWith('/companies/dashboard/public-services')) {
      return publicServices(l10n);
    }
    if (location.startsWith('/companies/dashboard/accounting')) {
      return CompanyWorkspaceItem(
        id: 'accounting',
        label: l10n.accounting,
        subtitle: l10n.manage_accounting_subtitle,
        route: '/companies/dashboard/accounting',
        icon: Iconsax.money_2,
      );
    }
    if (location.startsWith('/companies/dashboard/delivery')) {
      return CompanyWorkspaceItem(
        id: 'delivery',
        label: l10n.delivery,
        subtitle: l10n.section_label(l10n.delivery),
        route: '/companies/dashboard/delivery',
        icon: Icons.local_shipping_outlined,
      );
    }
    if (location.startsWith('/companies/dashboard/expenses')) {
      return CompanyWorkspaceItem(
        id: 'expenses',
        label: l10n.expenses,
        subtitle: l10n.section_label(l10n.expenses),
        route: '/companies/dashboard/expenses',
        icon: Iconsax.money_2,
      );
    }
    if (location.startsWith('/companies/dashboard/systems')) {
      return CompanyWorkspaceItem(
        id: 'systems',
        label: l10n.systems,
        subtitle: l10n.section_label(l10n.systems),
        route: '/companies/dashboard/systems',
        icon: Iconsax.flash_1,
      );
    }
    if (location.startsWith('/companies/dashboard/categories')) {
      return categories(l10n);
    }
    if (location.startsWith('/company-work')) {
      return CompanyWorkspaceItem(
        id: 'company_work',
        label: l10n.company_work_title,
        subtitle: l10n.company_work_subtitle,
        route: '/companies/dashboard/services',
        icon: Iconsax.gallery,
        serviceCode: 'company_work',
        externalRoute: '/company-work',
      );
    }
    return overview(l10n);
  }

  static CompanyWorkspaceItem? fromService(AppLocalizations l10n, CompanyService service) {
    switch (service.serviceCode) {
      case 'offers':
        return CompanyWorkspaceItem(
          id: 'offers',
          label: l10n.offers,
          subtitle: l10n.section_label(l10n.offers),
          route: '/companies/dashboard/services',
          icon: Iconsax.document,
          iconUrl: service.icon,
          serviceCode: service.serviceCode,
          externalRoute: _normalizeExternalRoute(service.route),
        );
      case 'inventory':
        return CompanyWorkspaceItem(
          id: 'inventory',
          label: l10n.inventory,
          subtitle: l10n.section_label(l10n.inventory),
          route: '/companies/dashboard/services',
          icon: Iconsax.box,
          iconUrl: service.icon,
          serviceCode: service.serviceCode,
          externalRoute: _normalizeExternalRoute(service.route),
        );
      case 'company_work':
        return CompanyWorkspaceItem(
          id: 'company_work',
          label: l10n.company_work_title,
          subtitle: l10n.company_work_subtitle,
          route: '/companies/dashboard/services',
          icon: Iconsax.gallery,
          iconUrl: service.icon,
          serviceCode: service.serviceCode,
          externalRoute: '/company-work',
        );
      case 'multi_member':
        return CompanyWorkspaceItem(
          id: 'members',
          label: l10n.members,
          subtitle: l10n.section_label(l10n.members),
          route: '/companies/dashboard/services',
          icon: Iconsax.people,
          iconUrl: service.icon,
          serviceCode: service.serviceCode,
          externalRoute: _normalizeExternalRoute(service.route),
        );
      case 'accounting':
        return CompanyWorkspaceItem(
          id: 'accounting',
          label: l10n.accounting,
          subtitle: l10n.manage_accounting_subtitle,
          route: '/companies/dashboard/accounting',
          icon: Iconsax.money_2,
          iconUrl: service.icon,
          serviceCode: service.serviceCode,
          externalRoute: '/companies/dashboard/accounting',
        );
      // Delivery and Expenses are NOT their own toggleable backend
      // services — they're sub-resources gated under the 'inventory' and
      // 'accounting' service codes respectively (confirmed by reading
      // `check_company_service_access(..., 'inventory', 'delivery', ...)`
      // and `check_company_service_access(..., 'accounting', 'accountant',
      // ...)` in the backend). So they can never appear as a distinct
      // `service.serviceCode` here — they're added conditionally in
      // `build()` instead, alongside the existing `offers_catalog`
      // synthetic-item pattern. `systems_portfolio` below IS a real,
      // distinct service code, so it's handled the normal way.
      case 'systems_portfolio':
        return CompanyWorkspaceItem(
          id: 'systems',
          label: l10n.systems,
          subtitle: l10n.section_label(l10n.systems),
          route: '/companies/dashboard/systems',
          icon: Iconsax.flash_1,
          iconUrl: service.icon,
          serviceCode: service.serviceCode,
          externalRoute: '/companies/dashboard/systems',
        );
      case 'analytics':
        return CompanyWorkspaceItem(
          id: 'analytics',
          label: l10n.analytics,
          subtitle: l10n.section_label(l10n.analytics),
          route: '/companies/dashboard/services',
          icon: Iconsax.chart_2,
          iconUrl: service.icon,
          serviceCode: service.serviceCode,
          externalRoute: _normalizeExternalRoute(service.route),
        );
      case 'storefront_b2b':
        return CompanyWorkspaceItem(
          id: 'storefront_b2b',
          label: l10n.b2b_storefront,
          subtitle: l10n.section_label(l10n.b2b_storefront),
          route: '/companies/dashboard/services',
          icon: Iconsax.building_3,
          iconUrl: service.icon,
          serviceCode: service.serviceCode,
          externalRoute: _normalizeExternalRoute(service.route),
        );
      case 'storefront_b2c':
        return CompanyWorkspaceItem(
          id: 'storefront_b2c',
          label: l10n.b2c_storefront,
          subtitle: l10n.section_label(l10n.b2c_storefront),
          route: '/companies/dashboard/services',
          icon: Iconsax.shop,
          iconUrl: service.icon,
          serviceCode: service.serviceCode,
          externalRoute: _normalizeExternalRoute(service.route),
        );
    }

    return null;
  }

  static bool _isServiceActive(String? status) {
    return CompanyService.isServiceActive(status);
  }

  static String? _normalizeExternalRoute(String? route) {
    if (route == null || route.isEmpty || route == 'null') return null;
    return route.startsWith('/') ? route : '/$route';
  }
}
