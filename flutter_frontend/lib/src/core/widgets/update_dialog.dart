import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/services/update_checker_service.dart';
import 'package:watt/src/utils/helper_methods.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dialog to notify user about available update
/// Non-blocking - user can dismiss and continue using the app
class UpdateAvailableDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  final VoidCallback? onUpdate;
  final VoidCallback? onLater;

  const UpdateAvailableDialog({
    super.key,
    required this.updateInfo,
    this.onUpdate,
    this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRequired = updateInfo.availability == UpdateAvailability.required;

    return PopScope(
      canPop: !isRequired,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Column(
          children: [
            Icon(
              Icons.system_update_alt,
              size: 48.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.updateAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.updateAvailableMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  _buildVersionRow(
                    context,
                    l10n.currentVersion,
                    updateInfo.currentVersion ?? '-',
                  ),
                  SizedBox(height: 8.h),
                  _buildVersionRow(
                    context,
                    l10n.newVersion,
                    updateInfo.storeVersion ?? '-',
                    isNew: true,
                  ),
                ],
              ),
            ),
            if (updateInfo.releaseNotes != null) ...[
              SizedBox(height: 16.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.whatsNew,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                constraints: BoxConstraints(maxHeight: 100.h),
                child: SingleChildScrollView(
                  child: Text(
                    updateInfo.releaseNotes!,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!isRequired)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onLater?.call();
              },
              child: Text(l10n.later),
            ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onUpdate?.call();
            },
            child: Text(l10n.updateNow),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow(
    BuildContext context,
    String label,
    String version, {
    bool isNew = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isNew
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'v$version',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isNew
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Snackbar to show when flexible update is downloaded and ready to install
class UpdateReadySnackbar extends StatelessWidget {
  final VoidCallback onInstall;

  const UpdateReadySnackbar({super.key, required this.onInstall});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.download_done,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.updateDownloaded,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  l10n.restartToInstall,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onInstall,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            child: Text(l10n.install),
          ),
        ],
      ),
    );
  }
}

/// Helper class to show update dialogs and snackbars
class UpdateUIHelper {
  /// Show update available dialog
  static Future<void> showUpdateDialog(
    BuildContext context,
    UpdateInfo updateInfo, {
    required VoidCallback onUpdate,
    VoidCallback? onLater,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible:
          updateInfo.availability != UpdateAvailability.required,
      builder: (context) => UpdateAvailableDialog(
        updateInfo: updateInfo,
        onUpdate: onUpdate,
        onLater: onLater,
      ),
    );
  }

  /// Show update ready snackbar
  static void showUpdateReadySnackbar(
    BuildContext context, {
    required VoidCallback onInstall,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: UpdateReadySnackbar(onInstall: onInstall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(minutes: 5),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.none,
      ),
    );
  }

  /// Handle the update flow based on update type
  static Future<void> handleUpdateFlow(
    BuildContext context,
    UpdateInfo updateInfo,
  ) async {
    final service = UpdateCheckerService();

    if (updateInfo.availability == UpdateAvailability.required &&
        updateInfo.isImmediateUpdateAllowed) {
      // For required updates, use immediate update
      dPrint('Starting immediate update', tag: 'UpdateUIHelper');
      await service.startImmediateUpdate();
    } else if (updateInfo.isFlexibleUpdateAllowed) {
      // For optional updates, show dialog first
      await showUpdateDialog(
        context,
        updateInfo,
        onUpdate: () async {
          dPrint('Starting flexible update', tag: 'UpdateUIHelper');
          await service.startFlexibleUpdate();
        },
        onLater: () {
          dPrint('User postponed update', tag: 'UpdateUIHelper');
        },
      );
    } else {
      // Fallback: open Play Store
      await showUpdateDialog(
        context,
        updateInfo,
        onUpdate: () async {
          await _openPlayStore();
        },
        onLater: () {},
      );
    }
  }

  /// Open Play Store for manual update
  static Future<void> _openPlayStore() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;

      final url = Uri.parse('market://details?id=$packageName');
      final fallbackUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageName',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      dPrint('Error opening Play Store: $e', tag: 'UpdateUIHelper');
    }
  }

  /// Check for flexible update completion and show install prompt
  static Future<void> checkAndShowInstallPrompt(BuildContext context) async {
    final service = UpdateCheckerService();
    final isReady = await service.isFlexibleUpdateReady();

    if (isReady && context.mounted) {
      showUpdateReadySnackbar(
        context,
        onInstall: () async {
          await service.completeFlexibleUpdate();
        },
      );
    }
  }
}
