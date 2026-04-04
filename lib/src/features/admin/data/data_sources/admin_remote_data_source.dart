import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/core/models/response.dart' as api;
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';

abstract class AdminRemoteDataSource {
  Future<api.PaginationResponse> listCompanies({String? status});
  Future<api.Response> updateCompanyStatus(int companyId, String status);
  Future<api.PaginationResponse> listServiceCatalog();
  Future<api.Response> createServiceCatalogEntry(ServiceCatalogItem item);
  Future<api.Response> updateServiceCatalogEntry(String serviceCode, Map<String, dynamic> data);
  Future<api.Response> deleteServiceCatalogEntry(String serviceCode);
  Future<api.PaginationResponse> listCompanyServices(int companyId);
  Future<api.Response> getCompanyDetails(int companyId);
  Future<api.PaginationResponse> listServiceRequests();
  Future<api.Response> reviewServiceRequest(int companyId, String serviceCode, Map<String, dynamic> data);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioService _dioService;

  AdminRemoteDataSourceImpl(this._dioService);

  @override
  Future<api.PaginationResponse> listCompanies({String? status}) async {
    final queryParameters = <String, dynamic>{};
    if (status != null) queryParameters['status'] = status;

    final response = await _dioService.get('/admin/companies/', queryParameters: queryParameters);
    return api.PaginationResponse.fromJson(response.body);
  }

  @override
  Future<api.Response> updateCompanyStatus(int companyId, String status) async {
    final response = await _dioService.post('/admin/companies/$companyId/status', data: {'status': status});
    return api.Response.fromJson(response.body);
  }

  @override
  Future<api.PaginationResponse> listServiceCatalog() async {
    final response = await _dioService.get('/admin/companies/catalog/services');
    return api.PaginationResponse.fromJson(response.body);
  }

  @override
  Future<api.Response> createServiceCatalogEntry(ServiceCatalogItem item) async {
    final response = await _dioService.post('/admin/companies/catalog/services', data: item.toJson());
    return api.Response.fromJson(response.body);
  }

  @override
  Future<api.Response> updateServiceCatalogEntry(String serviceCode, Map<String, dynamic> data) async {
    final response = await _dioService.put('/admin/companies/catalog/services/$serviceCode', data: data);
    return api.Response.fromJson(response.body);
  }

  @override
  Future<api.Response> deleteServiceCatalogEntry(String serviceCode) async {
    final response = await _dioService.delete('/admin/companies/catalog/services/$serviceCode');
    return api.Response.fromJson(response.body);
  }

  @override
  Future<api.PaginationResponse> listCompanyServices(int companyId) async {
    final response = await _dioService.get('/admin/companies/$companyId/services');
    return api.PaginationResponse.fromJson(response.body);
  }

  @override
  Future<api.Response> getCompanyDetails(int companyId) async {
    final response = await _dioService.get('/admin/companies/$companyId/details');
    return api.Response.fromJson(response.body);
  }

  @override
  Future<api.PaginationResponse> listServiceRequests() async {
    final response = await _dioService.get('/admin/companies/service-requests');
    return api.PaginationResponse.fromJson(response.body);
  }

  @override
  Future<api.Response> reviewServiceRequest(int companyId, String serviceCode, Map<String, dynamic> data) async {
    final response = await _dioService.post('/admin/companies/$companyId/services/$serviceCode/review', data: data);
    return api.Response.fromJson(response.body);
  }
}
