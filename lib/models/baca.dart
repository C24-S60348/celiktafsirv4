import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/getlistsurah.dart' as getlist;
import '../services/baca.dart' as service;
import '../services/download_service.dart';

/// Remove numbering from unordered list items and clean up nested list structures
String _removeNumbersFromUnorderedLists(String html) {
  String result = html;
  
  // Remove wrapper <ol><li style="list-style-type: none"><ol>...</ol></li></ol> structures
  result = result.replaceAllMapped(
    RegExp(
      r'<ol[^>]*>\s*<li[^>]*style="list-style-type:\s*none"[^>]*>\s*(<ol[^>]*>.*?</ol>)\s*</li>\s*</ol>',
      dotAll: true,
      caseSensitive: false,
    ),
    (match) => match.group(1)!, // Keep only the inner <ol>
  );
  
  // Remove wrapper <ul><li style="list-style-type: none"><ul>...</ul></li></ul> structures
  result = result.replaceAllMapped(
    RegExp(
      r'<ul[^>]*>\s*<li[^>]*style="list-style-type:\s*none"[^>]*>\s*(<ul[^>]*>.*?</ul>)\s*</li>\s*</ul>',
      dotAll: true,
      caseSensitive: false,
    ),
    (match) => match.group(1)!, // Keep only the inner <ul>
  );
  
  // Process <ul> tags to remove numbers
  int maxIterations = 20;
  int iteration = 0;
  
  while (iteration < maxIterations) {
    // Find the innermost <ul>...</ul> block
    final match = RegExp(
      r'<ul[^>]*>((?:(?!<ul[^>]*>).)*?)</ul>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(result);
    
    if (match == null) break;
    
    String fullMatch = match.group(0)!;
    String ulOpenTag = fullMatch.substring(0, fullMatch.indexOf('>') + 1);
    String ulContent = match.group(1)!;
    
    // Remove number patterns from <li> tags within this <ul>
    String cleanedContent = ulContent.replaceAllMapped(
      RegExp(r'(<li[^>]*>)\s*(\d+\.\s+)', caseSensitive: false),
      (m) => m.group(1)!,
    );
    
    result = result.replaceFirst(fullMatch, '$ulOpenTag$cleanedContent</ul>');
    iteration++;
  }
  
  return result;
}

/// Get proxied image URL for web to bypass CORS
String _getProxiedImageUrl(String imageUrl) {
  // Handle relative URLs by converting to absolute URLs
  String absoluteUrl = imageUrl;
  if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
    // If it's a relative URL, prepend the base URL
    const baseUrl = 'https://celiktafsir.net';
    if (imageUrl.startsWith('/')) {
      absoluteUrl = '$baseUrl$imageUrl';
    } else {
      absoluteUrl = '$baseUrl/$imageUrl';
    }
  }
  
  if (kIsWeb) {
    // For web, use CORS proxy for images
    const corsProxy = 'https://afwanhaziq.vps.webdock.cloud/proxy?url=';
    return '$corsProxy$absoluteUrl';
  }
  // For mobile, use direct URL
  return absoluteUrl;
}

/// Process HTML content to proxy all image URLs for web
String _processHtmlForWeb(String htmlContent) {
  if (!kIsWeb) {
    // For mobile, return content as-is
    return htmlContent;
  }
  
  // For web, proxy all image URLs in the HTML
  // Replace src="..." in img tags
  final imgPattern = RegExp(r'<img([^>]*)\s+src="([^"]*)"([^>]*)>', caseSensitive: false);
  
  return htmlContent.replaceAllMapped(imgPattern, (match) {
    final beforeSrc = match.group(1) ?? '';
    final originalSrc = match.group(2) ?? '';
    final afterSrc = match.group(3) ?? '';
    
    // Get proxied URL
    final proxiedSrc = _getProxiedImageUrl(originalSrc);
    
    return '<img$beforeSrc src="$proxiedSrc"$afterSrc>';
  });
}

