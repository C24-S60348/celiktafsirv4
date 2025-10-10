
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


