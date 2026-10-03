import 'package:flutter/material.dart';

/// Shows a full-screen zoomable image in a transparent ModalRoute.
///
/// Uses [PageRouteBuilder] with `opaque: false` so:
/// 1. Android physical back button & swipe back gesture are automatically handled by Flutter Navigator.
/// 2. The underlying reader page remains mounted underneath and never reloads/resets scroll.
/// 3. Top-left `←` and top-right `✕` buttons close the viewer seamlessly.
void showImageZoomOverlay(
  BuildContext context,
  String imageUrl, {
  bool isDark = false,
}) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black,
      pageBuilder: (
        BuildContext pageContext,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Zoomable image layer
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: SizedBox.expand(
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.deepPurple[300]! : Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.broken_image, size: 64, color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Gagal memuatkan gambar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Top-left Back button
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      tooltip: 'Kembali',
                      onPressed: () {
                        Navigator.of(pageContext).pop();
                      },
                    ),
                  ),
                ),
              ),

              // Top-right Close button
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      tooltip: 'Tutup',
                      onPressed: () {
                        Navigator.of(pageContext).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}



