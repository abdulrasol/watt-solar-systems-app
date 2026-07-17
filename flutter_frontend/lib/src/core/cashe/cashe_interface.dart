import 'package:flutter/foundation.dart';
import 'package:watt/src/features/auth/domain/entities/user.dart';
import 'package:watt/src/features/settings/domain/entiteis/settings.dart';

const legacyHttpCachePrefix = '_http_cache_';

abstract class CacheBox {
  VoidCallback listenKey(String key, void Function(dynamic value) callback);
}

abstract class CasheInterface {
  late final CacheBox box;

  /// Loads sensitive auth data (token, user) from secure storage into memory.
  /// Call once during app startup before using [token()] or [user()].
  Future<void> loadAuthFromSecureStorage();

  Future<void> save(String key, dynamic value);
  dynamic get(String key); // Changed to synchronous
  Future<void> delete(String key);
  Future<void> deleteByPrefix(String prefix);
  Future<void> clear();
  Future<void> saveUser(User user);
  User? user();
  Future<void> saveToken(String token);
  String? token();
  Future<void> saveSettings(Settings settings);
  Settings settings();
}
