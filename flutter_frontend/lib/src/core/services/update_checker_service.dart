import 'dart:io';
import 'package:in_app_update/in_app_update.dart' as in_app_update;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

/// Result of checking for app updates
enum UpdateAvailability {
  /// No update available
  notAvailable,

  /// Update is available but optional
  available,

  /// Update is available and required (force update)
  required,

  /// Could not determine update status
  unknown,
}

/// Information about available update
class UpdateInfo {
  final UpdateAvailability availability;
  final String? currentVersion;
  final String? storeVersion;
  final String? releaseNotes;
  final bool isImmediateUpdateAllowed;
  final bool isFlexibleUpdateAllowed;

  const UpdateInfo({
    required this.availability,
    this.currentVersion,
    this.storeVersion,
    this.releaseNotes,
    this.isImmediateUpdateAllowed = false,
    this.isFlexibleUpdateAllowed = false,
  });

  bool get hasUpdate =>
      availability == UpdateAvailability.available ||
      availability == UpdateAvailability.required;
}

/// Service for checking and handling app updates
class UpdateCheckerService {
  static final UpdateCheckerService _instance =
      UpdateCheckerService._internal();
  factory UpdateCheckerService() => _instance;
  UpdateCheckerService._internal();

  /// Check for available updates
  /// Returns UpdateInfo with details about available update
  Future<UpdateInfo> checkForUpdate() async {
    try {
      // Only check on Android (Play Store)
      if (!Platform.isAndroid) {
        return const UpdateInfo(availability: UpdateAvailability.notAvailable);
      }

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Check for in-app update availability using Google Play Core
      final appUpdateInfo = await in_app_update.InAppUpdate.checkForUpdate();

      dPrint(
        'Update check: available=${appUpdateInfo.updateAvailability}, '
        'immediateAllowed=${appUpdateInfo.immediateUpdateAllowed}, '
        'flexibleAllowed=${appUpdateInfo.flexibleUpdateAllowed}',
        tag: 'UpdateChecker',
      );

      // Determine update availability
      UpdateAvailability availability;
      if (appUpdateInfo.updateAvailability ==
          in_app_update.UpdateAvailability.developerTriggeredUpdateInProgress) {
        availability = UpdateAvailability.available;
      } else if (appUpdateInfo.updateAvailability ==
          in_app_update.UpdateAvailability.updateAvailable) {
        // Check if it's a required update based on client version staleness
        // If update has been available for a long time, it might be treated as required
        availability =
            appUpdateInfo.clientVersionStalenessDays != null &&
                appUpdateInfo.clientVersionStalenessDays! > 30
            ? UpdateAvailability.required
            : UpdateAvailability.available;
      } else {
        availability = UpdateAvailability.notAvailable;
      }

      return UpdateInfo(
        availability: availability,
        currentVersion: currentVersion,
        storeVersion: appUpdateInfo.availableVersionCode?.toString(),
        isImmediateUpdateAllowed: appUpdateInfo.immediateUpdateAllowed,
        isFlexibleUpdateAllowed: appUpdateInfo.flexibleUpdateAllowed,
      );
    } catch (e, s) {
      final isNotOwnedError = e.toString().contains('ERROR_APP_NOT_OWNED');
      dPrint(
        'Error checking for updates: $e',
        tag: 'UpdateChecker',
        stackTrace: isNotOwnedError ? null : s,
      );
      return const UpdateInfo(availability: UpdateAvailability.unknown);
    }
  }

  /// Start flexible update flow (user can continue using app while downloading)
  /// This shows a snackbar or banner when update is ready to install
  Future<void> startFlexibleUpdate() async {
    try {
      if (!Platform.isAndroid) return;

      await in_app_update.InAppUpdate.startFlexibleUpdate();
      dPrint('Flexible update started', tag: 'UpdateChecker');
    } catch (e, s) {
      dPrint(
        'Error starting flexible update: $e',
        tag: 'UpdateChecker',
        stackTrace: s,
      );
    }
  }

  /// Complete flexible update and restart the app
  Future<void> completeFlexibleUpdate() async {
    try {
      if (!Platform.isAndroid) return;

      await in_app_update.InAppUpdate.completeFlexibleUpdate();
      dPrint('Flexible update completed', tag: 'UpdateChecker');
    } catch (e, s) {
      dPrint(
        'Error completing flexible update: $e',
        tag: 'UpdateChecker',
        stackTrace: s,
      );
    }
  }

  /// Start immediate update flow (blocks user until update is installed)
  /// Use this for critical/security updates
  Future<void> startImmediateUpdate() async {
    try {
      if (!Platform.isAndroid) return;

      await in_app_update.InAppUpdate.performImmediateUpdate();
      dPrint('Immediate update started', tag: 'UpdateChecker');
    } catch (e, s) {
      dPrint(
        'Error starting immediate update: $e',
        tag: 'UpdateChecker',
        stackTrace: s,
      );
    }
  }

  /// Check if flexible update has been downloaded and is ready to install
  Future<bool> isFlexibleUpdateReady() async {
    try {
      if (!Platform.isAndroid) return false;

      final appUpdateInfo = await in_app_update.InAppUpdate.checkForUpdate();
      final isReady =
          appUpdateInfo.installStatus == in_app_update.InstallStatus.downloaded;
      dPrint('Flexible update ready: $isReady', tag: 'UpdateChecker');
      return isReady;
    } catch (e) {
      return false;
    }
  }
}
