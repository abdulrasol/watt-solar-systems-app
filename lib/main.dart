import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/utils/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
      title: 'Solar Hub',
      //home: const Home(),
      initialRoute: '/home',
      theme: AppTheme.lightTheme, // Apply the light theme
      darkTheme: AppTheme.darkTheme, // Apply the dark theme
      themeMode:
          ThemeMode.system, // Use system preference for theme (light/dark)
    );
  }
}
