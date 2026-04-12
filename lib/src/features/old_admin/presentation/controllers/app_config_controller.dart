import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/entities/app_config.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/app_config_repository.dart';

class AppConfigState {
  final bool isLoading;
  final String? error;
  final List<AppConfig> configs;
  final bool isSubmitting;

  const AppConfigState({this.isLoading = false, this.error, this.configs = const [], this.isSubmitting = false});

  AppConfigState copyWith({bool? isLoading, String? error, List<AppConfig>? configs, bool? isSubmitting}) {
    return AppConfigState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      configs: configs ?? this.configs,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AppConfigController extends Notifier<AppConfigState> {
  late AppConfigRepository _repository;

  @override
  AppConfigState build() {
    _repository = getIt<AppConfigRepository>();
    return const AppConfigState();
  }

  Future<void> fetchConfigs() async {
    state = state.copyWith(isLoading: true, error: null, configs: []);
    final result = await _repository.getAllConfigs();
    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error.toString()),
      (configs) => state = state.copyWith(isLoading: false, configs: configs),
    );
  }

  Future<void> createConfig({required String key, required bool value, String? description}) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final config = AppConfig(key: key, value: value, description: description);
    final result = await _repository.createConfig(config);
    result.fold((error) => state = state.copyWith(isSubmitting: false, error: error.toString()), (newConfig) {
      final updatedConfigs = [...state.configs, newConfig];
      state = state.copyWith(isSubmitting: false, configs: updatedConfigs);
    });
  }

  Future<void> updateConfig({required String oldKey, required String newKey, required bool value, String? description}) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final config = AppConfig(key: newKey, value: value, description: description);
    final result = await _repository.updateConfig(oldKey, config);
    result.fold((error) => state = state.copyWith(isSubmitting: false, error: error.toString()), (updatedConfig) {
      final updatedConfigs = state.configs.map((c) => c.key == oldKey ? updatedConfig : c).toList();
      state = state.copyWith(isSubmitting: false, configs: updatedConfigs);
    });
  }

  Future<void> deleteConfig(String key) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await _repository.deleteConfig(key);
    result.fold((error) => state = state.copyWith(isSubmitting: false, error: error.toString()), (_) {
      final updatedConfigs = state.configs.where((c) => c.key != key).toList();
      state = state.copyWith(isSubmitting: false, configs: updatedConfigs);
    });
  }

  Future<void> toggleConfig(String key, bool value) async {
    final result = await _repository.toggleConfig(key, value);
    result.fold((error) => state = state.copyWith(error: error.toString()), (updatedConfig) {
      final updatedConfigs = state.configs.map((c) => c.key == key ? updatedConfig : c).toList();
      state = state.copyWith(configs: updatedConfigs);
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final appConfigProvider = NotifierProvider<AppConfigController, AppConfigState>(() {
  return AppConfigController();
});
