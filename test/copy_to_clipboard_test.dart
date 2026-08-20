import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:celik_tafsir/views/baca_hujjah.dart';

import 'support/fake_http.dart';

/// Tests for the "Salin Kandungan" copy action and the website button on
/// the reading page.
///
/// The snackbars are shown from the .then()/.catchError() callbacks of
/// Clipboard.setData, i.e. after an async gap. Without a mounted guard,
/// leaving the page before the clipboard write completes tears down the
/// State and ScaffoldMessenger.of(context) throws. The last test pins that.
void main() {
  // The article body is sliced at the literal "Share this" by
  // BacaService.fetchContentFromUrl, so the fixture has to contain it.
  const articleHtml = '''
    <html><body>
      <div class="entry-content">
        <p>Kandungan ujian bagi hujjah.</p>
        <a href="https://celiktafsir.net/rujukan/">rujukan</a>
        Share this
      </div>
    </body></html>
  ''';

  late List<MethodCall> clipboardCalls;
  Duration clipboardDelay = Duration.zero;

  setUp(() {
    clipboardCalls = <MethodCall>[];
    clipboardDelay = Duration.zero;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    HttpOverrides.global = FakeHttpOverrides(articleHtml);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardCalls.add(call);
        if (clipboardDelay > Duration.zero) {
          await Future<void>.delayed(clipboardDelay);
        }
      }
      return null;
    });
  });

  tearDown(() {
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// Pushes BacaHujjahPage with the route arguments it reads in
  /// didChangeDependencies, behind a button so the route can be popped.
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

    // The page shows a 2s "Memuat kandungan..." snackbar while loading, and
    // ScaffoldMessenger shows one at a time. pumpAndSettle does not drain it
    // (an idle snackbar schedules no frames, it just holds a Timer), so wait
    // it out or the copy confirmation queues behind it.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  /// The copy action used to be a one-item PopupMenuButton behind the copy
  /// icon; it is now the icon itself, so this is a single tap.
  Future<void> tapCopyContent(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.copy));
  }

  testWidgets('copies the article body and confirms with a snackbar', (
    tester,
  ) async {
    await pumpPage(tester);

    await tapCopyContent(tester);
    // Not pumpAndSettle: the snackbar only lives for 1s, so settling would
    // run right past it and find nothing.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));

    expect(clipboardCalls, hasLength(1));
    final copied = (clipboardCalls.single.arguments as Map)['text'] as String;
    expect(copied, contains('Kandungan ujian bagi hujjah.'));
    // _stripHtmlTags should leave readable text, not markup.
    expect(copied, isNot(contains('<p>')));

    expect(find.text('Kandungan telah disalin ke klipbod'), findsOneWidget);
  });

  testWidgets('the website button overlays the article instead of leaving it', (
    tester,
  ) async {
    // The globe action used to push a full WebsitePage route, which navigated
    // away from the article. It now shows the same overlay inline links use.
    await pumpPage(tester);

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    expect(find.text('Open Website'), findsOneWidget);
    // The article is still mounted underneath, not replaced by a new route.
    expect(find.byType(BacaHujjahPage), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Open Website'), findsNothing);
    expect(find.byType(BacaHujjahPage), findsOneWidget);
  });

  testWidgets('leaving the page mid-copy does not throw', (tester) async {
    // The regression: pop the route while Clipboard.setData is still in
    // flight, so the .then() callback runs against an unmounted State.
    // The delay must outlast the pop transition -- during that animation the
    // outgoing page is still mounted, and the callback would run harmlessly.
    clipboardDelay = const Duration(seconds: 2);

    await pumpPage(tester);
    await tapCopyContent(tester);
    await tester.pump();

    // Guard against a vacuous pass: if the article never loaded, the copy
    // would short-circuit to "Kandungan belum dimuatkan" and never reach
    // the async gap this test exists to cover.
    expect(clipboardCalls, hasLength(1));

    // Leave before the clipboard write resolves.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    // Let the pending clipboard future complete against the dead State.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('buka'), findsOneWidget);
  });
}
