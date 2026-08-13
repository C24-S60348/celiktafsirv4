# Celik Tafsir — Updates & Todo

Versi semasa: **1.0.27+27** · Web: https://celiktafsir.web.app

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

---

## Todo (Belum siap)

1. **Soalan quiz** — belum ada langsung dalam app.
2. **Fix character rosak dalam app** — *kod sudah dibetulkan, tunggu owner
   sahkan atas telefon.*
   Puncanya memang `response.body`. Kalau server tak hantar `charset` dalam
   header, package `http` baca bait sebagai latin-1, jadi setiap aksara
   UTF-8 (tanda petik melengkung, dash panjang, huruf Arab) pecah — huruf
   Arab keluar sebagai `Ø¨ÙØ³ÙÙÙ`, tanda petik jadi `â`.
   Semua 8 service dalam `lib/services/` sekarang guna
   `decodeUtf8Body(response)` (`lib/utils/http_decode.dart`), iaitu
   `utf8.decode(response.bodyBytes, allowMalformed: true)`.
   Ada ujian `test/utf8_response_test.dart` yang gagal atas kod lama dan
   lulus atas kod baru, termasuk satu ujian yang menghalang service baru
   guna `response.body` lagi.
   **Masih perlu disahkan atas peranti sebenar** — sandbox sekat
   `celiktafsir.net` dan proxy `afwanhaziq.vps.webdock.cloud`, jadi ujian
   guna fixture UTF-8, bukan laman sebenar.
3. **Pilihan jenis tulisan (font) dalam Settings tak berfungsi.**
   Amiri / Scheherazade / Lateef / Noto Sans Arabic — pilihan disimpan
   (`selected_font`) tapi **tak pernah dibaca** di mana-mana, dan tiada
   font Arab di-bundle dalam `pubspec.yaml`. Baris "Tulisan" dalam Settings
   pun sudah `isEnabled: false`, jadi memang tak boleh ditekan.
   Perlu owner pilih: **bundle font** atau **buang picker**.
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
