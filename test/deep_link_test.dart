import 'package:flutter_test/flutter_test.dart';

import 'package:celik_tafsir/utils/deep_link.dart';

/// A shared link opens the app through either the verified App Link or the
/// custom scheme. The article it carries comes from whoever sent the link, so
/// it is checked before the app is pointed at it.
void main() {
  const article = 'https://celiktafsir.net/2013/03/28/baqarah-ayat-144/';

  test('reads the article out of a verified App Link', () {
    final uri = Uri.parse(
      'https://celiktafsir.web.app/buka/?u=${Uri.encodeQueryComponent(article)}',
    );

    expect(DeepLink.articleUrlFrom(uri), article);
  });

  test('reads the article out of the custom scheme fallback', () {
    final uri = Uri.parse(
      'celiktafsir://buka/?u=${Uri.encodeQueryComponent(article)}',
    );

    expect(DeepLink.articleUrlFrom(uri), article);
  });

  test('refuses to open anything that is not ours', () {
    // Anyone can send a link; without this the app would happily load a
    // stranger's page inside the reader.
    const hostile = [
      'https://celiktafsir.web.app/buka/?u=https://evil.example.com/phish',
      'celiktafsir://buka/?u=https://evil.example.com/phish',
      'https://celiktafsir.web.app/buka/?u=javascript:alert(1)',
      'https://celiktafsir.web.app/buka/?u=//evil.example.com/phish',
    ];

    for (final link in hostile) {
      expect(
        DeepLink.articleUrlFrom(Uri.parse(link)),
        isNull,
        reason: 'accepted a hostile target: $link',
      );
    }
  });

  test('ignores links that are not the share link at all', () {
    for (final link in [
      'https://example.com/buka/?u=$article',
      'https://celiktafsir.web.app/',
      'celiktafsir://buka/',
    ]) {
      expect(DeepLink.articleUrlFrom(Uri.parse(link)), isNull);
    }
    expect(DeepLink.articleUrlFrom(null), isNull);
  });

  test('derives a readable title from the slug', () {
    expect(DeepLink.titleFrom(article), 'Baqarah Ayat 144');
    expect(
      DeepLink.titleFrom('https://celiktafsir.net/2026/08/16/hadits-arbain-37/'),
      'Hadits Arbain 37',
    );
  });
}
