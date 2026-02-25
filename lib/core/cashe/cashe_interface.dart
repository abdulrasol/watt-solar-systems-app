import 'package:solar_hub/features/auth/models/user.dart';

abstract class CasheInterface {
  Future<void> save(String key, dynamic value);
  dynamic get(String key); // Changed to synchronous
  Future<void> delete(String key);
  Future<void> clear();
  Future<void> saveUser(User user);
  Future<User> user();
  Future<void> saveToken(String token);
  Future<String?> token();
}
