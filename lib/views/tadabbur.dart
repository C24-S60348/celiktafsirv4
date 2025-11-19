import 'package:flutter/material.dart';
import '../models/tadabbur.dart' as model;
import '../services/getlistsurah.dart' as getlist;

class TadabburPage extends StatefulWidget {
  @override
  _TadabburPageState createState() => _TadabburPageState();
}

class _TadabburPageState extends State<TadabburPage> {
  List<Map<String, String>> surahList = [];
  bool isLoading = true;

  List<Map<String, String>> filteredSurahList = [];

  @override
  void initState() {
    super.initState();
    _loadSurahNames();
  }

  void _loadSurahNames() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final names = await getlist.GetListSurah.getSurahNames();
      // Ensure all maps are properly typed as Map<String, String>
      final convertedNames = names.map((item) {
        return Map<String, String>.from(item.map((key, value) => MapEntry(key, value.toString())));
      }).toList();
      
      setState(() {
        surahList = convertedNames;
        filteredSurahList = convertedNames;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading surah names: $e');
      // Fallback to hardcoded list if scraping fails
      // Add additional_text field to fallback list
      final fallbackList = model.surahList.map((item) {
        final Map<String, String> newItem = Map<String, String>.from(item);
        if (!newItem.containsKey('additional_text')) {
          newItem['additional_text'] = '';
        }
        return newItem;
      }).toList();
      
      setState(() {
        surahList = fallbackList;
        filteredSurahList = fallbackList;
        isLoading = false;
      });
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      filteredSurahList = surahList
          .where(
            (surah) =>
                surah['name']!.toLowerCase().contains(query.toLowerCase()) ||
                (surah['additional_text']?.isNotEmpty == true && 
                 surah['additional_text']!.toLowerCase().contains(query.toLowerCase())),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilihan Surah', style: TextStyle(color: Colors.white)),
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
                        Color.fromARGB(255, 52, 21, 104),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      model.buildSearchField(_filterSurahs),
                      SizedBox(height: 20),
                      Center(
                        child: Image.asset(
                          'assets/images/bismillah.png',
                          fit: BoxFit.contain,
                          width: MediaQuery.of(context).size.width * 0.7,
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredSurahList.length,
                          itemBuilder: (context, index) {
                            final filteredSurah = filteredSurahList[index];
                            // Find the actual index in the original surahList
                            // For juzuk variants, we need to find the main surah index
                            final surahNumber = int.parse(filteredSurah['number']!);
                            final actualIndex = surahNumber - 1; // Convert to 0-based index
                            
                            return Column(
                              children: [
                                model.surahButton(
                                  context,
                                  filteredSurah['number']!,
                                  filteredSurah['name']!,
                                  filteredSurah['additional_text'] ?? '',
                                  () {
                                    Navigator.of(context).pushNamed('/surahPages', arguments: {
                                      ...filteredSurah,
                                      'surahIndex': actualIndex,
                                    });
                                  },
                                ),
                                SizedBox(height: 10),
                              ],
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
