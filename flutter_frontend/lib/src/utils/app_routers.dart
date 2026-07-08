import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/navigation/app_navigation.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/core/flags/feature_flags.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
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
import 'package:solar_hub/src/features/admin/presentation/screens/admin_offers_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_company_types_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_subscription_requests_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_company_inspector_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_api_lab_screen.dart';
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
import 'package:solar_hub/src/features/posters/presentation/screens/admin/admin_posters_screen.dart';
import 'package:solar_hub/src/features/posters/presentation/screens/company/company_posters_screen.dart';
import 'package:solar_hub/src/features/posters/presentation/screens/company/poster_create_screen.dart';

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
      return appRedirectForRoute(state.uri.path, authState, ref);
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
        path: '/feature-unavailable',
        builder: (BuildContext context, GoRouterState state) {
          return const _RouteRequirementPage(
            title: 'Feature Unavailable',
            message: 'This feature is currently disabled or unavailable.',
          );
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
            path: '/companies/dashboard/systems',
            builder: (BuildContext context, GoRouterState state) {
              return const CompanyDashboardSystemsScreen();
            },
          ),

          // Legacy flat redirects to nested routes for backwards compatibility.
          GoRoute(path: '/companies/dashboard/accounting', redirect: (context, state) => '/companies/dashboard/finance/accounting'),
          GoRoute(path: '/companies/dashboard/delivery', redirect: (context, state) => '/companies/dashboard/orders/delivery'),
          GoRoute(path: '/companies/dashboard/expenses', redirect: (context, state) => '/companies/dashboard/finance/expenses'),
          GoRoute(path: '/companies/dashboard/categories', redirect: (context, state) => '/companies/dashboard/inventory/categories'),
          GoRoute(path: '/companies/dashboard/customers', redirect: (context, state) => '/companies/dashboard/sales/customers'),
          GoRoute(path: '/companies/dashboard/suppliers', redirect: (context, state) => '/companies/dashboard/inventory/suppliers'),
          GoRoute(path: '/companies/dashboard/contacts', redirect: (context, state) => '/companies/dashboard/settings/contacts'),
          GoRoute(path: '/companies/dashboard/public-services', redirect: (context, state) => '/companies/dashboard/settings/public-services'),
          GoRoute(path: '/companies/dashboard/service-types', redirect: (context, state) => '/companies/dashboard/settings/service-types'),
          GoRoute(path: '/companies/dashboard/members', redirect: (context, state) => '/companies/dashboard/settings/members'),

          // Sales section
          GoRoute(
            path: '/companies/dashboard/sales',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/sales' ? '/companies/dashboard/sales/offers' : null,
            routes: [
              GoRoute(
                path: 'offers',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyOffersHub(embedded: true);
                },
              ),
              GoRoute(
                path: 'requests',
                builder: (BuildContext context, GoRouterState state) {
                  return const UserRequestsScreen(embedded: true);
                },
              ),
              GoRoute(
                path: 'customers',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyCustomersScreen(embedded: true);
                },
              ),
            ],
          ),

          // Inventory section
          GoRoute(
            path: '/companies/dashboard/inventory',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/inventory' ? '/companies/dashboard/inventory/products' : null,
            routes: [
              GoRoute(
                path: 'products',
                builder: (BuildContext context, GoRouterState state) {
                  return const InventoryPage(embedded: true);
                },
              ),
              GoRoute(
                path: 'categories',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyDashboardCategoriesScreen();
                },
              ),
              GoRoute(
                path: 'suppliers',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanySuppliersScreen(embedded: true);
                },
              ),
            ],
          ),

          // Orders & Logistics section
          GoRoute(
            path: '/companies/dashboard/orders',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/orders' ? '/companies/dashboard/orders/list' : null,
            routes: [
              GoRoute(
                path: 'list',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyOrdersScreen(embedded: true);
                },
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (BuildContext context, GoRouterState state) {
                      final authState = ref.read(authProvider);
                      final id = int.tryParse(state.pathParameters['id'] ?? '');
                      if (id == null || authState.company?.id == null) {
                        return const _RouteRequirementPage(
                          title: 'Order Unavailable',
                          message: 'This order link is invalid or requires a company workspace session.',
                        );
                      }
                      return OrderDetailScreen(orderId: id, companyId: authState.company?.id, sellerView: true);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'delivery',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyDashboardDeliveryScreen();
                },
              ),
            ],
          ),

          // Legacy redirect for company works (moved to Content & Ads section).
          GoRoute(path: '/companies/dashboard/orders/works', redirect: (_, state) => '/companies/dashboard/content/works'),

          // Legacy order-detail redirect (placed after the orders section so it
          // doesn't steal matches from /companies/dashboard/orders/list).
          GoRoute(path: '/companies/dashboard/orders/:id', redirect: (_, state) => '/companies/dashboard/orders/list/${state.pathParameters['id']}'),

          // Content & Ads section
          GoRoute(
            path: '/companies/dashboard/content',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/content' ? '/companies/dashboard/content/works' : null,
            routes: [
              GoRoute(
                path: 'works',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyWorkPage(embedded: true);
                },
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (BuildContext context, GoRouterState state) {
                      return const CompanyWorkFormPage(embedded: true);
                    },
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (BuildContext context, GoRouterState state) {
                      final work = state.extra is CompanyWork ? state.extra as CompanyWork : null;
                      return CompanyWorkFormPage(embedded: true, work: work);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'posters',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyPostersScreen(embedded: true);
                },
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (BuildContext context, GoRouterState state) {
                      return const PosterCreateScreen(embedded: true);
                    },
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (BuildContext context, GoRouterState state) {
                      return const PosterCreateScreen(embedded: true);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Finance section
          GoRoute(
            path: '/companies/dashboard/finance',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/finance' ? '/companies/dashboard/finance/expenses' : null,
            routes: [
              GoRoute(
                path: 'expenses',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyDashboardExpensesScreen();
                },
              ),
              GoRoute(
                path: 'accounting',
                builder: (BuildContext context, GoRouterState state) {
                  return const AccountingScreen(embedded: true);
                },
              ),
            ],
          ),

          // Settings section
          GoRoute(
            path: '/companies/dashboard/settings',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/settings' ? '/companies/dashboard/settings/profile' : null,
            routes: [
              GoRoute(
                path: 'members',
                builder: (BuildContext context, GoRouterState state) {
                  return const MembersPage(embedded: true);
                },
              ),
              GoRoute(
                path: 'contacts',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyDashboardContactsScreen();
                },
              ),
              GoRoute(
                path: 'public-services',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyDashboardPublicServicesScreen();
                },
              ),
              GoRoute(
                path: 'service-types',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyDashboardServiceTypesScreen();
                },
              ),
              GoRoute(
                path: 'profile',
                builder: (BuildContext context, GoRouterState state) {
                  return const CompanyRegistrationPage(embedded: true);
                },
              ),
            ],
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

          // ── Admin Core ──
          GoRoute(path: '/admin/core/configs', builder: (context, state) => const AppConfigsScreen()),
          GoRoute(path: '/admin/core/users', builder: (context, state) => const AdminUsersScreen()),
          GoRoute(path: '/admin/core/countries', builder: (context, state) => const AdminAddressScreen()),
          GoRoute(path: '/admin/core/cities', builder: (context, state) => const AdminAddressScreen()),
          GoRoute(path: '/admin/core/currencies', builder: (context, state) => const AdminCurrencyScreen()),
          GoRoute(path: '/admin/core/subscriptions', builder: (context, state) => const AdminSubscriptionPlansScreen()),
          GoRoute(path: '/admin/core/categories', builder: (context, state) => const AdminCategoriesScreen()),

          // ── Company Admin ──
          GoRoute(path: '/admin/companies', builder: (context, state) => const AdminCompaniesScreen()),
          GoRoute(path: '/admin/companies/:id', builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return AdminCompanyDetailsScreen(companyId: id);
          }),
          GoRoute(path: '/admin/company-types', builder: (context, state) => const AdminCompanyTypesScreen()),
          GoRoute(path: '/admin/service-types', builder: (context, state) => const AdminServiceTypesScreen()),
          GoRoute(path: '/admin/inspector', builder: (context, state) => const AdminCompanyInspectorScreen()),
          GoRoute(path: '/admin/inspector/details', redirect: (context, state) => '/admin/inspector'),
          GoRoute(path: '/admin/inspector/services', redirect: (context, state) => '/admin/inspector'),
          GoRoute(path: '/admin/subscription-requests', builder: (context, state) => const AdminSubscriptionRequestsScreen()),
          GoRoute(path: '/admin/service-catalog', builder: (context, state) => const AdminServiceCatalogScreen()),

          // ── Operations ──
          GoRoute(path: '/admin/ops/systems', builder: (context, state) => const AdminSystemsScreen()),
          GoRoute(path: '/admin/ops/notifications', builder: (context, state) => const SendNotificationScreen()),
          GoRoute(path: '/admin/ops/feedbacks', builder: (context, state) => const AdminFeedbacksScreen()),
          GoRoute(path: '/admin/ops/offers', builder: (context, state) => const AdminOffersScreen()),
          GoRoute(path: '/admin/ops/posters', builder: (context, state) => const AdminPostersScreen()),

          // ── Commerce ──
          GoRoute(path: '/admin/commerce/products', builder: (context, state) => const AdminProductsScreen()),

          // ── Tools ──
          GoRoute(path: '/admin/tools/api-lab', builder: (context, state) => const AdminApiLabScreen()),

          // ── Legacy Redirects (old flat routes → new nested routes) ──
          GoRoute(path: '/admin/feedbacks', redirect: (context, state) => '/admin/ops/feedbacks'),
          GoRoute(path: '/admin/configs', redirect: (context, state) => '/admin/core/configs'),
          GoRoute(path: '/admin/send-notification', redirect: (context, state) => '/admin/ops/notifications'),
          GoRoute(path: '/admin/currencies', redirect: (context, state) => '/admin/core/currencies'),
          GoRoute(path: '/admin/categories', redirect: (context, state) => '/admin/core/categories'),
          GoRoute(path: '/admin/address', redirect: (context, state) => '/admin/core/countries'),
          GoRoute(path: '/admin/users', redirect: (context, state) => '/admin/core/users'),
          GoRoute(path: '/admin/subscriptions', redirect: (context, state) => '/admin/core/subscriptions'),
          GoRoute(path: '/admin/products', redirect: (context, state) => '/admin/commerce/products'),
          GoRoute(path: '/admin/systems', redirect: (context, state) => '/admin/ops/systems'),
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

