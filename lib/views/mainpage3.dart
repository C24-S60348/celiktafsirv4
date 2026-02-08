import 'package:flutter/material.dart';
import '../utils/uihelper.dart';

class MainPage3 extends StatefulWidget {
  const MainPage3({super.key});

  @override
  _MainPage3State createState() => _MainPage3State();
}

class _MainPage3State extends State<MainPage3> {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate button size to match the background image buttons
    // Using EXACT same values as mainpage and mainpage2 for consistency
    var buttonSize = Size(screenWidth * 0.36, screenHeight * 0.27);
    var buttonStyle = ElevatedButton.styleFrom(
      minimumSize: buttonSize,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: mainPageSwipeWrapper(
        context: context,
        onSwipeDown: () => Navigator.of(context).pop(),
        child: Container(
        color: Colors.black,
        height: screenHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image - Kandungan 3.png
            Image.asset(
              'assets/images/Kandungan 3.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
            // 4 Clickable boxes positioned over the image
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.22), // Top spacing - SAME as mainpage and mainpage2
                  // First row - 2 boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // First button (top-left)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          // Add navigation here when needed
                          Navigator.of(context).pushNamed('/hadis-40');
                        },
                        child: SizedBox(),
                      ),
                      SizedBox(width: screenWidth * 0.04), // Spacing - SAME as mainpage and mainpage2
                      // Second button (top-right)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          // La Tahzan (Jangan Bersedih)
                          Navigator.of(context).pushNamed('/laa-tahzan');
                        },
                        child: SizedBox(),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015), // Spacing - SAME as mainpage and mainpage2
                  // Second row - 2 boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Third button (bottom-left)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          // Add navigation here when needed
                          // Navigator.of(context).pushNamed('/some-route');
                        },
                        child: SizedBox(),
                      ),
                      SizedBox(width: screenWidth * 0.04), // Spacing - SAME as mainpage and mainpage2
                      // Fourth button (bottom-right)
                      ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          // Add navigation here when needed
                          // Navigator.of(context).pushNamed('/some-route');
                        },
                        child: SizedBox(),
                      ),
                    ],
                  ),
                  // Hidden "Bacaan Terakhir" placeholder to match mainpage layout and centering
                  SizedBox(height: screenHeight * 0.04),
                  // Invisible placeholder with same height as "Bacaan Terakhir" in mainpage
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.015,
                    ),
                    constraints: BoxConstraints(
                      minHeight: screenHeight * 0.095 * 0.85,
                      maxHeight: screenHeight * 0.095,
                    ),
                    color: Colors.transparent, // Invisible
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
