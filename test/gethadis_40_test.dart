import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:celik_tafsir/services/gethadis_40.dart';

import 'support/fake_http.dart';

/// Hadis 40 used to return three hardcoded articles and could never show
/// more. It now scrapes its category, with the hardcoded three kept only as
/// a fallback so a wrong/unreachable category cannot make things worse.
void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  String categoryPage(String links) =>
      '<html><body><div class="posts">$links</div></body></html>';

  testWidgets('lists every hadis post found in the category', (tester) async {
    HttpOverrides.global = FakeHttpOverrides(
      categoryPage('''
        <a href="https://celiktafsir.net/2025/12/31/syarah-hadis-25-hadis-40-imam-nawawi/">HADIS #25 Sedekah dari Orang Miskin</a>
        <a href="https://celiktafsir.net/2026/01/07/syarah-hadis-26-hadis-40/">HADIS #26 Setiap Sendi Mesti Bersedekah</a>
        <a href="https://celiktafsir.net/2026/02/02/syarah-hadis-27-hadis-40/">HADIS #27 Mintalah Fatwa kepada Hatimu</a>
        <a href="https://celiktafsir.net/2026/03/09/syarah-hadis-28-hadis-40/">HADIS #28 Berpegang kepada Sunnah</a>
      '''),
    );

    final posts = await GetHadis40.getHadis40Posts();

    // The point of the fix: a fourth article now shows up on its own.
    expect(posts, hasLength(4));
    expect(posts.last['title'], 'HADIS #28 Berpegang kepada Sunnah');
    expect(
      posts.last['url'],
      'https://celiktafsir.net/2026/03/09/syarah-hadis-28-hadis-40/',
    );
  });

  testWidgets('sorts chronologically regardless of page order', (tester) async {
    HttpOverrides.global = FakeHttpOverrides(
      categoryPage('''
        <a href="https://celiktafsir.net/2026/02/02/syarah-hadis-27-hadis-40/">HADIS #27</a>
        <a href="https://celiktafsir.net/2025/12/31/syarah-hadis-25-hadis-40/">HADIS #25</a>
        <a href="https://celiktafsir.net/2026/01/07/syarah-hadis-26-hadis-40/">HADIS #26</a>
      '''),
    );

    final posts = await GetHadis40.getHadis40Posts();

    expect(
      posts.map((p) => p['title']).toList(),
      ['HADIS #25', 'HADIS #26', 'HADIS #27'],
    );
  });

  testWidgets('ignores non-hadis posts in the category', (tester) async {
    HttpOverrides.global = FakeHttpOverrides(
      categoryPage('''
        <a href="https://celiktafsir.net/2026/01/07/syarah-hadis-26-hadis-40/">HADIS #26</a>
        <a href="https://celiktafsir.net/2026/01/08/tafsir-surah-baqarah-ayat-3/">Tafsir Baqarah</a>
        <a href="https://celiktafsir.net/category/hadis-40/">Kategori</a>
      '''),
    );

    final posts = await GetHadis40.getHadis40Posts();

    expect(posts, hasLength(1));
    expect(posts.single['title'], 'HADIS #26');
  });

  testWidgets('recovers the hadis number kept outside the link', (
    tester,
  ) async {
    // Shape of the real listing page: the number lives in a sibling <span>,
    // so the anchor text on its own would drop it.
    HttpOverrides.global = FakeHttpOverrides(
      categoryPage('''
        <p><span style="color: #ff0000"><strong>HADIS #25<br /></strong></span><a href="https://celiktafsir.net/2025/12/31/syarah-hadis-25-hadis-40-imam-nawawi/">Sedekah dari Orang Miskin</a></p>
        <p><strong><span style="color: #ff0000">HADIS #29</span><br /></strong><a href="https://celiktafsir.net/2026/03/03/syarah-hadis-29-hadis-40-imam-nawawi/">Pintu-pintu Kebaikan</a></p>
      '''),
    );

    final posts = await GetHadis40.getHadis40Posts();

    expect(
      posts.map((p) => p['title']).toList(),
      ['HADIS #25 Sedekah dari Orang Miskin', 'HADIS #29 Pintu-pintu Kebaikan'],
    );
  });

  testWidgets('does not borrow a number from a shared container', (
    tester,
  ) async {
    // Several links under one heading: the number describes none of them.
    HttpOverrides.global = FakeHttpOverrides(
      categoryPage('''
        <p><strong>HADIS #25</strong>
          <a href="https://celiktafsir.net/2026/01/07/syarah-hadis-26-hadis-40/">Setiap Sendi Mesti Bersedekah</a>
          <a href="https://celiktafsir.net/2026/02/02/syarah-hadis-27-hadis-40/">Mintalah Fatwa kepada Hatimu</a>
        </p>
      '''),
    );

    final posts = await GetHadis40.getHadis40Posts();

    expect(
      posts.map((p) => p['title']).toList(),
      ['Setiap Sendi Mesti Bersedekah', 'Mintalah Fatwa kepada Hatimu'],
    );
  });

  testWidgets('falls back to the known articles when the category is empty', (
    tester,
  ) async {
    // A wrong or emptied category must not leave the section blank.
    HttpOverrides.global = FakeHttpOverrides(
      categoryPage('<a href="https://celiktafsir.net/about/">Tentang</a>'),
    );

    final posts = await GetHadis40.getHadis40Posts();

    expect(posts, hasLength(3));
    expect(posts.first['title'], 'HADIS #25 Sedekah dari Orang Miskin');
  });
}
