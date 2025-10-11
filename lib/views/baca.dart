import 'package:flutter/material.dart';
import '../utils/uihelper.dart';
import '../widgets/baca.dart' as widget;
import '../services/baca.dart' as service;
import '../services/getlistsurah.dart' as getlist;

class BacaPage extends StatefulWidget {
  @override
  _BacaPageState createState() => _BacaPageState();
}

class _BacaPageState extends State<BacaPage> {
  late Map<String, String> surahData;
  int currentPage = 0; // Changed to 0-based indexing
  int totalPages = 1;
  bool isLoading = true;
  int surahIndex = 0; // Add surah index

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      surahData = args.cast<String, String>();
      surahIndex = args['surahIndex'] ?? 0;
      currentPage = args['pageIndex'] ?? 0;
      _loadSurahContent();
    }
  }

  void _loadSurahContent() async {
    final surah = await getlist.GetListSurah.getSurahByIndex(surahIndex);
    if (surah != null) {
      setState(() {
        totalPages = surah['totalPages'];
        isLoading = false;
      });
    }
  }

  void _nextPage() {
    if (currentPage < totalPages - 1) {
      setState(() {
        currentPage++;
      });
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  void getDatasurah(surahindex, pageindex) async {
    final url = await getlist.GetListSurah.getSurahUrl(surahindex, pageindex);
    if (url != null) {
      setState(() {
        surahData['url'] = url;
      });
    }
  }

  Widget bodyContent() {
    return Column(
      children: [
        SizedBox(height: 20),
        
        FutureBuilder<String?>(
          future: getlist.GetListSurah.getSurahUrl(surahIndex, currentPage),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...");
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              return FutureBuilder<String?>(
                future: service.BacaService.fetchContentFromUrl(snapshot.data!, 'entry-content'),
                builder: (context, contentSnapshot) {
                  if (contentSnapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading.....");
                  } else if (contentSnapshot.hasError) {
                    return Text("Error loading content: ${contentSnapshot.error}");
                  } else if (contentSnapshot.hasData) {
                    final cleanText = service.BacaService.parseHtmlToText(contentSnapshot.data!);
                    return Text(
                      cleanText,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    );
                  } else {
                    return Text("No content available");
                  }
                },
              );
            } else {
              return Text("No URL available");
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 52, 21, 104),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            onPressed: () {
              // Bookmark functionality
            },
            icon: Icon(Icons.bookmark_border, color: Colors.white),
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
                  child: Text(
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
                    child: SingleChildScrollView(
                      child: widget.buildSurahBody(context, surahData, bodyContent()),
                    ),
                  ),
                ),
                
                // Navigation buttons
                widget.buildPageIndicator(
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
