import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/errors/exceptions.dart';
import 'package:solar_hub/src/core/services/push_notification_service.dart';
import 'package:solar_hub/src/core/widgets/app_logo.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/features/splash/domain/entities/startup_bootstrap_result.dart';
import 'package:solar_hub/src/features/splash/domain/usecases/get_cached_configs_usecase.dart';
import 'package:solar_hub/src/features/splash/domain/usecases/prepare_startup_usecase.dart';
import 'package:solar_hub/src/features/splash/domain/usecases/refresh_configs_usecase.dart';
import 'package:solar_hub/src/features/splash/presentation/providers/config_provider.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/settings/presentation/providers/settings_provider.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const Duration _minimumSplashDuration = Duration(milliseconds: 700);
  static const Duration _initialConfigWaitLimit = Duration(seconds: 2);
  String _version = "";
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final splashStartedAt = DateTime.now();

    // Fetch version
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version;
      });
    }

    try {
      final configProviderNotifier = ref.read(configProvider.notifier);

      final cachedConfigsResult = await getIt<GetCachedConfigsUseCase>()();
      var hasCachedConfigs = false;
      cachedConfigsResult.fold(
        (failure) {
          dPrint(
            'No cached configs available: ${failure.message}',
            tag: 'splash_screen',
          );
        },
        (snapshot) {
          hasCachedConfigs = snapshot.hasConfigs;
          configProviderNotifier.hydrateFromSnapshot(snapshot);
        },
      );

      if (!hasCachedConfigs) {
        try {
          final refreshResult = await getIt<RefreshConfigsUseCase>()().timeout(
            _initialConfigWaitLimit,
          );
          refreshResult.fold(
            (failure) {
              dPrint(
                'Initial remote config refresh failed: ${failure.message}',
                tag: 'splash_screen',
              );
            },
            (snapshot) {
              configProviderNotifier.hydrateFromSnapshot(snapshot);
              hasCachedConfigs = snapshot.hasConfigs;
            },
          );
        } on TimeoutException {
          dPrint(
            'Initial remote config refresh timed out after ${_initialConfigWaitLimit.inSeconds}s',
            tag: 'splash_screen',
          );
        }
      }

      final bootstrap = getIt<PrepareStartupUseCase>()();
      await _ensureMinimumSplashTime(splashStartedAt);

      if (!mounted) return;
      context.go(bootstrap.route);

      _startBackgroundInitialization(bootstrap);
    } catch (e, s) {
      dPrint('Initialization error: $e', tag: 'splash_screen', stackTrace: s);
      await _ensureMinimumSplashTime(splashStartedAt);
      if (mounted) context.go('/home');
    }
  }

  void _startBackgroundInitialization(StartupBootstrapResult bootstrap) {
    if (bootstrap.shouldRefreshConfigs) {
      unawaited(_refreshConfigsInBackground());
    }
    unawaited(_initializePushNotifications());
    if (bootstrap.shouldRefreshProfile) {
      unawaited(_refreshSignedInProfile());
    }
  }

  Future<void> _refreshConfigsInBackground() async {
    final configNotifier = ref.read(configProvider.notifier);
    configNotifier.setRefreshing(true);

    final refreshResult = await getIt<RefreshConfigsUseCase>()();
    if (!mounted) {
      configNotifier.setRefreshing(false);
      return;
    }

    refreshResult.fold(
      (failure) {
        dPrint(
          'Background config refresh failed: ${failure.message}',
          tag: 'splash_screen',
        );
        configNotifier.setRefreshing(false);
      },
      (snapshot) {
        configNotifier.hydrateFromSnapshot(snapshot);
      },
    );
  }

  Future<void> _initializePushNotifications() async {
    try {
      await getIt<PushNotificationService>().initialize();
      dPrint('Push notification service initialized', tag: 'splash_screen');
    } catch (e, s) {
      dPrint(
        'Push notification initialization failed: $e',
        tag: 'splash_screen',
        stackTrace: s,
      );
    }
  }

  Future<void> _refreshSignedInProfile() async {
    try {
      final response = await getIt<AuthRepository>().fetchProfile();
      await ref.read(authProvider.notifier).fetchProfile(response);

      final currentLanguage = ref.read(settingsProvider).language;
      unawaited(getIt<AuthRepository>().updateLanguage(currentLanguage));
    } on UnauthorizedException catch (e, s) {
      dPrint(
        'Profile refresh unauthorized: ${e.message}',
        tag: 'splash_screen',
        stackTrace: s,
      );
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go('/home');
      }
    } catch (e, s) {
      dPrint(
        'Profile refresh failed: $e',
        tag: 'splash_screen',
        stackTrace: s,
      );
    }
  }

  Future<void> _ensureMinimumSplashTime(DateTime splashStartedAt) async {
    final elapsed = DateTime.now().difference(splashStartedAt);
    if (elapsed >= _minimumSplashDuration) {
      return;
    }
    await Future.delayed(_minimumSplashDuration - elapsed);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Scaffold(
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo (Replace with your actual asset if available, or icon for now)
                    const AppLogo(size: 80, withBorder: true),
                    SizedBox(height: 24.h),
                    Text(
                      AppLocalizations.of(context)!.app_name_short,
                      style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      AppLocalizations.of(context)!.app_slug_short,
                      style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(height: 24.h),
                    LoadingWidget.widget(context: context, size: 30),
                    SizedBox(height: 24.h),
                    Text(
                      AppLocalizations.of(context)!.loading,
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppLocalizations.of(context)!.use_the_power_of_the_sun,
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600], fontSize: 18.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (_version.isNotEmpty)
                Positioned(
                  bottom: 30.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "${AppLocalizations.of(context)!.version} $_version",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.sp,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
