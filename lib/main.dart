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
import 'utils/theme_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentTheme = 'Light';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final theme = await ThemeHelper.getThemeName();
    if (mounted) {
      setState(() {
        _currentTheme = theme;
        _isLoading = false;
      });
    }
  }

  void _updateTheme(String newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Celik Tafsir',
      theme: ThemeHelper.getThemeData(_currentTheme),
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
            page = SettingsPage(onThemeChanged: _updateTheme);
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

