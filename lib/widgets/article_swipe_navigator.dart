import 'package:flutter/material.dart';

/// Wraps a reading page without claiming horizontal gestures.
///
/// Navigation remains available through the reader's on-screen controls. This
/// wrapper deliberately leaves swipes untouched so an accidental sideways
/// movement cannot switch articles or pages while reading.
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

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
