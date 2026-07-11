import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/navigation/app_navigation.dart';
import 'package:watt/src/core/widgets/pre_scaffold.dart';
import 'package:watt/src/utils/helper_methods.dart';
import 'package:watt/src/shared/domain/service_type.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/core/routes/app_routes.dart';
import 'package:watt/src/core/routes/route_guards.dart';
import 'package:watt/src/core/routes/admin_routes.dart';
import 'package:watt/src/core/routes/company_routes.dart';

// Public & Auth Screens
import 'package:watt/src/features/splash/presentation/screens/splash_screen.dart';
import 'package:watt/src/features/splash/presentation/screens/role_selection_page.dart';
import 'package:watt/src/features/home/presentation/screen/home.dart';
import 'package:watt/src/features/auth/presentation/screens/auth_page.dart';
import 'package:watt/src/features/auth/presentation/screens/profile_page.dart';
import 'package:watt/src/features/auth/presentation/screens/edit_profile_page.dart';
import 'package:watt/src/features/auth/presentation/screens/password_reset_page.dart';
import 'package:watt/src/features/auth/presentation/screens/company_registration_page.dart';
import 'package:watt/src/features/settings/presentation/screens/settings_page.dart';
import 'package:watt/src/features/feedback/presentation/screens/feedback_page.dart';
import 'package:watt/src/features/notifications/presentation/screens/notification_history_screen.dart';

// Inventory & Services

import 'package:watt/src/features/company_work/presentation/screens/company_work_page.dart';
import 'package:watt/src/features/company_work/presentation/screens/company_work_form_page.dart';
import 'package:watt/src/features/company_work/presentation/screens/company_work_details_page.dart';
import 'package:watt/src/features/company_work/domain/entities/company_work.dart';
import 'package:watt/src/features/services/presentation/screens/services_explorer_screen.dart';
import 'package:watt/src/features/services/presentation/screens/companies_screen.dart';
import 'package:watt/src/features/services/presentation/screens/company_details_screen.dart';
import 'package:watt/src/features/members/presentation/screens/members_page.dart';

// Storefront & Orders
import 'package:watt/src/features/storefront/presentation/screens/storefront_screen.dart';
import 'package:watt/src/features/storefront/presentation/screens/storefront_products_screen.dart';
import 'package:watt/src/features/storefront/presentation/screens/storefront_companies_screen.dart';
import 'package:watt/src/features/storefront/presentation/utils/storefront_routes.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/features/storefront/presentation/screens/storefront_product_route_wrapper.dart';
import 'package:watt/src/features/orders_buyer/presentation/screens/buyer_orders_screen.dart';
import 'package:watt/src/features/orders_core/presentation/screens/order_detail_screen.dart';
import 'package:watt/src/features/orders_core/domain/entities/order_models.dart';
import 'package:watt/src/features/orders_buyer/presentation/screens/order_checkout_result_screen.dart';

// Offers & Calculators
import 'package:watt/src/features/offers/presentation/screens/company_offers_hub.dart';
import 'package:watt/src/features/offers/presentation/screens/involves_catalog_screen.dart';
import 'package:watt/src/features/offers/presentation/screens/admin_offers_dashboard.dart';
import 'package:watt/src/features/offers/presentation/screens/user_requests_screen.dart';
import 'package:watt/src/features/offers/presentation/screens/form/solar_request_form.dart';
import 'package:watt/src/features/calculations/presentation/screens/offer_request_wizard.dart';
import 'package:watt/src/features/calculations/presentation/screens/fast_calculator.dart';
import 'package:watt/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:watt/src/features/structure_design/presentation/screens/structure_design_screen.dart';
import 'package:watt/src/features/roof_simulator/presentation/screens/roof_simulator_page.dart';
import 'package:watt/src/features/pv_system_designer/presentation/screens/pv_system_designer_screen.dart';

