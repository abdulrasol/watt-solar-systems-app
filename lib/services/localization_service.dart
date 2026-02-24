import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalizationService {
  final _box = GetStorage();
  final _key = 'languageCode';

  // Default locale
  static const fallbackLocale = Locale('en', 'US');

  // Supported locales
  static final locales = [const Locale('en', 'US'), const Locale('ar', 'SA')];

  // Get current locale from storage
  Locale get locale {
    final String? langCode = _box.read(_key);
    if (langCode == null) return fallbackLocale;
    return langCode == 'ar' ? const Locale('ar', 'SA') : const Locale('en', 'US');
  }

  // Switch language
  void changeLocale(String langCode) {
    _box.write(_key, langCode);
    final locale = langCode == 'ar' ? const Locale('ar', 'SA') : const Locale('en', 'US');
    Get.updateLocale(locale);
  }
}
