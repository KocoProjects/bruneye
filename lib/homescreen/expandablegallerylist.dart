import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../card/carddisplay.dart';
import '../card/cardslider.dart';
import '../card/cardservice.dart' as cardService;

class ExpandableGalleryList extends StatefulWidget {
  const ExpandableGalleryList({Key? key}) : super(key: key);

  @override
  _ExpandableGalleryListState createState() => _ExpandableGalleryListState();
}

class _ExpandableGalleryListState extends State<ExpandableGalleryList> {
  String _expandedSection = 'Highlights';
  Map<String, Future<List<Carddisplay>>?> _cardFutures = {};
  final List<String> _sections = ['Bookmarks', 'Artist', 'Highlights'];

  @override
  void initState() {
    super.initState();
    // Pre-fetch the cards for the initially expanded section
    _fetchCardsForSection(_expandedSection);
  }

  // Fetch cards for a specific section
  Future<List<Carddisplay>> _fetchCardsForSection(String section) {
    // Cache the future to avoid multiple requests for the same section
    _cardFutures[section] ??= _fetchAndFilterCards(section);
    return _cardFutures[section]!;
  }

  // Fetch cards based on section with separate API calls
  Future<List<Carddisplay>> _fetchAndFilterCards(String section) async {
    try {
      // Make a separate API call for each section
      switch (section) {
        case 'Bookmarks':
          return await cardService.CardService.fetchBookmarks();
        case 'Artist':
          return await cardService.CardService.fetchArtistCards();
        case 'Highlights':
          return await cardService.CardService.fetchHighlights();
        default:
          return await cardService.CardService.fetchCards();
      }
    } catch (e) {
      print('Error fetching cards for $section: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _sections.length,
          itemBuilder: (context, index) {
            final section = _sections[index];
            final isExpanded = _expandedSection == section;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    title: Text(
                      section,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    trailing: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isExpanded ? Icons.remove : Icons.add,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedSection = '';
                        } else {
                          _expandedSection = section;
                          _fetchCardsForSection(section);
                        }
                      });
                    },
                  ),
                ),

                // Expandable content
                AnimatedCrossFade(
                  firstChild: Container(height: 0),
                  secondChild: isExpanded
                      ? FutureBuilder<List<Carddisplay>>(
                    future: _fetchCardsForSection(section),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                const SizedBox(height: 8),
                                Text('Error: ${snapshot.error}'),
                              ],
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No ${section.toLowerCase()} found',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        );
                      } else {
                        // No fixed height constraint - let CardSlider determine its own size
                        return CardSlider(cardList: snapshot.data!);
                      }
                    },
                  )
                      : Container(),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),

                const Divider(thickness: 1.0),
              ],
            );
          },
        ),
      ),
    );
  }
}