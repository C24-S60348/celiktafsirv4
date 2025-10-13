import 'package:flutter/material.dart';
import '../utils/uihelper.dart';

class BookmarksPage extends StatefulWidget {
  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Map<String, dynamic>> bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    // TODO: Load bookmarks from storage
    // For now, using sample data
    setState(() {
      bookmarks = [
        {
          'surahNumber': '1',
          'surahName': 'Al-Fatihah',
          'surahNameArabic': 'الفاتحة',
          'verseNumber': '1',
          'verseText': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          'dateAdded': DateTime.now().subtract(Duration(days: 1)),
          'surahIndex': 0,
          'pageIndex': 0,
        },
        {
          'surahNumber': '2',
          'surahName': 'Al-Baqarah',
          'surahNameArabic': 'البقرة',
          'verseNumber': '10',
          'verseText': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
          'dateAdded': DateTime.now().subtract(Duration(days: 2)),
          'surahIndex': 1,
          'pageIndex': 9,
        },
      ];
    });
  }

  void _removeBookmark(int index) {
    setState(() {
      bookmarks.removeAt(index);
    });
    // TODO: Save to storage
  }

  void _navigateToVerse(Map<String, dynamic> bookmark) {
    Navigator.of(context).pushNamed('/baca', arguments: {
      'number': bookmark['surahNumber'],
      'name': bookmark['surahName'],
      'name_arab': bookmark['surahNameArabic'],
      'verseNumber': bookmark['verseNumber'],
      'surahIndex': bookmark['surahIndex'],
      'pageIndex': bookmark['pageIndex'],
    });
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
            child: bookmarks.isEmpty
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
                          'No bookmarks yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Bookmark verses while reading to see them here',
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
                                            '${bookmark['surahName']} (${bookmark['surahNameArabic']})',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(255, 52, 21, 104),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Halaman ${bookmark['verseNumber']}',
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
                                  'Added ${_formatDate(bookmark['dateAdded'])}',
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
