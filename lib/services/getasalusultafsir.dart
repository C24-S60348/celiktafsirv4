import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../utils/proxy_helper.dart';

class GetAsalUsulTafsir {
  static const String _baseUrl = 'https://celiktafsir.net';
  static const String _categoryUrl = 'https://celiktafsir.net/ilmu-usul-tafsir/';

  /// Scrape all post URLs and titles from the ilmu usul tafsir category page
  static Future<List<Map<String, String>>> scrapeAsalUsulTafsirPosts() async {
    final List<Map<String, String>> urlTitles = [];
    int page = 1;
    bool hasMorePages = true;
    
    while (hasMorePages) {
      try {
        // WordPress category pages typically use ?paged=X for pagination
        final url = page == 1 ? _categoryUrl : '$_categoryUrl?paged=$page';
        final response = await http.get(Uri.parse(getProxiedUrl(url)));
        
        if (response.statusCode != 200) {
          break;
        }
        
        final document = html_parser.parse(response.body);
        
        // Find all post links - look for links that match post URL pattern
        // Post URLs typically match pattern: /YYYY/MM/DD/post-slug/
        final postUrlPattern = RegExp(r'/(\d{4})/(\d{2})/(\d{2})/[^/]+/$');
        final allLinks = document.querySelectorAll('a');
        
        bool foundNewLinks = false;
        for (var link in allLinks) {
          final href = link.attributes['href'];
          if (href != null) {
            // Convert relative URL to absolute
            final absoluteUrl = href.startsWith('http') ? href : '$_baseUrl$href';
            
            // Check if it's a post URL (matches date pattern) and is from celiktafsir.net
            final dateMatch = postUrlPattern.firstMatch(absoluteUrl);
            if (absoluteUrl.contains('celiktafsir.net') && 
                dateMatch != null &&
                !urlTitles.any((item) => item['url'] == absoluteUrl) &&
                !absoluteUrl.contains('/category/') &&
                !absoluteUrl.contains('/tag/') &&
                !absoluteUrl.contains('/author/') &&
                !absoluteUrl.contains('/page/')) {
              // Extract date from URL for sorting
              final year = dateMatch.group(1)!;
              final month = dateMatch.group(2)!;
              final day = dateMatch.group(3)!;
              final dateString = '$year$month$day';
              
              // Try to get title from link text, otherwise extract from URL
              String title = link.text.trim();
              if (title.isEmpty) {
                title = extractTitleFromUrl(absoluteUrl);
              }
              
              urlTitles.add({
                'url': absoluteUrl,
                'title': title,
                'date': dateString, // Store date for sorting
              });
              foundNewLinks = true;
            }
          }
        }
        
        // Check if there's a next page link
        final nextPageLink = document.querySelector('a.next.page-numbers, .nav-next a, .pagination .next a, .pagination-next a');
        hasMorePages = foundNewLinks && nextPageLink != null;
        page++;
        
        // Safety limit to prevent infinite loops
        if (page > 100) {
          print('Warning: Reached page limit for ilmu usul tafsir category');
          break;
        }
        
        // If no new links found, stop
        if (!foundNewLinks) {
          hasMorePages = false;
        }
      } catch (e) {
        print('Error scraping page $page of ilmu usul tafsir category: $e');
        break;
      }
    }
    
    // Sort by date (chronologically) to maintain the website's intended order
    urlTitles.sort((a, b) {
      final dateA = a['date'] ?? '';
      final dateB = b['date'] ?? '';
      return dateA.compareTo(dateB);
    });
    
    return urlTitles;
  }

  /// Get all ilmu usul tafsir posts (with internet check)
  static Future<List<Map<String, String>>> getAsalUsulTafsirPosts() async {
    // Check if we have internet connection
    final hasInternet = await hasInternetConnection();
    
    if (hasInternet) {
      try {
        print('Scraping ilmu usul tafsir posts from $_categoryUrl...');
        final posts = await scrapeAsalUsulTafsirPosts();
        print('Successfully scraped ${posts.length} ilmu usul tafsir posts');
        return posts;
      } catch (e) {
        print('Error scraping ilmu usul tafsir posts: $e');
        return [];
      }
    } else {
      print('No internet connection, cannot fetch ilmu usul tafsir posts');
      return [];
    }
  }
}

