import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/uihelper.dart';

class InformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informasi', style: TextStyle(color: Colors.white)),
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
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mengenai Aplikasi',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),

                    Divider(color: Colors.white),
                    
                    Text(
                      'Qur\'an adalah bicara Allah ‎ﷻ buat hamba-hambaNya. Kita sebagai hamba amat dahagakan panduan daripadaNya dan tercari-cari cara yang paling praktikal untuk mendalami serta mendekatiNya.\n\n'
                      'Celiktafsir Apps ini dibangunkan dengan harapan dapat membantu pengguna di luar sana yang mencari tafsir Qur\'an dengan gaya bahasa santai serta lebih dekat dengan permasalahan seharian kita. Dengan penggunaan teknologi terkini, apps sebegini dapat memastikan kita boleh membaca dan menghayati tafsir Qur\'an di mana dan bila-bila masa sahaja.\n\n'
                      'Isi kandungan asal apps ini semuanya berasal daripada halaman web: http://celiktafsir.net\n\n'
                      'Antara features lain Celiktafsir:\n'
                      '▪Boleh dibaca secara Online atau Offline\n'
                      '▪Pelbagai pilihan warna mengikut selera pengguna\n'
                      '▪Bookmark halaman terakhir dibaca\n'
                      '▪Tutorial cara penggunaan apps disediakan\n'
                      '▪Bahasa tafsir yang santai dan bersahaja\n'
                      '▪Loncat dari surah ke surah dengan cepat\n'
                      '▪Boleh copy & paste ayat tafsir.\n\n'
                      'Moga dengan adanya apps, jiwa kita makin terpandu dengan panduan daripada Qur\'an.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 10),
                    Divider(color: Colors.black),
                    SizedBox(height: 10),
                    Text(
                      'Versi: 1.0.4',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Divider(color: Colors.black),
                    SizedBox(height: 10),
                    Text(
                      'Sebarang pertanyaan, saran, sila hubungi: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse('mailto:af1gaming01@gmail.com'));
                      },
                      child: Center(
                        child: Text(
                          'af1gaming01@gmail.com',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 51, 135, 54), decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(color: Colors.black),
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse('https://celiktafsir.net'));
                      },
                      child: Center(
                        child: Text(
                          'celiktafsir.net',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 51, 135, 54), decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: myButtonBlack(context, 'Tutorial', () {
                        Navigator.of(context).pushNamed('/tutorial');
                      },),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