String? appRedirectForRoute(String path, AuthState authState, [dynamic ref]) {
  if (ref != null && _isFeatureDisabledForRoute(path, ref)) {
    return '/feature-unavailable';
  }

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

  if (path.startsWith('/companies/dashboard/content/works/')) {
    final projectsValue = authState.company?.permissions?.projects;
    if (projectsValue == 'none' || projectsValue == null) {
      return '/home';
    }

    if ((path == '/companies/dashboard/content/works/add' || path.startsWith('/companies/dashboard/content/works/edit/')) && projectsValue != 'write') {
      return '/companies/dashboard/content/works';
    }
  }

  if (routeRequiresAuthenticatedUser(path) && !authState.isSigned) {
    return '/auth?redirect_to=$path';
  }

  return null;
}

bool _isFeatureDisabledForRoute(String path, Ref ref) {
  // Global
  if ((path == '/auth' || path.startsWith('/auth/')) && !isFeatureEnabled(ref, AppFeature.auth)) return true;
  if (path == '/notifications' && !isFeatureEnabled(ref, AppFeature.notifications)) return true;
  if (path == '/feedback' && !isFeatureEnabled(ref, AppFeature.feedback)) return true;
  
  // Dashboard & Calculators
  if ((path == '/user-requests' || path.startsWith('/user-requests/')) && !isFeatureEnabled(ref, AppFeature.userRequests)) return true;
  if (path == '/calculator/structure-design' && !isFeatureEnabled(ref, AppFeature.calculatorStructure)) return true;
  if (path == '/calculator/roof-simulator' && !isFeatureEnabled(ref, AppFeature.calculatorRoof)) return true;
  if (path == '/calculator/pv-system-designer' && !isFeatureEnabled(ref, AppFeature.calculatorPv)) return true;
  if (path == '/calculator/fast-calculator' && !isFeatureEnabled(ref, AppFeature.calculatorFast)) return true;
  if ((path == '/storefront' || path.startsWith('/storefront/')) && !isFeatureEnabled(ref, AppFeature.store, defaultValue: false)) return true;
  if ((path == '/services' || path.startsWith('/services/')) && !isFeatureEnabled(ref, AppFeature.services)) return true;
  
  // Company Dashboard
  if (path.startsWith('/companies/dashboard/sales') && !isFeatureEnabled(ref, AppFeature.companySales)) return true;
  if (path.startsWith('/companies/dashboard/inventory') && !isFeatureEnabled(ref, AppFeature.companyInventory)) return true;
  if (path.startsWith('/companies/dashboard/orders') && !isFeatureEnabled(ref, AppFeature.companyOrders)) return true;
  if (path.startsWith('/companies/dashboard/content') && !isFeatureEnabled(ref, AppFeature.companyContent)) return true;
  if (path.startsWith('/companies/dashboard/finance') && !isFeatureEnabled(ref, AppFeature.companyFinance)) return true;

  return false;
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
