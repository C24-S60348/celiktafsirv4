import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:celik_tafsir/views/baca.dart';

import 'support/fake_http.dart';

/// The surah reading page was the only reading page without a copy action --
/// the other six all carry "Salin Kandungan". These pin the new one.
///
/// The page copies through `model.getPlainText`, which shares the cache
/// `bodyContent` reads, so the fixture has to be scrapeable twice: once as the
/// category listing (an anchor matching /YYYY/MM/DD/slug/) and once as the
/// article itself (.entry-content sliced at the literal "Share this").
void main() {
  const articleHtml = '''
    <html><body>
      <div class="entry-content">
        <p><a href="https://celiktafsir.net/2026/01/01/fatihah-ayat-1/">Fatihah Ayat 1</a></p>
        <p>Kandungan ujian bagi surah.</p>
        Share this
      </div>
    </body></html>
  ''';

  /// Same listing anchor, but no .entry-content -- so the page URL resolves
  /// and the article fetch is what fails.
  const noArticleHtml = '''
    <html><body>
      <p><a href="https://celiktafsir.net/2026/01/01/fatihah-ayat-1/">Fatihah Ayat 1</a></p>
    </body></html>
  ''';

  late List<MethodCall> clipboardCalls;

  setUp(() {
    clipboardCalls = <MethodCall>[];
    SharedPreferences.setMockInitialValues(<String, Object>{});
    HttpOverrides.global = FakeHttpOverrides(articleHtml);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardCalls.add(call);
      }
      return null;
    });
  });

  tearDown(() {
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// Pushes BacaPage with the route arguments it reads in
  /// didChangeDependencies. category_url is passed explicitly, exactly as the
  /// surah list does, so the lookup never falls back to another juzuk.
  ///
  /// [categoryUrl] varies per test on purpose: the page-content cache in
  /// models/baca.dart is keyed by it and lives for the whole test file, so two
  /// tests sharing a URL would share a cached body.
  Future<void> pumpPage(WidgetTester tester, String categoryUrl) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BacaPage(),
                    settings: RouteSettings(
                      arguments: <String, dynamic>{
                        'number': '001',
                        'name': 'Al-Fatihah',
                        'surahIndex': 0,
                        'pageIndex': 0,
                        'pageTitle': 'Fatihah Ayat 1',
                        'category_url': categoryUrl,
                      },
                    ),
                  ),
                );
              },
              child: const Text('buka'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    // Let the article fetch land before the copy button is used.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets('copies the page body and confirms with a snackbar', (
    tester,
  ) async {
    await pumpPage(tester, 'https://celiktafsir.net/category/surah-001-ok/');

    await tester.tap(find.byIcon(Icons.copy));
    // Not pumpAndSettle: the snackbar is on a 2s timer, and settling would run
    // past it and find nothing.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));

    expect(clipboardCalls, hasLength(1));
    final copied = (clipboardCalls.single.arguments as Map)['text'] as String;
    expect(copied, contains('Kandungan ujian bagi surah.'));
    // htmlToPlainText should leave readable text, not markup.
    expect(copied, isNot(contains('<p>')));

    expect(find.text('Teks disalin'), findsOneWidget);
  });

  testWidgets('reports failure when the article never loaded', (tester) async {
    HttpOverrides.global = FakeHttpOverrides(noArticleHtml);

    await pumpPage(tester, 'https://celiktafsir.net/category/surah-001-kosong/');

    await tester.tap(find.byIcon(Icons.copy));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));

    expect(clipboardCalls, isEmpty);
    expect(find.text('Gagal menyalin teks'), findsOneWidget);
  });

  testWidgets('leaving the page mid-copy does not throw', (tester) async {
    // Smoke test, not a regression pin: the copy runs across two async gaps
    // (fetch, then Clipboard.setData) and popping in between must not leave a
    // callback talking to a dead State. Checked -- it still passes with the
    // mounted guard removed, because the try/catch in _copyPageText absorbs
    // the ScaffoldMessenger error and _showBookmarkMessage guards itself. So
    // it pins the behaviour, not the guard.
    await pumpPage(tester, 'https://celiktafsir.net/category/surah-001-pop/');

    await tester.tap(find.byIcon(Icons.copy));

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('buka'), findsOneWidget);
  });
}
