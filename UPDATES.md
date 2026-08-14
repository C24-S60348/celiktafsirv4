# Celik Tafsir — Updates & Todo

Versi semasa: **1.0.31+31** · Web: https://celiktafsir.web.app

Senarai ini disemak terus dengan kod, bukan dari ingatan.

---

## Sudah siap (Done)

1. **Navigasi kiri-kanan (butang)** — butang `<` `>` di bawah tajuk setiap
   halaman bacaan, supaya pembaca nampak ada page sebelum/selepas.
   (`lib/widgets/article_read_top_nav.dart`)
   **Swipe kiri-kanan di Halaman Utama pun dah jalan** — `PageView`
   3 muka surat grid 2x2, boleh swipe atau tekan anak panah.
   (`lib/views/mainpage.dart`)
2. **Tema tukar ke warna Celik Tafsir** — coklat terang / tan.
   (`lib/utils/theme_helper.dart`)
3. **Ruang bacaan lebih luas** — kandungan penuh lebar skrin.
4. **Bug fix — page tak lagi refresh sendiri bila klik bookmark.**
   (cache kandungan dalam `lib/models/baca.dart`)
5. **Bug fix — butang lebih senang ditekan.**
6. **Appbar hilang bila membaca, keluar balik bila swipe ke atas.**
   Guna `SliverAppBar(floating: true, snap: true)` — butang kiri-kanan
   pun ikut hilang/keluar sekali sebab dia duduk dalam appbar.
7. **Clickable text link** — link dalam artikel boleh tekan, keluar overlay
   "Open Website" untuk sahkan dulu sebelum buka browser.
   (`lib/utils/html_link_helper.dart`)
8. **Saiz font boleh tukar** — Kecil / Sederhana / Besar dalam Settings,
   terpakai pada semua kandungan artikel.
9. **Zoom gambar** — tekan gambar dalam artikel untuk besarkan.
10. **Salin kandungan** ke clipboard dari page bacaan.
11. **Bacaan terakhir + bookmark** disimpan.
12. **Swipe kiri-kanan dalam page bacaan** — enam-enam page `baca_*.dart`
    sekarang boleh ditukar dengan swipe, bukan butang sahaja.
    Swipe kanan-ke-kiri = artikel/halaman seterusnya, kiri-ke-kanan = sebelum.
    Kalau tiada page di arah itu, swipe diabaikan (sama macam butang chevron
    yang jadi kelabu). Gesture diletak dalam satu widget kongsi
    (`lib/widgets/article_swipe_navigator.dart`), bukan disalin enam kali.
    Scroll menegak tak terjejas — hanya drag melintang yang diambil, dan
    drag perlahan tidak dikira supaya bacaan tak tertukar tanpa sengaja.
13. **Warna appbar — owner putuskan kekal seperti asal.** Tan `#E6D7C4`
    (terang) / `#5C4033` (gelap) ialah warna app Celik Tafsir yang asal,
    jadi tiada perubahan dibuat. Nota warna disimpan di bawah untuk rujukan.
14. **Hadis 40 tak lagi tersekat pada 3 artikel.** URL senarai sebenar sudah
    disahkan terus dari laman web: `celiktafsir.net/hadis-40-imam-nawawi/`
    (teka lama `/hadis-40/` cuma redirect ke situ). Sekarang **12 artikel**
    keluar, HADIS #25 sampai #36. Nombor hadis diambil balik dari `<span>`
    di sebelah link, jadi tajuk kekal "HADIS #25 Sedekah dari Orang Miskin".
    (`lib/services/gethadis_40.dart`)
