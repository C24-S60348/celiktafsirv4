import 'package:flutter/material.dart';
import '../models/hujjah.dart' as model;
import '../utils/theme_helper.dart';
import '../widgets/article_read_bottom_nav.dart';

class BacaAsmaulHusnaPage extends StatefulWidget {
  const BacaAsmaulHusnaPage({super.key});

  @override
  _BacaAsmaulHusnaPageState createState() => _BacaAsmaulHusnaPageState();
}

class _BacaAsmaulHusnaPageState extends State<BacaAsmaulHusnaPage> {
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
        postTitle = args['title']?.toString() ?? 'Asmaul Husna';
        _currentIndex = args['index'] as int? ?? args['pageIndex'] as int? ?? 0;
        _total = args['total'] as int? ?? 0;
        _items = args['items'] as List<Map<String, dynamic>>?;
        _isInitialized = true;
        _loadAsmaulHusnaContent();
      }
    }
  }

  void _loadAsmaulHusnaContent() async {
    try {
      final themeName = await ThemeHelper.getThemeName();
      if (mounted && postUrl != null) {
        ThemeHelper.showMemuatSnackBar(context, themeName);
        // Actually load the content to ensure it's fetched
        final content = await model.getHujjahContent(postUrl!);
        
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
      print('Error loading Asmaul Husna content: $e');
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
      appBar: AppBar(
        title: Text(postTitle ?? 'Asmaul Husna'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
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
            icon: Icon(
              Icons.language,
            ),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: ThemeHelper.getThemeName(),
        builder: (context, snapshot) {
          final themeName = snapshot.data ?? 'Terang';
          final backgroundColor = ThemeHelper.getContentBackgroundColor(themeName);
          final textColor = ThemeHelper.getTextColor(themeName);
          final isDark = themeName == 'Gelap';
          
          return Stack(
            children: [
              Image.asset(
                'assets/images/bg.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                color: isDark ? Colors.black54 : null,
                colorBlendMode: isDark ? BlendMode.darken : null,
              ),
              Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          thickness: 2.0,
                          radius: Radius.circular(4.0),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildAsmaulHusnaBodyWithTheme(
                                  context,
                                  postTitle ?? 'Asmaul Husna',
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
                                if (_items != null && _items!.isNotEmpty)
                                  ArticleReadBottomNav(
                                    currentIndex: _currentIndex,
                                    total: _total,
                                    themeName: themeName,
                                    textColor: textColor,
                                    label: 'Halaman',
                                    onPrevious: _currentIndex > 0
                                        ? () {
                                            final prev = _items![_currentIndex - 1];
                                            Navigator.of(context).pushReplacementNamed(
                                              '/baca-asmaul-husna',
                                              arguments: {
                                                'url': prev['url'],
                                                'title': prev['title'],
                                                'pageIndex': prev['index'] ?? _currentIndex - 1,
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
                                              '/baca-asmaul-husna',
                                              arguments: {
                                                'url': next['url'],
                                                'title': next['title'],
                                                'pageIndex': next['index'] ?? _currentIndex + 1,
                                                'index': _currentIndex + 1,
                                                'total': _total,
                                                'items': _items,
                                              },
                                            );
                                          }
                                        : null,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  // Theme-aware Asmaul Husna body builder
  Widget _buildAsmaulHusnaBodyWithTheme(
    BuildContext context,
    String title,
    Widget bodyContent,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Asmaul Husna header
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

