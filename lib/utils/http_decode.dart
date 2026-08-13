import 'dart:convert';
import 'package:http/http.dart' as http;

/// Reads an HTTP response body as UTF-8, whatever the server says.
///
/// `response.body` picks its codec from the `charset` in the `Content-Type`
/// header, and when the server sends none the `http` package falls back to
/// **latin-1**. celiktafsir.net serves UTF-8 but does not always declare the
/// charset, so `response.body` turns every multi-byte character into mojibake:
/// each UTF-8 lead byte becomes a stray visible character (curly quotes and
/// long dashes leave an `â`, Arabic letters a run of `Ø`/`Ù`) and the
/// continuation bytes become invisible control characters. That is the
/// "character rosak" seen in the app while the website itself looks fine —
/// the browser sniffs the encoding, we did not.
///
/// Decoding [http.Response.bodyBytes] directly skips the header guess.
/// `allowMalformed: true` keeps one stray byte from throwing and losing a whole
/// article; it is replaced with U+FFFD instead.
String decodeUtf8Body(http.Response response) =>
    utf8.decode(response.bodyBytes, allowMalformed: true);