/// Extension builder for network images
Widget networkImageExtensionBuilder(ExtensionContext context) {
  final src = context.attributes['src'];
  if (src != null && src.isNotEmpty) {
    // Proxy the image URL for web to bypass CORS
    final proxiedUrl = _getProxiedImageUrl(src);
    
    return Image.network(
      proxiedUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image from: $proxiedUrl');
        print('Error: $error');
        return Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey[600]),
              SizedBox(height: 8),
              Text(
                'Gagal memuatkan gambar',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
  return SizedBox.shrink();
}

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
              '${surahData['pageTitle'] ?? surahData['name'] ?? ''}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

Widget bodyContent(surahIndex, currentPage, [bool isDark = false, Color? textColor]) {
  return FutureBuilder<double>(
    future: getFontSize(),
    builder: (context, fontSizeSnapshot) {
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
            final fontSize = fontSizeSnapshot.data ?? 16.0;
            // Remove numbers from unordered list items
            final cleanedHtml = _removeNumbersFromUnorderedLists(snapshot.data!);
            
            // Get text color - white for dark mode, black for light mode
            final htmlTextColor = isDark ? Colors.white : (textColor ?? Colors.black);
            
            return Html(
              data: cleanedHtml,
              style: {
                "body": Style(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  color: htmlTextColor,
                ),
                "p": Style(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  color: htmlTextColor,
                ),
                "div": Style(
                  color: htmlTextColor,
                ),
                "span": Style(
                  color: htmlTextColor,
                ),
                "strong": Style(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                ),
                "b": Style(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                ),
                "em": Style(
                  color: htmlTextColor,
                  fontStyle: FontStyle.italic,
                ),
                "i": Style(
                  color: htmlTextColor,
                  fontStyle: FontStyle.italic,
                ),
                "u": Style(
                  color: htmlTextColor,
                  textDecoration: TextDecoration.underline,
                ),
                "a": Style(
                  color: htmlTextColor,
                  textDecoration: TextDecoration.underline,
                ),
                "ul": Style(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  listStyleType: ListStyleType.disc,
                  padding: HtmlPaddings.only(left: 20),
                  color: htmlTextColor,
                ),
                "ol": Style(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  listStyleType: ListStyleType.none,
                  padding: HtmlPaddings.only(left: 20),
                  margin: Margins.zero,
                  display: Display.block,
                  color: htmlTextColor,
                ),
                "li": Style(
                  fontSize: FontSize(fontSize),
                  textAlign: TextAlign.justify,
                  padding: HtmlPaddings.only(bottom: 8),
                  color: htmlTextColor,
                ),
                "h1": Style(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                ),
                "h2": Style(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                ),
                "h3": Style(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                ),
                "h4": Style(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                ),
                "h5": Style(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                ),
                "h6": Style(
                  color: htmlTextColor,
                  fontWeight: FontWeight.bold,
                ),
                "img": Style(
                  width: Width(double.infinity),
                  height: Height(200),
                ),
              },
              extensions: [
                TagExtension(
                  tagsToExtend: {"img"},
                  builder: networkImageExtensionBuilder,
                ),
              ],
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
    },
  );
}

/// Get content for a specific page (cached or fetch)
Future<String?> _getPageContent(int surahIndex, int pageIndex) async {
  // First try to get from cache
  final cachedPage = await DownloadService.getCachedPage(surahIndex, pageIndex);
  
  if (cachedPage != null) {
    // Process HTML content to proxy images for web
    final htmlContent = cachedPage['htmlContent'];
    if (htmlContent != null && htmlContent is String) {
      return _processHtmlForWeb(htmlContent);
    }
  }
  
  // If not cached, fetch from URL
  final url = await getlist.GetListSurah.getSurahUrl(surahIndex, pageIndex);
  if (url != null) {
    final content = await service.BacaService.fetchContentFromUrl(url, 'entry-content');
    if (content != null) {
      // Process HTML content to proxy images for web
      return _processHtmlForWeb(content);
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

Future<void> addBookmark(int surahIndex, int currentPage, {String? categoryUrl}) async {
  try {
    final bookmark = {
      'surahIndex': surahIndex,
      'currentPage': currentPage,
      'categoryUrl': categoryUrl,
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