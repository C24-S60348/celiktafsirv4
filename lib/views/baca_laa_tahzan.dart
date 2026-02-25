import 'package:flutter/material.dart';
import '../models/laa_tahzan.dart' as model;
import '../utils/theme_helper.dart';
import '../widgets/article_read_bottom_nav.dart';

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

        if (mounted && content == null) {
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
              CustomScrollView(
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
                    actions: [
                      IconButton(
                        onPressed: () async {
                          if (postUrl != null) {
                            await Navigator.of(context).pushNamed('/websitepage', arguments: {
                              'url': postUrl,
                            });
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
                            ? () {
                                final prev = _items![_currentIndex - 1];
                                Navigator.of(context).pushReplacementNamed(
                                  '/baca-laa-tahzan',
                                  arguments: {
                                    'url': prev['url'],
                                    'title': prev['title'],
                                    'index': _currentIndex - 1,
                                    'total': _total,
                                    'items': _items,
                                  },
                                );
                              }
                            : null,
                        onNext: _currentIndex < _total - 1
                            ? () {
                                final next = _items![_currentIndex + 1];
                                Navigator.of(context).pushReplacementNamed(
                                  '/baca-laa-tahzan',
                                  arguments: {
                                    'url': next['url'],
                                    'title': next['title'],
                                    'index': _currentIndex + 1,
                                    'total': _total,
                                    'items': _items,
                                  },
                                );
                              }
                            : null,
                      ),
                    ),
                ],
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

