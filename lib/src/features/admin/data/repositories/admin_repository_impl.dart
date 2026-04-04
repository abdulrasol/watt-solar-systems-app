import 'package:solar_hub/src/features/admin/data/data_sources/admin_remote_data_source.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company_details.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AdminCompany>> listCompanies({String? status}) async {
    final response = await _remoteDataSource.listCompanies(status: status);
    return (response.body as List).map((e) => AdminCompany.fromJson(e)).toList();
  }

  @override
  Future<void> updateCompanyStatus(int companyId, String status) async {
    await _remoteDataSource.updateCompanyStatus(companyId, status);
  }

  @override
  Future<List<ServiceCatalogItem>> listServiceCatalog() async {
    final response = await _remoteDataSource.listServiceCatalog();
    return (response.body as List).map((e) => ServiceCatalogItem.fromJson(e)).toList();
  }

  @override
  Future<ServiceCatalogItem> createServiceCatalogEntry(ServiceCatalogItem item) async {
    final response = await _remoteDataSource.createServiceCatalogEntry(item);
    return ServiceCatalogItem.fromJson(response.body);
  }

  @override
  Future<ServiceCatalogItem> updateServiceCatalogEntry(String serviceCode, Map<String, dynamic> data) async {
    final response = await _remoteDataSource.updateServiceCatalogEntry(serviceCode, data);
    return ServiceCatalogItem.fromJson(response.body);
  }

  @override
  Future<void> deleteServiceCatalogEntry(String serviceCode) async {
    await _remoteDataSource.deleteServiceCatalogEntry(serviceCode);
  }

  @override
  Future<List<CompanyService>> listCompanyServices(int companyId) async {
    final response = await _remoteDataSource.listCompanyServices(companyId);
    return (response.body as List).map((e) => CompanyService.fromJson(e)).toList();
  }

  @override
  Future<AdminCompanyDetails> getCompanyDetails(int companyId) async {
    final response = await _remoteDataSource.getCompanyDetails(companyId);
    return AdminCompanyDetails.fromJson(response.body);
  }

  @override
  Future<List<ServiceRequest>> listServiceRequests() async {
    final response = await _remoteDataSource.listServiceRequests();
    return (response.body as List).map((e) => ServiceRequest.fromJson(e)).toList();
  }

  @override
  Future<void> reviewServiceRequest(int companyId, String serviceCode, Map<String, dynamic> data) async {
    await _remoteDataSource.reviewServiceRequest(companyId, serviceCode, data);
  }
}
