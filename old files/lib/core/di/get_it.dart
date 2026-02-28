import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/core/services/dio.dart';
import 'package:solar_hub/features/admin/controllers/admin_controller.dart';
import 'package:solar_hub/features/admin/services/admin_services.dart';
import 'package:solar_hub/features/compnay/controllers/auth_controller.dart';
import 'package:solar_hub/controllers/currency_controller.dart';
import 'package:solar_hub/controllers/data_controller.dart';
import 'package:solar_hub/features/accounting/controllers/accounting_controller.dart';
import 'package:solar_hub/controllers/notifications_controller.dart';
import 'package:solar_hub/core/cashe/cashe_interface.dart';
import 'package:solar_hub/core/cashe/get_storage_cashe.dart';
import '../../../../lib/src/features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../../lib/src/features/auth/data/repositories/auth_repository_impl.dart';
import '../../../../lib/src/features/auth/domain/repositories/auth_repository.dart';
import '../../../../lib/src/features/auth/presentation/controllers/auth_controller.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<CasheInterface>(() {
    debugPrint('init cashe servires ');
    return GetStorageCashe();
  });
  // controllers
  getIt.registerLazySingleton<AuthController>(() => Get.put(AuthController()));
  getIt.registerLazySingleton<CompanyController>(() => Get.put(CompanyController()));
  getIt.registerLazySingleton<AdminController>(() => Get.put(AdminController()));
  getIt.registerLazySingleton<CurrencyController>(() => Get.put(CurrencyController()));
  getIt.registerLazySingleton<DataController>(() => Get.put(DataController()));
  getIt.registerLazySingleton<NotificationsController>(() => Get.put(NotificationsController()));
  getIt.registerLazySingleton<AccountingController>(() => Get.put(AccountingController()));

  // services
  getIt.registerLazySingleton<DioService>(() => DioService());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(AuthDjangoDataSourceImpl()));
  getIt.registerLazySingleton<AdminServices>(() => AdminServices());
}
