import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:watt/src/core/cashe/cashe_interface.dart';
import 'package:watt/src/core/cashe/get_storage_cashe.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GetStorageCashe cache;
  late Directory storageDirectory;

  setUpAll(() {
    storageDirectory = Directory.systemTemp.createTempSync(
      'solar_hub_cache_test_',
    );
    PathProviderPlatform.instance = _FakePathProviderPlatform(
      storageDirectory.path,
    );
  });

  tearDownAll(() {
    if (storageDirectory.existsSync()) {
      storageDirectory.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    await GetStorage.init();
    await GetStorage().erase();
    cache = GetStorageCashe();
  });

  tearDown(() async {
    await GetStorage().erase();
  });

  test('deleteByPrefix removes only matching legacy http cache keys', () async {
    await cache.save('${legacyHttpCachePrefix}http_cache:/companies', 'old');
    await cache.save('${legacyHttpCachePrefix}http_cache:/profile', 'old');
    await cache.save('token', 'auth-token');
    await cache.save('settings', {'language': 'ar'});
    await cache.save('storefront_company_carts_v2', {'items': []});

    await cache.deleteByPrefix(legacyHttpCachePrefix);

    expect(cache.get('${legacyHttpCachePrefix}http_cache:/companies'), isNull);
    expect(cache.get('${legacyHttpCachePrefix}http_cache:/profile'), isNull);
    expect(cache.get('token'), 'auth-token');
    expect(cache.get('settings'), {'language': 'ar'});
    expect(cache.get('storefront_company_carts_v2'), {'items': []});
  });
}