15. **Font app sekarang sama dengan celiktafsir.net.** Ada pembaca beri
    review 4 bintang: *"font dalam aplikasi berbeza berbanding di dalam
    celik tafsir.net... kurang menarik dan agak susah untuk dibaca"*.
    Puncanya app **tiada font langsung** di-bundle, jadi ia guna font lalai
    peranti (Roboto di Android). Font sebenar laman web diambil terus dari
    stylesheet laman itu:
    - badan teks: **Arimo** (`.wf-active body{font-family:"Arimo"}`)
    - tajuk: **Alegreya** (`.wf-active h1..h6{font-family:"Alegreya"}`)

    **Owner minta satu font sahaja**, jadi Alegreya dibuang dan
    **Arimo dipakai untuk semua** — badan teks, tajuk artikel dan tajuk app
    bar. Arimo di-bundle dalam `assets/fonts/` (lesen OFL disertakan) dan
    dipakai melalui `ThemeData.fontFamily` + `articleHeadingStyles()`.
    Sudah disemak atas build web sebenar.

    *Perangkap:* `ThemeData.fontFamily` **tidak** sampai ke
    `AppBarTheme.titleTextStyle` (ia bukan sebahagian `textTheme`). Kalau
    dibiar kosong, tajuk app bar jatuh balik ke font lalai platform. Jadi
    nama font ditulis terus dalam `titleTextStyle`.
16. **Penjajaran teks sekarang ikut laman web.** Dulu semua page bacaan
    memaksa `TextAlign.justify` pada `body/p/ul/ol/li`. Dalam
    `flutter_html`, style yang kita hantar dipakai **selepas** style inline
    dokumen, jadi paksaan itu menewaskan penjajaran asal artikel.
    Laman web tetapkan penjajaran ikut perenggan — artikel Fatihah sahaja
    ada 58 `justify`, 4 `right` (teks Arab) dan 1 `center`. Sebab itu teks
    Arab dalam app terbentang penuh selebar skrin, sedangkan di laman web
    ia rata kanan.
    Paksaan itu dibuang, jadi app ikut apa yang artikel tetapkan.
    Ujian: `test/article_alignment_test.dart` (gagal atas kod lama).

---

## Todo (Belum siap)

1. **Soalan quiz** — belum ada langsung dalam app.
2. **Fix character rosak dalam app** — *kod sudah dibetulkan, tunggu owner
   sahkan atas telefon.*
   Suspek utama ialah `response.body`. Kalau server tak hantar `charset` dalam
   header, package `http` baca bait sebagai latin-1, jadi setiap aksara
   UTF-8 (tanda petik melengkung, dash panjang, huruf Arab) pecah — huruf
   Arab keluar sebagai `Ø¨ÙØ³ÙÙÙ`, tanda petik jadi `â`.
   Semua 8 service dalam `lib/services/` sekarang guna
   `decodeUtf8Body(response)` (`lib/utils/http_decode.dart`), iaitu
   `utf8.decode(response.bodyBytes, allowMalformed: true)`.
   Ada ujian `test/utf8_response_test.dart` yang gagal atas kod lama dan
   lulus atas kod baru, termasuk satu ujian yang menghalang service baru
   guna `response.body` lagi.
   **Masih perlu disahkan atas peranti sebenar** — ujian guna fixture
   UTF-8 yang dibuat sendiri, bukan respons laman sebenar.

   **Disemak terus dari laman web (2026-08-13).** Sandbox kali ini boleh
   capai kedua-dua domain, jadi header sudah dibaca sendiri:
   - `celiktafsir.net` hantar `content-type: text/html; charset=UTF-8`
     pada semua URL yang dicuba (artikel, senarai, `/asmaul-husna/`)
   - proxy `afwanhaziq.vps.webdock.cloud` hantar `charset=utf-8` juga,
     status 200 (tidak lagi 403)

   Maknanya pada hari ini `response.body` **sudah pun** dibaca sebagai
   UTF-8, jadi latin-1 itu mungkin bukan punca sebenar aksara rosak yang
   owner nampak. Fix `decodeUtf8Body` tetap elok dikekalkan — dia betul
   walau header hilang satu hari nanti — tetapi kalau aksara masih rosak
   atas telefon, puncanya di tempat lain (suspek: tiada font Arab
   di-bundle, lihat item font di bawah). Perlu screenshot dari owner.
3. **Pilihan jenis tulisan (font) dalam Settings tak berfungsi.**
   Amiri / Scheherazade / Lateef / Noto Sans Arabic — pilihan disimpan
   (`selected_font`) tapi **tak pernah dibaca** di mana-mana. Baris
   "Tulisan" dalam Settings pun sudah `isEnabled: false`, jadi memang tak
   boleh ditekan.
   *Nota:* font badan teks sudah pun betul sekarang (Arimo/Alegreya, ikut
   laman web — lihat item 15 di atas), jadi picker ini tinggal untuk font
   **Arab** sahaja. Tiada font Arab di-bundle: teks Arab bergantung pada
   font sistem peranti (Android/iOS ada), manakala web muat turun Noto
   dari `fonts.gstatic.com` secara automatik.
   Perlu owner pilih: **bundle font Arab** atau **buang picker**.
   (Cadangan: buang picker — lihat nota di bawah.)
