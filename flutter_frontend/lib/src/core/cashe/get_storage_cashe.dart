import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:watt/src/core/cashe/cashe_interface.dart';
import 'package:watt/src/features/auth/domain/entities/user.dart';
import 'package:watt/src/features/settings/domain/entiteis/settings.dart';

const _tokenKey = 'token';
const _userKey = 'user';

class GetStorageCashe implements CasheInterface {
  late final GetStorage _storage;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accountName: 'watt_secure_storage',
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  String? _memoryToken;
  User? _memoryUser;

  @override
  late final CacheBox box;

  GetStorageCashe() {
    _storage = GetStorage();
    box = _GetStorageBoxAdapter(_storage);
  }

  /// Loads the auth token and user from secure storage into memory.
  /// Must be called once during app startup (e.g., from the splash screen)
  /// before any synchronous [token()] or [user()] call.
  @override
  Future<void> loadAuthFromSecureStorage() async {
    _memoryToken = await _secureStorage.read(key: _tokenKey);
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson != null) {
      try {
        _memoryUser = User.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Failed to decode cached user: $e');
        }
        _memoryUser = null;
      }
    }
  }

  @override
  Future<void> save(String key, dynamic value) async {
    await _storage.write(key, value);
    await _storage.save();
  }

  @override
  dynamic get(String key) {
    return _storage.read(key);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.remove(key);
  }

  @override
  Future<void> deleteByPrefix(String prefix) async {
    final keys = List<String>.from(_storage.getKeys<Iterable<dynamic>>());
    for (final key in keys.where((key) => key.startsWith(prefix))) {
      await _storage.remove(key);
    }
  }

  @override
  Future<void> clear() async {
    await _storage.erase();
    await _secureStorage.deleteAll();
    _memoryToken = null;
    _memoryUser = null;
  }

  @override
  User? user() => _memoryUser;

  @override
  Future<void> saveUser(User user) async {
    _memoryUser = user;
    await _secureStorage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  @override
  String? token() => _memoryToken;

  @override
  Future<void> saveToken(String token) async {
    _memoryToken = token;
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    await _storage.write('settings', settings);
    await _storage.save();
  }

  @override
  Settings settings() {
    final Map<String, dynamic>? settingsMap = _storage
        .read<Map<String, dynamic>>('settings');
    if (settingsMap == null) {
      return Settings(
        isDark: false,
        isNotificationEnabled: false,
        language: 'ar',
        saveRolePageSelection: false,
        saveRolePageSelectionRoute: null,
      );
    }
    return Settings.fromJson(settingsMap);
  }
}

class _GetStorageBoxAdapter implements CacheBox {
  const _GetStorageBoxAdapter(this._storage);

  final GetStorage _storage;

  @override
  VoidCallback listenKey(String key, void Function(dynamic value) callback) {
    return _storage.listenKey(key, callback);
  }
}
