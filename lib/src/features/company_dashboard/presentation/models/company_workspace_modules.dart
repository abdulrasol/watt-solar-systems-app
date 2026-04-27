import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/service.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/company_workspace_item.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summery_provider.dart';

class CompanyWorkspaceModules {
  static CompanyWorkspaceItem overview(AppLocalizations l10n) =>
      CompanyWorkspaceItem(
        id: 'overview',
        label: l10n.overview,
        subtitle: l10n.quick_stats,
        route: '/companies/dashboard',
        icon: Iconsax.grid_1_bold,
      );

  static CompanyWorkspaceItem profile(AppLocalizations l10n) =>
      CompanyWorkspaceItem(
        id: 'profile',
        label: l10n.company_profile,
        subtitle: l10n.company_profile_subtitle,
        route: '/auth/company_registration',
        icon: Iconsax.edit_2_bold,
        externalRoute: '/auth/company_registration',
      );

  static CompanyWorkspaceItem services(AppLocalizations l10n) =>
      CompanyWorkspaceItem(
        id: 'services',
        label: l10n.services,
        subtitle: l10n.section_label(l10n.services),
        route: '/companies/dashboard/services',
        icon: Iconsax.category_2_bold,
      );

  static CompanyWorkspaceItem serviceTypes(AppLocalizations l10n) =>
      CompanyWorkspaceItem(
        id: 'service_types',
        label: l10n.service_types,
        subtitle: l10n.service_types_company_subtitle,
        route: '/companies/dashboard/service-types',
        icon: Iconsax.gallery_edit_bold,
      );

  static CompanyWorkspaceItem contacts(AppLocalizations l10n) =>
      CompanyWorkspaceItem(
        id: 'contacts',
        label: l10n.contacts,
        subtitle: l10n.company_contacts_subtitle,
        route: '/companies/dashboard/contacts',
        icon: Iconsax.call_bold,
      );

  static CompanyWorkspaceItem orders(AppLocalizations l10n) =>
      CompanyWorkspaceItem(
        id: 'orders',
        label: l10n.orders,
        subtitle: l10n.manage_orders_subtitle,
        route: '/companies/dashboard/orders',
        icon: Iconsax.receipt_1_bold,
      );

  static CompanyWorkspaceItem customers(AppLocalizations l10n) =>
      CompanyWorkspaceItem(
        id: 'customers',
        label: l10n.customers,
        subtitle: l10n.manage_customers_subtitle,
        route: '/companies/dashboard/customers',
        icon: Iconsax.people_bold,
      );

  static CompanyWorkspaceItem suppliers(AppLocalizations l10n) =>
      CompanyWorkspaceItem(
        id: 'suppliers',
        label: l10n.suppliers,
        subtitle: l10n.manage_suppliers_subtitle,
        route: '/companies/dashboard/suppliers',
        icon: Iconsax.buildings_2_bold,
      );

  static CompanyWorkspaceItem publicServices(AppLocalizations l10n) =>
      CompanyWorkspaceItem(
        id: 'public_services',
        label: l10n.company_public_services,
        subtitle: l10n.company_public_services_subtitle,
        route: '/companies/dashboard/public-services',
        icon: Iconsax.briefcase_bold,
      );

  static CompanyWorkspaceItem categories(AppLocalizations l10n) =>
      CompanyWorkspaceItem(
        id: 'categories',
        label: l10n.categories,
        subtitle: l10n.company_categories_subtitle,
        route: '/companies/dashboard/categories',
        icon: Iconsax.tag_bold,
      );

  static List<CompanyWorkspaceItem> build(
    AppLocalizations l10n,
    CompanySummeryState state,
  ) {
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

    final servicesList = [...?state.summery?.services];
    final hasActiveOffers = servicesList.any(
      (service) =>
          service.serviceCode == 'offers' && _isServiceActive(service.status),
    );

    for (final service in servicesList) {
      if (!_isServiceActive(service.status)) continue;
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
          icon: Iconsax.receipt_item_bold,
          serviceCode: 'offers_catalog',
          externalRoute: '/offers/catalog',
        ),
      );
    }

    return items;
  }

  static CompanyWorkspaceItem activeForLocation(
    String location,
    AppLocalizations l10n,
  ) {
    if (location.startsWith('/auth/company_registration')) {
      return profile(l10n);
    }
    if (location.startsWith('/companies/dashboard/services')) {
      return services(l10n);
    }
    if (location.startsWith('/companies/dashboard/service-types')) {
      return serviceTypes(l10n);
    }
    if (location.startsWith('/companies/dashboard/members') ||
        location.startsWith('/members')) {
      return CompanyWorkspaceItem(
        id: 'members',
        label: l10n.members,
        subtitle: l10n.section_label(l10n.members),
        route: '/companies/dashboard/services',
        icon: Iconsax.people_bold,
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
        icon: Iconsax.money_2_bold,
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
        icon: Iconsax.gallery_bold,
        serviceCode: 'company_work',
        externalRoute: '/company-work',
      );
    }
    return overview(l10n);
  }

  static CompanyWorkspaceItem? fromService(
    AppLocalizations l10n,
    CompanyService service,
  ) {
    switch (service.serviceCode) {
      case 'offers':
        return CompanyWorkspaceItem(
          id: 'offers',
          label: l10n.offers,
          subtitle: l10n.section_label(l10n.offers),
          route: '/companies/dashboard/services',
          icon: Iconsax.document_bold,
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
          icon: Iconsax.box_bold,
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
          icon: Iconsax.gallery_bold,
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
          icon: Iconsax.people_bold,
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
          icon: Iconsax.money_2_bold,
          iconUrl: service.icon,
          serviceCode: service.serviceCode,
          externalRoute: '/companies/dashboard/accounting',
        );
      case 'analytics':
        return CompanyWorkspaceItem(
          id: 'analytics',
          label: l10n.analytics,
          subtitle: l10n.section_label(l10n.analytics),
          route: '/companies/dashboard/services',
          icon: Iconsax.chart_2_bold,
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
          icon: Iconsax.building_3_bold,
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
          icon: Iconsax.shop_bold,
          iconUrl: service.icon,
          serviceCode: service.serviceCode,
          externalRoute: _normalizeExternalRoute(service.route),
        );
    }

    return null;
  }

  static bool _isServiceActive(String? status) {
    final value = status?.toLowerCase();
    return value == 'active' || value == 'approved' || value == 'string';
  }

  static String? _normalizeExternalRoute(String? route) {
    if (route == null || route.isEmpty || route == 'null') return null;
    return route.startsWith('/') ? route : '/$route';
  }
}
