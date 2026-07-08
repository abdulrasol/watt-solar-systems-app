import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/company_dashboard/presentation/models/navigation/company_navigation_item.dart';
import 'package:watt/src/features/company_dashboard/presentation/models/navigation/company_navigation_section.dart';
import 'package:watt/src/core/flags/feature_flags.dart';
import 'package:watt/src/utils/helper_methods.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Central registry for company dashboard navigation sections.
///
/// This is the single source of truth for the sidebar and bottom navigation.
class CompanyNavigationRegistry {
  const CompanyNavigationRegistry._();

  static List<CompanyNavigationSection> build(AppLocalizations l10n, WidgetRef ref) {
    return [
      _overviewSection(l10n),
      if (isFeatureEnabled(ref, AppFeature.companySales)) _salesSection(l10n, ref),
      if (isFeatureEnabled(ref, AppFeature.companyInventory)) _inventorySection(l10n, ref),
      if (isFeatureEnabled(ref, AppFeature.companyOrders)) _ordersSection(l10n, ref),
      if (isFeatureEnabled(ref, AppFeature.companyContent)) _contentSection(l10n, ref),
      if (isFeatureEnabled(ref, AppFeature.companyFinance)) _financeSection(l10n, ref),
      _settingsSection(l10n, ref),
    ];
  }

  static CompanyNavigationSection _overviewSection(AppLocalizations l10n) {
    return CompanyNavigationSection(
      id: 'overview',
      label: l10n.overview,
      icon: Iconsax.element_3,
      defaultRoute: '/companies/dashboard',
      items: const [
        CompanyNavigationItem(
          id: 'overview_home',
          label: 'الرئيسية',
          route: '/companies/dashboard',
          icon: Iconsax.element_3,
        ),
      ],
    );
  }

  static CompanyNavigationSection _salesSection(AppLocalizations l10n, WidgetRef ref) {
    return CompanyNavigationSection(
      id: 'sales',
      label: l10n.sales,
      icon: Iconsax.money_change,
      defaultRoute: '/companies/dashboard/sales/offers',
      items: [
        if (isFeatureEnabled(ref, AppFeature.offers))
          CompanyNavigationItem(
            id: 'offers',
            label: l10n.offers,
            route: '/companies/dashboard/sales/offers',
            icon: Iconsax.document_text,
          ),
        CompanyNavigationItem(
          id: 'requests',
          label: l10n.my_requests,
          route: '/companies/dashboard/sales/requests',
          icon: Iconsax.task_square,
        ),
        if (isFeatureEnabled(ref, AppFeature.companyCrm))
          CompanyNavigationItem(
            id: 'customers',
            label: l10n.customers,
            route: '/companies/dashboard/sales/customers',
            icon: Iconsax.people,
          ),
      ],
    );
  }

  static CompanyNavigationSection _inventorySection(AppLocalizations l10n, WidgetRef ref) {
    return CompanyNavigationSection(
      id: 'inventory',
      label: l10n.inventory,
      icon: Iconsax.box,
      defaultRoute: '/companies/dashboard/inventory/products',
      items: [
        if (isFeatureEnabled(ref, AppFeature.companyProducts))
          CompanyNavigationItem(
            id: 'products',
            label: l10n.products,
            route: '/companies/dashboard/inventory/products',
            icon: Iconsax.box_1,
          ),
        CompanyNavigationItem(
          id: 'categories',
          label: l10n.categories,
          route: '/companies/dashboard/inventory/categories',
          icon: Iconsax.tag,
        ),
        CompanyNavigationItem(
          id: 'suppliers',
          label: l10n.suppliers,
          route: '/companies/dashboard/inventory/suppliers',
          icon: Iconsax.buildings_2,
        ),
      ],
    );
  }

  static CompanyNavigationSection _ordersSection(AppLocalizations l10n, WidgetRef ref) {
    return CompanyNavigationSection(
      id: 'orders',
      label: l10n.orders,
      icon: Iconsax.truck_fast,
      defaultRoute: '/companies/dashboard/orders/list',
      items: [
        CompanyNavigationItem(
          id: 'orders_list',
          label: l10n.orders,
          route: '/companies/dashboard/orders/list',
          icon: Iconsax.receipt_item,
        ),
        CompanyNavigationItem(
          id: 'delivery',
          label: l10n.delivery,
          route: '/companies/dashboard/orders/delivery',
          icon: Iconsax.truck,
        ),
      ],
    );
  }

  static CompanyNavigationSection _contentSection(AppLocalizations l10n, WidgetRef ref) {
    return CompanyNavigationSection(
      id: 'content',
      label: l10n.content_and_ads,
      icon: Iconsax.gallery,
      defaultRoute: '/companies/dashboard/content/works',
      items: [
        CompanyNavigationItem(
          id: 'works',
          label: l10n.company_work_title,
          route: '/companies/dashboard/content/works',
          icon: Iconsax.gallery,
        ),
        CompanyNavigationItem(
          id: 'posters',
          label: l10n.posters,
          route: '/companies/dashboard/content/posters',
          icon: Iconsax.gallery_export,
        ),
      ],
    );
  }

  static CompanyNavigationSection _financeSection(AppLocalizations l10n, WidgetRef ref) {
    return CompanyNavigationSection(
      id: 'finance',
      label: l10n.finance,
      icon: Iconsax.money_2,
      defaultRoute: '/companies/dashboard/finance/expenses',
      items: [
        CompanyNavigationItem(
          id: 'expenses',
          label: l10n.expenses,
          route: '/companies/dashboard/finance/expenses',
          icon: Iconsax.money_2,
        ),
        CompanyNavigationItem(
          id: 'accounting',
          label: l10n.accounting,
          route: '/companies/dashboard/finance/accounting',
          icon: Iconsax.chart_2,
        ),
      ],
    );
  }

  static CompanyNavigationSection _settingsSection(AppLocalizations l10n, WidgetRef ref) {
    return CompanyNavigationSection(
      id: 'settings',
      label: l10n.settings,
      icon: Iconsax.setting_2,
      defaultRoute: '/companies/dashboard/settings/profile',
      items: [
        CompanyNavigationItem(
          id: 'profile',
          label: l10n.company_profile,
          route: '/companies/dashboard/settings/profile',
          icon: Iconsax.building_4,
        ),
        if (isFeatureEnabled(ref, AppFeature.companyMembers))
          CompanyNavigationItem(
            id: 'members',
            label: l10n.members,
            route: '/companies/dashboard/settings/members',
            icon: Iconsax.people,
          ),
        CompanyNavigationItem(
          id: 'contacts',
          label: l10n.contacts,
          route: '/companies/dashboard/settings/contacts',
          icon: Iconsax.call,
        ),
        CompanyNavigationItem(
          id: 'public_services',
          label: l10n.company_public_services,
          route: '/companies/dashboard/settings/public-services',
          icon: Iconsax.briefcase,
        ),
        CompanyNavigationItem(
          id: 'service_types',
          label: l10n.service_types,
          route: '/companies/dashboard/settings/service-types',
          icon: Iconsax.gallery_edit,
        ),
      ],
    );
  }
}
