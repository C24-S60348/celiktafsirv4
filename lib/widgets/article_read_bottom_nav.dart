import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';

/// Bottom nav row: Sebelum | Artikel X dari Y | Selepas.
/// Uses theme color (ThemeHelper.getAppBarColor) so one place controls color.
/// Used by Hujjah and Asmaul Husna read pages; only shown when user scrolls to end.
class ArticleReadBottomNav extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String themeName;
  final Color textColor;
  final String label; // e.g. 'Artikel' or 'Halaman'
  /// Tap target on the position text itself, e.g. to open a "go to page"
  /// dialog. Null (the default) leaves the label a plain, unstyled text.
  final VoidCallback? onTapPosition;

  const ArticleReadBottomNav({
    super.key,
    required this.currentIndex,
    required this.total,
    this.onPrevious,
    this.onNext,
    required this.themeName,
    required this.textColor,
    this.label = 'Artikel',
    this.onTapPosition,
  });

  static Color buttonColor(String themeName) => ThemeHelper.getAppBarColor(themeName);

  @override
  Widget build(BuildContext context) {
    final buttonColor = ThemeHelper.getAppBarColor(themeName);
    final text = total == 0
        ? '$label ${currentIndex + 1}'
        : '$label ${currentIndex + 1} dari $total';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8, 16, 8, 16 + MediaQuery.of(context).padding.bottom),
      color: ThemeHelper.getContentBackgroundColor(themeName),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: currentIndex > 0 ? onPrevious : null,
            icon: const Icon(Icons.arrow_back),
            label: Text('Sebelum'),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.black,
            ),
          ),
          onTapPosition == null
              ? Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                )
              : InkWell(
                  onTap: onTapPosition,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.unfold_more, size: 16, color: textColor),
                      ],
                    ),
                  ),
                ),
          ElevatedButton.icon(
            onPressed: currentIndex < total - 1 ? onNext : null,
            icon: const Icon(Icons.arrow_forward),
            label: Text('Selepas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
