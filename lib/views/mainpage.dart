import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: Text('Celik Tafsir', style: TextStyle(color: Colors.white),),
      //   centerTitle: true,
      //   automaticallyImplyLeading: false, // Disables back button
      //   backgroundColor: Colors.black,
      // ),
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image.asset(
            //   'assets/images/bg.jpg',
            //   fit: BoxFit.cover,
            //   width: double.infinity,
            //   height: double.infinity,
            // ),
            Image.asset(
              'assets/images/Kandungan.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
            // Button to navigate to Kandungan 2 page (top right)
            Positioned(
              top: 40,
              right: 16,
              child: SafeArea(
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () {
                    // Navigate to mainpage2 with slide transition
                    Navigator.of(context).pushNamed('/mainpage2');
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    shadowColor: Colors.black,
                    elevation: 5,
                  ),
                ),
              ),
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
                          Navigator.of(context).pushNamed('/settings');
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
