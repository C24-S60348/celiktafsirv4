import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/glosari.dart' as model;
import '../utils/theme_helper.dart';

class GlosariPage extends StatefulWidget {
  const GlosariPage({super.key});

  @override
  _GlosariPageState createState() => _GlosariPageState();
}

class _GlosariPageState extends State<GlosariPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  String? _glosariContent;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadGlosariContent();
    }
  }

  void _loadGlosariContent() async {
    try {
      // Get theme to determine snackbar color
      final themeName = await ThemeHelper.getThemeName();
      final isDark = themeName == 'Gelap';
      
      // Show a subtle notification that loading is starting
      if (mounted) {
        final themeName = isDark ? 'Gelap' : 'Terang';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Memuat kandungan...',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: ThemeHelper.getAppBarColor(themeName),
          ),
        );
      }
      
      // Actually load the content to ensure it's fetched
      final content = await model.getGlosariContent();
      
      if (mounted && content != null) {
        setState(() {
          _glosariContent = content;
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
    } catch (e) {
      print('Error memuat kandungan: $e');
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
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: ThemeHelper.getAppBarColor(themeName),
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    title: Text(
                      'Glosari',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    leading: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back),
                    ),
                    actions: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'content') {
                            if (_glosariContent != null && _glosariContent!.isNotEmpty) {
                              final plainText = _stripHtmlTags(_glosariContent!);
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
                          } else if (value == 'website') {
                            Navigator.of(context).pushNamed('/websitepage', arguments: {
                              'url': 'https://celiktafsir.net/glosari-blog/',
                            });
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
                          PopupMenuItem<String>(
                            value: 'website',
                            child: Row(
                              children: [
                                Icon(Icons.language, size: 20),
                                SizedBox(width: 8),
                                Text('Buka Laman Web'),
                              ],
                            ),
                          ),
                        ],
                        icon: Icon(Icons.settings),
                      ),
                    ],
                  ),
                  // Reading content: full width, no border, white (light) or theme (dark)
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      color: readingContainerColor,
                      padding: EdgeInsets.all(16.0),
                      child: _buildGlosariBodyWithTheme(
                        context,
                        model.bodyContent(isDark, textColor),
                        textColor,
                        isDark,
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

  // Theme-aware glosari body builder
  Widget _buildGlosariBodyWithTheme(
    BuildContext context,
    Widget bodyContent,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Glosari header
        Center(
          child: Text(
            'Glosari',
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

