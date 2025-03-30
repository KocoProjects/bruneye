import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bruneye/theme/themebsi.dart';
import '../../service/cardservice.dart';
import '../../ui/card/carddisplay.dart';
import '../../ui/card/cardslider.dart';
import '../../service/artservice.dart';

class ExpandableGalleryList extends StatefulWidget {
  const ExpandableGalleryList({Key? key}) : super(key: key);

  @override
  _ExpandableGalleryListState createState() => _ExpandableGalleryListState();
}

class _ExpandableGalleryListState extends State<ExpandableGalleryList> {
  String _expandedSection = 'Highlights';
  Map<String, Future<List<Carddisplay>>?> _cardFutures = {};
  final List<String> _sections = ['Bookmarks', 'Artist', 'Highlights'];

  // Map sections to art categories for visual theming
  final Map<String, String> _sectionCategories = {
    'Bookmarks': 'digital',
    'Artist': 'painting',
    'Highlights': 'photography',
  };

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
          return await CardService.fetchBookmarks();
        case 'Artist':
          return await ArtService.fetchArtistCards();
        case 'Highlights':
          return await CardService.fetchCards();
        default:
          return await CardService.fetchCards();
      }
    } catch (e) {
      print('Error fetching cards for $section: $e');
      return [];
    }
  }

  // Get a color for the section based on our theme
  Color _getSectionColor(String section) {
    final category = _sectionCategories[section] ?? 'default';
switch (category.toLowerCase()) {
      case 'painting':
        return const Color(0xFF7E57C2); // Purple
      case 'digital':
        return const Color(0xFF42A5F5); // Blue
      case 'photography':
        return const Color(0xFFF9AA33); // Amber
      default:
        return const Color(0xFF4A6572); // Blue Grey
    }  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          itemCount: _sections.length,
          itemBuilder: (context, index) {
            final section = _sections[index];
            final isExpanded = _expandedSection == section;
            final sectionColor = _getSectionColor(section);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: sectionColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isExpanded
                    ? Border.all(color: sectionColor, width: 2)
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(isExpanded ? 0 : 14),
                      bottomRight: Radius.circular(isExpanded ? 0 : 14),
                    ),
                    child: Material(
                      color: isExpanded ? sectionColor.withOpacity(0.12) : Colors.white,
                      child: InkWell(
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
                        splashColor: sectionColor.withOpacity(0.3),
                        highlightColor: sectionColor.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            title: Row(
                              children: [
                                Icon(
                                  _getSectionIcon(section),
                                  color: sectionColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  section,
                                  style: textTheme.titleLarge?.copyWith(
                                    color: isExpanded ? sectionColor.darker() : textTheme.titleLarge?.color,
                                    fontWeight: isExpanded ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isExpanded ? sectionColor : Colors.transparent,
                                border: Border.all(
                                  color: isExpanded ? sectionColor : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  isExpanded ? Icons.remove : Icons.add,
                                  size: 16,
                                  color: isExpanded ? Colors.white : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(
                                color: sectionColor,
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                      Icons.error_outline,
                                      color: Colors.redAccent,
                                      size: 48
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Could not load content',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Please try again later',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sentiment_neutral,
                                    color: Colors.grey.shade400,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No ${section.toLowerCase()} found',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: CardSlider(
                              cardList: snapshot.data!,
                              sectionColor: sectionColor,
                            ),
                          );
                        }
                      },
                    )
                        : Container(),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Get an icon based on the section type
  IconData _getSectionIcon(String section) {
    switch (section) {
      case 'Bookmarks':
        return Icons.bookmark;
      case 'Artist':
        return Icons.brush;
      case 'Highlights':
        return Icons.star;
      default:
        return Icons.image;
    }
  }
}

// Extension to darken colors for better contrast
extension ColorExtension on Color {
  Color darker([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}

// Note: You'll need to update CardSlider to accept a sectionColor parameter
// and use it for styling elements within the slider.