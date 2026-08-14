import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'theme_helper.dart';

/// `h1`-`h6` styles for article HTML.
///
/// The app deliberately uses one font throughout, so headings name
/// [ThemeHelper.bodyFontFamily] explicitly rather than a separate display
/// face. Naming it here rather than leaving it to inherit keeps headings from
/// drifting onto the platform default if a caller ever styles them further.
///
/// [textColor] is the colour the calling page already uses for HTML text
/// (null means "inherit", which is what the light theme wants).
Map<String, Style> articleHeadingStyles(Color? textColor) {
  return <String, Style>{
    for (final tag in const ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'])
      tag: Style(
        color: textColor,
        fontFamily: ThemeHelper.bodyFontFamily,
        fontWeight: FontWeight.bold,
      ),
  };
}
