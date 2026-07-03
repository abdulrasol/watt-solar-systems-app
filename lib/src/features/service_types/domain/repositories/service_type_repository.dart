import 'package:solar_hub/src/features/service_types/domain/models/service_type_form_payload.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';

abstract class ServiceTypeRepository {
  Future<List<ServiceType>> listPublicServiceTypes();
  Future<List<ServiceType>> listAdminServiceTypes();
  Future<ServiceType> createServiceType(ServiceTypeFormPayload payload);
  Future<ServiceType> updateServiceType(
    int serviceId,
    ServiceTypeFormPayload payload,
  );
  Future<void> deleteServiceType(int serviceId);
  Future<bool> toggleCompanyServiceType(int serviceId);
}
