import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:solar_hub/core/services/dio.dart';
import 'package:solar_hub/features/auth/controllers/auth_controller.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/controllers/currency_controller.dart';
import 'package:solar_hub/controllers/data_controller.dart';
import 'package:solar_hub/features/accounting/controllers/accounting_controller.dart';
import 'package:solar_hub/controllers/notifications_controller.dart';
import 'package:solar_hub/core/cashe/cashe_interface.dart';
import 'package:solar_hub/core/cashe/get_storage_cashe.dart';
import 'package:solar_hub/features/auth/services/auth_services.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<CasheInterface>(() {
    debugPrint('init cashe servires ');
    return GetStorageCashe();
  });
  getIt.registerLazySingleton<AuthController>(() => AuthController());
  getIt.registerLazySingleton<CompanyController>(() => CompanyController());
  getIt.registerLazySingleton<CurrencyController>(() => CurrencyController());
  getIt.registerLazySingleton<DataController>(() => DataController());
  getIt.registerLazySingleton<NotificationsController>(() => NotificationsController());
  getIt.registerLazySingleton<AccountingController>(() => AccountingController());
  getIt.registerLazySingleton<DioService>(() => DioService());
  getIt.registerLazySingleton<AuthServices>(() => AuthServices());
}
