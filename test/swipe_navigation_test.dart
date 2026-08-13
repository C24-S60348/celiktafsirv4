import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:celik_tafsir/views/baca_hujjah.dart';
import 'package:celik_tafsir/widgets/article_swipe_navigator.dart';

import 'support/fake_http.dart';

/// The main page has swiped between its grids for a while (`PageView` in
/// mainpage.dart); the reading pages only had the chevron buttons. These pin
/// the gesture and, just as importantly, that it obeys the same "is there a
/// page in that direction" rule the chevrons do.
void main() {
  group('ArticleSwipeNavigator', () {
    late List<String> calls;
    late ScrollController scrollController;

    Future<void> pump(
      WidgetTester tester, {
      bool hasPrevious = true,
      bool hasNext = true,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: ArticleSwipeNavigator(
            onPrevious: hasPrevious ? () => calls.add('previous') : null,
            onNext: hasNext ? () => calls.add('next') : null,
            child: ListView(
              controller: scrollController,
              children: const [SizedBox(height: 2000)],
            ),
          ),
        ),
      );
    }

    setUp(() {
      calls = <String>[];
      scrollController = ScrollController();
    });

    tearDown(() => scrollController.dispose());

    testWidgets('swiping right-to-left goes to the next article', (
      tester,
    ) async {
      await pump(tester);

      await tester.fling(find.byType(ListView), const Offset(-300, 0), 800);
      await tester.pumpAndSettle();

      expect(calls, ['next']);
    });

    testWidgets('swiping left-to-right goes back', (tester) async {
      await pump(tester);

      await tester.fling(find.byType(ListView), const Offset(300, 0), 800);
      await tester.pumpAndSettle();

      expect(calls, ['previous']);
    });

    testWidgets('a slow drag is not a page change', (tester) async {
      // Reading with a thumb on the screen drifts sideways; only a deliberate
      // flick should move the reader off the article.
      await pump(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(-12, 0));
        await tester.pump(const Duration(milliseconds: 60));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(calls, isEmpty);
    });

    testWidgets('swiping past the last article does nothing', (tester) async {
      await pump(tester, hasNext: false);

      await tester.fling(find.byType(ListView), const Offset(-300, 0), 800);
      await tester.pumpAndSettle();

      expect(calls, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('vertical scrolling still reaches the list', (tester) async {
      await pump(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(calls, isEmpty);
      expect(scrollController.offset, greaterThan(0));
    });
  });

  group('reading page', () {
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

    tearDown(() => HttpOverrides.global = null);

    testWidgets('swiping moves to the next article', (tester) async {
      const items = <Map<String, dynamic>>[
        {'url': 'https://celiktafsir.net/satu/', 'title': 'Artikel Satu'},
        {'url': 'https://celiktafsir.net/dua/', 'title': 'Artikel Dua'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          // The page swaps articles with pushReplacementNamed, so the named
          // route has to exist for the swipe to land anywhere.
          routes: {'/baca-hujjah': (_) => const BacaHujjahPage()},
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                // Pushed rather than used as `home:` so the first page gets
                // route arguments too -- it reads them in didChangeDependencies.
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BacaHujjahPage(),
                    settings: const RouteSettings(
                      arguments: <String, dynamic>{
                        'url': 'https://celiktafsir.net/satu/',
                        'title': 'Artikel Satu',
                        'index': 0,
                        'total': 2,
                        'items': items,
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
      // Wait out the 2s "Memuat kandungan..." snackbar: it schedules no frames
      // while idle, so pumpAndSettle alone returns with it still up.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Artikel Satu'), findsWidgets);

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(-300, 0),
        800,
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Artikel Dua'), findsWidgets);
    });
  });
}
