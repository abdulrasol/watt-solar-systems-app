import 'package:solar_hub/src/features/service_types/data/datasources/service_type_remote_data_source.dart';
import 'package:solar_hub/src/features/service_types/domain/models/service_type_form_payload.dart';
import 'package:solar_hub/src/features/service_types/domain/repositories/service_type_repository.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';

class ServiceTypeRepositoryImpl implements ServiceTypeRepository {
  final ServiceTypeRemoteDataSource _remoteDataSource;

  ServiceTypeRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ServiceType>> listPublicServiceTypes() {
    return _remoteDataSource.listPublicServiceTypes();
  }

  @override
  Future<List<ServiceType>> listAdminServiceTypes() {
    return _remoteDataSource.listAdminServiceTypes();
  }

  @override
  Future<ServiceType> createServiceType(ServiceTypeFormPayload payload) {
    return _remoteDataSource.createServiceType(payload);
  }

  @override
  Future<ServiceType> updateServiceType(
    int serviceId,
    ServiceTypeFormPayload payload,
  ) {
    return _remoteDataSource.updateServiceType(serviceId, payload);
  }

  @override
  Future<void> deleteServiceType(int serviceId) {
    return _remoteDataSource.deleteServiceType(serviceId);
  }

  @override
  Future<bool> toggleCompanyServiceType(int serviceId) {
    return _remoteDataSource.toggleCompanyServiceType(serviceId);
  }
}
