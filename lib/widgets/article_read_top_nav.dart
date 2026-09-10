import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';

/// Compact previous/next row shown directly under the reading page's title.
///
/// Designed to sit in `SliverAppBar.bottom`, so it inherits the app bar's
/// floating/snap behaviour: it slides away as soon as the reader scrolls down
/// into the article and comes back when they scroll up. Page position is
/// still spelled out in full by [ArticleReadBottomNav] at the end of the page.
class ArticleReadTopNav extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String themeName;
  final String label; // e.g. 'Artikel' or 'Halaman'
  /// Tap target on the position text itself, e.g. to open a "go to page"
  /// dialog. Null (the default) leaves the label a plain, unstyled text.
  final VoidCallback? onTapPosition;

  const ArticleReadTopNav({
    super.key,
    required this.currentIndex,
    required this.total,
    this.onPrevious,
    this.onNext,
    required this.themeName,
    this.label = 'Artikel',
    this.onTapPosition,
  });

  static const double _height = 44;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final isDark = themeName == 'Gelap';
    final foreground = isDark ? Colors.white : Colors.black;
    final disabled = foreground.withValues(alpha: 0.35);

    final text = total == 0
        ? '$label ${currentIndex + 1}'
        : '$label ${currentIndex + 1} / $total';

    return SizedBox(
      height: _height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            tooltip: 'Sebelum',
            icon: const Icon(Icons.chevron_left),
            color: foreground,
            disabledColor: disabled,
          ),
          Flexible(
            child: onTapPosition == null
                ? Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  )
                : InkWell(
                    onTap: onTapPosition,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              text,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: foreground,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.unfold_more, size: 14, color: foreground),
                        ],
                      ),
                    ),
                  ),
          ),
          IconButton(
            onPressed: onNext,
            tooltip: 'Selepas',
            icon: const Icon(Icons.chevron_right),
            color: foreground,
            disabledColor: disabled,
          ),
        ],
      ),
    );
  }
}

/// Background colour for the top nav strip, matching the app bar so the
/// strip reads as part of it rather than as a separate band.
Color articleReadTopNavColor(String themeName) =>
    ThemeHelper.getAppBarColor(themeName);
