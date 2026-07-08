import 'package:flutter/foundation.dart' show debugPrint, debugPrintStack, kDebugMode;
import 'package:solar_hub/src/features/splash/presentation/providers/config_provider.dart';
import 'package:solar_hub/src/core/flags/feature_flags.dart';
void dPrint(dynamic message, {String tag = 'debbuging', StackTrace? stackTrace}) {
  if (!kDebugMode) {
    return;
  }
  debugPrint('[$tag]: $message');
  if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
}

/// Strongly typed feature flag checker
bool isFeatureEnabled(dynamic ref, AppFeature feature, {bool skipFalseIfDebug = false, bool defaultValue = true}) {
  ref.watch(configProvider);
  return ref.read(configProvider.notifier).isEnabled(feature.key, skipFalseIfDebug: skipFalseIfDebug, defaultValue: defaultValue);
}

/// Legacy string-based checker (kept for backwards compatibility)
bool isEnabled(dynamic ref, String key, {bool skipFalseIfDebug = false, bool defaultValue = true}) {
  ref.watch(configProvider);
  return ref.read(configProvider.notifier).isEnabled(key, skipFalseIfDebug: skipFalseIfDebug, defaultValue: defaultValue);
}

/// Returns true when [error] indicates a backend feature is not enabled for
/// the current company type (e.g. accounting/expenses unavailable for this
/// company). This lets UI surfaces show a friendly "feature unavailable"
/// state instead of a generic retry error.
bool isServiceUnavailableForCompanyType(String? error) {
  if (error == null) return false;
  final lower = error.toLowerCase();
  return lower.contains('service not available') ||
      lower.contains('not available for company type');
}
