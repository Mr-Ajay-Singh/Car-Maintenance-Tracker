import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  Locale? _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale? get locale => _locale;

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null) {
      final localeParts = savedLocale.split('_');
      if (localeParts.length == 1) {
        _locale = Locale(localeParts[0]);
      } else if (localeParts.length == 2) {
        _locale = Locale(localeParts[0], localeParts[1]);
      }
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    String localeString = locale.languageCode;
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      localeString += '_${locale.countryCode}';
    }
    
    await prefs.setString(_localeKey, localeString);
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
} 