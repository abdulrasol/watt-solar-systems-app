import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watt/src/core/cashe/cashe_interface.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/features/auth/domain/entities/user.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/features/calculations/presentation/providers/systems_provider.dart';
import 'package:watt/src/features/settings/domain/entiteis/settings.dart';
import 'package:watt/src/shared/domain/company/company.dart';

void main() {
  late _FakeCache cache;
  late ProviderContainer container;

  setUp(() async {
    cache = _FakeCache();
    await getIt.reset();
    getIt.registerSingleton<CasheInterface>(cache);
    container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FixedAuthController(_companyMemberAuth())),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test('saveSystemPart persists a new local system and refreshes state', () async {
    final notifier = container.read(systemsProvider.notifier);

    await notifier.saveSystemPart(
      newSystemName: 'Battery Backup',
      companyId: null,
      partName: 'batteries',
      data: const <String, dynamic>{'count': 2, 'capacity_ah': 200},
    );

    final state = container.read(systemsProvider);
    expect(state.savedSystems, hasLength(1));
    expect(state.savedSystems.single.systemName, 'Battery Backup');
    expect(state.savedSystems.single.specs['batteries']['count'], 2);
    expect((cache.get('saved_system_models') as List), hasLength(1));
  });

  test('deleteSavedSystem removes persisted systems', () async {
    final notifier = container.read(systemsProvider.notifier);
    await notifier.saveSystemPart(
      newSystemName: 'Temp System',
      companyId: null,
      partName: 'batteries',
      data: const <String, dynamic>{'count': 1},
    );
    final savedId = container.read(systemsProvider).savedSystems.single.id!;

    await notifier.deleteSavedSystem(savedId);

    expect(container.read(systemsProvider).savedSystems, isEmpty);
    expect(cache.get('saved_system_models'), isEmpty);
  });

  test('requestOffers records a local pending request marker', () async {
    final notifier = container.read(systemsProvider.notifier);
    await notifier.saveSystemPart(
      newSystemName: 'Offer System',
      companyId: null,
      partName: 'batteries',
      data: const <String, dynamic>{'count': 4},
    );
    final system = container.read(systemsProvider).savedSystems.single;

    await notifier.requestOffers(system, notes: 'Need installer pricing');

    final updated = container.read(systemsProvider).savedSystems.single;
    expect(updated.specs['offer_request']['status'], 'pending_submission');
    expect(updated.specs['offer_request']['notes'], 'Need installer pricing');
  });
}

class _FixedAuthController extends AuthController {
  _FixedAuthController(this._state);

  final AuthState _state;

  @override
  AuthState build() => _state;
}

class _FakeCacheBox implements CacheBox {
  @override
  void Function() listenKey(String key, void Function(dynamic value) callback) =>
      () {};
}

class _FakeCache implements CasheInterface {
  @override
  CacheBox box = _FakeCacheBox();

  final Map<String, dynamic> _values = <String, dynamic>{};

  @override
  Future<void> loadAuthFromSecureStorage() async {}
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
  User? user() => null;
}

AuthState _companyMemberAuth() {
  return AuthState(
    isSigned: true,
    user: _user(),
  );
}

User _user() {
  return User(
    id: 44,
    username: 'member',
    email: 'member@example.com',
    firstName: 'Member',
    lastName: 'User',
    phone: '123',
    isCompanyMember: true,
    company: Company(
      id: 12,
      name: 'Solar Co',
      allowsB2B: true,
      allowsB2C: true,
      status: 'active',
    ),
  );
}
