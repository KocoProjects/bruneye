import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bruneye/theme/themebsi.dart';
import 'package:bruneye/service/languageservice.dart';
import 'package:bruneye/ui/card/carddisplay.dart';

class ArtService {
  static const String _baseUrl = 'https://d1f0-134-83-2-8.ngrok-free.app';
  static final LanguageService _languageService = LanguageService();

  static Future<List<Carddisplay>> fetchArtistCards() async {
    final List<Carddisplay> artistCards = [];

    try {
      final url = '$_baseUrl/api/artists';
      if (kDebugMode) {
        print('Fetching artists from: $url');
      }

      final response = await http.get(Uri.parse(url), headers: {
        "ngrok-skip-browser-warning": "1",
      });

      if (response.statusCode == 200) {
        final List<dynamic> artistsData = json.decode(response.body);
        await _languageService.initialize();

        for (var artist in artistsData) {
          if (artist == null) continue;

          final String firstName = artist['firstname'] ?? '';
          final String lastName = artist['lastname'] ?? '';
          final String artistName = '${firstName} ${lastName}'.trim();
          final String description = artist['description']?.toString() ?? '';
          final String imageUrl = artist['picurl']?.toString() ?? '';
          final String id = artist['artistid']?.toString() ?? '';

          // Create properly formatted data for Carddisplay
          final Map<String, dynamic> cardData = {
            'title': artistName,
            'description': description,
            'artist': '',
            'collectionname': 'Featured Artists',
            'artpicurl': imageUrl,
            'location': 'Gallery',
            'materials': 'Artist Profile',
          };

          // Only translate if needed
          if (_languageService.currentLanguage != 'en' && description.isNotEmpty) {
            try {
              cardData['description'] = await _languageService.translate(description);
            } catch (e) {
              if (kDebugMode) {
                print('Translation error: $e');
              }
            }
          }

          try {
            final card = Carddisplay.fromJson(
              cardData,
              onTap: () {},
              scale: 1.0,
              isFocused: false,
            );

            artistCards.add(card);
          } catch (e) {
            if (kDebugMode) {
              print('Error creating Carddisplay for artist $artistName: $e');
              print('Card data: $cardData');
            }
          }
        }

        return artistCards;
      } else {
        if (kDebugMode) {
          print('Failed to fetch artists: ${response.statusCode}');
        }
        throw Exception('Failed to fetch artists');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching artists: $e');
      }
      return [];
    }
  }
}