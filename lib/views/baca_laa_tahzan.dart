import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/laa_tahzan.dart' as model;
import '../utils/theme_helper.dart';
import '../utils/html_link_helper.dart';
import '../utils/html_plain_text.dart';
import '../widgets/article_read_bottom_nav.dart';
import '../widgets/article_read_top_nav.dart';
import '../widgets/article_swipe_navigator.dart';

class BacaLaaTahzanPage extends StatefulWidget {
  const BacaLaaTahzanPage({super.key});

  @override
  _BacaLaaTahzanPageState createState() => _BacaLaaTahzanPageState();
}

class _BacaLaaTahzanPageState extends State<BacaLaaTahzanPage> {
  late Map<String, String> postData;
  bool _isInitialized = false;
  final ScrollController _scrollController = ScrollController();
  String? postUrl;
  String? postTitle;
  int _currentIndex = 0;
  int _total = 0;
  List<Map<String, dynamic>>? _items;
  String? _laaTahzanContent;

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
        postTitle = args['title']?.toString() ?? 'La Tahzan';
        _currentIndex = args['index'] as int? ?? 0;
        _total = args['total'] as int? ?? 0;
        _items = args['items'] as List<Map<String, dynamic>>?;
        _isInitialized = true;
        _loadLaaTahzanContent();
      }
    }
  }

  void _loadLaaTahzanContent() async {
    try {
      final themeName = await ThemeHelper.getThemeName();
      if (mounted && postUrl != null) {
        ThemeHelper.showMemuatSnackBar(context, themeName);
        final content = await model.getLaaTahzanContent(postUrl!);

        if (mounted && content != null) {
          setState(() {
            _laaTahzanContent = content;
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
      print('Error loading La Tahzan content: $e');
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
      '/baca-laa-tahzan',
      arguments: {
        'url': item['url'],
        'title': item['title'],
        'index': newIndex,
        'total': _total,
        'items': _items,
      },
    );
  }

  /// Copies the loaded article body. The fetch fills [_laaTahzanContent] on
  /// load, so there is nothing to await here -- an empty field means the
  /// article has not landed yet (or failed), and we say so.
  void _copyContent() {
    if (_laaTahzanContent == null || _laaTahzanContent!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kandungan belum dimuatkan'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    _copyTextToClipboard(htmlToPlainText(_laaTahzanContent!), type: 'Kandungan');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: ThemeHelper.getThemeName(),
        builder: (context, snapshot) {
          final themeName = snapshot.data ?? 'Terang';
          final backgroundColor = ThemeHelper.getContentBackgroundColor(themeName);
          final isDark = themeName == 'Gelap';
          final baseTextColor = ThemeHelper.getTextColor(themeName);
          // Ensure all text is white in dark mode, while keeping bold/underline styling from HTML
          final textColor = isDark ? Colors.white : baseTextColor;
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
                        postTitle ?? 'La Tahzan',
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
                        IconButton(
                          onPressed: _copyContent,
                          tooltip: 'Salin Kandungan',
                          icon: Icon(Icons.copy),
                        ),
                        IconButton(
                          onPressed: () {
                            if (postUrl != null) {
                              showOpenWebsiteOverlay(context, postUrl!);
                            }
                          },
                          tooltip: 'Buka Laman Web',
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
                        child: _buildLaaTahzanBodyWithTheme(
                          context,
                          postTitle ?? 'La Tahzan',
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

  Widget _buildLaaTahzanBodyWithTheme(
    BuildContext context,
    String title,
    Widget bodyContent,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        bodyContent,
      ],
    );
  }
}

