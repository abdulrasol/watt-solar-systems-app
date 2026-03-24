import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/feedback_entity.dart';
import '../../domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FirebaseFirestore _firestore;

  FeedbackRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<FeedbackEntity> submitFeedback({required String name, String? phoneNumber, required String message, File? image}) async {
    try {
      String? imageData;
      if (image != null) {
        imageData = await _convertImageToBase64(image);
      }

      final feedback = FeedbackEntity(name: name, phoneNumber: phoneNumber, message: message, imageData: imageData, createdAt: DateTime.now(), isRead: false);

      final docRef = await _firestore.collection('feedbacks').add(feedback.toFirestore());

      return feedback.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw Exception('Failed to submit feedback: ${e.message}');
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  @override
  Future<List<FeedbackEntity>> getAllFeedbacks() async {
    try {
      final querySnapshot = await _firestore.collection('feedbacks').orderBy('createdAt', descending: true).limit(100).get();

      return querySnapshot.docs.map((doc) => FeedbackEntity.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch feedbacks: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch feedbacks: $e');
    }
  }

  @override
  Future<void> deleteFeedback(String id) async {
    try {
      await _firestore.collection('feedbacks').doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete feedback: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }

  @override
  Future<void> updateFeedbackReadStatus(String id, bool isRead) async {
    try {
      await _firestore.collection('feedbacks').doc(id).update({'isRead': isRead});
    } on FirebaseException catch (e) {
      throw Exception('Failed to update feedback status: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update feedback status: $e');
    }
  }

  Future<String> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      throw Exception('Failed to convert image: $e');
    }
  }
}
