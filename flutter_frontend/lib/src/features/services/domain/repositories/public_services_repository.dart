import 'package:watt/src/shared/domain/company/company.dart';
import 'package:watt/src/shared/domain/service_type.dart';
import 'package:watt/src/features/services/domain/entities/public_companies_query.dart';
import 'package:watt/src/features/services/domain/entities/public_companies_result.dart';

abstract class PublicServicesRepository {
  Future<List<ServiceType>> getTypes({bool forceRefresh = false});
  Future<PublicCompaniesResult> getCompanies(PublicCompaniesQuery query);
  Future<Company> getCompanyDetails(int companyId);
}
