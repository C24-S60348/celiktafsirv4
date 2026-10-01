import 'package:flutter/material.dart';

/// Shows a full-screen zoomable image in an OverlayEntry.
///
/// Deliberately an [OverlayEntry] rather than a dialog/route: closing removes
/// ONLY the overlay entry, so the underlying reading page stays mounted,
/// never resets its scroll position, and never refreshes or jumps to top.
///
/// Supports closing via:
/// 1. Top-left back button (`←`) - standard iOS/Android back action.
/// 2. Top-right close button (`✕`).
/// 3. Android hardware/gesture back button (via [BackButtonListener] or [PopScope]).
/// 4. Tap outside the image.
void showImageZoomOverlay(
  BuildContext context,
  String imageUrl, {
  bool isDark = false,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.of(context);
  late OverlayEntry entry;

  void closeOverlay() {
    if (entry.mounted) {
      entry.remove();
    }
  }

  entry = OverlayEntry(
    builder: (BuildContext overlayContext) {
      return BackButtonListener(
        onBackButtonPressed: () async {
          closeOverlay();
          return true; // Handled back press; do not pop underlying route
        },
        child: Material(
          color: Colors.black,
          child: Stack(
            children: [
              GestureDetector(
                onTap: closeOverlay,
                child: SizedBox.expand(
                  child: InteractiveViewer(
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
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      tooltip: 'Kembali',
                      onPressed: closeOverlay,
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
                      onPressed: closeOverlay,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
}


