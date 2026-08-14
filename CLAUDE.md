# CLAUDE.md

Notes for Claude Code sessions working on Celik Tafsir (Flutter app).

## Owner preferences

- **Bump the version on every web deploy.** `pubspec.yaml` `version:` moves
  together, patch and build number in step: `1.0.25+25` → `1.0.26+26`. The
  Information page shows it, so it is how the owner confirms which build is
  live. Always state the deployed version and the site link when reporting a
  push.
- Primary usage is **Android/iOS**; the web build matters less but is still
  deployed and tested.
- Report results **point by point**, and say plainly what was not done.

## Branches and deploys

| Branch | Purpose |
| --- | --- |
| `main` | Development trunk. Pushing here runs tests and builds a debug APK. |
| `build-web` | Deploy branch. **Pushing here deploys the live website.** |
| `azim-branch` | Teammate's feature branch (views). |
| `afwan-branch` | Owner's feature branch. |

- Website: **https://celiktafsir.web.app** (Firebase project `celiktafsir`).
- To deploy: merge `main` into `build-web` and push. Nothing else triggers it.
- `.github/workflows/deploy-firebase.yml` fires **only** on `build-web`;
  `.github/workflows/build-apk.yml` fires only on `main`. Keep it that way so
  ordinary work never touches the live site.
- CI pins Flutter **3.32.2**. Newer SDKs work locally but that is the version
  that actually builds the site and the APK.

## Do not confuse these two domains

- **celiktafsir.web.app** — the Flutter app (what we deploy).
- **celiktafsir.net** — the WordPress site the app *scrapes content from*.
  We never deploy to it. Some sandboxes block it at the egress proxy; others
  reach it fine. Try `curl -sSL https://celiktafsir.net/` before assuming you
  have to ask the owner for page contents.

## Architecture

```
lib/
  views/     screens (owner's teammate mostly works here)
  models/    per-section content + the Html widget that renders it
  services/  scraping celiktafsir.net (http + html parser)
  utils/     shared helpers
  widgets/   shared UI pieces
```

Each content section has a matching triple, e.g. Hujjah:
`views/baca_hujjah.dart` → `models/hujjah.dart` → `services/gethujjah.dart`.
Views call `model.bodyContent(...)`, which owns the `Html` widget.

### Section → model mapping is not always 1:1

`views/baca_asmaul_husna.dart` uses `models/hujjah.dart`. Check the import
before assuming.

## Things that have bitten us

- **`categoryUrl` must be threaded through every lookup.** Surahs split
  across juzuk (Baqarah spans juzuk 1–3) have one category per variant.
  Calling `getSurahByIndex`/`getSurahUrl` without `categoryUrl` silently
  falls back to the surah's default category and returns *another juzuk's*
  article. Juzuk 1 looks fine because it is the default — always test juzuk 2
  or 3. Cache keys must include `categoryUrl` for the same reason.
- **`BacaService.fetchContentFromUrl` slices the body at the literal string
  `"Share this"`.** Without it, `indexOf` returns -1, `substring` throws, and
  the whole fetch returns null. Test fixtures must contain it.
- **`.catchError` chained after `.then` swallows the `.then` failure.** A
  missing guard in `.then` will not surface if `.catchError` still has one.
  When verifying such a fix, remove *both* guards to confirm the test fails.
- **`pumpAndSettle` does not drain a displayed SnackBar.** An idle snackbar
  schedules no frames, it just holds a Timer, so settling returns with it
  still on screen and queues the next one behind it. Reading pages show a 2s
  "Memuat kandungan..." snackbar on load — pump past it.
- Popping a reading page refetches its article, so **prefer overlays to
  pushed routes** for transient prompts. See `showOpenWebsiteOverlay`.
- **The `style:` map you pass to `Html` beats the article's own inline CSS.**
  `flutter_html` merges in this order (`_styleTreeRecursive`): external CSS,
  then the document's `style="..."` attributes, then *your* map last. So a
  `Style(textAlign: ...)` on `"p"` silently overrides every per-paragraph
  alignment the article carries. celiktafsir.net sets alignment per
  paragraph -- the Fatihah article alone has 58 `justify`, 4 `right` (the
  Arabic) and 1 `center` -- so the pages used to stretch Arabic across the
  full width instead of right-aligning it. Only style what the article does
  not style itself. `test/article_alignment_test.dart` pins this.

