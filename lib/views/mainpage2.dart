import 'package:flutter/material.dart';

class MainPage2 extends StatefulWidget {
  const MainPage2({super.key});

  @override
  _MainPage2State createState() => _MainPage2State();
}

class _MainPage2State extends State<MainPage2> {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate button size and positions based on typical 2x2 grid layout
    // Adjust these values based on the actual image layout
    var buttonSize = Size(screenWidth * 0.4, screenHeight * 0.25);
    var buttonStyle = ElevatedButton.styleFrom(
      minimumSize: buttonSize,
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
      body: Container(
        color: Colors.black,
        height: screenHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image - Kandungan 2.png
            Image.asset(
              'assets/images/Kandungan 2.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
            // Back button to navigate back to mainpage with slide transition
            Positioned(
              top: 40,
              left: 16,
              child: SafeArea(
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    // Navigate back to mainpage with slide transition
                    // The slide transition will automatically reverse (slide from left to right)
                    Navigator.of(context).pop();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    shape: CircleBorder(),
                  ),
                ),
              ),
            ),
            // 4 Clickable boxes positioned over the image
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.15), // Adjust based on image layout
                  // First row - 2 boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Box 1 - Top Left (Glosari)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/glosari');
                        },
                        child: SizedBox(),
                      ),
                      SizedBox(width: screenWidth * 0.05), // Spacing between boxes
                      // Box 2 - Top Right (Hujjah)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/hujjah');
                        },
                        child: SizedBox(),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02), // Spacing between rows
                  // Second row - 2 boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Box 3 - Bottom Left (Asmaul Husna)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/asmaul-husna');
                        },
                        child: SizedBox(),
                      ),
                      SizedBox(width: screenWidth * 0.05), // Spacing between boxes
                      // Box 4 - Bottom Right (Asal Usul Tafsir)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/asal-usul-tafsir');
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

