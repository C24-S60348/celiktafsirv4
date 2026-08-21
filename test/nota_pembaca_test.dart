import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:celik_tafsir/utils/reader_notes.dart';
import 'package:celik_tafsir/views/baca_hujjah.dart';
import 'package:celik_tafsir/views/nota_pembaca.dart';

import 'support/fake_http.dart';

/// "Nota Pembaca" is one free-form notebook for the whole app -- not one note
/// per article -- reachable from the reading pages' app bar.
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

  testWidgets('typing is kept without pressing save', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotaPembacaPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Ayat 142 tentang kiblat.');
    // The page debounces before writing; wait past it.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(await ReaderNotes.load(), 'Ayat 142 tentang kiblat.');
  });

  testWidgets('notes written earlier come back when the page reopens', (
    tester,
  ) async {
    await ReaderNotes.save('Nota lama');

    await tester.pumpWidget(const MaterialApp(home: NotaPembacaPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nota lama'), findsOneWidget);
  });

  testWidgets('leaving the page immediately does not lose the last words', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const NotaPembacaPage()),
              ),
              child: const Text('buka'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Belum sempat autosave');
    // Pop straight away, inside the debounce window.
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(await ReaderNotes.load(), 'Belum sempat autosave');
  });

  testWidgets('the same notebook opens from a reading page', (tester) async {
    await ReaderNotes.save('Satu buku nota untuk seluruh app');

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/nota': (_) => const NotaPembacaPage()},
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
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

    await tester.tap(find.byIcon(Icons.edit_note));
    await tester.pumpAndSettle();

    expect(find.text('Nota Pembaca'), findsWidgets);
    expect(find.text('Satu buku nota untuk seluruh app'), findsOneWidget);
  });
}
