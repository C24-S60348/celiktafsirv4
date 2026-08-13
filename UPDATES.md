# Celik Tafsir — Updates & Todo

Versi semasa: **1.0.26+26** · Web: https://celiktafsir.web.app

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

---

## Todo (Belum siap)

1. **Soalan quiz** — belum ada langsung dalam app.
2. **Swipe kiri-kanan dalam page bacaan** — Halaman Utama dah boleh swipe,
   tapi page bacaan (`baca_*.dart`) masih butang sahaja, tiada gesture.
   Perlu tambah `onHorizontalDragEnd` untuk tukar page/artikel.
3. **Fix character rosak dalam app** (website OK, app je rosak).
   Suspek utama: semua service guna `response.body`. Kalau server tak hantar
   `charset` dalam header, package `http` akan baca sebagai latin-1, jadi
   UTF-8 (tanda petik melengkung, dash panjang, huruf Arab) jadi
   `â€œ` / `Ã—`. Cadangan fix: guna `utf8.decode(response.bodyBytes)`.
   **Belum disahkan** — sandbox sekat `celiktafsir.net` dan juga proxy
   `afwanhaziq.vps.webdock.cloud` (403 dari gateway, bukan dari server
   owner). Owner boleh benarkan domain proxy itu dalam network policy
   environment, barulah boleh test terus dari sini.
4. **Revise warna appbar (coklat) supaya padan dengan background (hijau).**
   Warna sebenar, diambil terus dari fail:
   - Background `assets/images/bg.jpg` — hijau pucat sejuk:
     medan `#F0F6F2`, corak/border `#D1E3D1`–`#E4F0E6`.
   - Hijau pekat Celik Tafsir (butang Tadabbur & band tajuk): `#537459`.
   - Appbar sekarang (`lib/utils/theme_helper.dart`): terang `#E6D7C4`
     (tan panas), gelap `#5C4033`, aksen `#8B7355`.

   Masalahnya tan `#E6D7C4` itu **warna panas** duduk atas hijau
   **sejuk** `#F0F6F2` — sebab itu nampak tak sekena, bukan sebab
   gelap/terang.

   Dua pilihan:
   - **(a)** Tukar appbar terus ke hijau pekat `#537459` + teks putih.
     Terus padan dengan butang Tadabbur dan band "Fahami Al-Quran".
   - **(b)** Kekal coklat tapi tarik ke arah sejuk/lembut supaya tak
     bergaduh dengan hijau.

   Perlu owner pilih (a) atau (b) sebelum tukar.
5. **Pilihan jenis tulisan (font) dalam Settings tak berfungsi.**
   Amiri / Scheherazade / Lateef / Noto Sans Arabic — pilihan disimpan
   (`selected_font`) tapi **tak pernah dibaca** di mana-mana, dan tiada
   font Arab di-bundle dalam `pubspec.yaml`. Jadi pilih pun tak ada kesan.
6. **Adjust saiz font Arab & terjemahan berasingan** (idea masabih.org) —
   lihat nota di bawah.
7. **Tarik/geser untuk adjust font** (bukan masuk Settings) — macam
   masabih.org. Belum ada.

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
