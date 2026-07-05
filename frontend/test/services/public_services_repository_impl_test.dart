import 'package:flutter_test/flutter_test.dart';
import 'package:solar_hub/src/features/services/data/data_sources/public_services_remote_data_source.dart';
import 'package:solar_hub/src/features/services/data/repositories/public_services_repository_impl.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_query.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_result.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';

void main() {
  test('service types are fetched fresh on every request', () async {
    final remoteDataSource = _FakePublicServicesRemoteDataSource();
    final repository = PublicServicesRepositoryImpl(remoteDataSource);

    final firstTypes = await repository.getTypes();
    final secondTypes = await repository.getTypes();
    final refreshedTypes = await repository.getTypes(forceRefresh: true);

    expect(remoteDataSource.getTypesCalls, 3);
    expect(firstTypes.single.id, 1);
    expect(secondTypes.single.id, 2);
    expect(refreshedTypes.single.id, 3);
  });
}

class _FakePublicServicesRemoteDataSource
    implements PublicServicesRemoteDataSource {
  int getTypesCalls = 0;

  @override
  Future<List<ServiceType>> getTypes() async {
    getTypesCalls += 1;
    return [ServiceType(id: getTypesCalls, name: 'Service $getTypesCalls')];
  }

  @override
  Future<PublicCompaniesResult> getCompanies(PublicCompaniesQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<Company> getCompanyDetails(int companyId) {
    throw UnimplementedError();
  }
}
