import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:celik_tafsir/views/baca_hujjah.dart';
import 'package:celik_tafsir/widgets/go_to_page_dialog.dart';

import 'support/fake_http.dart';

/// "Fungsi pergi ke halaman" -- tapping the "Artikel X / Y" position label
/// opens a dialog that jumps straight to the chosen article/page, instead of
/// stepping through Sebelum/Selepas one at a time.
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
    SharedPreferences.setMockInitialValues(<String, Object>{});
    HttpOverrides.global = FakeHttpOverrides(articleHtml);
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  Map<String, dynamic> itemsArgs() {
    final items = List.generate(
      6,
      (i) => {
        'url': 'https://celiktafsir.net/2026/01/0${i + 1}/artikel-$i/',
        'title': 'Artikel Ujian ${i + 1}',
      },
    );
    return <String, dynamic>{
      'url': items[0]['url'],
      'title': items[0]['title'],
      'index': 0,
      'total': items.length,
      'items': items,
    };
  }

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        // _goToArticle jumps via pushReplacementNamed('/baca-hujjah', ...),
        // so the route must be registered for the jump itself to work.
        routes: {'/baca-hujjah': (_) => const BacaHujjahPage()},
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BacaHujjahPage(),
                  settings: RouteSettings(arguments: itemsArgs()),
                ),
              ),
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

  testWidgets('tapping the position label jumps straight to the chosen article', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.textContaining('Artikel 1 / 6'), findsWidgets);

    await tester.tap(find.textContaining('Artikel 1 / 6').first);
    await tester.pumpAndSettle();

    expect(find.text('Pergi ke Artikel'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.text('Pergi'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.textContaining('Artikel 5 / 6'), findsWidgets);
  });

  testWidgets('an out-of-range number is rejected, not silently clamped', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.textContaining('Artikel 1 / 6').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '99');
    await tester.tap(find.text('Pergi'));
    await tester.pump();

    // Dialog stays open with an error, the page does not move.
    expect(find.text('Pergi ke Artikel'), findsOneWidget);
    expect(find.textContaining('Masukkan nombor'), findsOneWidget);
  });

  testWidgets('showGoToPageDialog returns null immediately when there is only one page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await showGoToPageDialog(
                context: context,
                total: 1,
                currentIndex: 0,
                themeName: 'Terang',
              );
              expect(result, isNull);
            },
            child: const Text('go'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text('Pergi ke Halaman'), findsNothing);
  });
}
