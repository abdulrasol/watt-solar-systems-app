import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/core/routes/app_routes.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/company_shell.dart';
import 'package:watt/src/features/company_dashboard/presentation/screens/company_dashboard_overview_screen.dart';
import 'package:watt/src/features/company_dashboard/presentation/screens/company_dashboard_systems_screen.dart';
import 'package:watt/src/features/offers/presentation/screens/company_offers_hub.dart';
import 'package:watt/src/features/offers/presentation/screens/user_requests_screen.dart';

import 'package:watt/src/features/company_dashboard/presentation/screens/company_storefront_preview_screen.dart';
import 'package:watt/src/features/inventory/presentation/screens/inventory_page.dart';
import 'package:watt/src/features/inventory/presentation/screens/add_product_page.dart';
import 'package:watt/src/features/inventory/presentation/screens/product_details_page.dart';
import 'package:watt/src/features/inventory/domain/entities/product.dart';
import 'package:watt/src/features/company_dashboard/presentation/screens/company_dashboard_categories_screen.dart';
import 'package:watt/src/features/crm/presentation/screens/crm_screens.dart' as crm; // Handle possible name clashes
import 'package:watt/src/features/orders_company/presentation/screens/company_orders_screen.dart';
import 'package:watt/src/features/orders_core/presentation/screens/order_detail_screen.dart';
import 'package:watt/src/features/company_dashboard/presentation/screens/company_dashboard_delivery_screen.dart';
import 'package:watt/src/features/company_work/presentation/screens/company_work_page.dart';
import 'package:watt/src/features/company_work/presentation/screens/company_work_form_page.dart';
import 'package:watt/src/features/company_work/domain/entities/company_work.dart';
import 'package:watt/src/features/posters/presentation/screens/company/company_posters_screen.dart';
import 'package:watt/src/features/posters/presentation/screens/company/poster_create_screen.dart';
import 'package:watt/src/features/company_dashboard/presentation/screens/company_dashboard_expenses_screen.dart';
import 'package:watt/src/features/accounting/presentation/screens/accounting_screen.dart';
import 'package:watt/src/features/members/presentation/screens/members_page.dart';
import 'package:watt/src/features/company_dashboard/presentation/screens/company_dashboard_contacts_screen.dart';
import 'package:watt/src/features/company_dashboard/presentation/screens/company_dashboard_public_services_screen.dart';
import 'package:watt/src/features/company_dashboard/presentation/screens/company_dashboard_service_types_screen.dart';
import 'package:watt/src/features/auth/presentation/screens/company_registration_page.dart';
import 'package:watt/src/core/widgets/pre_scaffold.dart';