## Conventions

- Guard `context`/`ScaffoldMessenger` after any async gap with `mounted`
  (or `context.mounted` for a `BuildContext` in scope). The reading views do
  this on their load paths; match it.
- Shared UI goes in `lib/widgets/`, shared behaviour in `lib/utils/`, rather
  than being copy-pasted across the six near-identical reading views. If you
  are about to paste the same block into all six, extract it first.
- User-facing strings are **Malay** ("Sebelum", "Selepas", "Salin
  Kandungan", "Memuat kandungan..."). Keep new strings in Malay.
- **Fonts must match celiktafsir.net**: body **Arimo**, headings
  **Alegreya**, both bundled in `assets/fonts/` and wired through
  `ThemeHelper.bodyFontFamily` / `headingFontFamily`. They are read from the
  site's own `jetpack-custom-fonts-css` block, not chosen by us -- a reader
  complained the app was harder to read than the website. Do not swap them
  for a "nicer" font. Article headings come from
  `utils/article_heading_styles.dart`; the six reading models spread it in
  rather than each declaring h1-h6.
- Neither font covers **Arabic**. That matches the website. Arabic falls back
  to the platform font on mobile, and on web Flutter fetches Noto from
  `fonts.gstatic.com` at runtime -- so Arabic shows as tofu boxes in any
  sandbox that blocks gstatic. That is the harness, not a bug.
- Reading pages use `CustomScrollView` + `SliverAppBar(floating: true,
  snap: true)`. Anything that should hide on scroll and come back belongs in
  the app bar's `bottom` — that is how `ArticleReadTopNav` works.

## Testing

- `flutter test` — widget tests live in `test/`.
- `flutter analyze` — there is a **pre-existing backlog of ~196 issues**
  (mostly `avoid_print`, `withOpacity`, deprecated `Radio` args) inherited
  from before. Do not treat a non-zero count as failure: compare against the
  baseline and make sure your change adds nothing new. Errors must stay at 0.
- Widget-testing a reading page needs: `SharedPreferences.setMockInitialValues`,
  an `HttpOverrides` stub, route arguments, and the "Share this" fixture.
  See `test/copy_to_clipboard_test.dart` for a working harness.
- A regression test is only real if it fails against the unfixed code. Check.

## Known rough edges (not yet fixed)

- `android/app/build.gradle.kts` hardcodes a release keystore path on the
  owner's Mac, with the passwords in plaintext — so CI builds a **debug** APK.
  The repo is public; the key should be rotated and moved to a secret.
- `views/websitepage.dart` is no longer navigated to, but is still routed
  from `main.dart`.

## Listing pages are hand-written WordPress pages, not category archives

Confirmed against the live site 2026-08-13. `/hadis-40-imam-nawawi/` and
`/category-example/` are both `type-page` posts whose `.entry-content` is a
hand-maintained list of links. Consequences:

- **There is no pagination markup**, so none of the four selectors the
  scrapers look for (`a.next.page-numbers`, `.nav-next a`, `.pagination .next
  a`, `.pagination-next a`) ever match. Every post is on page 1 and the loop
  correctly stops after one request. `/page/2/` serves the same page again;
  duplicate URLs make `foundNewLinks` false, so that is harmless too.
- **The link text is not the whole title.** Hadis 40 keeps the number in a
  sibling `<span>`: `<p><strong>HADIS #25</strong><br><a>Sedekah dari Orang
  Miskin</a></p>`. `GetHadis40._titleForLink` walks up to recover it. Check
  the surrounding markup before trusting anchor text in a new scraper.
- `celiktafsir.net/category-example/` **is not a placeholder** despite the
  name -- it is the real Hujjah listing, titled "Hujjah", 18 posts. Leave it
  alone.
- `celiktafsir.net/hadis-40/` 301-redirects to `/hadis-40-imam-nawawi/`, so
  the old guess worked by accident. Use the canonical URL.
