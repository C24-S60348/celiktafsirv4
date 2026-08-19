import 'package:flutter/material.dart';

/// Wraps a reading page so a horizontal swipe changes article/page, the same
/// gesture the main page already gives via its `PageView`.
///
/// Swipe right-to-left (the reader pulls the next page in) calls [onNext];
/// left-to-right calls [onPrevious]. A null callback means there is nothing in
/// that direction and the swipe is ignored — the same rule the chevrons in
/// `ArticleReadTopNav` use to grey themselves out, so gesture and buttons can
/// never disagree.
///
/// Put this around the whole `CustomScrollView`: vertical drags still reach the
/// scroll view, only horizontal ones are claimed here.
class ArticleSwipeNavigator extends StatelessWidget {
  const ArticleSwipeNavigator({
    super.key,
    required this.child,
    this.onPrevious,
    this.onNext,
  });

  final Widget child;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  /// Minimum fling speed (logical px/s) before a drag counts as a page change.
  /// Low enough for a relaxed thumb flick, high enough that the slight sideways
  /// drift of a vertical scroll does not throw the reader into another article.
  static const double minVelocity = 250;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Translucent so taps still reach links, images and buttons underneath;
      // only the horizontal drag is handled here.
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity <= -minVelocity) {
          onNext?.call();
        } else if (velocity >= minVelocity) {
          onPrevious?.call();
        }
      },
      child: child,
    );
  }
}
