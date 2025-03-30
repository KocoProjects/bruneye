import 'package:flutter/material.dart';
import 'package:bruneye/ui/card/carddisplay.dart';
import 'package:bruneye/service/detectservice.dart';
import 'package:bruneye/service/bookmarkservice.dart';
import 'package:bruneye/ui/card/fullscreencard.dart';

class DetectionInfoCard extends StatefulWidget {
  final String tag;
  final double confidence;

  const DetectionInfoCard({
    super.key,
    required this.tag,
    required this.confidence,
  });

  @override
  State<DetectionInfoCard> createState() => _DetectionInfoCardState();
}

class _DetectionInfoCardState extends State<DetectionInfoCard> {
  bool _isLoading = true;
  // The card details fetched from the API
  Carddisplay? _cardDetails;
  String _error = '';
  bool _isBookmarked = false;
  final BookmarkService _bookmarkService = BookmarkService();

  @override
  void initState() {
    super.initState();
    _loadCardDetails();
    _checkIfBookmarked();
  }

  Future<void> _loadCardDetails() async {
    try {
      setState(() {
        _isLoading = true;  // Ensure loading state is set
        _error = '';        // Clear any previous errors
      });

      print('Fetching card details for tag: ${widget.tag}');  // Debug log

      // Fetch card details using the tag
      final cardDetails = await DetectService.fetchCardByTag(widget.tag);

      print('API response: $cardDetails');  // Debug log to see the response

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (cardDetails != null) {
            _cardDetails = cardDetails;
            print('Card details loaded successfully: ${cardDetails.title}');
          } else {
            _error = 'No details found for this artwork (${widget.tag})';
            print('No card details found for tag: ${widget.tag}');
          }
        });
      }
    } catch (e, stackTrace) {  // Capture stack trace too
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load artwork details: ${e.toString()}';
        });
      }
      print('Error loading card details: $e');
      print('Stack trace: $stackTrace');  // Print stack trace for more context
    }
  }

  Future<void> _checkIfBookmarked() async {
    final isBookmarked = await _bookmarkService.isNameBookmarked(widget.tag);
    if (mounted) {
      setState(() {
        _isBookmarked = isBookmarked;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    try {
      // Toggle bookmark and get the new status
      final isBookmarked = await _bookmarkService.toggleBookmark(widget.tag);

      // Log to console for debugging
      print('Bookmark status for ${widget.tag}: ${isBookmarked ? "Saved" : "Removed"}');

      // Get all current bookmarks and log them
      final bookmarks = await _bookmarkService.getBookmarkedNames();
      print('Current bookmarks: $bookmarks');

      // Update UI
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });

        // Show snackbar feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isBookmarked
                    ? 'Bookmark saved: ${_cardDetails?.title ?? widget.tag}'
                    : 'Bookmark removed: ${_cardDetails?.title ?? widget.tag}'
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'VIEW ALL',
              onPressed: () {
                // Show all bookmarks in console
                print('All saved bookmarks: $bookmarks');
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save bookmark: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(widget.tag),
                  subtitle: Text(_error),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      onPressed: _toggleBookmark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Main card display with bookmark functionality similar to Carddisplay
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_cardDetails != null) ...[
            // Title and description section
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cardDetails!.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 22,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _cardDetails!.description.length > 100
                        ? '${_cardDetails!.description.substring(0, 97)}...'
                        : _cardDetails!.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Image with location and bookmark button
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenCard(
                            title: _cardDetails!.title,
                            description: _cardDetails!.description,
                            imageUrl: _cardDetails!.artPicUrl,
                            location: _cardDetails!.location,
                            tag: widget.tag,
                            artist: _cardDetails!.artist ?? 'Unknown Artist',
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      child: Image.network(
                        _cardDetails!.artPicUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
                          );
                        },
                      ),
                    ),
                  ),

                  // Location indicator and bookmark button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _cardDetails!.location,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 3.0,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                          onPressed: _toggleBookmark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // If no card details, show view details and bookmark buttons
          if (_cardDetails == null)
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: null,
                  child: const Text('NO DETAILS AVAILABLE'),
                ),
                IconButton(
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  onPressed: _toggleBookmark,
                ),
              ],
            ),
        ],
      ),
    );
  }
}