import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barwah_app/core/utils/currency_formatter.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController._();

  static final instance = AppLocaleController._();

  Locale _locale = const Locale('ar');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> setLocale(String languageCode) async {
    if (languageCode != 'ar' && languageCode != 'en') {
      return;
    }

    _locale = Locale(languageCode);
    CurrencyFormatter.setLocale(languageCode);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('app_language', languageCode);
    notifyListeners();
  }

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString('app_language');
    CurrencyFormatter.setLocale(languageCode ?? _locale.languageCode);

    if (languageCode == 'ar' || languageCode == 'en') {
      final savedLanguageCode = languageCode!;
      _locale = Locale(savedLanguageCode);
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    final nextLanguage = _locale.languageCode == 'ar' ? 'en' : 'ar';
    await setLocale(nextLanguage);
  }
}
