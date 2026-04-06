import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/core/models/response.dart' as api;
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class AdminRemoteDataSource {
  Future<api.PaginationResponse> listCompanies({String? status, int page = 1, int pageSize = 20});
  Future<api.Response> updateCompanyStatus(int companyId, String status);
  Future<api.PaginationResponse> listServiceCatalog();
  Future<api.Response> createServiceCatalogEntry(ServiceCatalogItem item);
  Future<api.Response> updateServiceCatalogEntry(String serviceCode, Map<String, dynamic> data);
  Future<api.Response> deleteServiceCatalogEntry(String serviceCode);
  Future<api.PaginationResponse> listCompanyServices(int companyId);
  Future<api.Response> getCompanyDetails(int companyId);
  Future<api.PaginationResponse> listServiceRequests({int page = 1, int pageSize = 20});
  Future<api.Response> reviewServiceRequest(int companyId, String serviceCode, Map<String, dynamic> data);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioService _dioService;

  AdminRemoteDataSourceImpl(this._dioService);

  @override
  Future<api.PaginationResponse> listCompanies({String? status, int page = 1, int pageSize = 20}) async {
    final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
    if (status != null) queryParameters['status'] = status;

    dPrint('listCompanies query: $queryParameters', tag: 'AdminDataSource');
    final response = await _dioService.get(AppUrls.companies, queryParameters: queryParameters, isPagination: true);
    dPrint('listCompanies response body type: ${response.body.runtimeType}', tag: 'AdminDataSource');
    return response as api.PaginationResponse;
  }

  @override
  Future<api.Response> updateCompanyStatus(int companyId, String status) async {
    final response = await _dioService.post(AppUrls.updateCompanyStatus(companyId), data: {'status': status});
    return response;
  }

  @override
  Future<api.PaginationResponse> listServiceCatalog() async {
    final response = await _dioService.get(AppUrls.adminServiceCatalog, isPagination: true);
    return response as api.PaginationResponse;
  }

  @override
  Future<api.Response> createServiceCatalogEntry(ServiceCatalogItem item) async {
    final response = await _dioService.post(AppUrls.adminServiceCatalog, data: item.toJson(includeCode: true));
    return response;
  }

  @override
  Future<api.Response> updateServiceCatalogEntry(String serviceCode, Map<String, dynamic> data) async {
    final response = await _dioService.put(AppUrls.adminServiceCatalogItem(serviceCode), data: data);
    return response;
  }

  @override
  Future<api.Response> deleteServiceCatalogEntry(String serviceCode) async {
    final response = await _dioService.delete(AppUrls.adminServiceCatalogItem(serviceCode));
    return response;
  }

  @override
  Future<api.PaginationResponse> listCompanyServices(int companyId) async {
    final response = await _dioService.get(AppUrls.companyAdminServices(companyId), isPagination: true);
    return response as api.PaginationResponse;
  }

  @override
  Future<api.Response> getCompanyDetails(int companyId) async {
    final response = await _dioService.get(AppUrls.companyAdminDetails(companyId));
    return response as api.Response;
  }

  @override
  Future<api.PaginationResponse> listServiceRequests({int page = 1, int pageSize = 20}) async {
    final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
    final response = await _dioService.get(AppUrls.adminServiceRequests, queryParameters: queryParameters, isPagination: true);
    return response as api.PaginationResponse;
  }

  @override
  Future<api.Response> reviewServiceRequest(int companyId, String serviceCode, Map<String, dynamic> data) async {
    final response = await _dioService.post(AppUrls.reviewCompanyService(companyId, serviceCode), data: data);
    return response;
  }
}
