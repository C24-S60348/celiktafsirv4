import 'package:flutter/material.dart';
import '../utils/uihelper.dart';
import '../models/tadabburmodel.dart' as model;

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
          .where((surah) =>
              surah['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilihan Surah', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Surah...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  _filterSurahs(value);
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/bismillah.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSurahList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      surahButton(
                        context,
                        filteredSurahList[index]['number']!,
                        filteredSurahList[index]['name']!,
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
    );
  }
}
