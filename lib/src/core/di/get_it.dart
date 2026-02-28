import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/cashe/get_storage_cashe.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:solar_hub/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import 'package:solar_hub/src/utils/toast_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<CasheInterface>(() {
    dPrint('init cashe servires', tag: 'getIt');
    GetStorage.init();
    return GetStorageCashe();
  });

  getIt.registerLazySingleton<ToastService>(() => ToastService());

  getIt.registerLazySingleton<AuthRepository>(() {
    dPrint('init auth repository', tag: 'getIt');
    return AuthRepositoryImpl(AuthDjangoDataSourceImpl());
  });

  getIt.registerLazySingleton<DioService>(() {
    dPrint('init dio service', tag: 'getIt');
    return DioService();
  });
}
