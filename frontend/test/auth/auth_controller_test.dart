import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/core/services/network_status_service.dart';
import 'package:solar_hub/src/core/services/push_notification_service.dart';
import 'package:solar_hub/src/features/auth/domain/entities/auth_response.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/settings/domain/entiteis/settings.dart';

void main() {
  late _FakeCache cache;
  late _FakePushNotificationService pushService;
  ProviderContainer? container;

  setUp(() async {
    cache = _FakeCache();
    await getIt.reset();
    getIt.registerSingleton<CasheInterface>(cache);
    getIt.registerSingleton<NetworkStatusService>(NetworkStatusService());
    getIt.registerSingleton<DioService>(DioService());
    pushService = _FakePushNotificationService();
    getIt.registerSingleton<PushNotificationService>(pushService);
    container = ProviderContainer();
  });

  tearDown(() async {
    container?.dispose();
    container = null;
    await getIt.reset();
  });

  test('login and logout keep auth state and cache in sync', () async {
    final notifier = container!.read(authProvider.notifier);
    final user = _user();

    await notifier.login(AuthResponse(token: 'token-1', user: user));

    expect(container!.read(authProvider).isSigned, isTrue);
    expect(cache.token(), 'token-1');
    expect(cache.user()?.id, user.id);
    expect(pushService.authenticatedCalls, 1);

    await notifier.logout();

    expect(container!.read(authProvider).isSigned, isFalse);
    expect(cache.token(), isNull);
    expect(cache.user(), isNull);
    expect(pushService.loggedOutCalls, 1);
  });

  test('storage listener updates state and is disposed with the provider', () async {
    container!.read(authProvider);

    cache.emitUser(_user(id: 9, username: 'listener'));
    expect(container!.read(authProvider).user?.id, 9);
    expect(cache.listenerCount, 1);

    container!.dispose();
    container = null;

    expect(cache.listenerCount, 0);
  });
}

class _FakePushNotificationService extends PushNotificationService {
  int authenticatedCalls = 0;
  int loggedOutCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> onAuthenticated() async {
    authenticatedCalls += 1;
  }

  @override
  Future<void> onLoggedOut() async {
    loggedOutCalls += 1;
  }
}

class _FakeCacheBox implements CacheBox {
  final Map<String, List<void Function(dynamic value)>> _listeners =
      <String, List<void Function(dynamic value)>>{};

  @override
  VoidCallback listenKey(String key, void Function(dynamic value) callback) {
    _listeners.putIfAbsent(key, () => <void Function(dynamic value)>[]).add(
      callback,
    );
    return () {
      _listeners[key]?.remove(callback);
      if (_listeners[key]?.isEmpty ?? false) {
        _listeners.remove(key);
      }
    };
  }

  void emit(String key, dynamic value) {
    final callbacks = List<void Function(dynamic value)>.from(
      _listeners[key] ?? const <void Function(dynamic value)>[],
    );
    for (final callback in callbacks) {
      callback(value);
    }
  }

  int get listenerCount =>
      _listeners.values.fold<int>(0, (sum, listeners) => sum + listeners.length);
}

class _FakeCache implements CasheInterface {
  @override
  CacheBox box = _FakeCacheBox();

  final Map<String, dynamic> _values = <String, dynamic>{};

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> deleteByPrefix(String prefix) async {
    _values.removeWhere((key, value) => key.startsWith(prefix));
  }

  void emitUser(User? user) {
    if (user == null) {
      _values.remove('user');
      (box as _FakeCacheBox).emit('user', null);
      return;
    }
    _values['user'] = user.toJson();
    (box as _FakeCacheBox).emit('user', user.toJson());
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

  int get listenerCount => (box as _FakeCacheBox).listenerCount;
}

User _user({int id = 7, String username = 'tester'}) {
  return User(
    id: id,
    username: username,
    email: '$username@example.com',
    firstName: 'Test',
    lastName: 'User',
    phone: '123',
  );
}
