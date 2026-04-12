import 'package:dio/dio.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/core/models/response.dart' as api;
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class CompanyServiceRequestRemoteDataSource {
  Future<api.Response> createServiceRequest({
    required int companyId,
    required String serviceCode,
    String? notes,
    MultipartFile? imageFile,
  });
}

class CompanyServiceRequestRemoteDataSourceImpl
    implements CompanyServiceRequestRemoteDataSource {
  final DioService _dioService;

  CompanyServiceRequestRemoteDataSourceImpl(this._dioService);

  @override
  Future<api.Response> createServiceRequest({
    required int companyId,
    required String serviceCode,
    String? notes,
    MultipartFile? imageFile,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('service_code', serviceCode));
      if (notes != null && notes.isNotEmpty) {
        formData.fields.add(MapEntry('notes', notes));
      }
      if (imageFile != null) {
        formData.files.add(MapEntry('image', imageFile));
      }

      final response = await _dioService.multipartRequest(
        AppUrls.createCompanyServiceRequest(companyId),
        file: formData,
      );
      return response;
    } catch (e, stackTrace) {
      dPrint(
        'createServiceRequest error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyServiceRequestRemoteDataSource',
      );
      rethrow;
    }
  }
}
