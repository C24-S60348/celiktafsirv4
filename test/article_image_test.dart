import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:celik_tafsir/views/baca_hujjah.dart';

import 'support/fake_http.dart';

/// celiktafsir.net wraps every article picture in a link to the full-size
/// file:
///
///   <p><a href="...makkahpusatbumi.jpg"><img src="..."></a></p>
///
/// The shared `<a>` extension rendered every anchor as `Text(element.text)`.
/// An anchor around an image has no text, so it collapsed to an empty string
/// and the `<img>` child was never built -- the article showed a blank gap
/// where the website shows a picture.
void main() {
  const articleHtml = '''
    <html><body>
      <div class="entry-content">
        <p>Perenggan sebelum gambar.</p>
        <p><a href="https://celiktafsir.net/wp-content/uploads/2013/03/makkahpusatbumi.jpg"><img src="https://celiktafsir.net/wp-content/uploads/2013/03/makkahpusatbumi.jpg?w=660" /></a></p>
        <p>Perenggan selepas gambar.</p>
        <p><a href="https://celiktafsir.net/rujukan/">rujukan biasa</a></p>
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
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets('an image wrapped in a link still renders', (tester) async {
    await pumpPage(tester);

    // Not find.byType(Image): the reading page draws assets/images/bg.jpg
    // behind the article, so any Image matcher passes regardless.
    final articleImages = tester
        .widgetList<Image>(find.byType(Image))
        .where((i) => i.image is NetworkImage)
        .map((i) => (i.image as NetworkImage).url)
        .where((url) => url.contains('makkahpusatbumi'))
        .toList();

    expect(
      articleImages,
      isNotEmpty,
      reason: 'the linked <img> was dropped, leaving a blank gap',
    );
  });

  testWidgets('ordinary text links are unaffected', (tester) async {
    await pumpPage(tester);

    expect(find.text('rujukan biasa'), findsOneWidget);
  });
}
