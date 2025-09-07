import 'package:flutter/material.dart';
import 'splashscreen.dart';
import 'homepage.dart';
import 'tutorial.dart';
import 'mainpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celik Tafsir',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/home': (context) => MyHomePage(title: 'Celik Tafsir'),
        '/tutorial': (context) => Tutorial(),
        '/mainpage': (context) => MainPage(),
      },
      // home: Tutorial(),
      home: SplashScreen(),
    );
  }
}

