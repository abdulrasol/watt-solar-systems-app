import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';
import 'package:solar_hub/src/features/settings/domain/entiteis/settings.dart';

class GetStorageCashe implements CasheInterface {
  @override
  late final box;

  GetStorageCashe() {
    box = GetStorage();
  }

  @override
  Future<void> save(String key, dynamic value) async {
    await box.write(key, value);
    box.save();
  }

  @override
  dynamic get(String key) {
    return box.read(key);
  }

  @override
  Future<void> delete(String key) async {
    await box.remove(key);
  }

  @override
  Future<void> clear() async {
    await box.erase();
  }

  @override
  User? user() {
    final userJson = box.read('user');
    if (userJson == null) {
      return null;
    }
    return User.fromJson(userJson);
  }

  @override
  Future<void> saveUser(User user) async {
    await box.write('user', user.toJson());
    box.save();
  }

  @override
  Future<void> saveToken(String token) async {
    await box.write('token', token);
    box.save();
  }

  @override
  String? token() {
    final token = box.read('token');
    if (token == null) {
      return null;
    }
    return token;
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    await box.write('settings', settings);
    box.save();
  }

  @override
  Settings settings() {
    final Map<String, dynamic>? settingsMap = box.read<Map<String, dynamic>>('settings');
    if (settingsMap == null) {
      return Settings(isDark: false, isNotificationEnabled: false, language: 'ar', saveRolePageSelection: false, saveRolePageSelectionRoute: null);
    }
    return Settings.fromJson(settingsMap);
  }
}
