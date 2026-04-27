import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/cashe/get_storage_cashe.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/core/services/network_status_service.dart';
import 'package:solar_hub/src/core/services/push_notification_service.dart';
import 'package:solar_hub/src/features/admin/data/data_sources/app_config_remote_data_source_impl.dart';
import 'package:solar_hub/src/features/admin/data/repositories/app_config_repository_impl.dart';
import 'package:solar_hub/src/features/admin/data/repositories/notification_repository_impl.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/app_config_repository.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/notification_repository.dart';
import 'package:solar_hub/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:solar_hub/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
// import 'package:solar_hub/src/features/company_dashboard/data/datasource/dashboard_remote_datastore.dart';
// import 'package:solar_hub/src/features/company_dashboard/data/repositories/dashboard_repository_impl.dart';
// import 'package:solar_hub/src/features/company_dashboard/domain/repositories/dashboard_repository.dart';
import 'package:solar_hub/src/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:solar_hub/src/features/feedback/data/data_sourece/remote_data_source.dart';
import 'package:solar_hub/src/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:solar_hub/src/features/splash/domain/repositories/app_init_repository.dart';
import 'package:solar_hub/src/features/company_dashboard/data/datasources/local_datasource.dart';
import 'package:solar_hub/src/features/company_dashboard/data/datasources/remote_datasource.dart';
import 'package:solar_hub/src/features/company_dashboard/data/repositoies/company_summery_repository_impl.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/dashboard_repository.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/usecases/get_company_usecase.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import 'package:solar_hub/src/services/toast_service.dart';

