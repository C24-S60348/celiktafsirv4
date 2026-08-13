import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Minimal in-memory `HttpClient` that answers every request with the same
/// body, so service tests can exercise a real scrape without a network.
///
/// Deliberately sends **no** `content-type` header, which is exactly what
/// celiktafsir.net does. That is what makes the `http` package fall back to
/// latin-1 in [Response.body] and mangle UTF-8 — see `utf8_response_test.dart`.

class FakeHttpOverrides extends HttpOverrides {
  FakeHttpOverrides(this.body);
  final String body;

  @override
  HttpClient createHttpClient(SecurityContext? context) => FakeHttpClient(body);
}

class FakeHttpClient implements HttpClient {
  FakeHttpClient(this.body);
  final String body;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      FakeHttpClientRequest(body);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      FakeHttpClientRequest(body);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHttpClientRequest implements HttpClientRequest {
  FakeHttpClientRequest(this.body);
  final String body;

  @override
  final HttpHeaders headers = FakeHttpHeaders();

  @override
  Future<void> addStream(Stream<List<int>> stream) => stream.drain<void>();

  @override
  Future<HttpClientResponse> get done async => FakeHttpClientResponse(body);

  @override
  Future<HttpClientResponse> close() async => FakeHttpClientResponse(body);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHttpClientResponse implements HttpClientResponse {
  FakeHttpClientResponse(this.body);
  final String body;

  @override
  int get statusCode => 200;

  @override
  int get contentLength => utf8.encode(body).length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  final HttpHeaders headers = FakeHttpHeaders();

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

class FakeHttpHeaders implements HttpHeaders {
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
