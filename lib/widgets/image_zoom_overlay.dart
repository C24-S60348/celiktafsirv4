import 'package:flutter/material.dart';

/// Shows a full-screen zoomable image with back button support (Android back button,
/// iOS back navigation / close button, tap background, or drag/close).
/// Uses [showDialog] so it registers as a route on the Navigator stack.
void showImageZoomOverlay(
  BuildContext context,
  String imageUrl, {
  bool isDark = false,
}) {
  showDialog<void>(
    context: context,
    useSafeArea: false,
    barrierDismissible: true,
    barrierColor: Colors.black,
    builder: (BuildContext dialogContext) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
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
                      return const Center(
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
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    tooltip: 'Kembali',
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    tooltip: 'Tutup',
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

