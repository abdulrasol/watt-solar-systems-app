import 'dart:io';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/core/cashe/cashe_interface.dart';
import 'package:solar_hub/core/di/get_it.dart';
import '../../lib/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/controllers/data_controller.dart';
import 'package:solar_hub/services/theme_service.dart';
import 'package:solar_hub/services/localization_service.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/utils/app_translations.dart';
import 'package:solar_hub/utils/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solar_hub/utils/supabase_constants.dart';
import 'package:solar_hub/controllers/notifications_controller.dart';
import 'package:solar_hub/controllers/currency_controller.dart';
import 'package:solar_hub/features/admin/controllers/admin_controller.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    debugPrint('Initializing SQL FFI for Desktop');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await GetStorage.init();
  await _initSupabase();
  runApp(const SolarHub());
}

class SolarHub extends StatelessWidget {
  const SolarHub({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: 'Solar Hub',
          navigatorKey: Get.key,
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: LocalizationService().locale, // Use saved locale
          fallbackLocale: LocalizationService.fallbackLocale,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeService().theme,
          initialRoute: '/splash',
          getPages: AppRoutes.routes,
          initialBinding: BindingsBuilder(() {
            getIt<CasheInterface>();
            getIt<DataController>();
            getIt<AuthController>();
            getIt<NotificationsController>();
            getIt<AdminController>();
            getIt<CurrencyController>();
            getIt<CompanyController>();
          }),
          builder: (context, child) {
            return ToastificationWrapper(child: child!);
          },
        );
      },
    );
  }
}

Future<void> _initSupabase() async {
  await Supabase.initialize(url: SupabaseConstants.supabaseUrl, anonKey: SupabaseConstants.supabaseAnonKey);
}
