import 'package:flutter/material.dart';
import 'views/splashscreen.dart';
import 'views/tutorial.dart';
import 'views/mainpage.dart';
import 'views/tadabbur.dart';
import 'views/information.dart';
import 'views/baca.dart';
import 'views/bookmarks.dart';
import 'views/websitepage.dart';
import 'views/settings.dart';
import 'views/surah_pages.dart';
import 'utils/uihelper.dart';

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
      onGenerateRoute: (settings) {
        Widget page;
        
        switch (settings.name) {
          case '/tutorial':
            page = Tutorial();
            break;
          case '/mainpage':
            page = MainPage();
            break;
          case '/tadabbur':
            page = TadabburPage();
            break;
          case '/info':
            page = InformationPage();
            break;
          case '/surahPages':
            page = SurahPagesPage();
            break;
          case '/baca':
            page = BacaPage();
            break;
          case '/bookmarks':
            page = BookmarksPage();
            break;
          case '/websitepage':
            page = WebsitePage();
            break;
          case '/settings':
            page = SettingsPage();
            break;
          default:
            page = SplashScreen();
        }
        
        return slideRoute(page, arguments: settings.arguments);
      },
      // home: Tutorial(),
      home: SplashScreen(),
    );
  }
}

