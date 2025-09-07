import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var buttonsize = Size(150, 200);
    var buttonstyle = ElevatedButton.styleFrom(
      minimumSize: buttonsize,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Celik Tafsir'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/Kandungan.png', 
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 65),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: buttonstyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/tadabbur');
                        },
                        child: Text('Tadabbur'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: buttonstyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/bookmarks');
                        },
                        child: Text('Bookmarks'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: buttonstyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/tetapan');
                        },
                        child: Text('Tetapan'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: buttonstyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/info');
                        },
                        child: Text('Info'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
