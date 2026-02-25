import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/core/cashe/cashe_interface.dart';
import 'package:solar_hub/features/auth/models/user.dart';

class GetStorageCashe implements CasheInterface {
  final box = GetStorage();

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
  Future<User> user() async {
    final userJson = box.read('user');
    if (userJson == null) {
      throw Exception('User not found in cache');
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
  Future<String?> token() async {
    final token = box.read('token');
    if (token == null) {
      return null;
    }
    return token;
  }
}
