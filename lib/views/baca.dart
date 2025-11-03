import 'package:flutter/material.dart';
import '../models/baca.dart' as model;
import '../services/getlistsurah.dart' as getlist;
import '../services/download_service.dart';

class BacaPage extends StatefulWidget {
  @override
  _BacaPageState createState() => _BacaPageState();
}

class _BacaPageState extends State<BacaPage> {
  late Map<String, String> surahData;
  int currentPage = 0; // Changed to 0-based indexing
  int totalPages = 0;
  // bool isLoading = true;
  int surahIndex = 0; // Add surah index
  bool isBookmarked = false; // Add bookmark state
  bool _isInitialized = false; // Add initialization flag
  final ScrollController _scrollController = ScrollController();

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
        surahData = args.cast<String, String>();
        surahIndex = args['surahIndex'] ?? 0;
        currentPage = args['pageIndex'] ?? 0;
        _isInitialized = true;
        _loadSurahContent();
        _checkBookmark(); // Check bookmark status when page loads
      }
    }
  }

  void _loadSurahContent() async {
    print('Loading surah content for index: $surahIndex');
    final surah = await getlist.GetListSurah.getSurahByIndex(surahIndex);
    print('Surah data: $surah');
    
    if (surah != null) {
      final pages = surah['totalPages'];
      print('Total pages from surah: $pages');
      
      setState(() {
        totalPages = pages;
        // isLoading = false;
      });
      
      print('Updated totalPages to: $totalPages');
      
      // Start downloading this surah in background
      _downloadSurahInBackground();
    } else {
      print('Surah data is null for index: $surahIndex');
    }
  }

  void _downloadSurahInBackground() async {
    try {
      // Check if surah is already downloaded
      final isDownloaded = await DownloadService.isSurahDownloaded(surahIndex);
      
      if (!isDownloaded) {
        // Show a subtle notification that download is starting
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Memuat kandungan...'),
            duration: Duration(seconds: 2),
            backgroundColor: Color.fromARGB(255, 52, 21, 104),
          ),
        );
        
        // Download in background
        await DownloadService.downloadSurahPages(surahIndex);
        
        // Show completion notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kandungan berjaya dimuatkan!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Debug: Check cached pages
        await DownloadService.debugCachedPages(surahIndex);
      }
    } catch (e) {
      print('Error memuat kandungan: $e');
    }
  }

  void _nextPage() {
    if (currentPage < totalPages - 1) {
      setState(() {
        currentPage++;
      });
      _checkBookmark(); // Check bookmark after page change
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      _checkBookmark(); // Check bookmark after page change
    }
  }

  void _toggleBookmark() async {
    if (isBookmarked) {
      // Remove bookmark
      await model.removeBookmark(surahIndex, currentPage);
      _showBookmarkMessage('Bookmark removed');
    } else {
      // Add bookmark
      await model.addBookmark(surahIndex, currentPage);
      _showBookmarkMessage('Bookmark added');
    }
    
    // Update UI state after bookmark operation
    _checkBookmark();
  }

  void _checkBookmark() async {
    final bookmarked = await model.isBookmarked(surahIndex, currentPage);
    if (mounted) {
      setState(() {
        isBookmarked = bookmarked;
      });
    }
  }

  void _showBookmarkMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 52, 21, 104),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${surahData['name']} (${surahData['name_arab']})',
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
            onPressed: _toggleBookmark,
            onLongPress: () {
              Navigator.of(context).pushNamed('/bookmarks');
            },
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () async {
              final url = await getlist.GetListSurah.getSurahUrl(surahIndex, currentPage);
              await Navigator.of(context).pushNamed('/websitepage', arguments: {
                'url': url,
              });
              // Refresh bookmark status when returning from websitepage
              _checkBookmark();
            },
            icon: Icon(
              Icons.language,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Page indicator
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: totalPages == 0 ? Text(
                    'Halaman ${currentPage + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ) : Text(
                    'Halaman ${currentPage + 1} dari $totalPages',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Divider(color: Colors.white),
                
                // Content area
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 2.0,
                      radius: Radius.circular(4.0),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: model.buildSurahBody(
                          context, 
                          surahData, 
                          model.bodyContent(surahIndex, currentPage)
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Navigation buttons
                model.buildPageIndicator(
                  currentPage, 
                  totalPages, 
                  _previousPage, 
                  _nextPage
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
