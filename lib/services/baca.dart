import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

class BacaService {
  static const String baseUrl = 'https://celiktafsir.net';

  /// Fetches HTML content from a URL and extracts data from element with specified class
  static Future<String?> fetchContentFromUrl(
    String url,
    String className,
  ) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final element = document.querySelector('.$className');

        if (element != null) {
          String? elementdata;
          elementdata = element.innerHtml.substring(
            0,
            element.innerHtml.indexOf("Share this"),
          );
          if (elementdata == "") {
            elementdata = element.innerHtml;
          } else {
            return elementdata;
          }
        }
      }
    } catch (e) {
      print('Error fetching content: $e');
    }
    return null;
  }

  /// Parses HTML content and extracts text
  static String parseHtmlToText(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    return document.body?.text ?? '';
  }

}
