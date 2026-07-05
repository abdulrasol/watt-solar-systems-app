import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:solar_hub/src/core/di/get_it.dart';
import '../../domain/repositories/feedback_repository.dart';

class FeedbackState {
  final bool isLoading;
  final String? error;
  final String? errorCode;
  final String? errorDetail;
  final bool isSuccess;
  final String? successCode;
  final File? selectedImage;

  FeedbackState({
    this.isLoading = false,
    this.error,
    this.errorCode,
    this.errorDetail,
    this.isSuccess = false,
    this.successCode,
    this.selectedImage,
  });

  FeedbackState copyWith({
    bool? isLoading,
    String? error,
    String? errorCode,
    String? errorDetail,
    bool? isSuccess,
    String? successCode,
    File? selectedImage,
    bool clearError = false,
    bool clearErrorCode = false,
    bool clearErrorDetail = false,
    bool clearSuccessCode = false,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      errorCode: clearErrorCode ? null : errorCode ?? this.errorCode,
      errorDetail: clearErrorDetail ? null : errorDetail ?? this.errorDetail,
      isSuccess: isSuccess ?? this.isSuccess,
      successCode: clearSuccessCode ? null : successCode ?? this.successCode,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

class FeedbackController extends Notifier<FeedbackState> {
  late FeedbackRepository _repository;
  final ImagePicker _picker = ImagePicker();

  @override
  FeedbackState build() {
    _repository = getIt<FeedbackRepository>();
    return FeedbackState();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );

      if (image != null) {
        // Compress image further
        final compressedFile = await _compressImage(File(image.path));
        state = state.copyWith(
          selectedImage: compressedFile,
          clearError: true,
          clearErrorCode: true,
          clearErrorDetail: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorCode: 'failed_to_pick_image',
        errorDetail: e.toString(),
        clearError: true,
      );
    }
  }

  Future<File> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return imageFile;

      // Resize and compress
      final resized = img.copyResize(image, width: 800);
      final compressed = img.encodeJpg(resized, quality: 75);

      // Save to temp file
      final tempFile = await File(
        '${imageFile.path}.compressed.jpg',
      ).writeAsBytes(compressed);
      return tempFile;
    } catch (e) {
      // If compression fails, return original
      return imageFile;
    }
  }

  Future<void> removeImage() async {
    state = state.copyWith(selectedImage: null);
  }

  Future<void> submitFeedback({
    required String name,
    String? phoneNumber,
    required String message,
  }) async {
    if (name.trim().isEmpty) {
      state = state.copyWith(
        errorCode: 'name_required',
        clearError: true,
        clearErrorDetail: true,
      );
      return;
    }

    if (message.trim().isEmpty) {
      state = state.copyWith(
        errorCode: 'feedback_required',
        clearError: true,
        clearErrorDetail: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      clearError: true,
      clearErrorCode: true,
      clearErrorDetail: true,
      clearSuccessCode: true,
    );

    try {
      await _repository.submitFeedback(
        name: name,
        phoneNumber: phoneNumber,
        message: message,
        image: state.selectedImage,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        successCode: 'feedback_submitted_successfully',
        selectedImage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
        isSuccess: false,
        clearErrorCode: true,
        clearErrorDetail: true,
      );
    }
  }

  void clearSuccess() {
    state = state.copyWith(isSuccess: false, clearSuccessCode: true);
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
      clearErrorCode: true,
      clearErrorDetail: true,
    );
  }
}

final feedbackProvider = NotifierProvider<FeedbackController, FeedbackState>(
  () {
    return FeedbackController();
  },
);
