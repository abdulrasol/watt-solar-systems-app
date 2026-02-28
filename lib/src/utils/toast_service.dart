import 'package:flutter/material.dart';

import 'package:toastification/toastification.dart';

class ToastService {
  static void show(BuildContext context, {required String title, required String message, ToastificationType type = ToastificationType.success}) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 16, offset: Offset(0, 16), spreadRadius: 0)],
      showProgressBar: true,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  static void success(BuildContext context, String title, String message) {
    show(context, title: title, message: message, type: ToastificationType.success);
  }

  static void error(BuildContext context, String title, String message) {
    show(context, title: title, message: message, type: ToastificationType.error);
  }

  static void info(BuildContext context, String title, String message) {
    show(context, title: title, message: message, type: ToastificationType.info);
  }

  static void warning(BuildContext context, String title, String message) {
    show(context, title: title, message: message, type: ToastificationType.warning);
  }
}
