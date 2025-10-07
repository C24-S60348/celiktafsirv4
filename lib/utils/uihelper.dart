
import 'package:flutter/material.dart';

Widget myButton(BuildContext context, String text, Function() onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
    ),
    onPressed: () {
      //pushNamedAndRemoveUntil untuk menghapus semua route sebelumnya dan menampilkan route home
      //pushReplacementNamed untuk menghapus route sebelumnya dan menampilkan route home
      onPressed();
    },
    child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),),
  );
}

Widget surahButton(BuildContext context, String nombor, String surah, Function() onPressed) {
  return Row(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/nomborplace.png', fit: BoxFit.contain, width: 100,),
          Text(nombor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
      Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/surahplace.png', fit: BoxFit.contain, width: 100,),
          Text(surah, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    ],
  );
}
