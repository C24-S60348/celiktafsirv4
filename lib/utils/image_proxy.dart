import 'package:flutter/foundation.dart' show kIsWeb;

/// The CORS proxy the web build routes celiktafsir.net images through.
///
/// celiktafsir.net serves its uploads without `Access-Control-Allow-Origin`,
/// so the browser refuses to hand the bytes to Flutter. The proxy adds the
/// header. Android and iOS fetch the site directly and need none of this.
const String imageCorsProxy = 'https://afwanhaziq.vps.webdock.cloud/proxy?url=';

const String _siteBaseUrl = 'https://celiktafsir.net';

/// Resolves an article `<img src>` to something `Image.network` can fetch.
///
/// Relative srcs are made absolute against celiktafsir.net. On web the result
/// is prefixed with [imageCorsProxy]; on mobile the direct URL is returned.
///
/// **Idempotent on purpose.** Every reading model proxies an article's images
/// twice: once when rewriting `src="..."` in the scraped HTML, and again in
/// the `<img>` TagExtension that builds the widget. Applying the prefix twice
/// produced
///
///     .../proxy?url=https://afwanhaziq.vps.webdock.cloud/proxy?url=https://celiktafsir.net/...
///
/// which made the VPS issue a second request to itself for every picture and
/// failed in the browser with `statusCode: 0`. Handing an already-proxied URL
/// back in now returns it unchanged, so the prefix can only ever be applied
/// once no matter how many layers call this.
///
/// [forWeb] overrides [kIsWeb]; it exists so tests can exercise the web branch,
/// which `flutter test` otherwise never takes.
String proxiedImageUrl(String imageUrl, {bool? forWeb}) {
  // Already proxied -- do not stack another prefix on top.
  if (imageUrl.startsWith(imageCorsProxy)) {
    return imageUrl;
  }

  String absoluteUrl = imageUrl;
  if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
    absoluteUrl = imageUrl.startsWith('/')
        ? '$_siteBaseUrl$imageUrl'
        : '$_siteBaseUrl/$imageUrl';
  }

  final useProxy = forWeb ?? kIsWeb;
  return useProxy ? '$imageCorsProxy$absoluteUrl' : absoluteUrl;
}
