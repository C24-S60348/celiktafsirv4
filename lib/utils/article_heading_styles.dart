import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'theme_helper.dart';

/// `h1`-`h6` styles for article HTML, in the same face celiktafsir.net sets
/// on its own headings (`.wf-active h1..h6 { font-family: "Alegreya" }`).
///
/// Body text does not need an entry here: `flutter_html` seeds its root style
/// from `DefaultTextStyle`, which `Material` fills from the theme, so
/// `ThemeData.fontFamily` already carries [ThemeHelper.bodyFontFamily] into
/// article paragraphs. Headings are the one part the theme cannot reach,
/// because each reading page overrides them to force bold.
///
/// [textColor] is the colour the calling page already uses for HTML text
/// (null means "inherit", which is what the light theme wants).
Map<String, Style> articleHeadingStyles(Color? textColor) {
  return <String, Style>{
    for (final tag in const ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'])
      tag: Style(
        color: textColor,
        fontFamily: ThemeHelper.headingFontFamily,
        fontWeight: FontWeight.bold,
      ),
  };
}
