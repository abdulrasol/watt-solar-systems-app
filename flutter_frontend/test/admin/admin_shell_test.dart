import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company_details.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_city.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_country.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_currency.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_global_category.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_subscription_plan.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_user.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:solar_hub/src/features/admin/presentation/screens/companies/admin_companies_screen.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_dashboard_card.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_shell.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';
import 'package:solar_hub/src/features/settings/domain/entiteis/settings.dart';

class _FakeBox implements CacheBox {
  @override
  VoidCallback listenKey(String key, void Function(dynamic) listener) => () {};
}

class _FakeCache implements CasheInterface {
  @override
  CacheBox box = _FakeBox();

  final Map<String, dynamic> _values = <String, dynamic>{};

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> deleteByPrefix(String prefix) async {
    _values.removeWhere((key, value) => key.startsWith(prefix));
  }

  @override
  dynamic get(String key) => _values[key];

  @override
  Future<void> save(String key, dynamic value) async {
    _values[key] = value;
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    _values['settings'] = settings.toJson();
  }

  @override
  Future<void> saveToken(String token) async {
    _values['token'] = token;
  }

  @override
  Future<void> saveUser(User user) async {
    _values['user'] = user.toJson();
  }

  @override
  Settings settings() => Settings(
    isDark: false,
    isNotificationEnabled: true,
    language: 'en',
    saveRolePageSelection: false,
  );

  @override
  String? token() => _values['token'] as String?;

  @override
  User? user() {
    final raw = _values['user'];
    if (raw is Map<String, dynamic>) {
      return User.fromJson(raw);
    }
    return null;
  }
}

class _FakeAdminRepository implements AdminRepository {
  int listCompaniesCalls = 0;

  @override
  Future<List<Company>> listCompanies({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    listCompaniesCalls++;
    return [];
  }

  @override
  Future<AdminCompanyDetails> getCompanyDetails(int companyId) {
    throw UnimplementedError();
  }

  @override
  Future<List<CompanyService>> listCompanyServices(int companyId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ServiceCatalogItem>> listServiceCatalog() async => [];


  @override
  Future<ServiceCatalogItem> createServiceCatalogEntry(
    ServiceCatalogItem item,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteServiceCatalogEntry(String serviceCode) async {}


 
  @override
  Future<ServiceCatalogItem> updateServiceCatalogEntry(
    String serviceCode,
    Map<String, dynamic> data,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCompanyStatus(int companyId, String status) async {}

  @override
  Future<List<AdminCurrency>> listCurrencies({int page = 1, int pageSize = 12}) async => [];
  @override
  Future<AdminCurrency> createCurrency(Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<AdminCurrency> updateCurrency(int id, Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<void> deleteCurrency(int id) async {}

  @override
  Future<List<AdminCountry>> listCountries() async => [];
  @override
  Future<AdminCountry> createCountry(Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<AdminCountry> updateCountry(int id, Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<void> deleteCountry(int id) async {}

  @override
  Future<List<AdminCity>> listCities({int? countryId}) async => [];
  @override
  Future<AdminCity> createCity(Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<AdminCity> updateCity(int id, Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<void> deleteCity(int id) async {}

  @override
  Future<List<AdminGlobalCategory>> listGlobalCategories({int page = 1, int pageSize = 12}) async => [];
  @override
  Future<AdminGlobalCategory> createGlobalCategory(Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<AdminGlobalCategory> updateGlobalCategory(int id, Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<void> deleteGlobalCategory(int id) async {}

  @override
  Future<List<AdminUser>> listUsers({int page = 1, int pageSize = 12}) async => [];
  @override
  Future<void> promoteUser(String username, bool promote) async {}

  @override
  Future<List<AdminSubscriptionPlan>> listSubscriptionPlans({int page = 1, int pageSize = 12}) async => [];
  @override
  Future<AdminSubscriptionPlan> createSubscriptionPlan(Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<AdminSubscriptionPlan> updateSubscriptionPlan(int id, Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<void> deleteSubscriptionPlan(int id) async {}
}

void main() {
  late _FakeAdminRepository repository;

  setUp(() async {
    repository = _FakeAdminRepository();
    await getIt.reset();
    getIt.registerLazySingleton<CasheInterface>(() => _FakeCache());
    getIt.registerLazySingleton<AdminRepository>(() => repository);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpAdminApp(
    WidgetTester tester, {
    required String initialLocation,
    required Size size,
  }) async {
    await tester.binding.setSurfaceSize(size);

    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return AdminShell(location: state.uri.path, child: child);
          },
          routes: [
            GoRoute(
              path: '/admin',
              builder: (context, state) => const AdminDashboard(),
            ),
            GoRoute(
              path: '/admin/companies',
              builder: (context, state) => const AdminCompaniesScreen(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        child: ProviderScope(child: MaterialApp.router(routerConfig: router)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard route does not trigger company loading', (
    tester,
  ) async {
    await pumpAdminApp(
      tester,
      initialLocation: '/admin',
      size: const Size(390, 844),
    );

    expect(find.byType(AdminDashboard), findsOneWidget);
    expect(find.byType(AdminDashboardCard), findsWidgets);
    expect(find.text('Open section'), findsWidgets);
    expect(repository.listCompaniesCalls, 0);
  });

  testWidgets('companies route lazy-loads only when opened', (tester) async {
    await pumpAdminApp(
      tester,
      initialLocation: '/admin/companies',
      size: const Size(1280, 900),
    );

    expect(find.text('Companies'), findsWidgets);
    expect(find.text('No companies found'), findsOneWidget);
    expect(repository.listCompaniesCalls, 1);
  });
}
