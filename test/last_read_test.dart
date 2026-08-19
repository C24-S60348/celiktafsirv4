import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:celik_tafsir/views/baca.dart';

import 'support/fake_http.dart';

/// Tapping "Bacaan Terakhir" reopened the surah at page 1 instead of the page
/// that was actually saved.
void main() {
  const articleHtml = '''
    <html><body>
      <div class="entry-content">
        <p>Kandungan ujian.</p>
        Share this
      </div>
    </body></html>
  ''';

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'lastRead': json.encode({
        'surahIndex': 1,
        'pageIndex': 34, // 0-based: the reader was on "Halaman 35"
        'surahName': 'Al-Baqarah',
        'pageTitle': 'Baqarah Ayat 142',
        'categoryUrl': null,
        'lastReadDate': '2026-08-14T07:00:00.000Z',
      }),
    });
    HttpOverrides.global = FakeHttpOverrides(articleHtml);
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  testWidgets('opening a saved page starts on that page, not page 1', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BacaPage(),
                    settings: const RouteSettings(
                      arguments: <String, dynamic>{
                        'number': '002',
                        'name': 'Al-Baqarah',
                        'name_arab': 'البقرة',
                        'surahIndex': 1,
                        'pageIndex': 34,
                        'pageTitle': 'Baqarah Ayat 142',
                        'category_url': null,
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
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // ArticleReadTopNav renders "Halaman <index + 1>" (with "/ total" when known).
    final label = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((s) => s.startsWith('Halaman '), orElse: () => '');

    expect(label, isNotEmpty, reason: 'page indicator never rendered');
    expect(
      label,
      startsWith('Halaman 35'),
      reason: 'reopened at the wrong page: got "$label"',
    );
  });
}
