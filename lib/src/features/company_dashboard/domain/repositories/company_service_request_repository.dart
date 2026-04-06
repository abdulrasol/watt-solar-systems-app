import 'package:dio/dio.dart';

abstract class CompanyServiceRequestRepository {
  Future<void> createServiceRequest({required int companyId, required String serviceCode, String? notes, MultipartFile? imageFile});
}
