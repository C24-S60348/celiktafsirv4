import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:celik_tafsir/views/search_page.dart';

import 'support/fake_http.dart';

/// "Carian Lanjutan" -- searches the whole site by delegating to
/// celiktafsir.net's own WordPress search, then opens results through the
/// generic single-article reader.
void main() {
  const resultsHtml = '''
    <html><body>
      <article>
        <h2 class="entry-title"><a href="https://celiktafsir.net/2013/03/28/baqarah-ayat-144/">Tafsir Surah Baqarah Ayat 144</a></h2>
        <div class="entry-summary"><p>Kiblat ke arah Kaabah. <a class="more-link">Continue reading</a></p></div>
      </article>
      <article>
        <h2 class="entry-title"><a href="https://celiktafsir.net/2013/03/28/baqarah-ayat-142/">Tafsir Surah Baqarah Ayat 142</a></h2>
        <div class="entry-summary"><p>Penukaran kiblat yang baru.</p></div>
      </article>
    </body></html>
  ''';

  const noResultsHtml = '<html><body><p>Nothing Found</p></body></html>';

  // Same shape as resultsHtml, but with real "next page" markup, so hasMore
  // resolves true after the first search.
  const resultsHtmlWithMore = '''
    <html><body>
      <article>
        <h2 class="entry-title"><a href="https://celiktafsir.net/2013/03/28/baqarah-ayat-144/">Tafsir Surah Baqarah Ayat 144</a></h2>
        <div class="entry-summary"><p>Kiblat ke arah Kaabah.</p></div>
      </article>
      <a class="next page-numbers" href="https://celiktafsir.net/page/2/?s=kiblat">Next</a>
    </body></html>
  ''';

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  Future<void> pumpSearchPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {'/baca-hujjah': (_) => const Scaffold(body: Text('ARTICLE OPENED'))},
        home: const SearchPage(),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows a prompt before anything is typed', (tester) async {
    HttpOverrides.global = FakeHttpOverrides(resultsHtml);
    await pumpSearchPage(tester);

    expect(find.textContaining('Taip untuk mula mencari'), findsOneWidget);
  });

  testWidgets('typing a query shows results from the site', (tester) async {
    HttpOverrides.global = FakeHttpOverrides(resultsHtml);
    await pumpSearchPage(tester);

    await tester.enterText(find.byType(TextField), 'kiblat');
    // Past the 500ms debounce.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Tafsir Surah Baqarah Ayat 144'), findsOneWidget);
    expect(find.text('Tafsir Surah Baqarah Ayat 142'), findsOneWidget);
    expect(find.textContaining('Kiblat ke arah Kaabah'), findsOneWidget);
    // The "Continue reading" link text must not leak into the snippet.
    expect(find.textContaining('Continue reading'), findsNothing);
  });

  testWidgets('tapping a result opens the generic reader', (tester) async {
    HttpOverrides.global = FakeHttpOverrides(resultsHtml);
    await pumpSearchPage(tester);

    await tester.enterText(find.byType(TextField), 'kiblat');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tafsir Surah Baqarah Ayat 144'));
    await tester.pumpAndSettle();

    expect(find.text('ARTICLE OPENED'), findsOneWidget);
  });

  testWidgets('an empty result set says so instead of looking broken', (
    tester,
  ) async {
    HttpOverrides.global = FakeHttpOverrides(noResultsHtml);
    await pumpSearchPage(tester);

    await tester.enterText(find.byType(TextField), 'zzxxqqnonexistent');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tiada hasil'), findsOneWidget);
  });

  testWidgets('the load-more spinner only shows while actually fetching', (
    tester,
  ) async {
    // hasMore=true (there IS a next page) must not by itself draw a spinner
    // -- that would claim work is in progress when nothing has been asked
    // for yet. Only an in-flight _loadMore() should show it. Using a fixture
    // with real pagination markup, so hasMore is genuinely true here (a
    // no-pagination fixture would pass by accident).
    HttpOverrides.global = FakeHttpOverrides(resultsHtmlWithMore);
    await pumpSearchPage(tester);

    await tester.enterText(find.byType(TextField), 'kiblat');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Tafsir Surah Baqarah Ayat 144'), findsOneWidget);
    // No _loadMore() is in flight yet -- nothing should be spinning, even
    // though more results exist.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('clearing the field returns to the initial prompt', (
    tester,
  ) async {
    HttpOverrides.global = FakeHttpOverrides(resultsHtml);
    await pumpSearchPage(tester);

    await tester.enterText(find.byType(TextField), 'kiblat');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Tafsir Surah Baqarah Ayat 144'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(find.textContaining('Taip untuk mula mencari'), findsOneWidget);
  });
}
