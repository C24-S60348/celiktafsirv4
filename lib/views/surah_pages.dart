import 'package:flutter/material.dart';
import '../services/getlistsurah.dart' as getlist;

class SurahPagesPage extends StatefulWidget {
  @override
  _SurahPagesPageState createState() => _SurahPagesPageState();
}

class _SurahPagesPageState extends State<SurahPagesPage> {
  late Map<String, String> surahData;
  int surahIndex = 0;
  List<Map<String, dynamic>> pages = [];
  bool isLoading = true;

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
        _loadPages();
      }
    }
  }

  void _loadPages() async {
    final surah = await getlist.GetListSurah.getSurahByIndex(surahIndex);
    if (surah != null) {
      final urls = surah['urls'] as List<String>;
      final List<Map<String, dynamic>> pageList = [];

      for (int i = 0; i < urls.length; i++) {
        final url = urls[i];
        final title = _extractTitleFromUrl(url);
        pageList.add({
          'index': i,
          'title': title,
          'url': url,
        });
      }

      setState(() {
        pages = pageList;
        isLoading = false;
      });
    }
  }

  String _extractTitleFromUrl(String url) {
    try {
      // Extract the last part of the URL (after the last /)
      final parts = url.split('/');
      // Filter out empty strings and get the last non-empty part
      final nonEmptyParts = parts.where((p) => p.isNotEmpty).toList();
      if (nonEmptyParts.isNotEmpty) {
        String title = nonEmptyParts.last;
        
        // Split by hyphens
        List<String> segments = title.split('-');
        
        // Process segments and join with spaces, but preserve hyphens between numbers
        List<String> processedSegments = [];
        for (int i = 0; i < segments.length; i++) {
          String segment = segments[i].trim();
          if (segment.isEmpty) continue;
          
          // Expand abbreviations
          if (segment.toLowerCase() == 'bah') {
            segment = 'bahagian';
          }
          
          // Capitalize first letter, rest lowercase
          if (segment.isNotEmpty) {
            segment = segment[0].toUpperCase() + segment.substring(1).toLowerCase();
          }
          
          processedSegments.add(segment);
          
          // If current and next segments are both numbers, add hyphen instead of space
          if (i < segments.length - 1) {
            String nextSegment = segments[i + 1].trim();
            if (_isNumeric(segment) && _isNumeric(nextSegment)) {
              processedSegments.add('-');
            } else {
              processedSegments.add(' ');
            }
          }
        }
        
        title = processedSegments.join('');
        
        // Clean up multiple spaces
        title = title.replaceAll(RegExp(r'\s+'), ' ');
        
        
        return title.trim();
      }
    } catch (e) {
      print('Error extracting title: $e');
    }
    
    // Fallback: return page number
    return 'Halaman ${pages.length + 1}';
  }
  
  bool _isNumeric(String str) {
    if (str.isEmpty) return false;
    return RegExp(r'^\d+$').hasMatch(str);
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
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Jumlah: ${pages.length} halaman',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white),
                SizedBox(height: 10),

                // Pages list
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 52, 21, 104),
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
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Color.fromARGB(255, 52, 21, 104),
                                  child: Text(
                                    '${page['index'] + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  page['title'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'Halaman ${page['index'] + 1}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.of(context).pushNamed('/baca', arguments: {
                                    ...surahData,
                                    'surahIndex': surahIndex,
                                    'pageIndex': page['index'],
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
      ),
    );
  }
}

