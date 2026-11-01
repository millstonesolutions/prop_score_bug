# CLAUDE.md — Prop Score Bug

Live NFL score bug for ProPresenter, built 2026-11-01. Owner: Heath (church AV/IT). Church-use license
(Millstone Solutions LLC). Public repo: millstonesolutions/prop_score_bug.

## Why it's shaped like this
- The church is on **ProPresenter 7.8.4**, the last perpetual-license version; it can't be updated. 7.9+ has a REST
  API that could fill message tokens, 7.8.4 doesn't. So the bug is a web page rendered by OBS, sent over NDI
  (DistroAV "Dedicated NDI output" filter, named `FBCLD Score Bug`), and shown by a ProPresenter prop holding a Live
  Video element. Props can't hold changing text.
- Data: ESPN's undocumented `site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard` (CORS `*`, no key).
  Bye-week fallback: `/teams/<abbr>` → `nextEvent`. Logos: `a.espncdn.com/i/teamlogos/nfl/500-dark/<abbr>.png`,
  falling back to the scoreboard's `team.logo`.

## Layout
- `index.html` — the whole page (HTML/CSS/JS, no build). `?team=`, `?preview=1`, `?demo=live|pre|half|final|bye`.
- `fonts/` — Lato (OFL), same files as the church's brand kit.
- `launcher/` — `Score Bug Server.applescript` + `install.sh` (osacompile into /Applications, bakes in the repo path).
  The app toggles `python3 -m http.server 8765 --bind 0.0.0.0` in this folder, detecting it with `lsof`.

## Things that bit us
- **OBS only renders a browser source while it's visible** (Program, Preview or a projector). Off-screen,
  `GetSourceScreenshot` and the NDI output are fully transparent even though the page loaded (the server log showed
  the fonts being fetched). A windowed projector of the Score Bug scene keeps it alive.
- **The launcher beachballed** on its first build: `do shell script "cd X && nohup server ... &"` backgrounds the
  whole `&&` list as a subshell that keeps do shell script's stdout pipe open, so the applet waits forever (the
  server *did* start). Keep `cd X || exit 1;` separate and background only the server with `< /dev/null > /dev/null
  2>&1 &`.
- At 960 px wide the status column ("Kickoff 12:00 PM") was clipped; the source is 1120 × 140.
- Resizing the source left a stale band from the old texture until the source was refreshed.
- OBS 32.2.2 crashed at launch on macOS 27.2 (in `QWidget::setCursor` → `QImage::toCGImage`), safe mode included.
  Fixed in OBS 33.0.0 (obsproject/obs-studio#14070). Some third-party plugins had to be disabled after the update.
- The Mac's OBS has obs-websocket on 127.0.0.1:4455 with no auth. Studio Mode is on, so setting the *preview*
  scene is safe; never change the program scene, and check `GetStreamStatus` first.

## Brand
FBC Lake Dallas kit: black, white, cyan `#02CAF2`, grays. **No red, ever** (pastor's call) — so no red possession
marker or red-zone red; the red zone is shown in cyan.
