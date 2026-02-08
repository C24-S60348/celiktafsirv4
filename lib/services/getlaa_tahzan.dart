import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:flutter/foundation.dart' show kIsWeb;

class GetLaaTahzan {
  static const String _baseUrl = 'https://celiktafsir.net';
  static const String _listUrl =
      'https://celiktafsir.net/la-tahzan-jangan-bersedih/';

  // CORS Proxy for Web - using custom proxy server (same as other services)
  static const String _corsProxy =
      'https://afwanhaziq.vps.webdock.cloud/proxy?url=';

  static String _getProxiedUrl(String url) {
    if (kIsWeb) return '$_corsProxy$url';
    return url;
  }

  static Future<bool> _hasInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse(_getProxiedUrl(_baseUrl)))
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Connection timeout');
      });
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static String _extractTitleFromUrl(String url) {
    try {
      final parts = url.split('/');
      final nonEmptyParts = parts.where((p) => p.isNotEmpty).toList();
      if (nonEmptyParts.isEmpty) return 'Untitled';

      String slug = nonEmptyParts.last;
      slug = slug.split('?').first.split('#').first;
      if (slug.isEmpty) return 'Untitled';

      final segments = slug.split('-').where((s) => s.trim().isNotEmpty);
      final processed = segments
          .map((s) => s.trim())
          .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
          .join(' ');
      return processed.trim().isEmpty ? 'Untitled' : processed.trim();
    } catch (e) {
      print('Error extracting title: $e');
      return 'Untitled';
    }
  }

  /// Scrape the La Tahzan list page and return items in-page order.
  static Future<List<Map<String, String>>> scrapeLaaTahzanPosts() async {
    final List<Map<String, String>> urlTitles = [];
    try {
      final response = await http.get(Uri.parse(_getProxiedUrl(_listUrl)));
      if (response.statusCode != 200) return [];

      final document = html_parser.parse(response.body);

      // Restrict extraction to the content area to avoid menu/sidebar links.
      final content = document.querySelector('.entry-content');
      final links =
          content?.querySelectorAll('a') ?? document.querySelectorAll('a');

      for (final link in links) {
        final href = link.attributes['href'];
        if (href == null) continue;

        if (href.startsWith('#') ||
            href.startsWith('mailto:') ||
            href.startsWith('tel:') ||
            href.startsWith('javascript:')) {
          continue;
        }

        final absoluteUrl = href.startsWith('http') ? href : '$_baseUrl$href';

        if (!absoluteUrl.startsWith(_baseUrl)) continue;
        if (absoluteUrl == _listUrl) continue;
        if (absoluteUrl.contains('/category/') ||
            absoluteUrl.contains('/tag/') ||
            absoluteUrl.contains('/author/')) {
          continue;
        }

        if (urlTitles.any((item) => item['url'] == absoluteUrl)) continue;

        String title = link.text.trim();
        if (title.isEmpty) {
          title = _extractTitleFromUrl(absoluteUrl);
        }

        urlTitles.add({
          'url': absoluteUrl,
          'title': title,
        });
      }
    } catch (e) {
      print('Error scraping La Tahzan page: $e');
      return [];
    }

    return urlTitles;
  }

  static Future<List<Map<String, String>>> getLaaTahzanPosts() async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) return [];

    try {
      print('Scraping La Tahzan posts from $_listUrl...');
      final posts = await scrapeLaaTahzanPosts();
      print('Successfully scraped ${posts.length} La Tahzan posts');
      return posts;
    } catch (e) {
      print('Error scraping La Tahzan posts: $e');
      return [];
    }
  }
}

