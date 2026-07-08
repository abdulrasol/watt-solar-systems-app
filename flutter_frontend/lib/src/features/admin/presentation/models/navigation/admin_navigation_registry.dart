import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/admin/presentation/models/navigation/admin_navigation_item.dart';
import 'package:watt/src/features/admin/presentation/models/navigation/admin_navigation_section.dart';

class AdminNavigationRegistry {
  const AdminNavigationRegistry._();

  static List<AdminNavigationSection> build(AppLocalizations l10n) {
    return [
      _workspaceSection(l10n),
      _coreSection(l10n),
      _companyAdminSection(l10n),
      _operationsSection(l10n),
      _commerceSection(l10n),
      _toolsSection(l10n),
    ];
  }

  static AdminNavigationSection _workspaceSection(AppLocalizations l10n) {
    return AdminNavigationSection(
      id: 'workspace',
      label: l10n.admin_workspace,
      icon: Iconsax.grid_1,
      items: [
        AdminNavigationItem(
          id: 'overview',
          label: l10n.overview,
          route: '/admin',
          icon: Iconsax.grid_1,
        ),
      ],
    );
  }

  static AdminNavigationSection _coreSection(AppLocalizations l10n) {
    return AdminNavigationSection(
      id: 'core',
      label: l10n.admin_core,
      icon: Iconsax.setting_2,
      items: [
        AdminNavigationItem(
          id: 'configs',
          label: l10n.admin_app_configs,
          route: '/admin/core/configs',
          icon: Iconsax.toggle_on_circle,
        ),
        AdminNavigationItem(
          id: 'users',
          label: l10n.admin_users,
          route: '/admin/core/users',
          icon: Iconsax.user,
        ),
        AdminNavigationItem(
          id: 'countries',
          label: l10n.admin_countries,
          route: '/admin/core/countries',
          icon: Iconsax.global,
        ),
        AdminNavigationItem(
          id: 'cities',
          label: l10n.admin_cities,
          route: '/admin/core/cities',
          icon: Iconsax.location,
        ),
        AdminNavigationItem(
          id: 'currencies',
          label: l10n.admin_currencies,
          route: '/admin/core/currencies',
          icon: Iconsax.money,
        ),
        AdminNavigationItem(
          id: 'subscriptions',
          label: l10n.admin_subscription_plans,
          route: '/admin/core/subscriptions',
          icon: Iconsax.card,
        ),
        AdminNavigationItem(
          id: 'categories',
          label: l10n.admin_global_categories,
          route: '/admin/core/categories',
          icon: Iconsax.category,
        ),
      ],
    );
  }

  static AdminNavigationSection _companyAdminSection(AppLocalizations l10n) {
    return AdminNavigationSection(
      id: 'company_admin',
      label: l10n.admin_company_admin,
      icon: Iconsax.buildings_2,
      items: [
        AdminNavigationItem(
          id: 'companies',
          label: l10n.companies,
          route: '/admin/companies',
          icon: Iconsax.buildings_2,
        ),
        AdminNavigationItem(
          id: 'company_types',
          label: l10n.admin_company_types,
          route: '/admin/company-types',
          icon: Iconsax.layer,
        ),
        AdminNavigationItem(
          id: 'service_types',
          label: l10n.service_types,
          route: '/admin/service-types',
          icon: Iconsax.gallery_edit,
        ),
        AdminNavigationItem(
          id: 'inspector_details',
          label: l10n.admin_inspector_details,
          route: '/admin/inspector/details',
          icon: Iconsax.document_text,
        ),
        AdminNavigationItem(
          id: 'inspector_services',
          label: l10n.admin_inspector_services,
          route: '/admin/inspector/services',
          icon: Iconsax.briefcase,
        ),
        AdminNavigationItem(
          id: 'subscription_requests',
          label: l10n.admin_subscription_requests,
          route: '/admin/subscription-requests',
          icon: Iconsax.ticket,
        ),
        AdminNavigationItem(
          id: 'service_catalog',
          label: l10n.admin_service_catalog,
          route: '/admin/service-catalog',
          icon: Iconsax.category_2,
        ),
      ],
    );
  }

  static AdminNavigationSection _operationsSection(AppLocalizations l10n) {
    return AdminNavigationSection(
      id: 'operations',
      label: l10n.admin_operations,
      icon: Iconsax.activity,
      items: [
        AdminNavigationItem(
          id: 'systems',
          label: l10n.systems,
          route: '/admin/ops/systems',
          icon: Iconsax.sun_1,
        ),
        AdminNavigationItem(
          id: 'notifications',
          label: l10n.notifications,
          route: '/admin/ops/notifications',
          icon: Iconsax.notification_bing,
        ),
        AdminNavigationItem(
          id: 'feedbacks',
          label: l10n.admin_feedbacks,
          route: '/admin/ops/feedbacks',
          icon: Iconsax.message,
        ),
        AdminNavigationItem(
          id: 'offers',
          label: l10n.admin_offers_requests,
          route: '/admin/ops/offers',
          icon: Iconsax.shop,
        ),
        AdminNavigationItem(
          id: 'posters',
          label: l10n.posters,
          route: '/admin/ops/posters',
          icon: Iconsax.gallery,
        ),
      ],
    );
  }

  static AdminNavigationSection _commerceSection(AppLocalizations l10n) {
    return AdminNavigationSection(
      id: 'commerce',
      label: l10n.admin_commerce,
      icon: Iconsax.box,
      items: [
        AdminNavigationItem(
          id: 'products',
          label: l10n.admin_global_products,
          route: '/admin/commerce/products',
          icon: Iconsax.box_1,
        ),
      ],
    );
  }

  static AdminNavigationSection _toolsSection(AppLocalizations l10n) {
    return AdminNavigationSection(
      id: 'tools',
      label: l10n.admin_tools,
      icon: Iconsax.code,
      items: [
        AdminNavigationItem(
          id: 'api_lab',
          label: l10n.admin_api_lab,
          route: '/admin/tools/api-lab',
          icon: Iconsax.code,
        ),
      ],
    );
  }
}
