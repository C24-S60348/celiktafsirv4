import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:celik_tafsir/services/gethadis_40.dart';

/// Hadis 40 used to return three hardcoded articles and could never show
/// more. It now scrapes its category, with the hardcoded three kept only as
/// a fallback so a wrong/unreachable category cannot make things worse.
void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  String categoryPage(String links) =>
      '<html><body><div class="posts">$links</div></body></html>';

  testWidgets('lists every hadis post found in the category', (tester) async {
    HttpOverrides.global = _FakeHttpOverrides(
      categoryPage('''
        <a href="https://celiktafsir.net/2025/12/31/syarah-hadis-25-hadis-40-imam-nawawi/">HADIS #25 Sedekah dari Orang Miskin</a>
        <a href="https://celiktafsir.net/2026/01/07/syarah-hadis-26-hadis-40/">HADIS #26 Setiap Sendi Mesti Bersedekah</a>
        <a href="https://celiktafsir.net/2026/02/02/syarah-hadis-27-hadis-40/">HADIS #27 Mintalah Fatwa kepada Hatimu</a>
        <a href="https://celiktafsir.net/2026/03/09/syarah-hadis-28-hadis-40/">HADIS #28 Berpegang kepada Sunnah</a>
      '''),
    );

    final posts = await GetHadis40.getHadis40Posts();

    // The point of the fix: a fourth article now shows up on its own.
    expect(posts, hasLength(4));
    expect(posts.last['title'], 'HADIS #28 Berpegang kepada Sunnah');
    expect(
      posts.last['url'],
      'https://celiktafsir.net/2026/03/09/syarah-hadis-28-hadis-40/',
    );
  });

  testWidgets('sorts chronologically regardless of page order', (tester) async {
    HttpOverrides.global = _FakeHttpOverrides(
      categoryPage('''
        <a href="https://celiktafsir.net/2026/02/02/syarah-hadis-27-hadis-40/">HADIS #27</a>
        <a href="https://celiktafsir.net/2025/12/31/syarah-hadis-25-hadis-40/">HADIS #25</a>
        <a href="https://celiktafsir.net/2026/01/07/syarah-hadis-26-hadis-40/">HADIS #26</a>
      '''),
    );

    final posts = await GetHadis40.getHadis40Posts();

    expect(
      posts.map((p) => p['title']).toList(),
      ['HADIS #25', 'HADIS #26', 'HADIS #27'],
    );
  });

  testWidgets('ignores non-hadis posts in the category', (tester) async {
    HttpOverrides.global = _FakeHttpOverrides(
      categoryPage('''
        <a href="https://celiktafsir.net/2026/01/07/syarah-hadis-26-hadis-40/">HADIS #26</a>
        <a href="https://celiktafsir.net/2026/01/08/tafsir-surah-baqarah-ayat-3/">Tafsir Baqarah</a>
        <a href="https://celiktafsir.net/category/hadis-40/">Kategori</a>
      '''),
    );

    final posts = await GetHadis40.getHadis40Posts();

    expect(posts, hasLength(1));
    expect(posts.single['title'], 'HADIS #26');
  });

  testWidgets('falls back to the known articles when the category is empty', (
    tester,
  ) async {
    // A wrong or emptied category must not leave the section blank.
    HttpOverrides.global = _FakeHttpOverrides(
      categoryPage('<a href="https://celiktafsir.net/about/">Tentang</a>'),
    );

    final posts = await GetHadis40.getHadis40Posts();

    expect(posts, hasLength(3));
    expect(posts.first['title'], 'HADIS #25 Sedekah dari Orang Miskin');
  });
}

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
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _FakeHttpClientRequest(body);

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
