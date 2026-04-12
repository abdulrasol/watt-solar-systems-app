import 'package:solar_hub/src/shared/domain/company/company_type.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_query.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_result.dart';

abstract class PublicServicesRepository {
  Future<List<CompanyType>> getTypes();
  Future<PublicCompaniesResult> getCompanies(PublicCompaniesQuery query);
  Future<Company> getCompanyDetails(int companyId);
}
