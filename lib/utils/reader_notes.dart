import 'package:shared_preferences/shared_preferences.dart';

/// "Nota Pembaca" -- one free-form notebook for the whole app.
///
/// Deliberately not per-article: the owner asked for a single notebook a
/// reader can jot anything into, reachable from any reading page. That is why
/// there is one key rather than one per surah/article, and why nothing here
/// takes a page index.
class ReaderNotes {
  static const String _key = 'nota_pembaca';

  /// The whole notebook. Empty string when nothing has been written yet.
  static Future<String> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '';
  }

  /// Replaces the notebook with [text].
  ///
  /// Trailing whitespace is kept: the reader may be mid-paragraph and having
  /// the cursor position shift under them on autosave would be worse than a
  /// few stray spaces.
  static Future<void> save(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, text);
  }
}
