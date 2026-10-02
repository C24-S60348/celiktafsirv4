import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../utils/proxy_helper.dart';
import '../utils/http_decode.dart';

/// "Advanced Search" -- searches across the whole site rather than just
/// surah names, by delegating to celiktafsir.net's own WordPress search.
///
/// WordPress's built-in search already covers full post content (not just
/// titles), spans every section (surah tafsir, Hujjah, Hadis 40, Glosari,
/// Asal Usul Tafsir, Laa Tahzan...), and needs no local index to keep in
/// sync -- so results are exactly as complete as the website's own search,
/// with nothing to maintain here beyond parsing its HTML.
class SearchService {
  static const String _baseUrl = 'https://celiktafsir.net';

  /// One page of results for [query], newest matches first (the site's own
  /// order). [page] is 1-based, matching WordPress's own numbering.
  static Future<SearchResultPage> search(String query, {int page = 1}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SearchResultPage(results: [], hasMore: false);
    }

    final encoded = Uri.encodeQueryComponent(trimmed);
    final url = page == 1
        ? '$_baseUrl/?s=$encoded'
        : '$_baseUrl/page/$page/?s=$encoded';

    final response = await http.get(Uri.parse(getProxiedUrl(url)));
    if (response.statusCode != 200) {
      return const SearchResultPage(results: [], hasMore: false);
    }

    final document = html_parser.parse(decodeUtf8Body(response));
    final results = <SearchResult>[];

    for (final article in document.querySelectorAll('article')) {
      final titleLink = article.querySelector('.entry-title a');
      final href = titleLink?.attributes['href'];
      final title = titleLink?.text.trim();
      if (href == null || href.isEmpty || title == null || title.isEmpty) {
        continue;
      }

      results.add(
        SearchResult(
          url: href,
          title: title,
          excerpt: _excerptOf(article),
        ),
      );
    }

    final nextPageLink = document.querySelector(
      'a.next.page-numbers, .nav-next a, .pagination .next a, .pagination-next a',
    );

    return SearchResultPage(results: results, hasMore: nextPageLink != null);
  }

  /// The entry-summary paragraph, with the trailing "Continue reading ..."
  /// link (and its screen-reader-only span) dropped -- neither belongs in a
  /// search-result snippet.
  static String _excerptOf(dom.Element article) {
    final summary = article.querySelector('.entry-summary p');
    if (summary == null) return '';

    final clone = summary.clone(true);
    clone.querySelector('a.more-link')?.remove();

    final text = clone.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    return text;
  }
}

class SearchResult {
  final String url;
  final String title;
  final String excerpt;

  const SearchResult({
    required this.url,
    required this.title,
    required this.excerpt,
  });
}

class SearchResultPage {
  final List<SearchResult> results;
  final bool hasMore;

  const SearchResultPage({required this.results, required this.hasMore});
}
