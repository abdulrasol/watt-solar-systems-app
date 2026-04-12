import 'package:dio/dio.dart';
import 'package:solar_hub/src/features/company_dashboard/data/data_sources/company_service_request_remote_data_source.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/company_service_request_repository.dart';

class CompanyServiceRequestRepositoryImpl
    implements CompanyServiceRequestRepository {
  final CompanyServiceRequestRemoteDataSource _remoteDataSource;

  CompanyServiceRequestRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createServiceRequest({
    required int companyId,
    required String serviceCode,
    String? notes,
    MultipartFile? imageFile,
  }) async {
    await _remoteDataSource.createServiceRequest(
      companyId: companyId,
      serviceCode: serviceCode,
      notes: notes,
      imageFile: imageFile,
    );
  }
}
