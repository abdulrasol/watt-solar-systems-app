import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:solar_hub/firebase_options.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/settings/presentation/providers/settings_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/app_routers.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:toastification/toastification.dart';
import 'package:timeago/timeago.dart' as timeago;

Future<void> _initializeFirebaseSafely() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stackTrace) {
    dPrint(
      'Firebase initialization skipped: $e',
      tag: 'main',
      stackTrace: stackTrace,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timeago with Arabic - set once, not on every build
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setDefaultLocale('ar'); // Set default locale at startup

  await _initializeFirebaseSafely();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    dPrint('Initializing SQL FFI for Desktop', tag: 'main');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  try {
    await GetStorage.init();
  } catch (e, stackTrace) {
    dPrint(
      'GetStorage initialization failed: $e',
      tag: 'main',
      stackTrace: stackTrace,
    );
  }
  setupDependencies();
  await getIt.allReady();
  runApp(const ProviderScope(child: SolarHub()));
}

class SolarHub extends ConsumerWidget {
  const SolarHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    // Use cachedRouterProvider to avoid recreating GoRouter on every rebuild
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return ToastificationWrapper(
          child: MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context)!.app_name,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar'), Locale('en')],
            locale: Locale(settings.language),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
          ),
        );
      },
    );
  }
}
