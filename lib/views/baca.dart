import 'package:flutter/material.dart';
import '../models/baca.dart' as model;
import '../services/getlistsurah.dart' as getlist;
import '../utils/theme_helper.dart';
import '../utils/html_link_helper.dart';
import '../widgets/article_read_bottom_nav.dart';

class BacaPage extends StatefulWidget {
  const BacaPage({super.key});

  @override
  _BacaPageState createState() => _BacaPageState();
}

class _BacaPageState extends State<BacaPage> {
  late Map<String, String> surahData;
  int currentPage = 0; // Changed to 0-based indexing
  int totalPages = 0;
  // bool isLoading = true;
  int surahIndex = 0; // Add surah index
  /// Use ValueNotifier so toggling bookmark only rebuilds the icon, not the whole page.
  final ValueNotifier<bool> _isBookmarked = ValueNotifier<bool>(false);
  bool _isInitialized = false; // Add initialization flag
  final ScrollController _scrollController = ScrollController();
  List<String>? _cachedTitles; // Cache titles to avoid calling service on navigation

  @override
  void dispose() {
    _isBookmarked.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? categoryUrl;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        surahData = args.cast<String, String>();
        surahIndex = args['surahIndex'] ?? 0;
        currentPage = args['pageIndex'] ?? 0;
        categoryUrl = args['category_url']?.toString();
        _isInitialized = true;
        _loadSurahContent();
        _checkBookmark(); // Check bookmark status when page loads
      }
    }
  }

  void _loadSurahContent() async {
    print('Loading surah content for index: $surahIndex');
    // Pass categoryUrl to ensure we get the correct variant (e.g., Baqarah Juzuk 2)
    final surah = await getlist.GetListSurah.getSurahByIndex(surahIndex, categoryUrl: categoryUrl);
    if (!mounted) return;
    print('Surah data: $surah');
    
    if (surah != null) {
      final pages = surah['totalPages'];
      final titles = surah['titles'] as List<String>?;
      print('Total pages from surah: $pages');
      
      setState(() {
        totalPages = pages;
        _cachedTitles = titles; // Cache titles for navigation
      });

      print('Updated totalPages to: $totalPages');

      // Update page title if not already set from navigation
      if (surahData['pageTitle'] == null && _cachedTitles != null && currentPage < _cachedTitles!.length) {
        if (!mounted) return;
        setState(() {
          surahData['pageTitle'] = _cachedTitles![currentPage];
        });
      }

      // Save last read (only if still mounted)
      if (mounted) _saveLastRead();
      if (mounted) _downloadSurahInBackground();
    } else {
      print('Surah data is null for index: $surahIndex');
    }
  }

  void _downloadSurahInBackground() async {
    // try {
    //   // Check if surah is already downloaded
    //   final isDownloaded = await DownloadService.isSurahDownloaded(surahIndex, categoryUrl: categoryUrl);
      
    //   if (!isDownloaded) {
    //     // Get theme to determine snackbar color
    //     final themeName = await ThemeHelper.getThemeName();
    //     final isDark = themeName == 'Gelap';
        
    //     // Show a subtle notification that download is starting
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           'Memuat kandungan...',
    //           style: TextStyle(color: Colors.white),
    //         ),
    //         duration: Duration(seconds: 2),
    //         backgroundColor: isDark ? Colors.grey[850] : Color.fromARGB(255, 52, 21, 104),
    //       ),
    //     );
        
    //     // Download in background with correct categoryUrl
    //     await DownloadService.downloadSurahPages(surahIndex, categoryUrl: categoryUrl);
        
    //     // Show completion notification
    //     if (mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text('Kandungan berjaya dimuatkan!'),
    //           duration: Duration(seconds: 2),
    //           backgroundColor: Colors.green,
    //         ),
    //       );
    //     }
        
    //     // Debug: Check cached pages
    //     await DownloadService.debugCachedPages(surahIndex, categoryUrl: categoryUrl);
    //   }
    // } catch (e) {
    //   print('Error memuat kandungan: $e');
    // }
    // Cache/download disabled for now
    // TODO: Re-enable after webapp is perfected
    print('Cache/download disabled - using direct fetch only');
  }

  void _updatePageTitle() {
    // Use cached titles directly without calling service
    if (_cachedTitles != null && currentPage >= 0 && currentPage < _cachedTitles!.length) {
      setState(() {
        surahData['pageTitle'] = _cachedTitles![currentPage];
      });
    }
  }

  void _nextPage() {
    if (currentPage < totalPages - 1) {
      setState(() {
        currentPage++;
      });
      _updatePageTitle(); // Update page title when navigating
      _checkBookmark(); // Check bookmark after page change
      _saveLastRead(); // Save last read when navigating
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      _updatePageTitle(); // Update page title when navigating
      _checkBookmark(); // Check bookmark after page change
      _saveLastRead(); // Save last read when navigating
    }
  }

  void _toggleBookmark() async {
    if (_isBookmarked.value) {
      await model.removeBookmark(surahIndex, currentPage);
      if (!mounted) return;
      _showBookmarkMessage('Bookmark removed');
    } else {
      await model.addBookmark(
        surahIndex,
        currentPage,
        categoryUrl: categoryUrl,
        pageTitle: surahData['pageTitle'] ?? surahData['name'],
      );
      if (!mounted) return;
      _showBookmarkMessage('Bookmark added');
    }
    if (!mounted) return;
    _checkBookmark();
  }

  void _checkBookmark() async {
    final bookmarked = await model.isBookmarked(surahIndex, currentPage);
    if (mounted) _isBookmarked.value = bookmarked;
  }

  void _saveLastRead() async {
    try {
      final pageTitle = surahData['pageTitle'] ?? surahData['name'] ?? '';
      await model.saveLastRead(
        surahIndex,
        currentPage,
        surahData['name'] ?? '',
        pageTitle,
        categoryUrl: categoryUrl,
      );
    } catch (e) {
      print('Error saving last read: $e');
    }
  }

  void _showBookmarkMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.black)),
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.primary,
      ),
    );
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
                  // Hideable app bar (hides when scrolling down, reappears when scrolling up)
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: ThemeHelper.getAppBarColor(themeName),
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    title: Text(
                      surahData['pageTitle'] ?? surahData['name'] ?? '',
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    leading: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back),
                    ),
                    actions: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _isBookmarked,
                        builder: (_, isBookmarked, __) => IconButton(
                          onPressed: _toggleBookmark,
                          onLongPress: () {
                            Navigator.of(context).pushNamed('/bookmarks');
                          },
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final url = await getlist.GetListSurah.getSurahUrl(surahIndex, currentPage);
                          if (!context.mounted) return;
                          // WebsitePage used to fall back to the site root when
                          // the surah URL was unavailable; keep that behaviour.
                          showOpenWebsiteOverlay(
                            context,
                            url ?? 'https://celiktafsir.net',
                          );
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
                      child: _buildSurahBodyWithTheme(
                        context,
                        surahData,
                        model.bodyContent(surahIndex, currentPage, isDark, textColor, categoryUrl),
                        textColor,
                        isDark,
                      ),
                    ),
                  ),
                  // Bottom row: Sebelum | Halaman X dari Y | Selepas (shared widget)
                  SliverToBoxAdapter(
                    child: ArticleReadBottomNav(
                      currentIndex: currentPage,
                      total: totalPages,
                      themeName: themeName,
                      textColor: textColor,
                      label: 'Halaman',
                      onPrevious: _previousPage,
                      onNext: _nextPage,
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

  // Theme-aware surah body builder
  Widget _buildSurahBodyWithTheme(
    BuildContext context,
    Map<String, String> surahData,
    Widget bodyContent,
    Color textColor,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Same max width as Pilihan Surah (600) so bismillah doesn't grow too large on wide screens
        const double maxBismillahWidth = 600;
        final bismillahWidth = (constraints.maxWidth * 0.7).clamp(0.0, maxBismillahWidth);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Surah header
            Center(
              child: Column(
                children: [
                  Text(
                    surahData['pageTitle'] ?? surahData['name'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Image.asset(
                    isDark 
                      ? 'assets/images/bismillah_darkmode.png'
                      : 'assets/images/bismillah.png',
                    fit: BoxFit.contain,
                    width: bismillahWidth,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Content placeholder
            bodyContent,
          ],
        );
      },
    );
  }

}
