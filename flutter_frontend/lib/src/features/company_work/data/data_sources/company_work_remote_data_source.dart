import 'dart:io';

import 'package:dio/dio.dart';
import 'package:solar_hub/src/core/models/response.dart' as local;
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/company_work/data/models/company_work_model.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class CompanyWorkRemoteDataSource {
  Future<(List<CompanyWorkModel>, int)> getPublicWorks(
    int companyId, {
    required int page,
    int? pageSize,
  });

  Future<(List<CompanyWorkModel>, int)> getCompanyWorks(
    int companyId, {
    required int page,
    int? pageSize,
  });

  Future<CompanyWorkModel> createWork(
    int companyId,
    Map<String, dynamic> payload, {
    List<File> images = const [],
  });

  Future<CompanyWorkModel> updateWork(
    int companyId,
    int workId,
    Map<String, dynamic> payload, {
    List<File> images = const [],
  });

  Future<void> deleteWork(int companyId, int workId);

  Future<void> deleteWorkImage(int companyId, int imageId);
}

class CompanyWorkRemoteDataSourceImpl implements CompanyWorkRemoteDataSource {
  CompanyWorkRemoteDataSourceImpl(this._dioService);

  final DioService _dioService;

  @override
  Future<(List<CompanyWorkModel>, int)> getPublicWorks(
    int companyId, {
    required int page,
    int? pageSize,
  }) async {
    return _getWorks(
      AppUrls.publicCompanyWorks(companyId),
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<(List<CompanyWorkModel>, int)> getCompanyWorks(
    int companyId, {
    required int page,
    int? pageSize,
  }) async {
    return _getWorks(
      AppUrls.companyWorks(companyId),
      page: page,
      pageSize: pageSize,
    );
  }

  Future<(List<CompanyWorkModel>, int)> _getWorks(
    String url, {
    required int page,
    int? pageSize,
  }) async {
    try {
      final response =
          await _dioService.get(
                url,
                queryParameters: {
                  'page': page,
                  ...?pageSize == null ? null : {'page_size': pageSize},
                },
                isPagination: true,
              )
              as local.PaginationResponse;

      if (response.error || response.status != 200) {
        throw Exception(
          response.messageUser.isEmpty
              ? response.message
              : response.messageUser,
        );
      }

      final items = (response.body as List)
          .whereType<Map>()
          .map(
            (item) =>
                CompanyWorkModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      return (items, response.count ?? items.length);
    } catch (e, stackTrace) {
      dPrint(
        'getWorks error: $e',
        tag: 'CompanyWorkRemoteDataSource',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<CompanyWorkModel> createWork(
    int companyId,
    Map<String, dynamic> payload, {
    List<File> images = const [],
  }) async {
    return _saveWork(AppUrls.companyWorks(companyId), payload, images: images);
  }

  @override
  Future<CompanyWorkModel> updateWork(
    int companyId,
    int workId,
    Map<String, dynamic> payload, {
    List<File> images = const [],
  }) async {
    return _saveWork(
      AppUrls.companyWork(companyId, workId),
      payload,
      images: images,
      isPut: true,
    );
  }

  Future<CompanyWorkModel> _saveWork(
    String url,
    Map<String, dynamic> payload, {
    List<File> images = const [],
    bool isPut = false,
  }) async {
    try {
      final formData = FormData();
      payload.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });
      for (final image in images) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dioService.multipartRequest(
        url,
        file: formData,
        isPut: isPut,
      );

      if (response.error || response.status != 200) {
        throw Exception(
          response.messageUser.isEmpty
              ? response.message
              : response.messageUser,
        );
      }

      final dynamic body = response.body;
      if (body is Map<String, dynamic>) {
        return CompanyWorkModel.fromJson(body);
      }
      if (body is Map) {
        return CompanyWorkModel.fromJson(Map<String, dynamic>.from(body));
      }
      throw Exception('Invalid work response');
    } catch (e, stackTrace) {
      dPrint(
        'saveWork error: $e',
        tag: 'CompanyWorkRemoteDataSource',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteWork(int companyId, int workId) async {
    await _delete(AppUrls.companyWork(companyId, workId));
  }

  @override
  Future<void> deleteWorkImage(int companyId, int imageId) async {
    await _delete(AppUrls.companyWorkImage(companyId, imageId));
  }

  Future<void> _delete(String url) async {
    try {
      final response = await _dioService.delete(url);
      if (response.error || response.status != 200) {
        throw Exception(
          response.messageUser.isEmpty
              ? response.message
              : response.messageUser,
        );
      }
    } catch (e, stackTrace) {
      dPrint(
        'deleteWork error: $e',
        tag: 'CompanyWorkRemoteDataSource',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
