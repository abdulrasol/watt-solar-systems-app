import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static void show({required String title, required String message, ToastificationType type = ToastificationType.success}) {
    // Fallback if Get.context is null (rare if app is running)
    if (Get.context == null) return;

    toastification.show(
      context: Get.context!,
      type: type,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 16, offset: Offset(0, 16), spreadRadius: 0)],
      showProgressBar: true,
      // closeButtonShowType: CloseButtonShowType.onHover, // Removed to fix error
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  static void success(String title, String message) {
    show(title: title, message: message, type: ToastificationType.success);
  }

  static void error(String title, String message) {
    show(title: title, message: message, type: ToastificationType.error);
  }

  static void info(String title, String message) {
    show(title: title, message: message, type: ToastificationType.info);
  }

  static void warning(String title, String message) {
    show(title: title, message: message, type: ToastificationType.warning);
  }
}
