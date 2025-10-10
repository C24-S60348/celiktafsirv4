import 'package:flutter/material.dart';
import '../utils/uihelper.dart';
import '../models/tadabbur.dart' as model;

class TadabburPage extends StatefulWidget {
  @override
  _TadabburPageState createState() => _TadabburPageState();
}

class _TadabburPageState extends State<TadabburPage> {
  final List<Map<String, String>> surahList = model.surahList;

  List<Map<String, String>> filteredSurahList = [];

  @override
  void initState() {
    super.initState();
    filteredSurahList = surahList;
  }

  void _filterSurahs(String query) {
    setState(() {
      filteredSurahList = surahList
          .where(
            (surah) =>
                surah['name']!.toLowerCase().contains(query.toLowerCase()) ||
                surah['name_arab']!.toLowerCase().contains(query.toLowerCase()),
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
            child: Column(
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
                      return Column(
                        children: [
                          model.surahButton(
                            context,
                            filteredSurahList[index]['number']!,
                            filteredSurahList[index]['name']!,
                            filteredSurahList[index]['name_arab']!,
                            () {},
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
