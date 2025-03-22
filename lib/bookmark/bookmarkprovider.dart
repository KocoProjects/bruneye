import 'package:flutter/material.dart';
import 'bookmarkservice.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkService _bookmarkService = BookmarkService();
  List<String> _bookmarkedNames = [];
  bool _isLoading = false;

  List<String> get bookmarkedNames => _bookmarkedNames;

  bool get isLoading => _isLoading;

  BookmarkProvider() {
    loadBookmarkedNames();
  }

  Future<List<String>> loadBookmarkedNames() async {
    _isLoading = true;
    notifyListeners();

    _bookmarkedNames = await _bookmarkService.getBookmarkedNames();

    _isLoading = false;
    notifyListeners();
    return _bookmarkedNames;
  }

  Future<void> toggleBookmark(String name) async {
    final isBookmarked = await _bookmarkService.toggleBookmark(name);

    if (isBookmarked && !_bookmarkedNames.contains(name)) {
      _bookmarkedNames.add(name);
    } else {
      _bookmarkedNames.remove(name);
    }

    notifyListeners();
  }

  bool isNameBookmarked(String name) {
    return _bookmarkedNames.contains(name);
  }

}
