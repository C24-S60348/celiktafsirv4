import 'package:flutter/material.dart';

Widget surahButton(BuildContext context, String nombor, String surah, String suraharab, Function() onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/images/nomborplace.png', fit: BoxFit.contain, width: MediaQuery.of(context).size.width * 0.15,),
            Text(nombor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/images/surahplace.png', fit: BoxFit.contain, width: MediaQuery.of(context).size.width * 0.7,),
            Column(
              children: [
                Text(surah, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                Text(suraharab, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildSearchField(Function(String) onSearch) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari Surah...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
        ),
        onChanged: (value) {
          onSearch(value);
        },
      ),
    );
}