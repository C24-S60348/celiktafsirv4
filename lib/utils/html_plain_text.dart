/// Turns article HTML into readable plain text, for copying to the clipboard.
///
/// Was an identical private `_stripHtmlTags` in each of the six reading views
/// plus Glosari; lifted out here so the surah page did not become the seventh
/// copy, and so a fix to the stripping lands everywhere at once.
///
/// Block-level tags become newlines so paragraph breaks survive; every other
/// tag is dropped and the handful of entities the site emits are decoded.
String htmlToPlainText(String htmlContent) {
  String plainText = htmlContent;

  // Replace block elements with double newlines to preserve paragraph structure
  plainText = plainText.replaceAll(RegExp(r'</p>\s*<p>', caseSensitive: false), '\n\n');
  plainText = plainText.replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '');
  plainText = plainText.replaceAll(RegExp(r'</p>', caseSensitive: false), '');
  plainText = plainText.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  plainText = plainText.replaceAll(RegExp(r'<div[^>]*>', caseSensitive: false), '');
  plainText = plainText.replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');
  plainText = plainText.replaceAll(RegExp(r'<blockquote[^>]*>', caseSensitive: false), '');
  plainText = plainText.replaceAll(RegExp(r'</blockquote>', caseSensitive: false), '');

  // Remove remaining HTML tags
  final RegExp htmlRegex = RegExp(r'<[^>]*>');
  plainText = plainText.replaceAll(htmlRegex, '');

  // Decode HTML entities
  plainText = plainText
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&');

  // Clean up excessive whitespace while preserving paragraph breaks
  // Replace multiple spaces with single space
  plainText = plainText.replaceAll(RegExp(r' +'), ' ');
  // Replace multiple newlines with double newlines (paragraph breaks)
  plainText = plainText.replaceAll(RegExp(r'\n\n+'), '\n\n');
  // Trim each line
  final lines = plainText.split('\n');
  plainText = lines.map((line) => line.trim()).join('\n');

  return plainText.trim();
}
