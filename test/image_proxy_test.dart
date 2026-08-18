import 'package:flutter_test/flutter_test.dart';

import 'package:celik_tafsir/utils/image_proxy.dart';

/// Every reading model proxies an article's images twice on web: once when
/// `_processHtmlForWeb` rewrites `src="..."` in the scraped HTML, and again in
/// the `<img>` TagExtension that builds the widget. That produced a URL naming
/// the proxy twice, so the VPS issued a second request to itself for every
/// picture and the browser gave up with:
///
///   Error: HTTP request failed, statusCode: 0,
///   .../proxy?url=https://afwanhaziq.vps.webdock.cloud/proxy?url=https://celiktafsir.net/...
///
/// `flutter test` never takes the `kIsWeb` branch, hence the `forWeb` override.
void main() {
  const articleImage =
      'https://celiktafsir.net/wp-content/uploads/2026/01/internal.png?w=1024';

  group('web', () {
    test('routes an article image through the CORS proxy', () {
      expect(
        proxiedImageUrl(articleImage, forWeb: true),
        '$imageCorsProxy$articleImage',
      );
    });

    test('applying it twice does not stack the proxy prefix', () {
      final once = proxiedImageUrl(articleImage, forWeb: true);
      final twice = proxiedImageUrl(once, forWeb: true);

      expect(twice, once, reason: 'second pass must be a no-op');
      expect(
        'proxy?url='.allMatches(twice).length,
        1,
        reason: 'the proxy must appear exactly once in the fetched URL',
      );
    });

    test('makes a relative src absolute before proxying', () {
      expect(
        proxiedImageUrl('/wp-content/uploads/a.png', forWeb: true),
        '${imageCorsProxy}https://celiktafsir.net/wp-content/uploads/a.png',
      );
      expect(
        proxiedImageUrl('wp-content/uploads/a.png', forWeb: true),
        '${imageCorsProxy}https://celiktafsir.net/wp-content/uploads/a.png',
      );
    });
  });

  group('mobile', () {
    test('fetches celiktafsir.net directly, with no proxy', () {
      expect(proxiedImageUrl(articleImage, forWeb: false), articleImage);
    });

    test('still makes a relative src absolute', () {
      expect(
        proxiedImageUrl('/wp-content/uploads/a.png', forWeb: false),
        'https://celiktafsir.net/wp-content/uploads/a.png',
      );
    });
  });
}
