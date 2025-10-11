import 'package:flutter/material.dart';

Widget buildPageIndicator(int currentPage, int totalPages, Function() onPrevious, Function() onNext) {
  return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: currentPage > 1 ? onPrevious : null,
                        icon: Icon(Icons.arrow_back),
                        label: Text('Sebelum'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: currentPage < totalPages ? onNext : null,
                        icon: Icon(Icons.arrow_forward),
                        label: Text('Selepas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
}

Widget buildSurahBody(BuildContext context, Map<String, String> surahData, Widget bodyContent) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Surah header
        Center(
          child: Column(
            children: [
              Text(
                'Surah ${surahData['name']}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                surahData['name_arab']!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/images/bismillah.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.6,
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        
        // Content placeholder
        bodyContent,
      ],
    );
}