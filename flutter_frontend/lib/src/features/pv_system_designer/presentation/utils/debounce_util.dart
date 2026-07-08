import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;

  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), callback);
  }

  void cancel() => _timer?.cancel();
  void dispose() => _timer?.cancel();
}
