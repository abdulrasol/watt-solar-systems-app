import 'package:flutter/foundation.dart'
    show debugPrint, debugPrintStack, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/splash/presentation/providers/config_provider.dart';

void dPrint(dynamic message, {String tag = 'debbuging', StackTrace? stackTrace}) {
  if (!kDebugMode) {
    return;
  }
  debugPrint('[$tag]: $message');
  if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
}
/// a
bool isEnabled(WidgetRef ref, String key, {bool skipFalseIfDebug = false, bool defaultValue = false}) {
  ref.watch(configProvider);
  return ref.read(configProvider.notifier).isEnabled(key, skipFalseIfDebug: skipFalseIfDebug, defaultValue: defaultValue);
}
