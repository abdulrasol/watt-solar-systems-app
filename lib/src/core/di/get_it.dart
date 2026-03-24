import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/cashe/get_storage_cashe.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/admin/data/datasources/app_config_remote_data_source_impl.dart';
import 'package:solar_hub/src/features/admin/data/repositories/app_config_repository_impl.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/app_config_repository.dart';
import 'package:solar_hub/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:solar_hub/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/features/company_dashboard/data/datasource/dashboard_remote_datastore.dart';
import 'package:solar_hub/src/features/company_dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/dashboard_repository.dart';
import 'package:solar_hub/src/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:solar_hub/src/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import 'package:solar_hub/src/utils/toast_service.dart';

import 'package:solar_hub/src/features/inventory/data/data_sources/inventory_remote_data_source.dart';
import 'package:solar_hub/src/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:solar_hub/src/features/inventory/domain/repositories/inventory_repository.dart';

import 'package:solar_hub/src/features/splash/data/datasources/app_init_local_data_source.dart';
import 'package:solar_hub/src/features/splash/data/datasources/app_init_remote_data_source.dart';
import 'package:solar_hub/src/features/splash/data/repositories/app_init_repository_impl.dart';
import 'package:solar_hub/src/features/splash/domain/repositories/app_init_repository.dart';
import 'package:solar_hub/src/features/splash/domain/usecases/get_configs_usecase.dart';

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

  getIt.registerLazySingleton<DashboardRepository>(() {
    dPrint('init dashboard repository', tag: 'getIt');
    return DashboardRepositoryImpl(DashboardRemoteDatastoreImpl(getIt<DioService>()));
  });

  getIt.registerLazySingleton<InventoryRepository>(() {
    dPrint('init inventory repository', tag: 'getIt');
    return InventoryRepositoryImpl(InventoryRemoteDataSourceImpl(getIt<DioService>()));
  });

  getIt.registerLazySingleton<AppInitRemoteDataSource>(() {
    dPrint('init app init data source', tag: 'getIt');
    return AppInitRemoteDataSourceImpl(getIt<DioService>());
  });

  getIt.registerLazySingleton<AppInitLocalDataSource>(() {
    dPrint('init app init local data source', tag: 'getIt');
    return AppInitLocalDataSourceImpl(casheInterface: getIt<CasheInterface>());
  });

  getIt.registerLazySingleton<AppInitRepository>(() {
    dPrint('init app init repository', tag: 'getIt');
    return AppInitRepositoryImpl(remoteDataSource: getIt<AppInitRemoteDataSource>(), localDataSource: getIt<AppInitLocalDataSource>());
  });

  getIt.registerLazySingleton<GetConfigsUseCase>(() {
    dPrint('init get configs usecase', tag: 'getIt');
    return GetConfigsUseCase(getIt<AppInitRepository>());
  });

  getIt.registerLazySingleton<FeedbackRepository>(() {
    dPrint('init feedback repository', tag: 'getIt');
    return FeedbackRepositoryImpl();
  });

  getIt.registerLazySingleton<AppConfigRepository>(() {
    dPrint('init app config repository', tag: 'getIt');
    return AppConfigRepositoryImpl(remoteDataSource: AppConfigRemoteDataSourceImpl(dioService: getIt<DioService>()));
  });
}
