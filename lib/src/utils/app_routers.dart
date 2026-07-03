import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/navigation/app_navigation.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_shell.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/fast_calculator.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/auth_page.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/company_registration_page.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/edit_profile_page.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/password_reset_page.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/profile_page.dart';
import 'package:solar_hub/src/features/feedback/presentation/screens/feedback_page.dart';
import 'package:solar_hub/src/features/home/presentation/screen/home.dart';
import 'package:solar_hub/src/features/inventory/presentation/screens/inventory_page.dart';
import 'package:solar_hub/src/features/members/presentation/screens/members_page.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/admin_offers_dashboard.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/company_offers_hub.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/solar_request_form.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/involves_catalog_screen.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/user_requests_screen.dart';
import 'package:solar_hub/src/features/settings/presentation/screens/settings_page.dart';
import 'package:solar_hub/src/features/splash/presentation/screens/role_selection_page.dart';
import 'package:solar_hub/src/features/splash/presentation/screens/splash_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_feedbacks_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/app_configs_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/send_notification_screen.dart';
import 'package:solar_hub/src/features/accounting/presentation/screens/accounting_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/companies/admin_companies_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/companies/admin_company_details_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/companies/admin_service_catalog_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/companies/admin_service_types_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_currency_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_categories_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_address_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_subscription_plans_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_products_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_systems_screen.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/product.dart';
import 'package:solar_hub/src/features/inventory/presentation/screens/add_product_page.dart';
import 'package:solar_hub/src/features/inventory/presentation/screens/product_details_page.dart';
import 'package:solar_hub/src/features/notifications/presentation/screens/notification_history_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/construction_page.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_overview_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_services_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_service_types_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_contacts_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_public_services_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_categories_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_delivery_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_expenses_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_systems_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_shell.dart';
import 'package:solar_hub/src/features/company_work/domain/entities/company_work.dart';
import 'package:solar_hub/src/features/company_work/presentation/screens/company_work_details_page.dart';
import 'package:solar_hub/src/features/company_work/presentation/screens/company_work_form_page.dart';
import 'package:solar_hub/src/features/company_work/presentation/screens/company_work_page.dart';
import 'package:solar_hub/src/features/crm/presentation/screens/crm_screens.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/offer_request_wizard.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/features/structure_design/presentation/screens/structure_design_screen.dart';
import 'package:solar_hub/src/features/roof_simulator/presentation/screens/roof_simulator_page.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/screens/pv_system_designer_screen.dart';
import 'package:solar_hub/src/features/orders_buyer/presentation/screens/buyer_orders_screen.dart';
import 'package:solar_hub/src/features/orders_buyer/presentation/screens/order_checkout_result_screen.dart';
import 'package:solar_hub/src/features/orders_company/presentation/screens/company_orders_screen.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/features/orders_core/presentation/screens/order_detail_screen.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_companies_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_products_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_routes.dart';
import 'package:solar_hub/src/features/services/presentation/screens/company_details_screen.dart';
import 'package:solar_hub/src/features/services/presentation/screens/companies_screen.dart';
import 'package:solar_hub/src/features/services/presentation/screens/services_explorer_screen.dart';

