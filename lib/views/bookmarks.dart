import 'package:flutter/material.dart';
import '../utils/uihelper.dart';
import '../models/baca.dart' as model;
import '../services/getlistsurah.dart' as getlist;
import '../models/tadabbur.dart' as surahlist;

class BookmarksPage extends StatefulWidget {
  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Map<String, dynamic>> bookmarks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() async {
    try {
      final savedBookmarks = await model.getBookmarks();
      setState(() {
        bookmarks = savedBookmarks;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading bookmarks: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _removeBookmark(int index) async {
    final bookmark = bookmarks[index];
    try {
      await model.removeBookmark(
        bookmark['surahIndex'], 
        bookmark['currentPage']
      );
      setState(() {
        bookmarks.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bookmark removed'),
          duration: Duration(seconds: 2),
          backgroundColor: const Color.fromARGB(255, 52, 21, 104),
        ),
      );
    } catch (e) {
      print('Error removing bookmark: $e');
    }
  }

  void _navigateToVerse(Map<String, dynamic> bookmark) async {
    try {
      // Get surah data from the service
      final surah = await getlist.GetListSurah.getSurahByIndex(bookmark['surahIndex']);
      if (surah != null) {
        Navigator.of(context).pushNamed('/baca', arguments: {
          'number': surah['surahIndex'],
          'name': surahlist.surahList[surah['surahIndex']]['name'],
          'name_arab': surahlist.surahList[surah['surahIndex']]['name_arab'],
          'surahIndex': bookmark['surahIndex'],
          'pageIndex': bookmark['currentPage'],
        });
      }
    } catch (e) {
      print('Error navigating to verse: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 52, 21, 104),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
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
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color.fromARGB(255, 52, 21, 104),
                      ),
                    ),
                  )
                : bookmarks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tiada bookmark',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Bookmark ayat semasa membaca untuk melihatnya di sini',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: bookmarks.length,
                        itemBuilder: (context, index) {
                          final bookmark = bookmarks[index];
                          return FutureBuilder<Map<String, dynamic>?>(
                            future: getlist.GetListSurah.getSurahByIndex(bookmark['surahIndex']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Card(
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(width: 16),
                                        Text('Loading...'),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              
                              final surah = snapshot.data;
                              if (surah == null) {
                                return SizedBox.shrink();
                              }
                              
                              return Card(
                                margin: EdgeInsets.only(bottom: 12),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () => _navigateToVerse(bookmark),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${surahlist.surahList[surah['surahIndex']]['name']} (${surahlist.surahList[surah['surahIndex']]['name_arab']})',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color.fromARGB(255, 52, 21, 104),
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'Halaman ${bookmark['currentPage'] + 1}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _removeBookmark(index),
                                              icon: Icon(
                                                Icons.bookmark_remove,
                                                color: Colors.red[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Added ${_formatDate(DateTime.parse(bookmark['dateAdded']))}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
