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
      shadowColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Celik Tafsir', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
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
                        child: SizedBox(),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: buttonstyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/bookmarks');
                        },
                        child: SizedBox(),
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
                        child: SizedBox(),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: buttonstyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/info');
                        },
                        child: SizedBox(),
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