// Create a globally accessible provider for the GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<bool>(false);
  ref.listen(authProvider, (previous, next) {
    refreshListenable.value = !refreshListenable.value;
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      return appRedirectForRoute(state.uri.path, authState);
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/role_selection',
        builder: (BuildContext context, GoRouterState state) {
          return const RoleSelectionPage();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return const Home();
        },
      ),
      GoRoute(
        path: '/auth',
        builder: (BuildContext context, GoRouterState state) {
          return AuthPage(redirectTo: state.uri.queryParameters['redirect_to']);
        },
        routes: [
          GoRoute(
            path: 'profile',
            builder: (BuildContext context, GoRouterState state) {
              return const ProfilePage();
            },
          ),
          GoRoute(
            path: 'edit_profile',
            builder: (BuildContext context, GoRouterState state) {
              return const EditProfilePage();
            },
          ),
          GoRoute(
            path: 'password-reset',
            builder: (BuildContext context, GoRouterState state) {
              return const PasswordResetPage();
            },
          ),
          GoRoute(
            path: 'company_registration',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyRegistrationPage();
            },
          ),
        ],
      ),

      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsPage();
        },
      ),
      GoRoute(
        path: '/feedback',
        builder: (BuildContext context, GoRouterState state) {
          return const FeedbackPage();
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) {
          return const NotificationHistoryScreen();
        },
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return CompanyShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: '/companies/dashboard',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyDashboardOverviewScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/services',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyDashboardServicesScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/service-types',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyDashboardServiceTypesScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/members',
            builder: (BuildContext context, GoRouterState state) {
              return const MembersPage();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/contacts',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyDashboardContactsScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/public-services',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyDashboardPublicServicesScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/categories',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyDashboardCategoriesScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/orders',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyOrdersScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/orders/:id',
            builder: (BuildContext context, GoRouterState state) {
              final authState = ref.read(authProvider);
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null || authState.company?.id == null) {
                return const _RouteRequirementPage(title: 'Order Unavailable', message: 'This order link is invalid or requires a company workspace session.');
              }
              return OrderDetailScreen(orderId: id, companyId: authState.company?.id, sellerView: true);
            },
          ),
          GoRoute(
            path: '/companies/dashboard/customers',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyCustomersScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/suppliers',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanySuppliersScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/accounting',
            builder: (BuildContext context, GoRouterState state) {
              return const AccountingScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/delivery',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyDashboardDeliveryScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/expenses',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyDashboardExpensesScreen();
            },
          ),
          GoRoute(
            path: '/companies/dashboard/systems',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyDashboardSystemsScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryPage(),
        routes: [
          GoRoute(path: 'add', builder: (context, state) => const AddProductPage()),
          GoRoute(path: 'product/:id', builder: (BuildContext context, GoRouterState state) => buildInventoryProductRoute(state)),
          GoRoute(
            path: 'edit/:id',
            builder: (BuildContext context, GoRouterState state) {
              final product = state.extra is Product ? state.extra as Product : null;
              if (product == null) {
                return const _RouteRequirementPage(
                  title: 'Product Edit Unavailable',
                  message: 'Open product editing from the inventory list or product details page.',
                );
              }
              return AddProductPage(product: product);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/company-work',
        builder: (context, state) => const CompanyWorkPage(),
        routes: [
          GoRoute(path: 'add', builder: (context, state) => const CompanyWorkFormPage()),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final work = state.extra is CompanyWork ? state.extra as CompanyWork : null;
              return CompanyWorkDetailsPage(workId: id, initialWork: work);
            },
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) {
              final work = state.extra is CompanyWork ? state.extra as CompanyWork : null;
              return CompanyWorkFormPage(work: work);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/storefront/:audience/orders',
        builder: (context, state) {
          final audience = state.pathParameters['audience'] == 'b2b' ? OrderAudience.b2b : OrderAudience.b2c;
          return BuyerOrdersScreen(audience: audience);
        },
      ),
      GoRoute(
        path: '/storefront/:audience/orders/:id',
        builder: (context, state) {
          final audience = state.pathParameters['audience'] == 'b2b' ? OrderAudience.b2b : OrderAudience.b2c;
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _RouteRequirementPage(title: 'Order Unavailable', message: 'This order link is invalid.');
          }
          return OrderDetailScreen(orderId: id, audience: audience);
        },
      ),
      GoRoute(path: '/storefront/order-result', builder: (context, state) => buildOrderResultRoute(state)),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AdminShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: '/admin',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminDashboard();
            },
          ),
          GoRoute(
            path: '/admin/feedbacks',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminFeedbacksScreen();
            },
          ),
          GoRoute(
            path: '/admin/configs',
            builder: (BuildContext context, GoRouterState state) {
              return const AppConfigsScreen();
            },
          ),
          GoRoute(
            path: '/admin/send-notification',
            builder: (BuildContext context, GoRouterState state) {
              return const SendNotificationScreen();
            },
          ),
          GoRoute(
            path: '/admin/companies',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminCompaniesScreen();
            },
          ),
          GoRoute(
            path: '/admin/companies/:id',
            builder: (BuildContext context, GoRouterState state) {
              final id = int.parse(state.pathParameters['id']!);
              return AdminCompanyDetailsScreen(companyId: id);
            },
          ),
          GoRoute(
            path: '/admin/service-catalog',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminServiceCatalogScreen();
            },
          ),
          GoRoute(
            path: '/admin/service-types',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminServiceTypesScreen();
            },
          ),
          GoRoute(
            path: '/admin/currencies',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminCurrencyScreen();
            },
          ),
          GoRoute(
            path: '/admin/categories',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminCategoriesScreen();
            },
          ),
          GoRoute(
            path: '/admin/address',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminAddressScreen();
            },
          ),
          GoRoute(
            path: '/admin/users',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminUsersScreen();
            },
          ),
          GoRoute(
            path: '/admin/subscriptions',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminSubscriptionPlansScreen();
            },
          ),
          GoRoute(
            path: '/admin/products',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminProductsScreen();
            },
          ),
          GoRoute(
            path: '/admin/systems',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminSystemsScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: '/service-status',
        builder: (BuildContext context, GoRouterState state) {
          final extras = state.extra as Map<String, dynamic>?;
          return ServiceStatusPage(
            serviceName: extras?['name'] ?? 'Feature',
            serviceCode: extras?['code'] ?? '',
            status: extras?['status'],
            iconUrl: extras?['icon'],
          );
        },
      ),
      GoRoute(path: '/user-requests', builder: (context, state) => const UserRequestsScreen()),
      GoRoute(
        path: '/user-requests/new',
        builder: (context, state) {
          final prefill = state.extra is SolarRequestFormPrefill ? state.extra as SolarRequestFormPrefill : null;
          return SolarRequestForm(prefill: prefill);
        },
      ),
      GoRoute(path: '/calculator/request-offer-wizard', builder: (context, state) => const OfferRequestWizard()),
      GoRoute(
        path: '/calculator/structure-design',
        builder: (context, state) => StructureDesignScreen(initialInput: state.extra as StructureDesignInput?),
      ),
      GoRoute(path: '/calculator/roof-simulator', builder: (context, state) => const RoofSimulatorPage()),
      GoRoute(path: '/calculator/pv-system-designer', builder: (context, state) => const PvSystemDesignerScreen()),
      GoRoute(path: '/calculator/fast-calculator', builder: (context, state) => const FastCalculator()),
      GoRoute(path: '/members', builder: (context, state) => const MembersPage()),
      GoRoute(path: '/offers', builder: (context, state) => const CompanyOffersHub()),
      GoRoute(path: '/offers/catalog', builder: (context, state) => const InvolvesCatalogScreen()),
      GoRoute(path: '/admin-marketplace', builder: (context, state) => const AdminOffersDashboard()),
      GoRoute(
        path: '/storefront',
        builder: (context, state) {
          final audience = state.extra as StorefrontAudience? ?? storefrontAudienceFromQuery(state.uri.queryParameters['audience']);
          final companyId = int.tryParse(state.uri.queryParameters['company_id'] ?? '');
          return PreScaffold(
            child: StorefrontScreen(audience: audience, companyId: companyId),
          );
        },
      ),
      GoRoute(
        path: '/storefront/products',
        builder: (context, state) {
          final audience = storefrontAudienceFromQuery(state.uri.queryParameters['audience']);
          final companyId = int.tryParse(state.uri.queryParameters['company_id'] ?? '');
          final globalCategoryId = int.tryParse(state.uri.queryParameters['global_category_id'] ?? '');
          final title = state.uri.queryParameters['title'];

          return StorefrontProductsScreen(audience: audience, companyId: companyId, initialGlobalCategoryId: globalCategoryId, title: title);
        },
      ),
      GoRoute(
        path: '/storefront/companies',
        builder: (context, state) {
          final audience = storefrontAudienceFromQuery(state.uri.queryParameters['audience']);
          return StorefrontCompaniesScreen(audience: audience);
        },
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) {
          return const PreScaffold(child: ServicesExplorerScreen());
        },
      ),
      GoRoute(
        path: '/services/companies',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          final typeName = state.uri.queryParameters['typeName'] ?? state.uri.queryParameters['typeId'] ?? l10n.services;
          final typeId = int.tryParse(state.uri.queryParameters['typeId'] ?? '') ?? 0;

          return PreScaffold(
            title: typeName,
            child: CompaniesScreen(
              type: ServiceType(id: typeId, name: typeName),
            ),
          );
        },
      ),
      GoRoute(
        path: '/services/company/:id',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          final companyId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return PreScaffold(
            title: l10n.services_company_details,
            child: CompanyDetailsScreen(companyId: companyId),
          );
        },
      ),
    ],
  );
});

