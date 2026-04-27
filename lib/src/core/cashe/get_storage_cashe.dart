import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';
import 'package:solar_hub/src/features/settings/domain/entiteis/settings.dart';

class GetStorageCashe implements CasheInterface {
  late final GetStorage _storage;

  @override
  late final CacheBox box;

  GetStorageCashe() {
    _storage = GetStorage();
    box = _GetStorageBoxAdapter(_storage);
  }

  @override
  Future<void> save(String key, dynamic value) async {
    await _storage.write(key, value);
    _storage.save();
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
  Future<void> clear() async {
    await _storage.erase();
  }

  @override
  User? user() {
    final userJson = _storage.read('user');
    if (userJson == null) {
      return null;
    }
    return User.fromJson(userJson);
  }

  @override
  Future<void> saveUser(User user) async {
    await _storage.write('user', user.toJson());
    _storage.save();
  }

  @override
  Future<void> saveToken(String token) async {
    await _storage.write('token', token);
    _storage.save();
  }

  @override
  String? token() {
    final token = _storage.read('token');
    if (token == null) {
      return null;
    }
    return token;
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    await _storage.write('settings', settings);
    _storage.save();
  }

  @override
  Settings settings() {
    final Map<String, dynamic>? settingsMap = _storage.read<Map<String, dynamic>>('settings');
    if (settingsMap == null) {
      return Settings(isDark: false, isNotificationEnabled: false, language: 'ar', saveRolePageSelection: false, saveRolePageSelectionRoute: null);
    }
    return Settings.fromJson(settingsMap);
  }
}

class _GetStorageBoxAdapter implements CacheBox {
  const _GetStorageBoxAdapter(this._storage);

  final GetStorage _storage;

  @override
  void listenKey(String key, void Function(dynamic value) callback) {
    _storage.listenKey(key, callback);
  }
}
