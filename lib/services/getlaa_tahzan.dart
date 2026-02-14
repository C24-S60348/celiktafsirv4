import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../utils/proxy_helper.dart';

class GetLaaTahzan {
  static const String _baseUrl = 'https://celiktafsir.net';
  static const String _listUrl =
      'https://celiktafsir.net/la-tahzan-jangan-bersedih/';

  /// Scrape the La Tahzan list page and return items in-page order.
  static Future<List<Map<String, String>>> scrapeLaaTahzanPosts() async {
    final List<Map<String, String>> urlTitles = [];
    try {
      final response = await http.get(Uri.parse(getProxiedUrl(_listUrl)));
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
          title = extractTitleFromUrl(absoluteUrl);
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
    final hasInternet = await hasInternetConnection();
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