String? appRedirectForRoute(String path, AuthState authState) {
  if (routeRequiresAdmin(path) && !authState.isSuperUser) {
    return authState.isSigned ? '/home' : '/auth?redirect_to=$path';
  }

  if (routeRequiresCompanyMember(path) && !authState.isCompanyMember) {
    return authState.isSigned ? '/home' : '/auth?redirect_to=$path';
  }

  if (path == '/company-work' || path.startsWith('/company-work/')) {
    final projectsValue = authState.company?.permissions?.projects;
    if (projectsValue == 'none' || projectsValue == null) {
      return '/home';
    }

    if ((path == '/company-work/add' || path.startsWith('/company-work/edit/')) && projectsValue != 'write') {
      return '/company-work';
    }
  }

  if (routeRequiresAuthenticatedUser(path) && !authState.isSigned) {
    return '/auth?redirect_to=$path';
  }

  return null;
}

// `/admin-marketplace` used to be excluded from this check (it doesn't
// match `/admin` or `/admin/*`), so any signed-in non-admin user could
// navigate straight to the Marketplace Oversight screen — the backend
// calls would still 403, but the UI shell itself was reachable. Widened to
// close that gap.
bool routeRequiresAdmin(String path) => path == '/admin' || path.startsWith('/admin/') || path == '/admin-marketplace';

