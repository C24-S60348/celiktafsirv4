import 'package:flutter/material.dart';

/// Shows a full-screen zoomable image in an Overlay. Closing removes only the
/// overlay entry (no Navigator.pop), so the underlying page does not refresh
/// and scroll position is preserved.
void showImageZoomOverlay(BuildContext context, String imageUrl, {bool isDark = false}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (BuildContext overlayContext) {
      return Material(
        color: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
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
                        children: [
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
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  entry.remove();
                },
              ),
            ),
          ],
        ),
      );
    },
  );

  overlay.insert(entry);
}
