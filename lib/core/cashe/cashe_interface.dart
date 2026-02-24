abstract class CasheInterface {
  Future<void> save(String key, dynamic value);
  dynamic get(String key); // Changed to synchronous
  Future<void> delete(String key);
  Future<void> clear();
}