4. **Adjust saiz font Arab & terjemahan berasingan** (idea masabih.org) —
   lihat nota di bawah.
5. **Tarik/geser untuk adjust font** (bukan masuk Settings) — macam
   masabih.org. Belum ada.

---

## Nota warna (rujukan sahaja — appbar kekal seperti asal)

Warna sebenar, diambil terus dari fail:

- Background `assets/images/bg.jpg` — hijau pucat sejuk:
  medan `#F0F6F2`, corak/border `#D1E3D1`–`#E4F0E6`.
- Hijau pekat Celik Tafsir (butang Tadabbur & band tajuk): `#537459`.
- Appbar (`lib/utils/theme_helper.dart`): terang `#E6D7C4`,
  gelap `#5C4033`, aksen `#8B7355`.

`appBarColorLight` bukan untuk appbar sahaja — jalur navigasi atas
(`ArticleReadTopNav`) dan snackbar "Memuat kandungan..." pun ikut warna
yang sama. Jadi kalau satu hari nak tukar, tukar di `getAppBarColor` dan
semak tiga tempat itu sekali.

---

## Nota: bundle font Arab atau buang picker?

**Cadangan: buang picker.** Sebabnya:

1. Empat fail `.ttf` Arab (Amiri, Scheherazade, Lateef, Noto Sans Arabic)
   besar — setiap satu boleh cecah 300KB–1MB. Semua sekali naikkan saiz
   APK dan, lebih teruk, saiz muat turun web.
2. Kandungan dari celiktafsir.net campur Arab dan Melayu dalam perenggan
   yang sama, tiada tag berasingan. Kalau font Arab dipakai untuk seluruh
   `Html` widget, teks Melayu pun ikut tukar dan jadi pelik.
   Untuk pakai font Arab pada bahagian Arab sahaja, kena buat pembalut
   `<span class="arab">` dahulu — kerja yang sama dengan item "asingkan
   saiz font Arab & terjemahan" di bawah.
3. Baris itu sudah dimatikan (`isEnabled: false`), jadi buang picker tidak
   mengubah apa-apa yang pengguna boleh buat hari ini.

Jadi lebih baik buang picker sekarang, dan bila kerja "asingkan Arab vs
terjemahan" dibuat nanti, masuk semula pilihan font **bersama** pembalut
`.arab` — sekali kerja, bukan dua.

---

## Nota: boleh ke asingkan saiz font Arab & terjemahan?

**Boleh, tapi kena buat sendiri.** Kandungan datang dari
celiktafsir.net sebagai HTML bercampur — Arab dan Melayu dalam perenggan
yang sama, tiada tag/class berasingan. Jadi tak boleh terus style ikut tag.

Cara yang boleh jalan:

1. Sebelum render, imbas HTML dan balut setiap rentetan huruf Arab
   (Unicode `U+0600–U+06FF`, `U+0750–U+077F`, `U+FE70–U+FEFF`) dengan
   `<span class="arab">`.
2. Dalam `Html(style: {...})` di `lib/models/baca.dart`, tambah entri
   `".arab"` dengan `FontSize` + `fontFamily` tersendiri.
3. Simpan dua nilai dalam SharedPreferences: `font_size_arab` dan
   `font_size` (terjemahan), dua-dua boleh laras.
4. Untuk "tarik adjust" macam masabih: letak slider dalam bottom sheet
   pada page bacaan, bukan dalam Settings.

Risiko: pengesanan ikut aksara, jadi kalau ada nombor ayat atau tanda baca
bercampur dalam teks Arab, pembahagian mungkin tak sekemas masabih.org yang
memang simpan Arab dan terjemahan sebagai dua medan berasingan.

Kalau nak font Arab betul-betul cantik (Amiri/Scheherazade), kena
bundle fail `.ttf` dalam `assets/fonts/` dan daftar dalam `pubspec.yaml`
dulu — sekarang tiada.
