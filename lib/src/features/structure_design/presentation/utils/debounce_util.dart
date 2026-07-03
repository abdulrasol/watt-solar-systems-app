import 'dart:async';
import 'package:flutter/material.dart';

/// Utility class for debouncing function calls.
class Debouncer {
  Debouncer({required this.milliseconds});

  final int milliseconds;
  Timer? _timer;

  /// Runs the [callback] after [milliseconds] have passed since the last call.
  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), callback);
  }

  /// Cancels any pending debounced call.
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the debouncer and cancels any pending call.
  void dispose() {
    _timer?.cancel();
  }
}