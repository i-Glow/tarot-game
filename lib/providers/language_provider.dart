import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app language/locale
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  static const String _languageKey = 'language_code';

  Locale get locale => _locale;

  /// Initialize and load saved language preference
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode == 'en' || languageCode == 'fr') {
      _locale = Locale(languageCode);

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      notifyListeners();
    }
  }

  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      setLocale('fr');
    } else {
      setLocale('en');
    }
  }
}
