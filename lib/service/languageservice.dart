import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'package:flutter/material.dart';
import 'package:bruneye/language/langselector.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  final translator = GoogleTranslator();

  // Supported languages, more can be added
  final Map<String, String> languages = {
    'en': 'English',
    'es': 'Spanish',
    'hi': 'Hindi',
    'fr': 'French',
  };

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  Future<void> initialize() async {
    // Load the saved language code from SharedPreferences
    // default language is English
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('languageCode') ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    if (languages.containsKey(languageCode)) {
      // Save the selected language code to SharedPreferences based on language code
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', languageCode);
      _currentLanguage = languageCode;
    }
  }

  Future<String> translate(String text) async {
    if (_currentLanguage == 'en') return text;

    try {
      final translation = await translator.translate(
        text,
        from: 'en',
        to: _currentLanguage,
      );
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }
}
