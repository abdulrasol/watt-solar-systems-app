import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watt/src/core/routes/app_routes.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_shell.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:watt/src/features/admin/presentation/screens/app_configs_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/send_notification_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/companies/admin_companies_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/companies/admin_company_details_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/companies/admin_service_catalog_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/companies/admin_service_types_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_currency_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_categories_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_address_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_subscription_plans_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_products_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_systems_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_offers_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_company_types_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_subscription_requests_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_company_inspector_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_api_lab_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_feedbacks_screen.dart';
import 'package:watt/src/features/posters/presentation/screens/admin/admin_posters_screen.dart';

class AdminRoutes {
  static final route = StatefulShellRoute.indexedStack(
    builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
      return AdminShell(navigationShell: navigationShell);
    },
    branches: [
      // Branch 1: Workspace
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.admin,
            builder: (context, state) => const AdminDashboard(),
          ),
        ],
      ),
      // Branch 2: Core
      StatefulShellBranch(
        routes: [
          GoRoute(path: AppRoutes.adminConfigs, builder: (context, state) => const AppConfigsScreen()),
          GoRoute(path: AppRoutes.adminUsers, builder: (context, state) => const AdminUsersScreen()),
          GoRoute(path: AppRoutes.adminCountries, builder: (context, state) => const AdminAddressScreen()),
          GoRoute(path: AppRoutes.adminCities, builder: (context, state) => const AdminAddressScreen()),
          GoRoute(path: AppRoutes.adminCurrencies, builder: (context, state) => const AdminCurrencyScreen()),
          GoRoute(path: AppRoutes.adminSubscriptions, builder: (context, state) => const AdminSubscriptionPlansScreen()),
          GoRoute(path: AppRoutes.adminCategories, builder: (context, state) => const AdminCategoriesScreen()),
          // Legacy redirects
          GoRoute(path: '/admin/configs', redirect: (context, state) => AppRoutes.adminConfigs),
          GoRoute(path: '/admin/currencies', redirect: (context, state) => AppRoutes.adminCurrencies),
          GoRoute(path: '/admin/categories', redirect: (context, state) => AppRoutes.adminCategories),
          GoRoute(path: '/admin/address', redirect: (context, state) => AppRoutes.adminCountries),
          GoRoute(path: '/admin/users', redirect: (context, state) => AppRoutes.adminUsers),
          GoRoute(path: '/admin/subscriptions', redirect: (context, state) => AppRoutes.adminSubscriptions),
        ],
      ),
      // Branch 3: Company Admin
      StatefulShellBranch(
        routes: [
          GoRoute(path: AppRoutes.adminCompanies, builder: (context, state) => const AdminCompaniesScreen()),
          GoRoute(
            path: AppRoutes.adminCompanyDetails,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return AdminCompanyDetailsScreen(companyId: id);
            },
          ),
          GoRoute(path: AppRoutes.adminCompanyTypes, builder: (context, state) => const AdminCompanyTypesScreen()),
          GoRoute(path: AppRoutes.adminServiceTypes, builder: (context, state) => const AdminServiceTypesScreen()),
          GoRoute(path: AppRoutes.adminInspector, builder: (context, state) => const AdminCompanyInspectorScreen()),
          GoRoute(path: '/admin/inspector/details', redirect: (context, state) => AppRoutes.adminInspector),
          GoRoute(path: '/admin/inspector/services', redirect: (context, state) => AppRoutes.adminInspector),
          GoRoute(path: AppRoutes.adminSubscriptionRequests, builder: (context, state) => const AdminSubscriptionRequestsScreen()),
          GoRoute(path: AppRoutes.adminServiceCatalog, builder: (context, state) => const AdminServiceCatalogScreen()),
        ],
      ),
      // Branch 4: Operations
      StatefulShellBranch(
        routes: [
          GoRoute(path: AppRoutes.adminSystems, builder: (context, state) => const AdminSystemsScreen()),
          GoRoute(path: AppRoutes.adminNotifications, builder: (context, state) => const SendNotificationScreen()),
          GoRoute(path: AppRoutes.adminFeedbacks, builder: (context, state) => const AdminFeedbacksScreen()),
          GoRoute(path: AppRoutes.adminOffers, builder: (context, state) => const AdminOffersScreen()),
          GoRoute(path: AppRoutes.adminPosters, builder: (context, state) => const AdminPostersScreen()),
          // Legacy redirects
          GoRoute(path: '/admin/systems', redirect: (context, state) => AppRoutes.adminSystems),
          GoRoute(path: '/admin/send-notification', redirect: (context, state) => AppRoutes.adminNotifications),
          GoRoute(path: '/admin/feedbacks', redirect: (context, state) => AppRoutes.adminFeedbacks),
        ],
      ),
      // Branch 5: Commerce
      StatefulShellBranch(
        routes: [
          GoRoute(path: AppRoutes.adminProducts, builder: (context, state) => const AdminProductsScreen()),
          // Legacy redirects
          GoRoute(path: '/admin/products', redirect: (context, state) => AppRoutes.adminProducts),
        ],
      ),
      // Branch 6: Tools
      StatefulShellBranch(
        routes: [
          GoRoute(path: AppRoutes.adminApiLab, builder: (context, state) => const AdminApiLabScreen()),
        ],
      ),
    ],
  );
}
