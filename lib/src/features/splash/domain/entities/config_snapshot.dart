import 'package:solar_hub/src/features/splash/domain/entities/config.dart';

class ConfigSnapshot {
  final List<Config> configs;
  final DateTime? lastUpdated;
  final bool isFromCache;
  final int schemaVersion;

  const ConfigSnapshot({
    required this.configs,
    required this.lastUpdated,
    required this.isFromCache,
    required this.schemaVersion,
  });

  bool get hasConfigs => configs.isNotEmpty;

  ConfigSnapshot copyWith({
    List<Config>? configs,
    DateTime? lastUpdated,
    bool? isFromCache,
    int? schemaVersion,
  }) {
    return ConfigSnapshot(
      configs: configs ?? this.configs,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isFromCache: isFromCache ?? this.isFromCache,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }
}
