import 'package:flutter/material.dart';
import 'package:bruneye/service/bookmarkservice.dart';

class BookmarkButton extends StatefulWidget {
  final String tag;

  const BookmarkButton({Key? key, required this.tag}) : super(key: key);

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  final BookmarkService _bookmarkService = BookmarkService();
  bool? _isBookmarked;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final isBookmarked = await _bookmarkService.isNameBookmarked(widget.tag);
    if (mounted) {
      setState(() {
        _isBookmarked = isBookmarked;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final newStatus = await _bookmarkService.toggleBookmark(widget.tag);
    if (mounted) {
      setState(() {
        _isBookmarked = newStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isBookmarked == true ? Icons.bookmark : Icons.bookmark_border,
        color: _isBookmarked == true ? Colors.amber : Colors.white,
      ),
      onPressed: _toggleBookmark,
    );
  }
}