import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:celik_tafsir/widgets/article_read_top_nav.dart';

void main() {
  Widget host({
    required int currentIndex,
    required int total,
    VoidCallback? onPrevious,
    VoidCallback? onNext,
    String label = 'Artikel',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ArticleReadTopNav(
          currentIndex: currentIndex,
          total: total,
          onPrevious: onPrevious,
          onNext: onNext,
          themeName: 'Terang',
          label: label,
        ),
      ),
    );
  }

  testWidgets('shows the 1-based position within the total', (tester) async {
    await tester.pumpWidget(host(currentIndex: 1, total: 3));
    expect(find.text('Artikel 2 / 3'), findsOneWidget);
  });

  testWidgets('falls back to the bare position when the total is unknown', (
    tester,
  ) async {
    await tester.pumpWidget(host(currentIndex: 0, total: 0, label: 'Halaman'));
    expect(find.text('Halaman 1'), findsOneWidget);
  });

  testWidgets('previous is disabled on the first article', (tester) async {
    await tester.pumpWidget(host(currentIndex: 0, total: 3, onNext: () {}));

    final prev = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_left),
    );
    expect(prev.onPressed, isNull);

    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );
    expect(next.onPressed, isNotNull);
  });

  testWidgets('next is disabled on the last article', (tester) async {
    await tester.pumpWidget(host(currentIndex: 2, total: 3, onPrevious: () {}));

    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );
    expect(next.onPressed, isNull);
  });

  testWidgets('the arrows fire their callbacks', (tester) async {
    var previous = 0;
    var next = 0;

    await tester.pumpWidget(
      host(
        currentIndex: 1,
        total: 3,
        onPrevious: () => previous++,
        onNext: () => next++,
      ),
    );

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();

    expect(previous, 1);
    expect(next, 1);
  });

  testWidgets('fits the height it advertises to SliverAppBar.bottom', (
    tester,
  ) async {
    const nav = ArticleReadTopNav(
      currentIndex: 0,
      total: 3,
      themeName: 'Terang',
    );
    expect(nav.preferredSize.height, 44);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: nav)));
    expect(tester.getSize(find.byType(ArticleReadTopNav)).height, 44);
  });
}
