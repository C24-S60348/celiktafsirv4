import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Builds the link a reader sends to someone else, and opens the share sheet.
///
/// The link points at a small page on our own site rather than straight at the
/// article, because it has to serve four different people: someone with the
/// app on Android, someone without it on Android, someone on an iPhone, and
/// someone at a desktop. The page sorts that out; see `web/buka/index.html`.
///
/// Firebase Dynamic Links used to do this and was shut down in August 2025,
/// so the redirect is ours to host.
class ShareArticle {
  static const String _smartLinkBase = 'https://celiktafsir.web.app/buka/';

  /// The shareable link for [articleUrl] (an article on celiktafsir.net).
  static String linkFor(String? articleUrl) {
    if (articleUrl == null || articleUrl.isEmpty) return _smartLinkBase;
    return '$_smartLinkBase?u=${Uri.encodeQueryComponent(articleUrl)}';
  }

  /// Opens the platform share sheet with [title] and the smart link.
  ///
  /// [origin] positions the sheet on iPad, where it is a popover anchored to
  /// the widget that opened it; without it iPadOS throws.
  static Future<void> share({
    required BuildContext context,
    required String? articleUrl,
    String? title,
  }) async {
    final link = linkFor(articleUrl);
    final heading = (title == null || title.trim().isEmpty)
        ? 'Celik Tafsir'
        : title.trim();
    final box = context.findRenderObject() as RenderBox?;

    await SharePlus.instance.share(
      ShareParams(
        text: '$heading\n\n$link',
        subject: heading,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }
}