// Common
import 'package:watt/src/features/company_dashboard/presentation/screens/construction_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<bool>(false);
  ref.listen(authProvider, (previous, next) {
    refreshListenable.value = !refreshListenable.value;
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      dPrint(state.uri.path, tag: 'PATH');
      return RouteGuards.appRedirectForRoute(state.uri.path, authState, ref);
    },
    routes: <RouteBase>[
      // Public Screens
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.roleSelection, builder: (context, state) => const RoleSelectionPage()),
      GoRoute(path: AppRoutes.home, builder: (context, state) => const Home()),
      GoRoute(
        path: AppRoutes.featureUnavailable,
        builder: (context, state) => const RouteRequirementPage(title: 'Feature Unavailable', message: 'This feature is currently disabled or unavailable.'),
      ),
      GoRoute(
        path: AppRoutes.serviceStatus,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return ServiceStatusPage(
            serviceName: extras?['name'] ?? 'Feature',
            serviceCode: extras?['code'] ?? '',
            status: extras?['status'],
            iconUrl: extras?['icon'],
          );
        },
      ),

      // Auth
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => AuthPage(redirectTo: state.uri.queryParameters['redirect_to']),
        routes: [
          GoRoute(path: AppRoutes.authProfile, builder: (context, state) => const ProfilePage()),
          GoRoute(path: AppRoutes.authEditProfile, builder: (context, state) => const EditProfilePage()),
          GoRoute(path: AppRoutes.authPasswordReset, builder: (context, state) => const PasswordResetPage()),
          GoRoute(path: AppRoutes.authCompanyRegistration, builder: (context, state) => const CompanyRegistrationPage()),
        ],
      ),

      // Core User Screens
      GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsPage()),
      GoRoute(path: AppRoutes.feedback, builder: (context, state) => const FeedbackPage()),
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const NotificationHistoryScreen()),

      // Shell Routes (Stateful)
      CompanyRoutes.route,
      AdminRoutes.route,



      // Company Work
      GoRoute(
        path: AppRoutes.companyWork,
        builder: (context, state) => const CompanyWorkPage(),
        routes: [
          GoRoute(path: AppRoutes.companyWorkAdd, builder: (context, state) => const CompanyWorkFormPage()),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final work = state.extra is CompanyWork ? state.extra as CompanyWork : null;
              return CompanyWorkDetailsPage(workId: id, initialWork: work);
            },
          ),
          GoRoute(
            path: AppRoutes.companyWorkEdit,
            builder: (context, state) {
              final work = state.extra is CompanyWork ? state.extra as CompanyWork : null;
              return CompanyWorkFormPage(work: work);
            },
          ),
        ],
      ),

      // Storefront & Orders
      GoRoute(
        path: AppRoutes.storefrontOrders,
        builder: (context, state) {
          final audience = state.pathParameters['audience'] == 'b2b' ? OrderAudience.b2b : OrderAudience.b2c;
          return BuyerOrdersScreen(audience: audience);
        },
      ),
      GoRoute(
        path: AppRoutes.storefrontOrderDetails,
        builder: (context, state) {
          final audience = state.pathParameters['audience'] == 'b2b' ? OrderAudience.b2b : OrderAudience.b2c;
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const RouteRequirementPage(title: 'Order Unavailable', message: 'This order link is invalid.');
          }
          return OrderDetailScreen(orderId: id, audience: audience);
        },
      ),
      GoRoute(path: AppRoutes.storefrontOrderResult, builder: (context, state) => buildOrderResultRoute(state)),
      
      GoRoute(
        path: AppRoutes.storefront,
        builder: (context, state) {
          final audience = state.extra as StorefrontAudience? ?? storefrontAudienceFromQuery(state.uri.queryParameters['audience']);
          final companyId = int.tryParse(state.uri.queryParameters['company_id'] ?? '');
          return PreScaffold(child: StorefrontScreen(audience: audience, companyId: companyId));
        },
      ),
      GoRoute(
        path: AppRoutes.storefrontProducts,
        builder: (context, state) {
          final audience = storefrontAudienceFromQuery(state.uri.queryParameters['audience']);
          final companyId = int.tryParse(state.uri.queryParameters['company_id'] ?? '');
          final globalCategoryId = int.tryParse(state.uri.queryParameters['global_category_id'] ?? '');
          final title = state.uri.queryParameters['title'];
          return StorefrontProductsScreen(audience: audience, companyId: companyId, initialGlobalCategoryId: globalCategoryId, title: title);
        },
      ),
      GoRoute(
        path: AppRoutes.storefrontProductDetails,
        builder: (context, state) {
          final audience = storefrontAudienceFromQuery(state.uri.queryParameters['audience']);
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const RouteRequirementPage(title: 'Product Unavailable', message: 'This product link is invalid.');
          }
          return StorefrontProductRouteWrapper(productId: id, audience: audience);
        },
      ),
      GoRoute(
        path: AppRoutes.storefrontCompanies,
        builder: (context, state) {
          final audience = storefrontAudienceFromQuery(state.uri.queryParameters['audience']);
          return StorefrontCompaniesScreen(audience: audience);
        },
      ),

      // Calculators & Requests
      GoRoute(path: AppRoutes.userRequests, builder: (context, state) => const UserRequestsScreen()),
      GoRoute(
        path: AppRoutes.userRequestsNew,
        builder: (context, state) {
          final prefill = state.extra is SolarRequestFormPrefill ? state.extra as SolarRequestFormPrefill : null;
          return SolarRequestForm(prefill: prefill);
        },
      ),
      GoRoute(path: AppRoutes.calcOfferWizard, builder: (context, state) => const OfferRequestWizard()),
      GoRoute(
        path: AppRoutes.calcStructureDesign,
        builder: (context, state) => StructureDesignScreen(initialInput: state.extra as StructureDesignInput?),
      ),
      GoRoute(path: AppRoutes.calcRoofSimulator, builder: (context, state) => const RoofSimulatorPage()),
      GoRoute(path: AppRoutes.calcPvSystem, builder: (context, state) => const PvSystemDesignerScreen()),
      GoRoute(path: AppRoutes.calcFast, builder: (context, state) => const FastCalculator()),

      // Services & Offers
      GoRoute(path: AppRoutes.members, builder: (context, state) => const MembersPage()),
      GoRoute(path: AppRoutes.offers, builder: (context, state) => const CompanyOffersHub()),
      GoRoute(path: AppRoutes.offersCatalog, builder: (context, state) => const InvolvesCatalogScreen()),
      GoRoute(path: AppRoutes.adminMarketplace, builder: (context, state) => const AdminOffersDashboard()),
      
      GoRoute(
        path: AppRoutes.services,
        builder: (context, state) => const PreScaffold(child: ServicesExplorerScreen()),
      ),
      GoRoute(
        path: AppRoutes.servicesCompanies,
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          final typeName = state.uri.queryParameters['typeName'] ?? state.uri.queryParameters['typeId'] ?? l10n.services;
          final typeId = int.tryParse(state.uri.queryParameters['typeId'] ?? '') ?? 0;
          return PreScaffold(
            title: typeName,
            child: CompaniesScreen(type: ServiceType(id: typeId, name: typeName)),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.servicesCompanyDetails,
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

class RouteRequirementPage extends StatelessWidget {
  const RouteRequirementPage({super.key, required this.title, required this.message, this.actionLabel, this.onAction});

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

Widget buildOrderResultRoute(GoRouterState state) {
  final order = state.extra is OrderRecord ? state.extra as OrderRecord : null;
  if (order == null) {
    final audience = storefrontAudienceFromQuery(state.uri.queryParameters['audience']);
    return RouteRequirementPage(
      title: 'Order Result Unavailable',
      message: 'The checkout result is only available immediately after placing an order.',
      actionLabel: 'Open My Orders',
      onAction: (context) => context.go('${AppRoutes.storefront}/${audience == StorefrontAudience.b2b ? 'b2b' : 'b2c'}/orders'),
    );
  }
  return OrderCheckoutResultScreen(order: order);
}
