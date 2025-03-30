import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bruneye/ui/card/carddisplay.dart';
import 'package:bruneye/service/languageservice.dart';
import 'package:bruneye/service/bookmarkservice.dart';
import 'package:bruneye/providers/bookmarkprovider.dart';
import 'package:bruneye/service/languageservice.dart';

class CardService {
  // Base URL and API paths
  // ngrok is used for tunneling to localhost
  static const String _baseUrl = 'https://d1f0-134-83-2-8.ngrok-free.app';

  // API paths for fetching cards
  static const String _apiPath = '/api/artcards';

  // API path for fetching bookmarks info
  static const String _bookPath = '/api/art';

  static String get baseUrl => _baseUrl;

  static String get fullApiUrl => '$_baseUrl$_apiPath';
  static final LanguageService _languageService = LanguageService();

  // Fetch and translate cards
  static Future<List<Carddisplay>> fetchCards({String endpoint = ''}) async {
    await _languageService.initialize();

    final url = endpoint.isEmpty
        ? '$_baseUrl$_apiPath'
        : '$_baseUrl$_apiPath/$endpoint';
    final response = await http.get(Uri.parse(url), headers: {
      "ngrok-skip-browser-warning": "1",
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final translatedCards = <Carddisplay>[];

      for (var item in data) {
        // Only translate if not in English
        if (_languageService.currentLanguage != 'en') {
          // Translate the description
          item['description'] =
          await _languageService.translate(item['description']);
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
        // Print the error response for debugging when no body
        print('Response body: ${response.body ?? 'No response body'}');
      }
      throw Exception('Failed to load data');
    }
  }

// Fetch bookmarks
  static Future<List<Carddisplay>> fetchBookmarks() async {
    await _languageService.initialize();
// Load the list of bookmarked names
    final List<String>? bookmarkedNames = await BookmarkProvider()
        .loadBookmarkedNames();

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
            data['description'] =
            await _languageService.translate(data['description']);
          }
          bookmarkedCards.add(Carddisplay.fromJson(
              data,
              onTap: () {},
              scale: 1.0,
              isFocused: false
          ));
        } else {
          if (kDebugMode) {
            print('Failed to load data for $name: ${response.body ??
                'No response body'}');
          }
        }
      }
    }

    return bookmarkedCards;
  }

}