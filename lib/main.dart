import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/settings/presentation/providers/settings_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/app_routers.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    dPrint('Initializing SQL FFI for Desktop', tag: 'main');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await GetStorage.init();
  setupDependencies();
  await getIt.allReady();
  runApp(const ProviderScope(child: SolarHub()));
}

class SolarHub extends ConsumerWidget {
  const SolarHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return ToastificationWrapper(
          child: MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context)!.app_name,
            debugShowCheckedModeBanner: false,
            // Translations
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            locale: Locale(settings.language),
            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
            // Router
            routerConfig: ref.watch(routerProvider),
          ),
        );
      },
    );
  }
}
