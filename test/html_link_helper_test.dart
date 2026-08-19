import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:celik_tafsir/utils/html_link_helper.dart';

/// Tests for the shared <a> TagExtension used by all six content models.
///
/// The extension deliberately uses an OverlayEntry rather than a dialog route,
/// so that confirming or cancelling a link never pops the reading page (which
/// would refetch the article). These tests pin that behaviour down.
void main() {
  const urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');

  late List<MethodCall> launchCalls;

  setUp(() {
    launchCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, (call) async {
      launchCalls.add(call);
      // canLaunch/launch both return a bool.
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, null);
  });

  Widget host(String html, {bool isDark = false}) {
    return MaterialApp(
      home: Scaffold(
        body: Html(
          data: html,
          extensions: [buildLinkTagExtension(isDark)],
        ),
      ),
    );
  }

  testWidgets('renders anchor text instead of dropping the link', (
    tester,
  ) async {
    await tester.pumpWidget(
      host('<p>Rujuk <a href="https://celiktafsir.net">laman web</a></p>'),
    );
    await tester.pumpAndSettle();

    expect(find.text('laman web'), findsOneWidget);
  });

  testWidgets('tapping a link shows the Open Website overlay with the href', (
    tester,
  ) async {
    await tester.pumpWidget(
      host('<a href="https://celiktafsir.net/rujukan/">rujukan</a>'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open Website'), findsNothing);

    await tester.tap(find.text('rujukan'));
    await tester.pumpAndSettle();

    expect(find.text('Open Website'), findsOneWidget);
    expect(find.text('https://celiktafsir.net/rujukan/'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('Cancel dismisses the overlay without launching a URL', (
    tester,
  ) async {
    await tester.pumpWidget(
      host('<a href="https://celiktafsir.net">rujukan</a>'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('rujukan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Open Website'), findsNothing);
    expect(launchCalls, isEmpty);
  });

  testWidgets('Open dismisses the overlay and launches the URL', (
    tester,
  ) async {
    await tester.pumpWidget(
      host('<a href="https://celiktafsir.net">rujukan</a>'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('rujukan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Open Website'), findsNothing);
    expect(launchCalls, isNotEmpty);
  });

  testWidgets('the article stays on screen while the overlay is open', (
    tester,
  ) async {
    // Regression guard: the extension must not use Navigator, otherwise
    // dismissing the prompt pops the reading page and triggers a refetch.
    await tester.pumpWidget(
      host('<p>kandungan artikel</p><a href="https://celiktafsir.net">rujukan</a>'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('rujukan'));
    await tester.pumpAndSettle();

    expect(find.text('kandungan artikel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('kandungan artikel'), findsOneWidget);
    expect(find.text('rujukan'), findsOneWidget);
  });

  testWidgets('an empty href does not open the overlay', (tester) async {
    await tester.pumpWidget(host('<a href="">kosong</a>'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('kosong'));
    await tester.pumpAndSettle();

    expect(find.text('Open Website'), findsNothing);
    expect(launchCalls, isEmpty);
  });

  testWidgets('link colour follows the theme flag', (tester) async {
    await tester.pumpWidget(
      host('<a href="https://celiktafsir.net">rujukan</a>', isDark: false),
    );
    await tester.pumpAndSettle();

    final lightStyle = tester.widget<Text>(find.text('rujukan')).style!;
    expect(lightStyle.color, const Color(0xFF0000EE));
    expect(lightStyle.decoration, TextDecoration.underline);

    await tester.pumpWidget(
      host('<a href="https://celiktafsir.net">rujukan</a>', isDark: true),
    );
    await tester.pumpAndSettle();

    final darkStyle = tester.widget<Text>(find.text('rujukan')).style!;
    expect(darkStyle.color, Colors.white);
  });
}
