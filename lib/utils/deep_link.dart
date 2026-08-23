/// Turns an incoming link into the article it should open.
///
/// Two shapes arrive, both produced by `web/buka/index.html`:
///
///   https://celiktafsir.web.app/buka/?u=<article>   (verified App Link)
///   celiktafsir://buka/?u=<article>                 (custom scheme fallback)
///
/// The `u` value is checked against the same allowlist the web page uses. A
/// link is attacker-supplied -- anyone can send one -- so an unchecked value
/// would let a stranger point the app's reader at any page on the internet.
class DeepLink {
  static const List<String> _allowedArticleHosts = [
    'celiktafsir.net',
    'www.celiktafsir.net',
    'celiktafsir.web.app',
  ];

  /// The article to open, or null when [uri] is not one of ours or carries
  /// nothing usable (in which case the app should just open normally).
  static String? articleUrlFrom(Uri? uri) {
    if (uri == null) return null;

    final isOurAppLink = uri.scheme == 'https' &&
        uri.host == 'celiktafsir.web.app' &&
        uri.path.startsWith('/buka');
    final isOurScheme = uri.scheme == 'celiktafsir';
    if (!isOurAppLink && !isOurScheme) return null;

    final raw = uri.queryParameters['u'];
    if (raw == null || raw.isEmpty) return null;

    final target = Uri.tryParse(raw);
    if (target == null) return null;
    if (target.scheme != 'https' && target.scheme != 'http') return null;
    if (!_allowedArticleHosts.contains(target.host)) return null;

    return target.toString();
  }

  /// A readable title for [articleUrl], derived from its slug, for the app bar
  /// while the article itself is still loading.
  static String titleFrom(String articleUrl) {
    final segments = Uri.parse(articleUrl)
        .pathSegments
        .where((s) => s.isNotEmpty)
        .toList();
    if (segments.isEmpty) return 'Celik Tafsir';
    final slug = segments.last;
    final words = slug
        .split('-')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
    return words.isEmpty ? 'Celik Tafsir' : words;
  }
}
