import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/getlistsurah.dart' as getlist;
import '../services/baca.dart' as service;
import '../services/download_service.dart';

Future<double> getFontSize() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('font_size') ?? 16.0;
}

Widget buildPageIndicator(
  int currentPage,
  int totalPages,
  Function() onPrevious,
  Function() onNext,
) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: currentPage > 0 ? onPrevious : null,
          icon: Icon(Icons.arrow_back),
          label: Text('Sebelum'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: currentPage < totalPages - 1 ? onNext : null,
          icon: Icon(Icons.arrow_forward),
          label: Text('Selepas'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Widget buildSurahBody(
  BuildContext context,
  Map<String, String> surahData,
  Widget bodyContent,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Surah header
      Center(
        child: Column(
          children: [
            Text(
              'Surah ${surahData['name']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              surahData['name_arab']!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/images/bismillah.png',
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * 0.6,
            ),
          ],
        ),
      ),
      SizedBox(height: 30),

      // Content placeholder
      bodyContent,
    ],
  );
}

Widget bodyContent(surahIndex, currentPage) {
  double fontSize = 16.0;
  getFontSize().then((value) {
    fontSize = value;
  });
  return FutureBuilder<String?>(
    future: _getPageContent(surahIndex, currentPage),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 52, 21, 104),
                ),
              ),
              SizedBox(height: 16),
              // Text("Memuatkan kandungan..."),
            ],
          ),
        );
      } else if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text("Gagal memuat kandungan."),
            ],
          ),
        );
      } else if (snapshot.hasData) {
        return Text(
          snapshot.data!,
          style: TextStyle(fontSize: fontSize),
          textAlign: TextAlign.justify,
        );
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text("Sila sambungkan internet untuk memuatkan kandungan"),
            ],
          ),
        );
      }
    },
  );
}

/// Get content for a specific page (cached or fetch)
Future<String?> _getPageContent(int surahIndex, int pageIndex) async {
  // First try to get from cache
  final cachedPage = await DownloadService.getCachedPage(surahIndex, pageIndex);
  
  if (cachedPage != null) {
    return cachedPage['textContent'];
  }
  
  // If not cached, fetch from URL
  final url = await getlist.GetListSurah.getSurahUrl(surahIndex, pageIndex);
  if (url != null) {
    final content = await service.BacaService.fetchContentFromUrl(url, 'entry-content');
    if (content != null) {
      return service.BacaService.parseHtmlToText(content);
    }
  }
  
  return null;
}

// Database functions for bookmarks
Future<List<Map<String, dynamic>>> getBookmarks() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getString('bookmarks');
    if (bookmarksJson != null) {
      final List<dynamic> bookmarksList = json.decode(bookmarksJson);
      return bookmarksList.cast<Map<String, dynamic>>();
    }
    return [];
  } catch (e) {
    print('Error getting bookmarks: $e');
    return [];
  }
}

Future<void> saveBookmarks(List<Map<String, dynamic>> bookmarks) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = json.encode(bookmarks);
    await prefs.setString('bookmarks', bookmarksJson);
  } catch (e) {
    print('Error saving bookmarks: $e');
  }
}

Future<void> addBookmark(int surahIndex, int currentPage) async {
  try {
    final bookmark = {
      'surahIndex': surahIndex,
      'currentPage': currentPage,
      'dateAdded': DateTime.now().toIso8601String(),
    };
    final bookmarks = await getBookmarks();
    
    // Check if bookmark already exists
    final existingIndex = bookmarks.indexWhere((b) => 
      b['surahIndex'] == surahIndex && b['currentPage'] == currentPage);
    
    if (existingIndex == -1) {
      bookmarks.add(bookmark);
      await saveBookmarks(bookmarks);
    }
  } catch (e) {
    print('Error adding bookmark: $e');
  }
}

Future<void> removeBookmark(int surahIndex, int currentPage) async {
  try {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => 
      b['surahIndex'] == surahIndex && b['currentPage'] == currentPage);
    await saveBookmarks(bookmarks);
  } catch (e) {
    print('Error removing bookmark: $e');
  }
}

Future<bool> isBookmarked(int surahIndex, int currentPage) async {
  try {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => 
      b['surahIndex'] == surahIndex && b['currentPage'] == currentPage);
  } catch (e) {
    print('Error checking bookmark: $e');
    return false;
  }
}