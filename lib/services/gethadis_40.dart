import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../utils/proxy_helper.dart';
import '../utils/http_decode.dart';

class GetHadis40 {
  static const String _baseUrl = 'https://celiktafsir.net';

  /// Page listing every Syarah Hadis 40 post. Confirmed against the live site
  /// on 2026-08-13: the old guess (/hadis-40/) only 301-redirects here.
  ///
  /// It is a hand-maintained WordPress *page*, not a category archive, so it
  /// carries no pagination markup -- every post sits on this one page and the
  /// loop below stops after the first request. The paging code is kept because
  /// it costs nothing and would keep working if this ever became an archive.
  static const String _categoryUrl =
      'https://celiktafsir.net/hadis-40-imam-nawawi/';

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

  /// Slugs that count as a Hadis 40 post.
  ///
  /// The owner does not spell them consistently: #25-#36 are
  /// `syarah-hadis-NN-hadis-40...`, but #37 was published as
  /// `hadits-arbain-37`. A plain `contains('hadis')` check silently dropped
  /// it, so the section stopped at #36 even though the listing showed #37.
  /// Accept the spellings the site actually uses -- hadis / hadits / hadith,
  /// and arbain (Arba'in), the collection's own name.
  static final RegExp _hadisSlugPattern = RegExp(
    r'hadi(?:s|ts|th)|arbain',
    caseSensitive: false,
  );

  /// "HADIS #25" as the listing writes it, wherever it sits in the markup.
  static final RegExp _hadisNumberPattern = RegExp(
    r'HADIS\s*#\s*(\d+)',
    caseSensitive: false,
  );

  /// The listing keeps the hadis number *outside* the link:
  ///
  ///   <p><strong><span>HADIS #25</span><br></strong>
  ///      <a href="...">Sedekah dari Orang Miskin</a></p>
  ///
  /// so the anchor text alone loses it. Recover the number from the enclosing
  /// element, giving back the "HADIS #25 Sedekah dari Orang Miskin" titles the
  /// section showed while they were hardcoded.
  static String _titleForLink(dom.Element link, String absoluteUrl) {
    final linkText = link.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (linkText.length <= 3) {
      return extractTitleFromUrl(absoluteUrl);
    }

    // Already numbered (a plainer listing, or our own test fixtures).
    if (_hadisNumberPattern.hasMatch(linkText)) return linkText;

    // Walk up while the ancestor still describes this one post; the moment it
    // holds several links its text belongs to no single article.
    dom.Element? ancestor = link.parent;
    for (var depth = 0; depth < 2 && ancestor != null; depth++) {
      if (ancestor.querySelectorAll('a').length != 1) break;
      final match = _hadisNumberPattern.firstMatch(ancestor.text);
      if (match != null) return 'HADIS #${match.group(1)} $linkText';
      ancestor = ancestor.parent;
    }

    return linkText;
  }

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

        final document = html_parser.parse(decodeUtf8Body(response));

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
          if (!_hadisSlugPattern.hasMatch(slug)) continue;

          if (absoluteUrl.contains('celiktafsir.net') &&
              !urlTitles.any((item) => item['url'] == absoluteUrl) &&
              !absoluteUrl.contains('/category/') &&
              !absoluteUrl.contains('/tag/') &&
              !absoluteUrl.contains('/author/') &&
              !absoluteUrl.contains('/page/')) {
            final dateString =
                '${dateMatch.group(1)}${dateMatch.group(2)}${dateMatch.group(3)}';

            urlTitles.add({
              'url': absoluteUrl,
              'title': _titleForLink(link, absoluteUrl),
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
