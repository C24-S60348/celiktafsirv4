import 'package:flutter/material.dart';
import 'views/splashscreen.dart';
import 'views/tutorial.dart';
import 'views/mainpage.dart';
import 'views/tadabbur.dart';
import 'views/information.dart';

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
        '/tutorial': (context) => Tutorial(),
        '/mainpage': (context) => MainPage(),
        '/tadabbur': (context) => TadabburPage(),
        '/info': (context) => InformationPage(),
      },
      // home: Tutorial(),
      home: SplashScreen(),
    );
  }
}

