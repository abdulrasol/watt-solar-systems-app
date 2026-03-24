import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/auth_page.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/company_registration_page.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/edit_profile_page.dart';
import 'package:solar_hub/src/features/auth/presentation/screens/profile_page.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_layout.dart';
import 'package:solar_hub/src/features/home/presentation/screen/home.dart';
import 'package:solar_hub/src/features/settings/presentation/screens/settings_page.dart';
import 'package:solar_hub/src/features/splash/presentation/screens/role_selection_page.dart';
import 'package:solar_hub/src/features/splash/presentation/screens/splash_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/screen/admin_dashboard.dart';
import 'package:solar_hub/src/features/admin/presentation/screen/feedbacks.dart';
import 'package:solar_hub/src/features/admin/presentation/screen/app_configs_screen.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/product.dart';
import 'package:solar_hub/src/features/inventory/presentation/screens/add_product_page.dart';
import 'package:solar_hub/src/features/inventory/presentation/screens/product_details_page.dart';

// Create a globally accessible provider for the GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  // We can watch the auth state if we want the router to refresh on auth changes
  // Or just read it inside the redirect callback.

  return GoRouter(
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
        routes: [
          GoRoute(
            path: 'role_selection',
            builder: (BuildContext context, GoRouterState state) {
              return const RoleSelectionPage();
            },
          ),
        ],
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
        path: '/company/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const CompanyDashboardLayout();
        },
      ),
      GoRoute(
        path: '/company-dashboard/inventory/add',
        builder: (BuildContext context, GoRouterState state) {
          return const AddProductPage();
        },
      ),
      GoRoute(
        path: '/company-dashboard/inventory/product/:id',
        builder: (BuildContext context, GoRouterState state) {
          final product = state.extra as Product;
          return ProductDetailsPage(product: product);
        },
      ),
      GoRoute(
        path: '/company-dashboard/inventory/edit/:id',
        builder: (BuildContext context, GoRouterState state) {
          final product = state.extra as Product;
          return AddProductPage(product: product);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (BuildContext context, GoRouterState state) {
          return const AdminDashboard();
        },
        routes: [
          GoRoute(
            path: 'feedbacks',
            builder: (BuildContext context, GoRouterState state) {
              return const FeedbacksScreen();
            },
          ),
          GoRoute(
            path: 'configs',
            builder: (BuildContext context, GoRouterState state) {
              return const AppConfigsScreen();
            },
          ),
        ],
      ),
    ],
  );
});
