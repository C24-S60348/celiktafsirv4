import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:celik_tafsir/services/baca.dart';
import 'package:celik_tafsir/services/getlaa_tahzan.dart';
import 'package:celik_tafsir/utils/http_decode.dart';

import 'support/fake_http.dart';

/// Characters that come back broken in the app while the website looks fine:
/// curly quotes, an em dash, and Arabic. All are multi-byte in UTF-8, so all
/// of them survive or break together.
const String _arabic = 'بِسْمِ ٱللَّٰهِ';
const String _malay = '“Fahami Al-Quran” — insya-Allah';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  group('decodeUtf8Body', () {
    // The bug itself, in one assertion: with no charset in the header the
    // `http` package reads UTF-8 bytes as latin-1. If this ever stops being
    // true the fix below is no longer load-bearing and can go.
    test('response.body mangles UTF-8 when the server sends no charset', () {
      final bytes = utf8.encode(_malay);
      final response = http.Response.bytes(bytes, 200);

      expect(response.body, isNot(_malay));
      // Byte-for-byte latin-1: every UTF-8 lead byte becomes its own visible
      // character (0xE2 -> 'â'), the continuation bytes become invisible C1
      // controls. On screen the reader sees stray 'â'/'Ø' where the quote or
      // the Arabic word should be.
      expect(response.body, latin1.decode(bytes));
      expect(response.body, contains('â'));
    });

    test('reads the bytes as UTF-8 instead', () {
      final response = http.Response.bytes(
        utf8.encode('$_malay $_arabic'),
        200,
      );

      expect(decodeUtf8Body(response), '$_malay $_arabic');
    });

    // A single bad byte must cost one character, not the whole article.
    test('survives a malformed byte', () {
      final response = http.Response.bytes([
        ...utf8.encode('Fahami'),
        0xFF,
        ...utf8.encode(' Al-Quran'),
      ], 200);

      final decoded = decodeUtf8Body(response);
      expect(decoded, startsWith('Fahami'));
      expect(decoded, endsWith(' Al-Quran'));
    });
  });

  group('services decode article HTML as UTF-8', () {
    // `fetchContentFromUrl` slices the body at the literal "Share this", so the
    // fixture must contain it or the fetch returns null for unrelated reasons.
    testWidgets('article body keeps Arabic and curly quotes', (tester) async {
      HttpOverrides.global = FakeHttpOverrides(
        '<html><body><div class="entry-content">'
        '<p>$_arabic</p><p>$_malay</p>'
        '<div>Share this</div>'
        '</div></body></html>',
      );

      final content = await BacaService.fetchContentFromUrl(
        'https://celiktafsir.net/some-article/',
        'entry-content',
      );

      expect(content, isNotNull);
      expect(content, contains(_arabic));
      expect(content, contains(_malay));
    });

    testWidgets('scraped list titles keep their accents', (tester) async {
      HttpOverrides.global = FakeHttpOverrides(
        '<html><body><div class="entry-content">'
        '<a href="https://celiktafsir.net/la-tahzan-1/">$_malay</a>'
        '</div></body></html>',
      );

      final posts = await GetLaaTahzan.scrapeLaaTahzanPosts();

      expect(posts, hasLength(1));
      expect(posts.first['title'], _malay);
    });
  });

  // Every service shares the same failure mode, so guard the whole directory
  // rather than one file at a time: a new scraper reaching for `response.body`
  // reintroduces the bug silently.
  test('no service reads response.body', () {
    final offenders = <String>[];
    for (final file in Directory('lib/services').listSync().whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      if (file.readAsStringSync().contains('response.body')) {
        offenders.add(file.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'use decodeUtf8Body(response) — response.body decodes as latin-1 '
          'when the server sends no charset',
    );
  });
}
