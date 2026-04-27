import 'package:dio/dio.dart';
import 'package:solar_hub/src/core/models/response.dart' as api;
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/service_types/domain/models/service_type_form_payload.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class ServiceTypeRemoteDataSource {
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

class ServiceTypeRemoteDataSourceImpl implements ServiceTypeRemoteDataSource {
  final DioService _dioService;

  ServiceTypeRemoteDataSourceImpl(this._dioService);

  @override
  Future<List<ServiceType>> listPublicServiceTypes() async {
    try {
      final response = await _dioService.get(
        AppUrls.serviceTypesPublic,
        isList: true,
      );
      final body = (response as api.ListResponse).body as List? ?? const [];
      return body
          .whereType<Map>()
          .map((item) => ServiceType.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    } catch (e, stackTrace) {
      dPrint(
        'listPublicServiceTypes error: $e',
        stackTrace: stackTrace,
        tag: 'ServiceTypeRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<List<ServiceType>> listAdminServiceTypes() async {
    try {
      final response = await _dioService.get(
        AppUrls.serviceTypes,
        isList: true,
      );
      final body = (response as api.ListResponse).body as List? ?? const [];
      return body
          .whereType<Map>()
          .map((item) => ServiceType.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    } catch (e, stackTrace) {
      dPrint(
        'listAdminServiceTypes error: $e',
        stackTrace: stackTrace,
        tag: 'ServiceTypeRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<ServiceType> createServiceType(ServiceTypeFormPayload payload) async {
    final response = await _dioService.multipartRequest(
      AppUrls.serviceTypes,
      file: await _buildFormData(payload),
    );
    return ServiceType.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<ServiceType> updateServiceType(
    int serviceId,
    ServiceTypeFormPayload payload,
  ) async {
    final response = await _dioService.multipartRequest(
      AppUrls.serviceType(serviceId),
      file: await _buildFormData(payload),
      isPut: true,
    );
    return ServiceType.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<void> deleteServiceType(int serviceId) async {
    await _dioService.delete(AppUrls.serviceType(serviceId));
  }

  @override
  Future<bool> toggleCompanyServiceType(int serviceId) async {
    final response = await _dioService.post(
      AppUrls.toggleServiceType(serviceId),
    );
    final body = response.body;
    if (body is Map<String, dynamic>) {
      return body['selected'] == true;
    }
    return false;
  }

  Future<FormData> _buildFormData(ServiceTypeFormPayload payload) async {
    final formData = FormData();
    if (payload.name != null) {
      formData.fields.add(MapEntry('name', payload.name!));
    }
    if (payload.description != null) {
      formData.fields.add(MapEntry('description', payload.description!));
    }
    if (payload.imagePath != null && payload.imagePath!.isNotEmpty) {
      formData.files.add(
        MapEntry('image', await MultipartFile.fromFile(payload.imagePath!)),
      );
    }
    return formData;
  }
}
