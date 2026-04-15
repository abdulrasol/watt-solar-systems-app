import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/features/settings/domain/entiteis/settings.dart';

final settingsProvider = NotifierProvider<SettingsProvider, Settings>(
  SettingsProvider.new,
);

class SettingsProvider extends Notifier<Settings> {
  final CasheInterface casheService = getIt<CasheInterface>();
  @override
  Settings build() {
    return casheService.settings();
  }

  void toggleDark() {
    state = Settings(
      isDark: !state.isDark,
      isNotificationEnabled: state.isNotificationEnabled,
      language: state.language,
      saveRolePageSelection: state.saveRolePageSelection,
    );
    casheService.saveSettings(state);
  }

  void toggleNotification() {
    state = Settings(
      isDark: state.isDark,
      isNotificationEnabled: !state.isNotificationEnabled,
      language: state.language,
      saveRolePageSelection: state.saveRolePageSelection,
    );
    casheService.saveSettings(state);
  }

  void setLanguage(String language) {
    state = Settings(
      isDark: state.isDark,
      isNotificationEnabled: state.isNotificationEnabled,
      language: language,
      saveRolePageSelection: state.saveRolePageSelection,
    );
    casheService.saveSettings(state);

    // Silently sync to server if authenticated, so notifications use the
    // new language immediately without requiring the user to restart the app.
    final token = casheService.token();
    if (token != null) {
      getIt<AuthRepository>().updateLanguage(language);
    }
  }

  void toggleSaveRolePageSelection() {
    state = Settings(
      isDark: state.isDark,
      isNotificationEnabled: state.isNotificationEnabled,
      language: state.language,
      saveRolePageSelection: !state.saveRolePageSelection,
    );
    casheService.saveSettings(state);
  }

  void setSaveRolePageSelectionRoute(String route) {
    state = Settings(
      isDark: state.isDark,
      isNotificationEnabled: state.isNotificationEnabled,
      language: state.language,
      saveRolePageSelection: state.saveRolePageSelection,
      saveRolePageSelectionRoute: route,
    );
    casheService.saveSettings(state);
  }
}
