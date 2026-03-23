import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config.dart';

/// Provides access to the app's global configurations.
final configProvider = NotifierProvider<ConfigNotifier, Map<String, bool>>(ConfigNotifier.new);

class ConfigNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    // Start with an empty map of configurations
    return {};
  }

  /// Sets the configs from the API response
  /// This optimizes it into an O(1) lookup Map.
  void setConfigs(List<Config> configsList) {
    final Map<String, bool> newConfigs = {};
    for (var config in configsList) {
      newConfigs[config.key] = config.value;
    }
    state = newConfigs;
  }

  /// Checks if a specific feature or config is enabled.
  /// Runs in O(1) time. Defaults to false if the key doesn't exist.
  bool isEnabled(String key, {bool defaultValue = false, bool skipFalseIfDebug = false}) {
    if (skipFalseIfDebug && kDebugMode) {
      return true;
    }
    return state[key] ?? defaultValue;
  }
}
