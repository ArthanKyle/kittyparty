import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('selected_language') ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> changeLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', code);
    _locale = Locale(code);
    notifyListeners();
  }
}
