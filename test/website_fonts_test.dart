import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:celik_tafsir/utils/article_heading_styles.dart';
import 'package:celik_tafsir/utils/theme_helper.dart';

/// A reader reported the app's text looked different from celiktafsir.net and
/// was harder to read. The app bundled no font at all, so it fell back to the
/// platform default. These tests pin the app to the website's body face,
/// Arimo, used throughout -- the owner asked for a single font.
void main() {
  test('both themes use the website font everywhere', () {
    for (final theme in ['Terang', 'Gelap']) {
      final data = ThemeHelper.getThemeData(theme);
      expect(
        data.textTheme.bodyMedium?.fontFamily,
        'Arimo',
        reason: '$theme theme lost the body font',
      );
      // AppBarTheme.titleTextStyle is not part of textTheme, so
      // ThemeData.fontFamily does NOT reach it. Leaving it unset silently
      // drops app bar titles back onto the platform default font.
      expect(
        data.appBarTheme.titleTextStyle?.fontFamily,
        'Arimo',
        reason: '$theme theme app bar titles fell off the app font',
      );
    }
  });

  testWidgets('article body text inherits the font through DefaultTextStyle', (
    tester,
  ) async {
    // flutter_html seeds its root style from DefaultTextStyle rather than from
    // Theme, so this inheritance path is what actually carries the font into
    // article paragraphs. If it breaks, articles silently go back to Roboto.
    late TextStyle inherited;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeHelper.getThemeData('Terang'),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              inherited = DefaultTextStyle.of(context).style;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(inherited.fontFamily, 'Arimo');
  });

  test('article headings use the same single font', () {
    final styles = articleHeadingStyles(null);

    expect(styles.keys, containsAll(['h1', 'h2', 'h3', 'h4', 'h5', 'h6']));
    for (final entry in styles.entries) {
      expect(
        entry.value.fontFamily,
        'Arimo',
        reason: '${entry.key} drifted off the single app font',
      );
      expect(entry.value.fontWeight, FontWeight.bold);
    }
  });

  test('headings keep the colour the calling page asked for', () {
    expect(articleHeadingStyles(Colors.white)['h2']?.color, Colors.white);
    expect(articleHeadingStyles(null)['h2']?.color, isNull);
  });

  test('every font file declared in pubspec.yaml exists', () {
    // A mistyped asset path does not fail the build -- Flutter just falls back
    // to the default font, which is the exact bug being fixed here.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final fontsSection = pubspec.substring(pubspec.indexOf('\n  fonts:'));
    // Anchored to line start so the commented-out examples further down the
    // generated pubspec ("# - asset: fonts/Schyler-Regular.ttf") are skipped.
    final assets = RegExp(r'^\s*- asset: (\S+)', multiLine: true)
        .allMatches(fontsSection)
        .map((m) => m.group(1)!)
        .toList();

    expect(assets, isNotEmpty, reason: 'no fonts declared in pubspec.yaml');
    expect(
      assets.where((a) => a.contains('Arimo')).length,
      3,
      reason: 'expected Arimo regular, bold and italic',
    );

    for (final asset in assets) {
      expect(
        File(asset).existsSync(),
        isTrue,
        reason: '$asset is declared in pubspec.yaml but missing on disk',
      );
    }
  });
}
