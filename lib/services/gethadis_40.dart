import '../utils/proxy_helper.dart';

class GetHadis40 {
  static const String _hadis25Url =
      'https://celiktafsir.net/2025/12/31/syarah-hadis-25-hadis-40-imam-nawawi/';
  static const String _hadis26Url =
      'https://celiktafsir.net/2026/01/07/syarah-hadis-26-hadis-40/';
  static const String _hadis27Url =
      'https://celiktafsir.net/2026/02/02/syarah-hadis-27-hadis-40/';

  /// Get the Hadis 40 page as a list of 3 articles (fixed titles)
  static Future<List<Map<String, String>>> getHadis40Posts() async {
    final hasInternet = await hasInternetConnection();

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

