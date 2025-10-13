import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/getlistsurah.dart' as getlist;
import '../services/baca.dart' as service;

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
  return FutureBuilder<String?>(
          future: getlist.GetListSurah.getSurahUrl(surahIndex, currentPage),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...");
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              return FutureBuilder<String?>(
                future: service.BacaService.fetchContentFromUrl(snapshot.data!, 'entry-content'),
                builder: (context, contentSnapshot) {
                  if (contentSnapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading.....");
                  } else if (contentSnapshot.hasError) {
                    return Text("Error loading content: ${contentSnapshot.error}");
                  } else if (contentSnapshot.hasData) {
                    final cleanText = service.BacaService.parseHtmlToText(contentSnapshot.data!);
                    return Text(
                      cleanText,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    );
                  } else {
                    return Text("No content available");
                  }
                },
              );
            } else {
              return Text("No URL available");
            }
          },
  );
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