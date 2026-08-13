import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../utils/proxy_helper.dart';

class GetHadis40 {
  static const String _baseUrl = 'https://celiktafsir.net';

  /// Category page listing every Syarah Hadis 40 post.
  ///
  /// TODO(owner): confirm this is the real listing URL. It is a best guess
  /// modelled on the other sections (/asmaul-husna/, /ilmu-usul-tafsir/).
  /// If it is wrong the scrape simply finds nothing and we fall back to
  /// [_knownPosts], i.e. the previous hardcoded behaviour -- so a bad guess
  /// costs a wasted request, never wrong articles.
  static const String _categoryUrl = 'https://celiktafsir.net/hadis-40/';

  /// The three articles this service used to return unconditionally.
  /// Kept only as a fallback for when the category cannot be scraped.
  static const List<Map<String, String>> _knownPosts = [
    {
      'url':
          'https://celiktafsir.net/2025/12/31/syarah-hadis-25-hadis-40-imam-nawawi/',
      'title': 'HADIS #25 Sedekah dari Orang Miskin',
      'date': '20251231',
    },
    {
      'url': 'https://celiktafsir.net/2026/01/07/syarah-hadis-26-hadis-40/',
      'title': 'HADIS #26 Setiap Sendi Mesti Bersedekah',
      'date': '20260107',
    },
    {
      'url': 'https://celiktafsir.net/2026/02/02/syarah-hadis-27-hadis-40/',
      'title': 'HADIS #27 Mintalah Fatwa kepada Hatimu',
      'date': '20260202',
    },
  ];

  /// Scrape every Hadis 40 post URL and title from the category page.
  static Future<List<Map<String, String>>> scrapeHadis40Posts() async {
    final List<Map<String, String>> urlTitles = [];
    int page = 1;
    bool hasMorePages = true;

    while (hasMorePages) {
      try {
        // WordPress category pages typically use ?paged=X for pagination
        final url = page == 1 ? _categoryUrl : '$_categoryUrl?paged=$page';
        final response = await http.get(Uri.parse(getProxiedUrl(url)));

        if (response.statusCode != 200) {
          break;
        }

        final document = html_parser.parse(response.body);

        // Post URLs match /YYYY/MM/DD/post-slug/
        final postUrlPattern = RegExp(r'/(\d{4})/(\d{2})/(\d{2})/([^/]+)/$');
        final allLinks = document.querySelectorAll('a');

        bool foundNewLinks = false;
        for (var link in allLinks) {
          final href = link.attributes['href'];
          if (href == null) continue;

          final absoluteUrl = href.startsWith('http') ? href : '$_baseUrl$href';
          final dateMatch = postUrlPattern.firstMatch(absoluteUrl);
          if (dateMatch == null) continue;

          // Only accept hadis posts. If _categoryUrl ever points at the wrong
          // page, this keeps unrelated articles out of the Hadis 40 list.
          final slug = dateMatch.group(4)!.toLowerCase();
          if (!slug.contains('hadis')) continue;

          if (absoluteUrl.contains('celiktafsir.net') &&
              !urlTitles.any((item) => item['url'] == absoluteUrl) &&
              !absoluteUrl.contains('/category/') &&
              !absoluteUrl.contains('/tag/') &&
              !absoluteUrl.contains('/author/') &&
              !absoluteUrl.contains('/page/')) {
            final dateString =
                '${dateMatch.group(1)}${dateMatch.group(2)}${dateMatch.group(3)}';

            // Prefer the anchor's own text (the real post title, e.g.
            // "HADIS #25 Sedekah dari Orang Miskin"); fall back to the slug.
            final linkText = link.text.trim();
            final title = linkText.isNotEmpty && linkText.length > 3
                ? linkText
                : extractTitleFromUrl(absoluteUrl);

            urlTitles.add({
              'url': absoluteUrl,
              'title': title,
              'date': dateString,
            });
            foundNewLinks = true;
          }
        }

        final nextPageLink = document.querySelector(
          'a.next.page-numbers, .nav-next a, .pagination .next a, .pagination-next a',
        );
        hasMorePages = foundNewLinks && nextPageLink != null;
        page++;

        // Safety limit to prevent infinite loops
        if (page > 100) {
          print('Warning: Reached page limit for Hadis 40 category');
          break;
        }

        if (!foundNewLinks) {
          hasMorePages = false;
        }
      } catch (e) {
        print('Error scraping page $page of Hadis 40 category: $e');
        break;
      }
    }

    // Sort chronologically so Hadis #25 stays before #26.
    urlTitles.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));

    return urlTitles;
  }

  /// Get all Hadis 40 posts (with internet check).
  ///
  /// Falls back to [_knownPosts] when the category yields nothing, so the
  /// section never regresses below the three articles it used to show.
  static Future<List<Map<String, String>>> getHadis40Posts() async {
    final hasInternet = await hasInternetConnection();

    if (!hasInternet) {
      print('No internet connection, cannot fetch Hadis 40 page');
      return [];
    }

    final scraped = await scrapeHadis40Posts();
    if (scraped.isNotEmpty) {
      return scraped;
    }

    print(
      'Hadis 40 category scrape found nothing at $_categoryUrl, '
      'falling back to the known articles',
    );
    return _knownPosts.map((e) => Map<String, String>.from(e)).toList();
  }
}
