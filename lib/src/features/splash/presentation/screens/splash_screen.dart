import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/services/push_notification_service.dart';
import 'package:solar_hub/src/core/widgets/app_logo.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/features/splash/domain/usecases/get_configs_usecase.dart';
import 'package:solar_hub/src/features/splash/presentation/providers/config_provider.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/settings/domain/entiteis/settings.dart';
import 'package:solar_hub/src/features/settings/presentation/providers/settings_provider.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Fetch app configs early
      final configsResult = await getIt<GetConfigsUseCase>()();
      configsResult.fold(
        (failure) {
          dPrint('Failed to load configs: ${failure.message}', tag: 'splash_screen');
          // Proceed with default behavior since configs failed
        },
        (configs) {
          dPrint('Loaded ${configs.length} configs successfully', tag: 'splash_screen');
          // Store the configs in the global Map for O(1) fast reading!
          ref.read(configProvider.notifier).setConfigs(configs);
        },
      );
      await getIt<PushNotificationService>().initialize();
      dPrint('Push notification service initialized', tag: 'splash_screen');

      // Now access auth provider (after dependencies are ready)
      final authState = ref.read(authProvider);

      // Artificial delay for better UX (so logo doesn't flash)
      await Future.delayed(const Duration(seconds: 4));

      // Check if user is logged in
      if (authState.user == null) {
        // User not logged in -> Go to Auth/Home (Guest)
        // Actually usually Force Login or Guest Home.
        // If Home supports Guest, go to Home.
        if (mounted) context.go('/home');
        return;
      }

      // User is logged in -> Load Data
      try {
        // Initialize controllers that might need data

        // Wait for critical data
        final response = await getIt<AuthRepository>().fetchProfile();
        await ref.read(authProvider.notifier).fetchProfile(response);

        // Routing Logic
        if (authState.isCompanyMember || authState.isSuperUser) {
          // Is Company Member -> Check for saved choices or go to Role Selection
          final handled = loadSaveMyChoies();
          if (!handled) {
            if (mounted) context.go('/role_selection');
          }
        } else {
          // Normal User -> Go to Home
          if (mounted) context.go('/home');
        }
      } catch (e, s) {
        // Logic error or offline? Go home or retry
        dPrint(e, tag: 'splash_screen', stackTrace: s);
        if (mounted) context.go('/home');
      }
    } catch (e, s) {
      dPrint('Initialization error: $e', tag: 'splash_screen', stackTrace: s);
      // Still try to continue after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo (Replace with your actual asset if available, or icon for now)
                const AppLogo(size: 80, withBorder: true),
                SizedBox(height: 24.h),
                Text(
                  AppLocalizations.of(context)!.app_name,
                  style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context)!.app_slug,
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600], fontSize: 18.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                LoadingWidget.widget(context: context, size: 30),
                // const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context)!.loading,
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context)!.use_the_power_of_the_sun,
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600], fontSize: 18.sp),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool loadSaveMyChoies() {
    final Settings settings = ref.watch(settingsProvider);

    bool saveMyChoies = settings.saveRolePageSelection;
    if (saveMyChoies) {
      final String? myChoies = settings.saveRolePageSelectionRoute;
      if (myChoies == null || myChoies.isEmpty) {
        context.go('/home');
        return true;
      } else {
        context.go(myChoies);
        return true;
      }
    }
    return false;
  }
}
