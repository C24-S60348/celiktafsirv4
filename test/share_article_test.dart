import 'package:flutter_test/flutter_test.dart';

import 'package:celik_tafsir/utils/share_article.dart';

/// A shared link has to serve four different people: someone with the app on
/// Android, someone without it on Android, someone on an iPhone, and someone
/// at a desktop. It therefore points at our own redirect page
/// (web/buka/index.html) rather than straight at the article.
void main() {
  test('the link carries the article so the page can forward to it', () {
    final link = ShareArticle.linkFor(
      'https://celiktafsir.net/2013/03/28/baqarah-ayat-144/',
    );

    final uri = Uri.parse(link);
    expect(uri.host, 'celiktafsir.web.app');
    expect(uri.path, '/buka/');
    expect(
      uri.queryParameters['u'],
      'https://celiktafsir.net/2013/03/28/baqarah-ayat-144/',
    );
  });

  test('a query string in the article survives the round trip', () {
    // Article URLs carry things like ?w=660; encoding them wrongly would
    // truncate the link and send the reader to the wrong page.
    const article = 'https://celiktafsir.net/2013/03/28/baqarah-ayat-144/?a=1&b=2';

    final uri = Uri.parse(ShareArticle.linkFor(article));

    expect(uri.queryParameters['u'], article);
  });

  test('falls back to the plain link when the article is unknown', () {
    // getSurahUrl returns null when the page cannot be resolved; sharing
    // should still hand over something openable.
    for (final empty in <String?>[null, '']) {
      expect(ShareArticle.linkFor(empty), 'https://celiktafsir.web.app/buka/');
    }
  });
}
