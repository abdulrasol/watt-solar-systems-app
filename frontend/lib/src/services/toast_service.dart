import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/feedback/domain/repositories/feedback_repository.dart';
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

  static void showErrorWithDetail(BuildContext context, {required String title, required String message, required dynamic detail}) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => _showErrorDialog(context, title, detail),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      description: GestureDetector(behavior: HitTestBehavior.opaque, onLongPress: () => _showErrorDialog(context, title, detail), child: Text(message)),
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

  static void _showErrorDialog(BuildContext context, String title, dynamic detail) {
    String errorString = '';
    try {
      if (detail is Map || detail is List) {
        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        errorString = encoder.convert(detail);
      } else {
        errorString = detail.toString();
      }
    } catch (e) {
      errorString = detail.toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detailed Error Informaton:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                child: SelectableText(errorString, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                // Submit feedback
                await getIt<FeedbackRepository>().submitFeedback(name: 'System Error Report', message: 'Automated error report:\n$errorString');
                if (context.mounted) {
                  Navigator.pop(context);
                  success(context, 'Report Sent', 'Thank you for reporting this issue.');
                }
              } catch (e) {
                if (context.mounted) {
                  error(context, 'Report Failed', 'Could not send the report.');
                }
              }
            },
            child: const Text('Send Report'),
          ),
        ],
      ),
    );
  }

  static void success(BuildContext context, String title, String message) {
    show(context, title: title, message: message, type: ToastificationType.success);
  }

  static void error(BuildContext context, String title, String message) {
    showErrorWithDetail(context, title: title, message: message, detail: message);
  }

  static void info(BuildContext context, String title, String message) {
    show(context, title: title, message: message, type: ToastificationType.info);
  }

  static void warning(BuildContext context, String title, String message) {
    show(context, title: title, message: message, type: ToastificationType.warning);
  }
}
