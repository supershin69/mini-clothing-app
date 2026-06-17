import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = Locale("en");

  Locale get currentLocale => _currentLocale;
  bool get isMyanmar => _currentLocale.languageCode == "my";

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('lang_code') ?? 'en';
    _currentLocale = Locale(langCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    if (_currentLocale.languageCode == "en") {
      _currentLocale = const Locale("my");
      await prefs.setString("lang_code", "my");
    } else {
      _currentLocale = const Locale("en");
      await prefs.setString("lang_code", "en");
    }

    notifyListeners();
  }
}
