import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config_snapshot.dart';

/// Provides access to the app's global configurations.
final configProvider = NotifierProvider<ConfigNotifier, ConfigState>(
  ConfigNotifier.new,
);

class ConfigState {
  final Map<String, bool> values;
  final bool isHydrated;
  final bool isRefreshing;
  final DateTime? lastUpdated;

  const ConfigState({
    required this.values,
    required this.isHydrated,
    required this.isRefreshing,
    required this.lastUpdated,
  });

  const ConfigState.initial()
    : values = const {},
      isHydrated = false,
      isRefreshing = false,
      lastUpdated = null;

  ConfigState copyWith({
    Map<String, bool>? values,
    bool? isHydrated,
    bool? isRefreshing,
    DateTime? lastUpdated,
    bool clearLastUpdated = false,
  }) {
    return ConfigState(
      values: values ?? this.values,
      isHydrated: isHydrated ?? this.isHydrated,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastUpdated: clearLastUpdated ? null : (lastUpdated ?? this.lastUpdated),
    );
  }
}

class ConfigNotifier extends Notifier<ConfigState> {
  @override
  ConfigState build() {
    return const ConfigState.initial();
  }

  void hydrateFromSnapshot(ConfigSnapshot snapshot) {
    state = state.copyWith(
      values: _mapConfigs(snapshot.configs),
      isHydrated: true,
      isRefreshing: false,
      lastUpdated: snapshot.lastUpdated,
    );
  }

  void setRefreshing(bool isRefreshing) {
    state = state.copyWith(isRefreshing: isRefreshing);
  }

  void setConfigs(
    List<Config> configsList, {
    DateTime? lastUpdated,
    bool isHydrated = true,
    bool isRefreshing = false,
  }) {
    state = state.copyWith(
      values: _mapConfigs(configsList),
      isHydrated: isHydrated,
      isRefreshing: isRefreshing,
      lastUpdated: lastUpdated,
    );
  }

  Map<String, bool> _mapConfigs(List<Config> configsList) {
    final Map<String, bool> newConfigs = {};
    for (var config in configsList) {
      newConfigs[config.key] = config.value;
    }
    return newConfigs;
  }

  bool isEnabled(String key, {bool defaultValue = false, bool skipFalseIfDebug = false}) {
    if (skipFalseIfDebug && kDebugMode) {
      return true;
    }
    return state.values[key] ?? defaultValue;
  }
}
