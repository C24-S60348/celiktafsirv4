import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class GetHadis40 {
  static const String _baseUrl = 'https://celiktafsir.net';
  static const String _hadis25Url =
      'https://celiktafsir.net/2025/12/31/syarah-hadis-25-hadis-40-imam-nawawi/';
  static const String _hadis26Url =
      'https://celiktafsir.net/2026/01/07/syarah-hadis-26-hadis-40/';
  static const String _hadis27Url =
      'https://celiktafsir.net/2026/02/02/syarah-hadis-27-hadis-40/';

  // CORS Proxy for Web - using custom proxy server (same pattern as GetHujjah)
  static const String _corsProxy =
      'https://afwanhaziq.vps.webdock.cloud/proxy?url=';

  /// Get the URL with CORS proxy if running on web
  static String _getProxiedUrl(String url) {
    if (kIsWeb) {
      // For web, use custom CORS proxy
      return '$_corsProxy$url';
    }
    // For mobile, use direct URL (no CORS restrictions)
    return url;
  }

  /// Check internet connection
  static Future<bool> _hasInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse(_getProxiedUrl(_baseUrl)))
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get the Hadis 40 page as a list of 3 articles (fixed titles)
  static Future<List<Map<String, String>>> getHadis40Posts() async {
    final hasInternet = await _hasInternetConnection();

    if (!hasInternet) {
      print('No internet connection, cannot fetch Hadis 40 page');
      return [];
    }

    // We expose the 3 Hadis 40 articles as separate entries
    return [
      {
        'url': _hadis25Url,
        'title': 'HADIS #25 Sedekah dari Orang Miskin',
        'date': '00000000', // dummy date to keep structure consistent
      },
      {
        'url': _hadis26Url,
        'title': 'HADIS #26 Setiap Sendi Mesti Bersedekah',
        'date': '00000001',
      },
      {
        'url': _hadis27Url,
        'title': 'HADIS #27 Mintalah Fatwa kepada Hatimu',
        'date': '00000002',
      },
    ];
  }
}

