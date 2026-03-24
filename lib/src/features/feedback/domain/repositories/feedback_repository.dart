import 'dart:io';
import '../entities/feedback_entity.dart';

abstract class FeedbackRepository {
  Future<FeedbackEntity> submitFeedback({required String name, String? phoneNumber, required String message, File? image});

  Future<List<FeedbackEntity>> getAllFeedbacks();
  Future<void> deleteFeedback(String id);
  Future<void> updateFeedbackReadStatus(String id, bool isRead);
}
