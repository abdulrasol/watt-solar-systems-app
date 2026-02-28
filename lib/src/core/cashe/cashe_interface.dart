import 'package:solar_hub/src/features/auth/domain/entities/user.dart';
import 'package:solar_hub/src/features/settings/domain/entiteis/settings.dart';

abstract class CasheInterface {
  late final box;
  Future<void> save(String key, dynamic value);
  dynamic get(String key); // Changed to synchronous
  Future<void> delete(String key);
  Future<void> clear();
  Future<void> saveUser(User user);
  User? user();
  Future<void> saveToken(String token);
  String? token();
  Future<void> saveSettings(Settings settings);
  Settings settings();
}
