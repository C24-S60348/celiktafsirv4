import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:celik_tafsir/views/baca_hujjah.dart';

/// Tests for the "Salin Kandungan" copy action added on azim-branch.
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
    HttpOverrides.global = _FakeHttpOverrides(articleHtml);

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

  Future<void> tapCopyContent(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.copy));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salin Kandungan'));
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

/// Serves a canned article body for every request so the page can load
/// content without touching the network.
class _FakeHttpOverrides extends HttpOverrides {
  _FakeHttpOverrides(this.body);

  final String body;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _FakeHttpClient(body);
}

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient(this.body);

  final String body;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest(body);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest(body);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this.body);

  final String body;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  // IOClient pipes the (empty) request body into the request, which calls
  // addStream then close. Both must hand back real futures.
  @override
  Future<void> addStream(Stream<List<int>> stream) => stream.drain<void>();

  @override
  Future<HttpClientResponse> get done async => _FakeHttpClientResponse(body);

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse(body);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientResponse implements HttpClientResponse {
  _FakeHttpClientResponse(this.body);

  final String body;

  @override
  int get statusCode => 200;

  @override
  int get contentLength => utf8.encode(body).length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => 'OK';

  @override
  List<RedirectInfo> get redirects => const <RedirectInfo>[];

  @override
  List<Cookie> get cookies => const <Cookie>[];

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([utf8.encode(body)]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = <String, List<String>>{};

  @override
  List<String>? operator [](String name) => _headers[name.toLowerCase()];

  @override
  String? value(String name) => _headers[name.toLowerCase()]?.first;

  @override
  void forEach(void Function(String name, List<String> values) action) =>
      _headers.forEach(action);

  @override
  ContentType? get contentType => ContentType.html;

  @override
  int get contentLength => -1;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
