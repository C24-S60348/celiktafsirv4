import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:celik_tafsir/views/baca_hujjah.dart';

import 'support/fake_http.dart';

/// The reading pages used to force `textAlign: TextAlign.justify` on body, p,
/// ul, ol and li. `flutter_html` applies the caller's style map *after* the
/// document's own inline styles (see `_styleTreeRecursive`), so that override
/// won over every `style="text-align: ..."` the article carries.
///
/// celiktafsir.net writes alignment per paragraph -- the Fatihah article alone
/// has 58 `justify`, 4 `right` (the Arabic) and 1 `center`. Forcing justify
/// stretched the Arabic across the full width instead of letting it sit right
/// aligned the way the website renders it.
void main() {
  // BacaService.fetchContentFromUrl slices the body at the literal
  // "Share this", so the fixture has to contain it.
  const articleHtml = '''
    <html><body>
      <div class="entry-content">
        <p style="text-align: justify">Perenggan biasa yang dijustifikasi.</p>
        <p style="text-align: right">ARABICLINE</p>
        <p style="text-align: center">Perenggan di tengah.</p>
        <p>Perenggan tanpa penjajaran.</p>
        <p><a href="https://celiktafsir.net/wp-content/uploads/2013/03/gambar.jpg"><img src="https://celiktafsir.net/wp-content/uploads/2013/03/gambar.jpg?w=660" /></a></p>
        Share this
      </div>
    </body></html>
  ''';

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    HttpOverrides.global = FakeHttpOverrides(articleHtml);
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BacaHujjahPage(),
                    settings: const RouteSettings(
                      arguments: <String, dynamic>{
                        'url': 'https://celiktafsir.net/2026/01/01/ujian/',
                        'title': 'Ujian Hujjah',
                        'index': 0,
                        'total': 1,
                        'items': <Map<String, dynamic>>[],
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
    // Reading pages show a 2s "Memuat kandungan..." snackbar; pumpAndSettle
    // does not drain it because an idle snackbar schedules no frames.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  /// The alignment `flutter_html` actually resolved for the paragraph whose
  /// rendered text contains [needle].
  TextAlign alignmentOf(WidgetTester tester, String needle) {
    final richText = tester
        .widgetList<RichText>(find.byType(RichText))
        .firstWhere((w) => w.text.toPlainText().contains(needle));
    return richText.textAlign;
  }

  testWidgets('the article keeps the alignment the website gave it', (
    tester,
  ) async {
    await pumpPage(tester);

    // The Arabic is the case that mattered: forcing justify stretched it
    // across the width instead of leaving it right aligned.
    expect(alignmentOf(tester, 'ARABICLINE'), TextAlign.right);
    expect(alignmentOf(tester, 'dijustifikasi'), TextAlign.justify);
    expect(alignmentOf(tester, 'di tengah'), TextAlign.center);
  });

  testWidgets('a paragraph with no alignment is not force-justified', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(
      alignmentOf(tester, 'tanpa penjajaran'),
      isNot(TextAlign.justify),
      reason: 'the page is imposing an alignment the article never asked for',
    );
  });
}
