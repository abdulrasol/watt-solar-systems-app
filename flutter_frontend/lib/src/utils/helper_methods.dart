import 'package:flutter/foundation.dart' show debugPrint, debugPrintStack, kDebugMode;
import 'package:watt/src/utils/app_urls.dart';
import 'package:watt/src/features/splash/presentation/providers/config_provider.dart';
import 'package:watt/src/core/flags/feature_flags.dart';
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

/// Resolves a potentially relative image path from the backend to a fully qualified URL.
String? resolveImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  
  final host = AppUrls.baseUrl.replaceAll(RegExp(r'/api/v1$'), '');
  return '$host${path.startsWith('/') ? '' : '/'}$path';
}
