import 'dart:io';

import 'package:solar_hub/src/features/feedback/data/data_sourece/remote_data_source.dart';

import '../../domain/entities/feedback_entity.dart';
import '../../domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  FeedbackRepositoryImpl(this._remoteDataSource);

  final FeedbackRemoteDataSource _remoteDataSource;

  @override
  Future<FeedbackEntity> submitFeedback({
    required String name,
    String? phoneNumber,
    required String message,
    File? image,
  }) async {
    return _remoteDataSource.submitFeedback(
      name: name,
      phoneNumber: phoneNumber,
      message: message,
      image: image,
    );
  }

  @override
  Future<List<FeedbackEntity>> getAllFeedbacks() async {
    return _remoteDataSource.fetchFeedbacks();
  }

  @override
  Future<void> deleteFeedback(String id) async {
    await _remoteDataSource.deleteFeedback(_parseId(id));
  }

  @override
  Future<void> updateFeedbackReadStatus(String id, bool isRead) async {
    await _remoteDataSource.updateFeedbackReadStatus(_parseId(id), isRead);
  }

  int _parseId(String id) {
    final parsedId = int.tryParse(id);
    if (parsedId == null) {
      throw Exception('Invalid feedback id: $id');
    }
    return parsedId;
  }
}