bool routeRequiresCompanyMember(String path) {
  return path.startsWith('/companies/dashboard') ||
      path == '/inventory' ||
      path.startsWith('/inventory/') ||
      path == '/company-work' ||
      path.startsWith('/company-work/') ||
      path == '/members' ||
      path == '/offers' ||
      path.startsWith('/offers/');
}

bool routeRequiresAuthenticatedUser(String path) {
  return path == '/auth/profile' ||
      path == '/auth/edit_profile' ||
      path == '/notifications' ||
      path == '/user-requests' ||
      path.startsWith('/user-requests/') ||
      path == '/calculator/request-offer-wizard' ||
      (path.startsWith('/storefront/') && path.contains('/orders'));
}

class _RouteRequirementPage extends StatelessWidget {
  const _RouteRequirementPage({required this.title, required this.message, this.actionLabel, this.onAction});

  final String title;
  final String message;
  final String? actionLabel;
  final void Function(BuildContext context)? onAction;

  @override
  Widget build(BuildContext context) {
    return PreScaffold(
      title: title,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 56),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: () => onAction!(context), child: Text(actionLabel!)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildInventoryProductRoute(GoRouterState state) {
  final product = state.extra is Product ? state.extra as Product : null;
  if (product == null) {
    return const _RouteRequirementPage(title: 'Product Unavailable', message: 'Open this page from the inventory list so the product can be loaded safely.');
  }
  return ProductDetailsPage(product: product);
}

Widget buildOrderResultRoute(GoRouterState state) {
  final order = state.extra is OrderRecord ? state.extra as OrderRecord : null;
  if (order == null) {
    final audience = storefrontAudienceFromQuery(state.uri.queryParameters['audience']);
    return _RouteRequirementPage(
      title: 'Order Result Unavailable',
      message: 'The checkout result is only available immediately after placing an order.',
      actionLabel: 'Open My Orders',
      onAction: (context) => context.go('/storefront/${audience == StorefrontAudience.b2b ? 'b2b' : 'b2c'}/orders'),
    );
  }
  return OrderCheckoutResultScreen(order: order);
}
