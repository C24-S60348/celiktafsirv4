import 'package:flutter/material.dart';
import '../models/laa_tahzan.dart' as model;
import '../utils/theme_helper.dart';

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
        _isInitialized = true;
        _loadLaaTahzanContent();
      }
    }
  }

  void _loadLaaTahzanContent() async {
    try {
      final themeName = await ThemeHelper.getThemeName();
      final isDark = themeName == 'Gelap';

      if (mounted && postUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Memuat kandungan...',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
            backgroundColor:
                isDark ? Colors.grey[850] : Color.fromARGB(255, 52, 21, 104),
          ),
        );

        final content = await model.getLaaTahzanContent(postUrl!);

        if (mounted) {
          if (content != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kandungan berjaya dimuatkan!'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          } else {
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
      appBar: AppBar(
        title: Text(
          postTitle ?? 'La Tahzan',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 52, 21, 104),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: ThemeHelper.getThemeName(),
        builder: (context, snapshot) {
          final themeName = snapshot.data ?? 'Terang';
          final backgroundColor = ThemeHelper.getContentBackgroundColor(themeName);
          final isDark = themeName == 'Gelap';
          final baseTextColor = ThemeHelper.getTextColor(themeName);
          // Ensure all text is white in dark mode, while keeping bold/underline styling from HTML
          final textColor = isDark ? Colors.white : baseTextColor;

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
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
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

