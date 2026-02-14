import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// CORS proxy base URL for web. Used when fetching from celiktafsir.net on web.
const String corsProxyBaseUrl = 'https://afwanhaziq.vps.webdock.cloud/proxy?url=';

/// Returns the URL to use for HTTP requests. On web, uses the CORS proxy; otherwise returns the original URL.
String getProxiedUrl(String url) {
  if (kIsWeb) return '$corsProxyBaseUrl$url';
  return url;
}

/// Default URL used for connection check (celiktafsir.net).
const String _connectionCheckUrl = 'https://celiktafsir.net';

/// Checks if the device has internet by requesting [url] (or [_connectionCheckUrl]).
/// Uses proxied URL on web. Retries up to 2 times with 8s timeout per attempt.
Future<bool> hasInternetConnection({String? url}) async {
  final checkUrl = url ?? _connectionCheckUrl;
  for (var attempt = 0; attempt < 2; attempt++) {
    try {
      final response = await http.get(Uri.parse(getProxiedUrl(checkUrl))).timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw Exception('Connection timeout'),
      );
      return response.statusCode == 200;
    } catch (_) {
      if (attempt == 1) return false;
    }
  }
  return false;
}

bool _isNumeric(String str) {
  if (str.isEmpty) return false;
  return RegExp(r'^\d+$').hasMatch(str);
}

/// Extracts a human-readable title from a URL path (last segment, hyphen-separated).
/// Expands "bah" to "bahagian" and keeps hyphens between numeric segments (e.g. "1-2").
/// [fallback] is returned when the result would be empty (default "Untitled").
String extractTitleFromUrl(String url, {String fallback = 'Untitled'}) {
  try {
    final parts = url.split('/');
    final nonEmptyParts = parts.where((p) => p.isNotEmpty).toList();
    if (nonEmptyParts.isEmpty) return fallback;

    String slug = nonEmptyParts.last;
    slug = slug.split('?').first.split('#').first;
    if (slug.isEmpty) return fallback;

    final segments = slug.split('-');
    final List<String> processedSegments = [];
    for (int i = 0; i < segments.length; i++) {
      String segment = segments[i].trim();
      if (segment.isEmpty) continue;

      if (segment.toLowerCase() == 'bah') segment = 'bahagian';
      if (segment.isNotEmpty) {
        segment = segment[0].toUpperCase() + segment.substring(1).toLowerCase();
      }
      processedSegments.add(segment);

      if (i < segments.length - 1) {
        final nextSegment = segments[i + 1].trim();
        processedSegments.add(
          (_isNumeric(segment) && _isNumeric(nextSegment)) ? '-' : ' ',
        );
      }
    }

    String title = processedSegments.join('');
    title = Uri.decodeComponent(title);
    title = title.replaceAll(RegExp(r'\s+'), ' ');
    title = title.trim();
    return title.isEmpty ? fallback : title;
  } catch (_) {
    return fallback;
  }
}
