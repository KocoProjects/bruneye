import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../bookmark/bookmarkprovider.dart';
import '../gallery/infoindicator.dart';
import 'carddisplay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  final translator = GoogleTranslator();

  final Map<String, String> languages = {
    'en': 'English',
    'es': 'Spanish',
    'hi': 'Hindi',
    'fr': 'French',
  };

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('languageCode') ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    if (languages.containsKey(languageCode)) {
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

class CardService {
  static const String _baseUrl = 'https://c69e-134-83-2-8.ngrok-free.app';
  static const String _apiPath = '/api/artcards';
  static const String _bookPath = '/api/art';
  static String get baseUrl => _baseUrl;
  static String get fullApiUrl => '$_baseUrl$_apiPath';
  static final LanguageService _languageService = LanguageService();

  // Fetch and translate cards
  static Future<List<Carddisplay>> fetchCards({String endpoint = ''}) async {
    await _languageService.initialize();
    final url = endpoint.isEmpty ? '$_baseUrl$_apiPath' : '$_baseUrl$_apiPath/$endpoint';

    final response = await http.get(Uri.parse(url), headers: {
      "ngrok-skip-browser-warning": "1",
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final translatedCards = <Carddisplay>[];

      for (var item in data) {
        // Only translate if not in English
        if (_languageService.currentLanguage != 'en') {
          item['description'] = await _languageService.translate(item['description']);
        }

        translatedCards.add(Carddisplay.fromJson(
            item,
            onTap: () {},
            scale: 1.0,
            isFocused: false
        ));
      }

      return translatedCards;
    } else {
      if (kDebugMode) {
        print('Response body: ${response.body ?? 'No response body'}');
      }
      throw Exception('Failed to load data');
    }
  }

  static Future<List<Carddisplay>> fetchBookmarks() async {
    await _languageService.initialize();
    // Assuming getBookmarkedNames is a method that fetches bookmarked names
    final List<String>? bookmarkedNames = await BookmarkProvider().loadBookmarkedNames();
    final List<Carddisplay> bookmarkedCards = [];
    if (bookmarkedNames != null) {
      for (final name in bookmarkedNames) {
        final url = '$_baseUrl$_bookPath/$name';
        final response = await http.get(Uri.parse(url), headers: {
          "ngrok-skip-browser-warning": "1",
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (_languageService.currentLanguage != 'en') {
            data['description'] = await _languageService.translate(data['description']);
          }
          bookmarkedCards.add(Carddisplay.fromJson(
              data,
              onTap: () {},
              scale: 1.0,
              isFocused: false
          ));
        } else {
          if (kDebugMode) {
            print('Failed to load data for $name: ${response.body ?? 'No response body'}');
          }
        }
      }
    }

    return bookmarkedCards;
  }

  // Fetch artist cards
  static Future<List<Carddisplay>> fetchArtistCards() async {
    return fetchCards();
  }

  // Fetch highlights
  static Future<List<Carddisplay>> fetchHighlights() async {
    return fetchCards();
  }
}

class DetectService {
  static const String _baseUrl = 'https://3e64-134-83-2-8.ngrok-free.app';
  static const String _apiPath = '/api/art/';
  static String get baseUrl => _baseUrl;
  static String get fullApiUrl => '$_baseUrl$_apiPath';
  static final LanguageService _languageService = LanguageService();

  // Fetch a single card by tag
  static Future<Carddisplay?> fetchCardByTag(String tag) async {
    await _languageService.initialize();
    // Construct the URL for the specific tag endpoint
    final url = '$_baseUrl$_apiPath/tag/$tag';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "ngrok-skip-browser-warning": "1",
      });

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // Check if we got data for the requested tag
        if (data != null) {
          // Translate description if needed
          if (_languageService.currentLanguage != 'en') {
            data['description'] = await _languageService.translate(data['description']);
          }

          return Carddisplay.fromJson(
              data,
              onTap: () {},
              scale: 1.0,
              isFocused: false
          );
        }
        return null; // No card found with this tag
      } else {
        if (kDebugMode) {
          print('Response body: ${response.body ?? 'No response body'}');
        }
        throw Exception('Failed to load card data for tag: $tag');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching card by tag: $e');
      }
      throw Exception('Failed to load card data for tag: $tag');
    }
  }
}