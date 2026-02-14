import 'package:flutter/material.dart';
import '../services/getlistsurah.dart' as getlist;
import '../utils/proxy_helper.dart';
import '../utils/theme_helper.dart';

class SurahPagesPage extends StatefulWidget {
  const SurahPagesPage({super.key});

  @override
  _SurahPagesPageState createState() => _SurahPagesPageState();
}

class _SurahPagesPageState extends State<SurahPagesPage> {
  late Map<String, String> surahData;
  int surahIndex = 0;
  List<Map<String, dynamic>> pages = [];
  bool isLoading = true;
  bool hasNoInternet = false;

  String? categoryUrl;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isLoading) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        surahData = {
          'name': args['name']?.toString() ?? '',
          'name_arab': args['name_arab']?.toString() ?? '',
          'number': args['number']?.toString() ?? '',
        };
        surahIndex = args['surahIndex'] ?? 0;
        categoryUrl = args['category_url']?.toString();
        _loadPages();
      }
    }
  }

  void _loadPages() async {
    final hasInternet = await hasInternetConnection();
    if (!mounted) return;

    final surah = await getlist.GetListSurah.getSurahByIndex(surahIndex, categoryUrl: categoryUrl);
    if (!mounted) return;

    if (surah != null) {
      final urls = List<String>.from(surah['urls'] as List);
      final titles = surah['titles'] as List<String>?;
      final List<Map<String, dynamic>> pageList = [];

      for (int i = 0; i < urls.length; i++) {
        final url = urls[i];
        final title = (titles != null && i < titles.length)
            ? titles[i]
            : extractTitleFromUrl(url, fallback: 'Halaman ${i + 1}');
        pageList.add({
          'index': i,
          'title': title,
          'url': url,
        });
      }

      setState(() {
        pages = pageList;
        isLoading = false;
        hasNoInternet = (!hasInternet && urls.isEmpty);
      });
    } else {
      setState(() {
        pages = [];
        isLoading = false;
        hasNoInternet = !hasInternet;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${surahData['name']}'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/info');
            },
            icon: Icon(Icons.info_outline),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: ThemeHelper.getThemeName(),
        builder: (context, snapshot) {
          final themeName = snapshot.data ?? 'Terang';
          final textColor = ThemeHelper.getTextColor(themeName);
          final backgroundColor = ThemeHelper.getContentBackgroundColor(themeName);
          final isDark = themeName == 'Gelap';
          
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
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            'Pilih Halaman',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          isLoading 
                            ? SizedBox(height: 15,)
                            : hasNoInternet && pages.isEmpty
                              ? Text(
                                  'Tiada sambungan internet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  'Jumlah: ${pages.length} halaman',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey[300] : Colors.black87,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Divider(color: textColor.withOpacity(0.3)),
                    SizedBox(height: 10),

                    // Pages list
                    Expanded(
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ThemeHelper.getLoadingIndicatorColor(themeName),
                                ),
                              ),
                            )
                          : hasNoInternet && pages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.wifi_off,
                                      size: 64,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Tiada sambungan internet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                                      child: Text(
                                        'Sila semak sambungan internet anda dan cuba lagi.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.grey[400] : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : pages.isEmpty
                              ? Center(
                                  child: Text(
                                    'Tiada halaman tersedia',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark ? Colors.grey[400] : Colors.black54,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: pages.length,
                                  itemBuilder: (context, index) {
                                    final page = pages[index];
                                    // debugPrint('Page: ${page['title']}');
                                    return Card(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 4.0,
                                      ),
                                      elevation: 2,
                                      color: backgroundColor,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: ThemeHelper.getAppBarColor(themeName),
                                          child: Text(
                                            '${page['index'] + 1}',
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          page['title'] as String,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: textColor,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Halaman ${page['index'] + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.grey[400] : Colors.black54,
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: textColor,
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pushNamed('/baca', arguments: {
                                            ...surahData,
                                            'surahIndex': surahIndex,
                                            'pageIndex': page['index'],
                                            'pageTitle': page['title'],
                                            'category_url': categoryUrl,
                                          });
                                        },
                                      ),
                                    );
                                  },
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
}

