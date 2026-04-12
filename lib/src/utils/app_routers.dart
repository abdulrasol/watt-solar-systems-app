import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/navigation/app_navigation.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_shell.dart';
import 'package:solar_hub/src/shared/domain/company/company_type.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/auth_page.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/company_registration_page.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/edit_profile_page.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/password_reset_page.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/profile_page.dart';
import 'package:solar_hub/src/features/feedback/presentation/screens/feedback_page.dart';
import 'package:solar_hub/src/features/home/presentation/screen/home.dart';
import 'package:solar_hub/src/features/inventory/presentation/screens/inventory_page.dart';
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
import 'package:solar_hub/src/features/admin/presentation/screens/companies/admin_companies_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/companies/admin_company_details_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/companies/admin_service_catalog_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/companies/admin_service_requests_screen.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/product.dart';
import 'package:solar_hub/src/features/inventory/presentation/screens/add_product_page.dart';
import 'package:solar_hub/src/features/inventory/presentation/screens/product_details_page.dart';
import 'package:solar_hub/src/features/notifications/presentation/screens/notification_history_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/construction_page.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_overview_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_services_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_contacts_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_public_services_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_categories_screen.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_shell.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/offer_request_wizard.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_screen.dart';
import 'package:solar_hub/src/features/services/presentation/screens/company_details_screen.dart';
import 'package:solar_hub/src/features/services/presentation/screens/companies_screen.dart';
import 'package:solar_hub/src/features/services/presentation/screens/services_explorer_screen.dart';

// Create a globally accessible provider for the GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  // We can watch the auth state if we want the router to refresh on auth changes
  // Or just read it inside the redirect callback.

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      // For global redirects if needed
      return null;
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
          return const AuthPage();
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
            redirect: (BuildContext context, GoRouterState state) {
              // Read the current authentication state synchronously
              final isSigned = ref.read(authProvider).isSigned;

              if (!isSigned) {
                // If the user is NOT logged in, redirect them to the auth (login) page.
                // You can even pass the intended location as a query parameter if you want to route back!
                // e.g. return '/auth?redirect_to=${state.uri.toString()}';
                return '/auth';
              }
              // If signed in, let them through
              return null;
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
        ],
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryPage(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddProductPage(),
          ),
          GoRoute(
            path: 'product/:id',
            builder: (BuildContext context, GoRouterState state) {
              final product = state.extra as Product;
              return ProductDetailsPage(product: product);
            },
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (BuildContext context, GoRouterState state) {
              final product = state.extra as Product;
              return AddProductPage(product: product);
            },
          ),
        ],
      ),
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
            path: '/admin/service-requests',
            builder: (BuildContext context, GoRouterState state) {
              return const AdminServiceRequestsScreen();
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
      GoRoute(
        path: '/user-requests',
        builder: (context, state) => const UserRequestsScreen(),
      ),
      GoRoute(
        path: '/user-requests/new',
        builder: (context, state) {
          final prefill = state.extra is SolarRequestFormPrefill
              ? state.extra as SolarRequestFormPrefill
              : null;
          return SolarRequestForm(prefill: prefill);
        },
        redirect: (BuildContext context, GoRouterState state) {
          final isSigned = ref.read(authProvider).isSigned;
          if (!isSigned) return '/auth';
          return null;
        },
      ),
      GoRoute(
        path: '/calculator/request-offer-wizard',
        builder: (context, state) => const OfferRequestWizard(),
        redirect: (BuildContext context, GoRouterState state) {
          final isSigned = ref.read(authProvider).isSigned;
          if (!isSigned) return '/auth';
          return null;
        },
      ),
      GoRoute(
        path: '/offers',
        builder: (context, state) => const CompanyOffersHub(),
      ),
      GoRoute(
        path: '/offers/catalog',
        builder: (context, state) => const InvolvesCatalogScreen(),
      ),
      GoRoute(
        path: '/admin-marketplace',
        builder: (context, state) => const AdminOffersDashboard(),
      ),
      GoRoute(
        path: '/storefront',
        builder: (context, state) {
          final audience = state.extra as StorefrontAudience?;
          return PreScaffold(
            child: StorefrontScreen(
              audience: audience ?? StorefrontAudience.b2c,
            ),
          );
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
          final typeCode = state.uri.queryParameters['typeCode'] ?? '';
          final typeName =
              state.uri.queryParameters['typeName'] ??
              state.uri.queryParameters['typeCode'] ??
              l10n.services;
          final typeId =
              int.tryParse(state.uri.queryParameters['typeId'] ?? '') ?? 0;

          return PreScaffold(
            title: typeName,
            child: CompaniesScreen(
              type: CompanyType(id: typeId, code: typeCode, name: typeName),
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