class CompanyRoutes {
  static final route = StatefulShellRoute.indexedStack(
    builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
      return CompanyShell(navigationShell: navigationShell);
    },
    branches: [
      // Branch 1: Overview
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.companyDashboard,
            builder: (context, state) => const CompanyDashboardOverviewScreen(),
          ),
          GoRoute(
            path: AppRoutes.companySystems,
            builder: (context, state) => const CompanyDashboardSystemsScreen(),
          ),
        ],
      ),
      // Branch 2: Sales
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/companies/dashboard/sales',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/sales' ? AppRoutes.companySalesOffers : null,
            routes: [
              GoRoute(
                path: 'offers',
                builder: (context, state) => const CompanyOffersHub(embedded: true),
              ),
              GoRoute(
                path: 'requests',
                builder: (context, state) => const UserRequestsScreen(embedded: true),
              ),
              GoRoute(
                path: 'customers',
                builder: (context, state) => const crm.CompanyCustomersScreen(embedded: true),
              ),
              GoRoute(
                path: 'storefront-preview',
                builder: (context, state) => const CompanyStorefrontPreviewScreen(),
              ),
            ],
          ),
          // Legacy redirects
          GoRoute(path: '/companies/dashboard/customers', redirect: (context, state) => AppRoutes.companySalesCustomers),
        ],
      ),
      // Branch 3: Inventory
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/companies/dashboard/inventory',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/inventory' ? AppRoutes.companyInventoryProducts : null,
            routes: [
              GoRoute(
                path: 'products',
                builder: (context, state) => const InventoryPage(embedded: true),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddProductPage(),
                  ),
                  GoRoute(
                    path: 'product/:id',
                    builder: (context, state) {
                      final product = state.extra is Product ? state.extra as Product : null;
                      if (product == null) {
                        return const PreScaffold(
                          title: 'Product Unavailable',
                          child: Center(child: Text('Open this page from the inventory list so the product can be loaded safely.')),
                        );
                      }
                      return ProductDetailsPage(product: product);
                    },
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) {
                      final product = state.extra is Product ? state.extra as Product : null;
                      if (product == null) {
                        return const PreScaffold(
                          title: 'Product Edit Unavailable',
                          child: Center(child: Text('Open product editing from the inventory list or product details page.')),
                        );
                      }
                      return AddProductPage(product: product);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'categories',
                builder: (context, state) => const CompanyDashboardCategoriesScreen(),
              ),
              GoRoute(
                path: 'suppliers',
                builder: (context, state) => const crm.CompanySuppliersScreen(embedded: true),
              ),
            ],
          ),
          // Legacy redirects
          GoRoute(path: '/companies/dashboard/categories', redirect: (context, state) => AppRoutes.companyInventoryCategories),
          GoRoute(path: '/companies/dashboard/suppliers', redirect: (context, state) => AppRoutes.companyInventorySuppliers),
        ],
      ),
      // Branch 4: Orders
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/companies/dashboard/orders',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/orders' ? AppRoutes.companyOrdersList : null,
            routes: [
              GoRoute(
                path: 'list',
                builder: (context, state) => const CompanyOrdersScreen(embedded: true),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (BuildContext context, GoRouterState state) {
                      // Using Consumer context requires a bit of logic, we can just use Riverpod's ProviderScope
                      return Consumer(
                        builder: (context, ref, _) {
                          final authState = ref.read(authProvider);
                          final id = int.tryParse(state.pathParameters['id'] ?? '');
                          if (id == null || authState.company?.id == null) {
                            return const PreScaffold(
                              title: 'Order Unavailable',
                              child: Center(child: Text('This order link is invalid or requires a company workspace session.')),
                            );
                          }
                          return OrderDetailScreen(orderId: id, companyId: authState.company?.id, sellerView: true);
                        }
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'delivery',
                builder: (context, state) => const CompanyDashboardDeliveryScreen(),
              ),
            ],
          ),
          // Legacy redirects
          GoRoute(path: '/companies/dashboard/delivery', redirect: (context, state) => AppRoutes.companyOrdersDelivery),
          GoRoute(path: '/companies/dashboard/orders/works', redirect: (_, state) => AppRoutes.companyContentWorks),
          GoRoute(path: '/companies/dashboard/orders/:id', redirect: (_, state) => '${AppRoutes.companyOrdersList}/${state.pathParameters['id']}'),
        ],
      ),
      // Branch 5: Content
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/companies/dashboard/content',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/content' ? AppRoutes.companyContentWorks : null,
            routes: [
              GoRoute(
                path: 'works',
                builder: (context, state) => const CompanyWorkPage(embedded: true),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const CompanyWorkFormPage(embedded: true),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) {
                      final work = state.extra is CompanyWork ? state.extra as CompanyWork : null;
                      return CompanyWorkFormPage(embedded: true, work: work);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'posters',
                builder: (context, state) => const CompanyPostersScreen(embedded: true),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const PosterCreateScreen(embedded: true),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) => const PosterCreateScreen(embedded: true),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Branch 6: Finance
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/companies/dashboard/finance',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/finance' ? AppRoutes.companyFinanceExpenses : null,
            routes: [
              GoRoute(
                path: 'expenses',
                builder: (context, state) => const CompanyDashboardExpensesScreen(),
              ),
              GoRoute(
                path: 'accounting',
                builder: (context, state) => const AccountingScreen(embedded: true),
              ),
            ],
          ),
          // Legacy redirects
          GoRoute(path: '/companies/dashboard/expenses', redirect: (context, state) => AppRoutes.companyFinanceExpenses),
          GoRoute(path: '/companies/dashboard/accounting', redirect: (context, state) => AppRoutes.companyFinanceAccounting),
        ],
      ),
      // Branch 7: Settings
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/companies/dashboard/settings',
            redirect: (context, state) => state.uri.path == '/companies/dashboard/settings' ? AppRoutes.companySettingsProfile : null,
            routes: [
              GoRoute(
                path: 'members',
                builder: (context, state) => const MembersPage(embedded: true),
              ),
              GoRoute(
                path: 'contacts',
                builder: (context, state) => const CompanyDashboardContactsScreen(),
              ),
              GoRoute(
                path: 'public-services',
                builder: (context, state) => const CompanyDashboardPublicServicesScreen(),
              ),
              GoRoute(
                path: 'service-types',
                builder: (context, state) => const CompanyDashboardServiceTypesScreen(),
              ),
              GoRoute(
                path: 'profile',
                builder: (context, state) => const CompanyRegistrationPage(embedded: true),
              ),
            ],
          ),
          // Legacy redirects
          GoRoute(path: '/companies/dashboard/contacts', redirect: (context, state) => AppRoutes.companySettingsContacts),
          GoRoute(path: '/companies/dashboard/public-services', redirect: (context, state) => AppRoutes.companySettingsPublicServices),
          GoRoute(path: '/companies/dashboard/service-types', redirect: (context, state) => AppRoutes.companySettingsServiceTypes),
          GoRoute(path: '/companies/dashboard/members', redirect: (context, state) => AppRoutes.companySettingsMembers),
        ],
      ),
    ],
  );
}
