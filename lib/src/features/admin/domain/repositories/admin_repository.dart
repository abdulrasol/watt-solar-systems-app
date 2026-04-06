import 'package:solar_hub/src/features/admin/domain/models/admin_company_details.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company.dart';

abstract class AdminRepository {
  Future<List<Company>> listCompanies({String? status, int page = 1, int pageSize = 20});
  Future<void> updateCompanyStatus(int companyId, String status);
  Future<List<ServiceCatalogItem>> listServiceCatalog();
  Future<ServiceCatalogItem> createServiceCatalogEntry(ServiceCatalogItem item);
  Future<ServiceCatalogItem> updateServiceCatalogEntry(String serviceCode, Map<String, dynamic> data);
  Future<void> deleteServiceCatalogEntry(String serviceCode);
  Future<List<CompanyService>> listCompanyServices(int companyId);
  Future<AdminCompanyDetails> getCompanyDetails(int companyId);
  Future<List<ServiceRequest>> listServiceRequests({int page = 1, int pageSize = 20});
  Future<void> reviewServiceRequest(int companyId, String serviceCode, Map<String, dynamic> data);
  Future<void> toggleCompanyService(int companyId, String serviceCode, Map<String, dynamic> data);
}
