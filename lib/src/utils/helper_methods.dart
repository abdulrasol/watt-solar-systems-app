import 'package:flutter/foundation.dart' show debugPrint, debugPrintStack;

void dPrint(dynamic message, {String tag = 'debbuging', StackTrace? stackTrace}) {
  debugPrint('[$tag]: $message');
  if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
}
