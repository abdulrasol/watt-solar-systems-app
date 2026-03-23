import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/features/splash/domain/usecases/get_configs_usecase.dart';
import 'package:solar_hub/src/features/splash/presentation/providers/config_provider.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/settings/domain/entiteis/settings.dart';
import 'package:solar_hub/src/features/settings/presentation/providers/settings_provider.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final AuthState authState;

  @override
  void initState() {
    super.initState();
    authState = ref.read(authProvider);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
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

    // Artificial delay for better UX (so logo doesn't flash)
    await Future.delayed(const Duration(seconds: 1));

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (Replace with your actual asset if available, or icon for now)
            Icon(Icons.solar_power, size: 80, color: Colors.orange.shade700),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.solar_hub, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.use_the_power_of_the_sun, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.loading, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
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
