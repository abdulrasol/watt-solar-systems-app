import 'package:solar_hub/src/features/admin/domain/models/admin_company.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company_details.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';

abstract class AdminRepository {
  Future<List<AdminCompany>> listCompanies({String? status});
  Future<void> updateCompanyStatus(int companyId, String status);
  Future<List<ServiceCatalogItem>> listServiceCatalog();
  Future<ServiceCatalogItem> createServiceCatalogEntry(ServiceCatalogItem item);
  Future<ServiceCatalogItem> updateServiceCatalogEntry(String serviceCode, Map<String, dynamic> data);
  Future<void> deleteServiceCatalogEntry(String serviceCode);
  Future<List<CompanyService>> listCompanyServices(int companyId);
  Future<AdminCompanyDetails> getCompanyDetails(int companyId);
  Future<List<ServiceRequest>> listServiceRequests();
  Future<void> reviewServiceRequest(int companyId, String serviceCode, Map<String, dynamic> data);
}
