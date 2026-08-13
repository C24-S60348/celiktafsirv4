import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows the "Open Website" confirmation for [url] on top of the current page.
///
/// Deliberately an OverlayEntry rather than a pushed route or a dialog: the
/// reading page stays mounted underneath, so dismissing this never pops the
/// article and never triggers a refetch of its content.
void showOpenWebsiteOverlay(BuildContext context, String url) {
  if (url.isEmpty) return;
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Open Website',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                url,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      entry.remove();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      entry.remove();
                      launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: const Text('Open'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
}

/// Shared TagExtension for HTML <a> links:
/// - Shows an "Open Website" overlay (no Navigator.pop, so page doesn't refresh)
/// - Opens the link via url_launcher in an external browser/app
TagExtension buildLinkTagExtension(bool isDark) {
  return TagExtension(
    tagsToExtend: {'a'},
    builder: (extensionContext) {
      final href = extensionContext.attributes['href'];
      final text = extensionContext.element?.text ?? href ?? '';

      return GestureDetector(
        onTap: () {
          if (href == null || href.isEmpty) return;

          final ctx = extensionContext.buildContext;
          if (ctx == null) return;

          showOpenWebsiteOverlay(ctx, href);
        },
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0000EE),
            decoration: TextDecoration.underline,
          ),
        ),
      );
    },
  );
}
