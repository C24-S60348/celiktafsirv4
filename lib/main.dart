import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'views/mainpage2.dart';
import 'views/mainpage3.dart';
import 'views/glosari.dart';
import 'views/hujjah.dart';
import 'views/baca_hujjah.dart';
import 'views/asmaul_husna.dart';
import 'views/baca_asmaul_husna.dart';
import 'views/asal_usul_tafsir.dart';
import 'views/baca_asal_usul_tafsir.dart';
import 'views/laa_tahzan.dart';
import 'views/baca_laa_tahzan.dart';
import 'views/hadis_40.dart';
import 'views/baca_hadis_40.dart';
import 'utils/uihelper.dart';
import 'utils/theme_helper.dart';
import 'views/nota_pembaca.dart';
import 'package:app_links/app_links.dart';
import 'utils/deep_link.dart';

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

  /// Lets the deep link handler navigate without a BuildContext from a route.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _listenForSharedLinks();
  }

  /// Opens the article carried by a shared link.
  ///
  /// Covers both ways one arrives: the link that launched a cold start, and
  /// links that arrive while the app is already open.
  Future<void> _listenForSharedLinks() async {
    if (kIsWeb) return; // the web build is already at the URL
    final links = AppLinks();
    try {
      _openIfArticle(await links.getInitialLink());
    } catch (_) {
      // A malformed launch URI must not stop the app from starting.
    }
    _linkSubscription = links.uriLinkStream.listen(
      _openIfArticle,
      onError: (_) {},
    );
  }

  void _openIfArticle(Uri? uri) {
    final articleUrl = DeepLink.articleUrlFrom(uri);
    if (articleUrl == null) return; // not ours, or nothing to open
    // Wait for the navigator: a cold start delivers the link before the first
    // route exists.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.pushNamed(
        '/baca-hujjah',
        arguments: <String, dynamic>{
          'url': articleUrl,
          'title': DeepLink.titleFrom(articleUrl),
          'index': 0,
          'total': 1,
          'items': const <Map<String, dynamic>>[],
        },
      );
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
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
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
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
          case '/nota':
            page = NotaPembacaPage();
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
          case '/mainpage2':
            page = MainPage2();
            break;
          case '/kandungan2':
            page = MainPage2(); // Keep old route for backward compatibility
            break;
          case '/mainpage3':
            page = MainPage3();
            break;
          case '/glosari':
            page = GlosariPage();
            break;
          case '/hujjah':
            page = HujjahPage();
            break;
          case '/baca-hujjah':
            page = BacaHujjahPage();
            break;
          case '/asmaul-husna':
            page = AsmaulHusnaPage();
            break;
          case '/baca-asmaul-husna':
            page = BacaAsmaulHusnaPage();
            break;
          case '/asal-usul-tafsir':
            page = AsalUsulTafsirPage();
            break;
          case '/baca-asal-usul-tafsir':
            page = BacaAsalUsulTafsirPage();
            break;
          case '/laa-tahzan':
            page = LaaTahzanPage();
            break;
          case '/baca-laa-tahzan':
            page = BacaLaaTahzanPage();
            break;
          case '/hadis-40':
            page = Hadis40Page();
            break;
          case '/baca-hadis-40':
            page = BacaHadis40Page();
            break;
          default:
            page = SplashScreen();
        }

        // Main page flow uses vertical slide (swipe up/down); others use horizontal slide
        if (settings.name == '/mainpage2' || settings.name == '/mainpage3') {
          return verticalSlideRoute(page, arguments: settings.arguments);
        }
        return slideRoute(page, arguments: settings.arguments);
      },
      // home: Tutorial(),
      home: SplashScreen(),
    );
  }
}

