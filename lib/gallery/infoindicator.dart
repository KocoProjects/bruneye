import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../bookmark/bookmarkservice.dart';
import '../card/carddisplay.dart';
import '../card/cardservice.dart';

class DetectionInfoIndicator extends StatelessWidget {


  final String tag;
  final double confidence;

  const DetectionInfoIndicator({
    super.key,
    required this.tag,
    required this.confidence,
  });

  final bool _animate = true;

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      startDelay: const Duration(milliseconds: 1000),
      glowColor: Colors.grey,
      glowShape: BoxShape.circle,
      animate: _animate,
      curve: Curves.fastOutSlowIn,
      child: Material(
        elevation: 8.0,
        shape: const CircleBorder(),
        child: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: IconButton(
            icon: const Icon(Icons.touch_app_rounded, size: 50),
            onPressed: () {
              _showInfoCard(context);
            },
          ),
          radius: 30.0,
        ),
      ),
    );
  }

  void _showInfoCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: DetectionInfoCard(
                  tag: tag,
                  confidence: confidence,
                ),
              ),
            );
          },
        );
      },
    );
  }
}


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
      final cardDetails = await DetectService.fetchCardByTag(widget.tag);
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (cardDetails != null) {
            _cardDetails = cardDetails;
          } else {
            _error = 'No details found for this artwork';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load artwork details';
        });
      }
      print('Error loading card details: $e');
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

    // Main card display with bookmark functionality
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card content (unchanged)
          // ...

          // Action buttons
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _cardDetails != null ? () {
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
                } : null,
                child: const Text('VIEW DETAILS'),
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