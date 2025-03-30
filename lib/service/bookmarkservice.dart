import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _bookmarkedNamesKey = 'bookmarked_names';

  // Get all bookmarked names
  Future<List<String>> getBookmarkedNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarkedNamesKey) ?? [];
  }

  // Save the list of bookmarked names
  Future<void> saveBookmarkedNames(List<String> names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarkedNamesKey, names);
  }

  // Add a name to bookmarks
  Future<void> bookmarkName(String name) async {
    final bookmarkedNames = await getBookmarkedNames();

    if (!bookmarkedNames.contains(name)) {
      bookmarkedNames.add(name);
      await saveBookmarkedNames(bookmarkedNames);
    }
  }

  // Remove a name from bookmarks
  Future<void> unbookmarkName(String name) async {
    final bookmarkedNames = await getBookmarkedNames();

    bookmarkedNames.remove(name);
    await saveBookmarkedNames(bookmarkedNames);
  }

  // Check if a name is bookmarked
  Future<bool> isNameBookmarked(String name) async {
    final bookmarkedNames = await getBookmarkedNames();
    return bookmarkedNames.contains(name);
  }


  // Toggle bookmark status for a name
  Future<bool> toggleBookmark(String name) async {
    final isBookmarked = await isNameBookmarked(name);

    if (isBookmarked) {
      await unbookmarkName(name);
      return false;
    } else {
      await bookmarkName(name);
      return true;
    }
  }
}