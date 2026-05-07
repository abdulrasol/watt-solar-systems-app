import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/features/services/data/datasources/public_services_remote_data_source.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_query.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_result.dart';
import 'package:solar_hub/src/features/services/domain/repositories/public_services_repository.dart';

class PublicServicesRepositoryImpl implements PublicServicesRepository {
  final PublicServicesRemoteDataSource _remoteDataSource;

  PublicServicesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ServiceType>> getTypes({bool forceRefresh = false}) =>
      _remoteDataSource.getTypes();

  @override
  Future<PublicCompaniesResult> getCompanies(PublicCompaniesQuery query) {
    return _remoteDataSource.getCompanies(query);
  }

  @override
  Future<Company> getCompanyDetails(int companyId) {
    return _remoteDataSource.getCompanyDetails(companyId);
  }
}
