import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/asalusultafsir.dart' as model;
import '../utils/theme_helper.dart';
import '../utils/html_link_helper.dart';
import '../widgets/article_read_bottom_nav.dart';
import '../widgets/article_read_top_nav.dart';
import '../widgets/article_swipe_navigator.dart';

class BacaAsalUsulTafsirPage extends StatefulWidget {
  const BacaAsalUsulTafsirPage({super.key});

  @override
  _BacaAsalUsulTafsirPageState createState() => _BacaAsalUsulTafsirPageState();
}

class _BacaAsalUsulTafsirPageState extends State<BacaAsalUsulTafsirPage> {
  late Map<String, String> postData;
  bool _isInitialized = false;
  final ScrollController _scrollController = ScrollController();
  String? postUrl;
  String? postTitle;
  int _currentIndex = 0;
  int _total = 0;
  List<Map<String, dynamic>>? _items;
  String? _asalUsulTafsirContent;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        postData = args.cast<String, String>();
        postUrl = args['url']?.toString();
        postTitle = args['title']?.toString() ?? 'Ilmu Usul Tafsir';
        _currentIndex = args['index'] as int? ?? 0;
        _total = args['total'] as int? ?? 0;
        _items = args['items'] as List<Map<String, dynamic>>?;
        _isInitialized = true;
        _loadAsalUsulTafsirContent();
      }
    }
  }

  void _loadAsalUsulTafsirContent() async {
    try {
      final themeName = await ThemeHelper.getThemeName();
      if (mounted && postUrl != null) {
        ThemeHelper.showMemuatSnackBar(context, themeName);
        // Actually load the content to ensure it's fetched
        final content = await model.getAsalUsulTafsirContent(postUrl!);
        
        if (mounted && content != null) {
          setState(() {
            _asalUsulTafsirContent = content;
          });
        } else if (mounted && content == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuatkan kandungan'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading ilmu usul tafsir content: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuatkan kandungan'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shared by the top and bottom nav rows.
  void _goToArticle(int newIndex) {
    final item = _items![newIndex];
    Navigator.of(context).pushReplacementNamed(
      '/baca-asal-usul-tafsir',
      arguments: {
        'url': item['url'],
        'title': item['title'],
        'index': newIndex,
        'total': _total,
        'items': _items,
      },
    );
  }

  void _copyTextToClipboard(String text, {String type = 'Teks'}) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type telah disalin ke klipbod'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyalin $type'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  String _stripHtmlTags(String htmlContent) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: ThemeHelper.getThemeName(),
        builder: (context, snapshot) {
          final themeName = snapshot.data ?? 'Terang';
          final backgroundColor = ThemeHelper.getContentBackgroundColor(themeName);
          final textColor = ThemeHelper.getTextColor(themeName);
          final isDark = themeName == 'Gelap';
          // Reading container: white in light (no border), theme background in dark
          final readingContainerColor = isDark ? backgroundColor : Colors.white;

          return Stack(
            children: [
              // Background image with dark overlay in dark mode
              Image.asset(
                'assets/images/bg.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                color: isDark ? Colors.black54 : null,
                colorBlendMode: isDark ? BlendMode.darken : null,
              ),
              ArticleSwipeNavigator(
                onPrevious: (_items != null && _currentIndex > 0)
                    ? () => _goToArticle(_currentIndex - 1)
                    : null,
                onNext: (_items != null && _currentIndex < _total - 1)
                    ? () => _goToArticle(_currentIndex + 1)
                    : null,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      backgroundColor: ThemeHelper.getAppBarColor(themeName),
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      title: Text(
                        postTitle ?? 'Ilmu Usul Tafsir',
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      leading: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back),
                      ),
                      bottom: (_items != null && _items!.isNotEmpty)
                          ? PreferredSize(
                              preferredSize:
                                  const Size.fromHeight(44),
                              child: Container(
                                color: articleReadTopNavColor(themeName),
                                child: ArticleReadTopNav(
                                  currentIndex: _currentIndex,
                                  total: _total,
                                  themeName: themeName,
                                  label: 'Artikel',
                                  onPrevious: _currentIndex > 0
                                      ? () => _goToArticle(_currentIndex - 1)
                                      : null,
                                  onNext: _currentIndex < _total - 1
                                      ? () => _goToArticle(_currentIndex + 1)
                                      : null,
                                ),
                              ),
                            )
                          : null,
                      actions: [
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'content') {
                              if (_asalUsulTafsirContent != null && _asalUsulTafsirContent!.isNotEmpty) {
                                final plainText = _stripHtmlTags(_asalUsulTafsirContent!);
                                _copyTextToClipboard(plainText, type: 'Kandungan');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Kandungan belum dimuatkan'),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'content',
                              child: Row(
                                children: [
                                  Icon(Icons.article, size: 20),
                                  SizedBox(width: 8),
                                  Text('Salin Kandungan'),
                                ],
                              ),
                            ),
                          ],
                          icon: Icon(Icons.copy),
                        ),
                        IconButton(
                          onPressed: () {
                            if (postUrl != null) {
                              showOpenWebsiteOverlay(context, postUrl!);
                            }
                          },
                          icon: Icon(Icons.language),
                        ),
                      ],
                    ),
                    // Reading content: full width, no border, white (light) or theme (dark)
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        color: readingContainerColor,
                        padding: EdgeInsets.all(16.0),
                        child: _buildAsalUsulTafsirBodyWithTheme(
                          context,
                          postTitle ?? 'Ilmu Usul Tafsir',
                          postUrl != null
                              ? model.bodyContent(postUrl!, isDark, textColor)
                              : Center(
                                  child: Text(
                                    'Tiada URL tersedia',
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                          textColor,
                          isDark,
                        ),
                      ),
                    ),
                    // Bottom row: Sebelum | Artikel X dari Y | Selepas
                    if (_items != null && _items!.isNotEmpty)
                      SliverToBoxAdapter(
                        child: ArticleReadBottomNav(
                          currentIndex: _currentIndex,
                          total: _total,
                          themeName: themeName,
                          textColor: textColor,
                          label: 'Artikel',
                          onPrevious: _currentIndex > 0
                              ? () => _goToArticle(_currentIndex - 1)
                              : null,
                          onNext: _currentIndex < _total - 1
                              ? () => _goToArticle(_currentIndex + 1)
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Theme-aware ilmu usul tafsir body builder
  Widget _buildAsalUsulTafsirBodyWithTheme(
    BuildContext context,
    String title,
    Widget bodyContent,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ilmu Usul Tafsir header
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        SizedBox(height: 20),

        // Content placeholder
        bodyContent,
      ],
    );
  }
}