import 'package:solar_hub/src/features/inventory/data/data_sources/inventory_remote_data_source.dart';
import 'package:solar_hub/src/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:solar_hub/src/features/company_work/data/data_sources/company_work_remote_data_source.dart';
import 'package:solar_hub/src/features/company_work/data/repositories/company_work_repository_impl.dart';
import 'package:solar_hub/src/features/company_dashboard/data/data_sources/company_management_remote_data_source.dart';
import 'package:solar_hub/src/features/company_dashboard/data/repositories/company_management_repository_impl.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/company_management_repository.dart';
import 'package:solar_hub/src/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:solar_hub/src/features/company_work/domain/repositories/company_work_repository.dart';
import 'package:solar_hub/src/features/members/data/data_sources/members_remote_data_source.dart';
import 'package:solar_hub/src/features/members/data/repositories/members_repository_impl.dart';
import 'package:solar_hub/src/features/members/domain/repositories/members_repository.dart';
import 'package:solar_hub/src/features/notifications/data/repositories/notification_history_repository_impl.dart';
import 'package:solar_hub/src/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:solar_hub/src/features/offers/data/data_sources/offers_remote_data_source.dart';
import 'package:solar_hub/src/features/offers/data/data_sources/offers_remote_data_source_impl.dart';
import 'package:solar_hub/src/features/offers/data/repositories/offers_repository_impl.dart';
import 'package:solar_hub/src/features/offers/domain/repositories/offers_repository.dart';
import 'package:solar_hub/src/features/splash/data/datasources/app_init_local_data_source.dart';
import 'package:solar_hub/src/features/splash/data/datasources/app_init_remote_data_source.dart';
import 'package:solar_hub/src/features/splash/data/repositories/app_init_repository_impl.dart';
import 'package:solar_hub/src/features/splash/domain/usecases/get_cached_configs_usecase.dart';
import 'package:solar_hub/src/features/splash/domain/usecases/get_configs_usecase.dart';
import 'package:solar_hub/src/features/splash/domain/usecases/prepare_startup_usecase.dart';
import 'package:solar_hub/src/features/splash/domain/usecases/refresh_configs_usecase.dart';
import 'package:solar_hub/src/features/admin/data/data_sources/admin_remote_data_source.dart';
import 'package:solar_hub/src/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:solar_hub/src/features/accounting/data/datasources/accounting_remote_data_source.dart';
import 'package:solar_hub/src/features/accounting/data/repositories/accounting_repository_impl.dart';
import 'package:solar_hub/src/features/accounting/domain/repositories/accounting_repository.dart';
import 'package:solar_hub/src/features/crm/data/datasources/crm_remote_data_source.dart';
import 'package:solar_hub/src/features/crm/data/repositories/crm_repository_impl.dart';
import 'package:solar_hub/src/features/crm/domain/repositories/crm_repository.dart';
import 'package:solar_hub/src/features/orders_buyer/data/datasources/orders_remote_data_source.dart';
import 'package:solar_hub/src/features/orders_buyer/data/repositories/orders_repository_impl.dart';
import 'package:solar_hub/src/features/orders_buyer/domain/repositories/orders_repository.dart';
import 'package:solar_hub/src/features/storefront/data/datasources/storefront_remote_data_source.dart';
import 'package:solar_hub/src/features/storefront/data/repositories/storefront_repository_impl.dart';
import 'package:solar_hub/src/features/storefront/domain/repositories/storefront_repository.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:solar_hub/src/features/services/data/datasources/public_services_remote_data_source.dart';
import 'package:solar_hub/src/features/services/data/repositories/public_services_repository_impl.dart';
import 'package:solar_hub/src/features/services/domain/repositories/public_services_repository.dart';
import 'package:solar_hub/src/features/service_types/data/datasources/service_type_remote_data_source.dart';
import 'package:solar_hub/src/features/service_types/data/repositories/service_type_repository_impl.dart';
import 'package:solar_hub/src/features/service_types/domain/repositories/service_type_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<CasheInterface>(() {
    dPrint('init cashe servires', tag: 'getIt');
    GetStorage.init();
    return GetStorageCashe();
  });

  getIt.registerLazySingleton<ToastService>(() => ToastService());

  getIt.registerLazySingleton<NetworkStatusService>(
    () => NetworkStatusService(),
  );

  getIt.registerLazySingleton<AuthRepository>(() {
    dPrint('init auth repository', tag: 'getIt');
    return AuthRepositoryImpl(AuthDjangoDataSourceImpl());
  });

  getIt.registerLazySingleton<DioService>(() {
    dPrint('init dio service', tag: 'getIt');
    return DioService();
  });

  getIt.registerLazySingleton<PushNotificationService>(() {
    dPrint('init push notification service', tag: 'getIt');
    return PushNotificationService();
  });

  getIt.registerLazySingleton<InventoryRepository>(() {
    dPrint('init inventory repository', tag: 'getIt');
    return InventoryRepositoryImpl(
      InventoryRemoteDataSourceImpl(getIt<DioService>()),
    );
  });

  getIt.registerLazySingleton<CompanyWorkRepository>(() {
    dPrint('init company work repository', tag: 'getIt');
    return CompanyWorkRepositoryImpl(
      CompanyWorkRemoteDataSourceImpl(getIt<DioService>()),
    );
  });

  getIt.registerLazySingleton<MembersRemoteDataSource>(() {
    dPrint('init members remote data source', tag: 'getIt');
    return MembersRemoteDataSourceImpl(getIt<DioService>());
  });

  getIt.registerLazySingleton<MembersRepository>(() {
    dPrint('init members repository', tag: 'getIt');
    return MembersRepositoryImpl(getIt<MembersRemoteDataSource>());
  });

  getIt.registerLazySingleton<StorefrontRepository>(() {
    dPrint('init storefront repository', tag: 'getIt');
    return StorefrontRepositoryImpl(
      StorefrontRemoteDataSourceImpl(getIt<DioService>()),
    );
  });

  getIt.registerLazySingleton<StorefrontCartController>(() {
    dPrint('init storefront cart controller', tag: 'getIt');
    return StorefrontCartController(getIt<CasheInterface>());
  });

  getIt.registerLazySingleton<PublicServicesRepository>(() {
    dPrint('init public services repository', tag: 'getIt');
    return PublicServicesRepositoryImpl(
      PublicServicesRemoteDataSourceImpl(getIt<DioService>()),
    );
  });

  getIt.registerLazySingleton<ServiceTypeRepository>(() {
    dPrint('init service type repository', tag: 'getIt');
    return ServiceTypeRepositoryImpl(
      ServiceTypeRemoteDataSourceImpl(getIt<DioService>()),
    );
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
    return AppInitRepositoryImpl(
      remoteDataSource: getIt<AppInitRemoteDataSource>(),
      localDataSource: getIt<AppInitLocalDataSource>(),
    );
  });

  getIt.registerLazySingleton<GetConfigsUseCase>(() {
    dPrint('init get configs usecase', tag: 'getIt');
    return GetConfigsUseCase(getIt<AppInitRepository>());
  });

  getIt.registerLazySingleton<GetCachedConfigsUseCase>(() {
    dPrint('init get cached configs usecase', tag: 'getIt');
    return GetCachedConfigsUseCase(getIt<AppInitRepository>());
  });

  getIt.registerLazySingleton<RefreshConfigsUseCase>(() {
    dPrint('init refresh configs usecase', tag: 'getIt');
    return RefreshConfigsUseCase(getIt<AppInitRepository>());
  });

  getIt.registerLazySingleton<PrepareStartupUseCase>(() {
    dPrint('init prepare startup usecase', tag: 'getIt');
    return PrepareStartupUseCase(cache: getIt<CasheInterface>());
  });

  getIt.registerLazySingleton<FeedbackRepository>(() {
    dPrint('init feedback repository', tag: 'getIt');
    return FeedbackRepositoryImpl(getIt<FeedbackRemoteDataSource>());
  });

  getIt.registerLazySingleton<FeedbackRemoteDataSource>(() {
    dPrint('init feedback remote data source', tag: 'getIt');
    return FeedbackRemoteDataSourceImpl(getIt<DioService>());
  });

  getIt.registerLazySingleton<AppConfigRepository>(() {
    dPrint('init app config repository', tag: 'getIt');
    return AppConfigRepositoryImpl(
      remoteDataSource: AppConfigRemoteDataSourceImpl(
        dioService: getIt<DioService>(),
      ),
    );
  });

  getIt.registerLazySingleton<NotificationRepository>(() {
    dPrint('init notification repository', tag: 'getIt');
    return NotificationRepositoryImpl(getIt<DioService>());
  });

  getIt.registerLazySingleton<NotificationHistoryRepository>(() {
    dPrint('init notification history repository', tag: 'getIt');
    return NotificationHistoryRepositoryImpl(getIt<DioService>());
  });

  getIt.registerLazySingleton<LocalDataSource>(() {
    dPrint('init company summery local data source', tag: 'getIt');
    return LocalDataSourceImpl(casheInterface: getIt<CasheInterface>());
  });

  getIt.registerLazySingleton<RemoteDataSource>(() {
    dPrint('init company summery remote data source', tag: 'getIt');
    return RemoteDataSourceImpl();
  });

  getIt.registerLazySingleton<CompanySummeryRepository>(() {
    dPrint('init company summery repository', tag: 'getIt');
    return CompanySummeryRepositoryImpl(
      remoteDataSource: getIt<RemoteDataSource>(),
      localDataSource: getIt<LocalDataSource>(),
    );
  });

  getIt.registerLazySingleton<GetCompanySummeryUseCase>(() {
    dPrint('init get company summery usecase', tag: 'getIt');
    return GetCompanySummeryUseCase(
      repository: getIt<CompanySummeryRepository>(),
    );
  });

  // ==================== OFFERS & REQUESTS ====================
  getIt.registerLazySingleton<OffersRemoteDataSource>(() {
    dPrint('init offers remote data source', tag: 'getIt');
    return OffersRemoteDataSourceImpl(getIt<DioService>());
  });

  getIt.registerLazySingleton<OffersRepository>(() {
    dPrint('init offers repository', tag: 'getIt');
    return OffersRepositoryImpl(getIt<OffersRemoteDataSource>());
  });

  // ==================== ADMIN = :joined companies section ====================
  getIt.registerLazySingleton<AdminRemoteDataSource>(() {
    dPrint('init admin remote data source', tag: 'getIt');
    return AdminRemoteDataSourceImpl(getIt<DioService>());
  });

  getIt.registerLazySingleton<AdminRepository>(() {
    dPrint('init admin repository', tag: 'getIt');
    return AdminRepositoryImpl(getIt<AdminRemoteDataSource>());
  });

  getIt.registerLazySingleton<CompanyManagementRemoteDataSource>(() {
    dPrint('init company management remote data source', tag: 'getIt');
    return CompanyManagementRemoteDataSourceImpl(getIt<DioService>());
  });

  getIt.registerLazySingleton<CompanyManagementRepository>(() {
    dPrint('init company management repository', tag: 'getIt');
    return CompanyManagementRepositoryImpl(
      getIt<CompanyManagementRemoteDataSource>(),
    );
  });

  getIt.registerLazySingleton<OrdersRemoteDataSource>(() {
    dPrint('init orders remote data source', tag: 'getIt');
    return OrdersRemoteDataSourceImpl(getIt<DioService>());
  });

  getIt.registerLazySingleton<OrdersRepository>(() {
    dPrint('init orders repository', tag: 'getIt');
    return OrdersRepositoryImpl(getIt<OrdersRemoteDataSource>());
  });

  getIt.registerLazySingleton<CrmRemoteDataSource>(() {
    dPrint('init crm remote data source', tag: 'getIt');
    return CrmRemoteDataSourceImpl(getIt<DioService>());
  });

  getIt.registerLazySingleton<CrmRepository>(() {
    dPrint('init crm repository', tag: 'getIt');
    return CrmRepositoryImpl(getIt<CrmRemoteDataSource>());
  });

  getIt.registerLazySingleton<AccountingRemoteDataSource>(() {
    dPrint('init accounting remote data source', tag: 'getIt');
    return AccountingRemoteDataSourceImpl(getIt<DioService>());
  });

  getIt.registerLazySingleton<AccountingRepository>(() {
    dPrint('init accounting repository', tag: 'getIt');
    return AccountingRepositoryImpl(getIt<AccountingRemoteDataSource>());
  });
}
