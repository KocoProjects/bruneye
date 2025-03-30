import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bruneye/service/languageservice.dart';
import 'package:bruneye/ui/card/carddisplay.dart';
import 'dart:async';
import 'dart:io';




class DetectService {
  static const String _baseUrl = 'https://d1f0-134-83-2-8.ngrok-free.app';
  static const String _apiPath = '/api/art/';
  static String get baseUrl => _baseUrl;
  static String get fullApiUrl => '$_baseUrl$_apiPath';
  static final LanguageService _languageService = LanguageService();

  static Future<Carddisplay?> fetchCardByTag(String tag) async {
    if (tag.isEmpty) {
      if (kDebugMode) {
        print('Warning: Empty tag provided to fetchCardByTag');
      }
      return null;
    }

    await _languageService.initialize();
    final Uri uri = Uri.parse('$_baseUrl$_apiPath$tag');

    if (kDebugMode) {
      print('Fetching card from: $uri');
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          "ngrok-skip-browser-warning": "1",
          "Content-Type": "application/json",
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out. Server might be unavailable.');
        },
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          if (kDebugMode) {
            print('Empty response body received for tag: $tag');
          }
          return null;
        }

        try {
          final dynamic data = json.decode(response.body);

          if (data != null) {
            if (_languageService.currentLanguage != 'en') {
              try {
                data['description'] = await _languageService.translate(data['description']);
              } catch (e) {
                if (kDebugMode) {
                  print('Translation failed: $e. Using original description.');
                }
              }
            }

            return Carddisplay.fromJson(
                data,
                onTap: () {},
                scale: 1.0,
                isFocused: false
            );
          } else {
            if (kDebugMode) {
              print('Null data after parsing JSON for tag: $tag');
            }
            return null;
          }
        } catch (e) {
          if (kDebugMode) {
            print('JSON parsing error: $e');
            print('Raw response: ${response.body}');
          }
          throw FormatException('Invalid response format: ${e.toString()}');
        }
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print('Card not found for tag: $tag');
        }
        return null; // Return null for not found instead of throwing exception
      } else {
        if (kDebugMode) {
          print('Error status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        throw HttpException('Failed to load card data. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in fetchCardByTag: ${e.toString()}');
      }
      rethrow; // Rethrow to let caller handle the specific exception
    }
  }
}