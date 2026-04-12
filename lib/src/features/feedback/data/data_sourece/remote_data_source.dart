import 'dart:io';

import 'package:dio/dio.dart';
import 'package:solar_hub/src/core/models/response.dart' as api;
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/feedback/domain/entities/feedback_entity.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class FeedbackRemoteDataSource {
  Future<FeedbackEntity> submitFeedback({
    required String name,
    String? phoneNumber,
    required String message,
    File? image,
  });

  Future<List<FeedbackEntity>> fetchFeedbacks({int page, int pageSize});
  Future<void> deleteFeedback(int id);
  Future<void> updateFeedbackReadStatus(int id, bool isRead);
}

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  FeedbackRemoteDataSourceImpl(this._dioService);

  final DioService _dioService;

  @override
  Future<FeedbackEntity> submitFeedback({
    required String name,
    String? phoneNumber,
    required String message,
    File? image,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('name', name));
      formData.fields.add(MapEntry('message', message));
      formData.fields.add(
        MapEntry('created_at', DateTime.now().toUtc().toIso8601String()),
      );
      formData.fields.add(const MapEntry('is_read', 'false'));

      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        formData.fields.add(MapEntry('phone_number', phoneNumber.trim()));
      }

      if (image != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dioService.multipartRequest(
        AppUrls.feedbacks,
        file: formData,
      );

      _throwIfFailed(response, 'Failed to submit feedback');

      return FeedbackEntity.fromJson(
        Map<String, dynamic>.from(response.body ?? const {}),
      );
    } catch (e, stackTrace) {
      dPrint('submitFeedback error: $e', stackTrace: stackTrace, tag: 'FeedbackRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<List<FeedbackEntity>> fetchFeedbacks({
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final response =
          await _dioService.get(
                AppUrls.feedbacks,
                queryParameters: {'page': page, 'page_size': pageSize},
                isPagination: true,
              )
              as api.PaginationResponse;

      _throwIfFailed(response, 'Failed to load feedbacks');

      final items = (response.body as List? ?? const []);
      final feedbacks = items
          .whereType<Map>()
          .map((item) => FeedbackEntity.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return feedbacks;
    } catch (e, stackTrace) {
      dPrint('fetchFeedbacks error: $e', stackTrace: stackTrace, tag: 'FeedbackRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<void> deleteFeedback(int id) async {
    try {
      final response = await _dioService.delete(AppUrls.feedback(id));
      _throwIfFailed(response, 'Failed to delete feedback');
    } catch (e, stackTrace) {
      dPrint('deleteFeedback error: $e', stackTrace: stackTrace, tag: 'FeedbackRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<void> updateFeedbackReadStatus(int id, bool isRead) async {
    try {
      final response = await _dioService.put(
        AppUrls.feedbackStatus(id),
        data: {'is_read': isRead},
      );
      _throwIfFailed(response, 'Failed to update feedback status');
    } catch (e, stackTrace) {
      dPrint('updateFeedbackReadStatus error: $e', stackTrace: stackTrace, tag: 'FeedbackRemoteDataSource');
      rethrow;
    }
  }

  void _throwIfFailed(api.BaseResponse response, String fallback) {
    if (response.error || response.status != 200) {
      throw Exception(
        response.messageUser.isEmpty
            ? (response.message.isEmpty ? fallback : response.message)
            : response.messageUser,
      );
    }
  }
}
