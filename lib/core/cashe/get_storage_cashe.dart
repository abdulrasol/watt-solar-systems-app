import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/core/cashe/cashe_interface.dart';

class GetStorageCashe implements CasheInterface {
  final _box = GetStorage();

  @override
  Future<void> save(String key, dynamic value) async {
    await _box.write(key, value);
    _box.save();
  }

  @override
  dynamic get(String key) {
    return _box.read(key);
  }

  @override
  Future<void> delete(String key) async {
    await _box.remove(key);
  }

  @override
  Future<void> clear() async {
    await _box.erase();
  }
}
