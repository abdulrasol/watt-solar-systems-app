import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/admin/layouts/admin_dashboard_layout.dart';
import 'package:solar_hub/features/community/screens/notifications_page.dart';
import 'package:solar_hub/features/community/screens/post_details_page.dart';
import 'package:solar_hub/features/company_dashboard/screens/main_dashboard_page.dart';
import 'package:solar_hub/features/store/screens/cart_page.dart';
import 'package:solar_hub/layouts/shared/auth/auth_page.dart';
import 'package:solar_hub/features/calculations/layouts/calculator_landing_page.dart';
import 'package:solar_hub/features/calculations/old/wires_calculator.dart';
import 'package:solar_hub/features/calculations/layouts/tools/direction_calculator.dart';
import 'package:solar_hub/features/calculations/layouts/tools/pump_calculator.dart';
import 'package:solar_hub/layouts/user/home.dart';
import 'package:solar_hub/features/calculations/layouts/system_calculator_wizard.dart';
import 'package:solar_hub/layouts/shared/splash_screen.dart';
import 'package:solar_hub/layouts/shared/role_selection_page.dart';
import 'package:solar_hub/features/systems/screens/system_details_page.dart';

import 'package:solar_hub/layouts/shared/settings/settings_page.dart';
import 'package:solar_hub/layouts/shared/profile/profile_page.dart';
import 'package:solar_hub/features/profile/screens/edit_profile_page.dart';
import 'package:solar_hub/features/profile/screens/company_profile_page.dart';
import 'package:solar_hub/features/profile/screens/edit_company_profile_page.dart';
import 'package:solar_hub/features/orders/screens/order_list_user.dart';
import 'package:solar_hub/features/systems/screens/my_systems_page.dart';
import 'package:solar_hub/features/store/screens/company_store_page.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/utils/route_helpers.dart';

class AppRoutes {
  static final routes = <GetPage>[
    GetPage(name: '/calculator', page: () => const CalculatorLandingPage(), transition: Transition.cupertino),

    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/role_selection', page: () => const RoleSelectionPage()),

    GetPage(name: '/home', page: () => Home()),
    GetPage(name: '/admin_dashboard', page: () => const AdminDashboardLayout(), transition: Transition.fadeIn),
    // calculations
    GetPage(name: '/solar-wizard', page: () => const SystemCalculatorWizard(), transition: Transition.cupertino),

    GetPage(
      name: '/community/post',
      page: () => PostDetailsPage(post: Get.arguments),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: '/community/system',
      page: () => SystemDetailsPage(system: Get.arguments, isCommunityView: true),
      transition: Transition.cupertino,
    ),
    GetPage(name: '/community/notifications', page: () => NotificationsScreen(), transition: Transition.upToDown),

    GetPage(name: '/wires', page: () => WiresCalculator(), transition: Transition.cupertino),
    GetPage(name: '/direction', page: () => DirectionCalculator(), transition: Transition.cupertino),
    GetPage(name: '/pump', page: () => PumpCalculator(), transition: Transition.cupertino),

    GetPage(name: '/auth', page: () => AuthPage(), transition: Transition.fadeIn),
    GetPage(name: '/settings', page: () => SettingsPage(), transition: Transition.cupertino),

    // Profile routes
    GetPage(name: '/profile', page: () => const ProfilePage(), transition: Transition.cupertino),
    GetPage(name: '/profile/edit', page: () => const EditProfilePage(), transition: Transition.cupertino),

    // Company profile routes
    GetPage(
      name: '/company/:id/profile',
      page: () {
        final companyId = Get.parameters['id']!;
        return CompanyProfilePage(companyId: companyId);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: '/company/:id/edit',
      page: () {
        final companyId = Get.parameters['id']!;
        return EditCompanyProfilePage(companyId: companyId);
      },
      transition: Transition.cupertino,
    ),

    GetPage(name: '/my-orders', page: () => const UserOrderListPage(), transition: Transition.cupertino),
    GetPage(name: '/my-systems', page: () => const MySystemsPage(), transition: Transition.cupertino),

    // Store
    GetPage(name: '/cart', page: () => const CartPage(), transition: Transition.cupertino),
    GetPage(
      name: '/store/:id',
      page: () {
        final companyId = Get.parameters['id'];
        if (companyId == null) {
          return const Scaffold(body: Center(child: Text("Invalid Company ID")));
        }
        return FutureBuilder<CompanyModel?>(
          future: fetchCompany(companyId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Scaffold(body: Center(child: Text("Company not found")));
            }
            return ShopPage(company: snapshot.data!);
          },
        );
      },
      transition: Transition.cupertino,
    ),

    // Company Dashboard
    GetPage(name: '/company_dashboard', page: () => const MainDashboardPage(), transition: Transition.fadeIn),
  ];
}
