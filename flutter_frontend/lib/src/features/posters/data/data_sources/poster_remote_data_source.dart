import 'package:dio/dio.dart';
import 'package:watt/src/core/models/response.dart' as api;
import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/features/posters/data/models/poster_model.dart';
import 'package:watt/src/utils/app_urls.dart';

class PosterRemoteDataSource {
  final DioService _dio;

  PosterRemoteDataSource(this._dio);

  Future<List<PosterModel>> fetchActivePosters() async {
    final response = await _dio.get(AppUrls.activePosters, isList: true);
    final list = response.body as List;
    return list.map((e) => PosterModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<api.PaginationResponse> fetchCompanyPosters({required int companyId, int page = 1, int pageSize = 12, String? status}) async {
    final params = <String, dynamic>{'page': page, 'page_size': pageSize};
    if (status != null) params['status'] = status;
    final response = await _dio.get(AppUrls.companyPosters(companyId), queryParameters: params, isPagination: true);
    return response as api.PaginationResponse;
  }

  Future<PosterModel> createPoster({required int companyId, required String text, required String actionType, int? actionId, String? imagePath}) async {
    final formData = FormData.fromMap({
      if (text.isNotEmpty) 'text': text,
      'action_type': actionType,
      'action_id': ?actionId,
      if (imagePath != null) 'image': await MultipartFile.fromFile(imagePath),
    });
    final response = await _dio.multipartRequest(AppUrls.companyPosters(companyId), file: formData);
    return PosterModel.fromJson(Map<String, dynamic>.from(response.body as Map));
  }

  Future<PosterModel> updatePoster({required int companyId, required int posterId, String? text, String? actionType, int? actionId, String? imagePath}) async {
    final map = <String, dynamic>{};
    if (text != null) map['text'] = text;
    if (actionType != null) map['action_type'] = actionType;
    if (actionId != null) map['action_id'] = actionId;
    if (imagePath != null) map['image'] = await MultipartFile.fromFile(imagePath);
    final formData = FormData.fromMap(map);
    final response = await _dio.multipartRequest(AppUrls.companyPoster(companyId, posterId), file: formData, isPut: true);
    return PosterModel.fromJson(Map<String, dynamic>.from(response.body as Map));
  }

  Future<void> deletePoster({required int companyId, required int posterId}) async {
    await _dio.delete(AppUrls.companyPoster(companyId, posterId));
  }

  Future<PosterModel> togglePosterActive({required int companyId, required int posterId}) async {
    final response = await _dio.patch(AppUrls.companyPosterToggle(companyId, posterId));
    return PosterModel.fromJson(Map<String, dynamic>.from(response.body as Map));
  }

  Future<api.PaginationResponse> fetchAdminPosters({int page = 1, int pageSize = 12, String? status, String? search, String? validity}) async {
    final params = <String, dynamic>{'page': page, 'page_size': pageSize};
    if (status != null) params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (validity != null) params['validity'] = validity;
    final response = await _dio.get(AppUrls.adminPosters, queryParameters: params, isPagination: true);
    return response as api.PaginationResponse;
  }

  Future<PosterModel> reviewPoster({required int posterId, required String status, int durationDays = 7}) async {
    final response = await _dio.post(AppUrls.adminPosterReview(posterId), data: {'status': status, 'duration_days': durationDays});
    return PosterModel.fromJson(Map<String, dynamic>.from(response.body as Map));
  }

  Future<PosterModel> extendPoster({required int posterId, required String expiresAt}) async {
    final response = await _dio.post(AppUrls.adminPosterExtend(posterId), data: {'expires_at': expiresAt});
    return PosterModel.fromJson(Map<String, dynamic>.from(response.body as Map));
  }
}
