import 'package:watt/src/shared/domain/company/company.dart';
import 'package:watt/src/shared/domain/service_type.dart';
import 'package:watt/src/features/services/data/data_sources/public_services_remote_data_source.dart';
import 'package:watt/src/features/services/domain/entities/public_companies_query.dart';
import 'package:watt/src/features/services/domain/entities/public_companies_result.dart';
import 'package:watt/src/features/services/domain/repositories/public_services_repository.dart';

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
