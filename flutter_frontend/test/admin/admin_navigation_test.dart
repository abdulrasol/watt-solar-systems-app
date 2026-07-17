import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:watt/src/core/cashe/cashe_interface.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:watt/src/features/admin/presentation/models/admin_module.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_feedbacks_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/app_configs_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/send_notification_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/companies/admin_companies_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/companies/admin_service_types_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_currency_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_categories_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_address_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_subscription_plans_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_products_screen.dart';
import 'package:watt/src/features/admin/presentation/screens/admin_systems_screen.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_shell.dart';
import 'package:watt/src/features/auth/domain/entities/user.dart';
import 'package:watt/src/features/settings/domain/entiteis/settings.dart';

class _FakeCache implements CasheInterface {
  @override
  late final CacheBox box;
  @override
  Future<void> loadAuthFromSecureStorage() async {}
  @override
  Future<void> clear() async {}
  @override
  Future<void> delete(String key) async {}
  @override
  Future<void> deleteByPrefix(String prefix) async {}
  @override
  dynamic get(String key) => null;
  @override
  Future<void> save(String key, dynamic value) async {}
  @override
  Future<void> saveSettings(Settings settings) async {}
  @override
  Future<void> saveToken(String token) async {}
  @override
  Future<void> saveUser(User user) async {}
  @override
  Settings settings() => Settings(isDark: false, isNotificationEnabled: true, language: 'en', saveRolePageSelection: false);
  @override
  String? token() => null;
  @override
  User? user() => null;
}

class _FakeAdminRepository implements AdminRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerLazySingleton<CasheInterface>(() => _FakeCache());
    getIt.registerLazySingleton<AdminRepository>(() => _FakeAdminRepository());
  });

  Future<void> pumpAdminApp(WidgetTester tester, String location) async {
    final router = GoRouter(
      initialLocation: location,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AdminShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/admin', builder: (context, state) => const AdminDashboard())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/feedbacks', builder: (context, state) => const AdminFeedbacksScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/configs', builder: (context, state) => const AppConfigsScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/send-notification', builder: (context, state) => const SendNotificationScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/companies', builder: (context, state) => const AdminCompaniesScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/service-types', builder: (context, state) => const AdminServiceTypesScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/currencies', builder: (context, state) => const AdminCurrencyScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/categories', builder: (context, state) => const AdminCategoriesScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/address', builder: (context, state) => const AdminAddressScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/subscriptions', builder: (context, state) => const AdminSubscriptionPlansScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/products', builder: (context, state) => const AdminProductsScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/systems', builder: (context, state) => const AdminSystemsScreen())]),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1280, 900),
        child: ProviderScope(child: MaterialApp.router(routerConfig: router)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Admin Navigation Tests', () {
    for (final module in AdminModules.navItems) {
      testWidgets('Navigation to ${module.label}', (tester) async {
        await pumpAdminApp(tester, module.route);
        expect(find.text(module.label), findsWidgets);
      });
    }
  });
}
