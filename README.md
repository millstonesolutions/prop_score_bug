# Millstone Solutions Prop Score Bug

A live NFL score bug you can pop up and hide in **ProPresenter** like any other prop: team logos, score, quarter,
game clock, possession and down and distance, updated every 10 seconds during the game.

It's a single web page. **OBS** renders it and sends it out over **NDI**; a ProPresenter prop with a Live Video
element shows that NDI feed. That route works on **ProPresenter 7.8.4** (the last perpetual-license version), which
has no API for putting changing text on screen.

> **Status: early testing.** Tested in a browser and in OBS 33.0.1 on Apple Silicon against live ESPN data.
> The ProPresenter end and a full live game haven't been checked yet. Please report what works and what doesn't.

---

## Contents
- [How it fits together](#how-it-fits-together)
- [Requirements](#requirements)
- [Install](#install)
- [OBS setup](#obs-setup)
- [ProPresenter prop](#propresenter-prop)
- [Page options](#page-options)
- [Score Bug Server (optional)](#score-bug-server-optional)
- [Known limits](#known-limits)
- [License](#license)
- [Credits and legal](#credits-and-legal)

## How it fits together
```
ESPN scoreboard JSON ──> index.html (OBS Browser Source) ──> DistroAV NDI filter ──> ProPresenter prop (Live Video)
```
The page finds the team's game on ESPN's current NFL scoreboard (falling back to the team's next game in a bye week)
and draws one bar:

| State | Shows |
|---|---|
| Before kickoff | Both teams, records, "Kickoff 12:00 PM" (or the day), TV network |
| In progress | Scores, quarter and clock, a dot for possession, down and distance (highlighted in the red zone) |
| Halftime, end of quarter, delays | ESPN's own status text |
| Final | Final score, the losing side dimmed |

It polls every 10 s while the game is on and every 60 s otherwise. If ESPN stops answering for two minutes the bug
dims instead of going blank.

## Requirements
- macOS (the launcher is a Mac app; the page itself runs anywhere)
- [OBS Studio](https://obsproject.com) 33 or later. 32.2.x crashes on startup under macOS 27.2.
- [DistroAV](https://github.com/DistroAV/DistroAV) (the NDI plugin for OBS) and the NDI runtime
- ProPresenter 7 with NDI input, on the same network

## Install
```bash
git clone https://github.com/millstonesolutions/prop_score_bug.git ~/Projects/prop_score_bug
```
OBS loads the page straight from the folder, so nothing else is needed. To add the optional server app, see
[Score Bug Server](#score-bug-server-optional).

## OBS setup
1. Add a scene called **Score Bug**.
2. Add a **Browser** source to it: tick **Local file**, choose `index.html`, width **1120**, height **140**. Leave
   "Shutdown source when not visible" off.
3. Right-click the source → **Filters** → add **Dedicated NDI® output**, and name it (e.g. `FBCLD Score Bug`).
4. **Keep the scene visible somewhere.** OBS only draws a browser source while it's on screen (Program, Preview or a
   projector), and NDI sends blank frames otherwise. Right-click the Score Bug scene → **Windowed Projector** and
   leave that window open behind everything else. Turn on **Settings → General → Save projectors on exit** so it
   comes back after a restart.

The page background is transparent and the bug itself is a solid black box, so it looks right whether or not
ProPresenter keys the NDI alpha channel.

## ProPresenter prop
1. Create a prop and add a **Live Video** element.
2. Pick the NDI source named in step 3 above.
3. Size and position it, and crop to the bug if the transparent edge shows.
4. Trigger the prop to show the score; clear props to hide it. The page keeps updating while the prop is hidden,
   so the score is current the moment it comes up.

## Page options
Add them to the URL in a browser, or use the server URL in OBS (see below), e.g. `index.html?team=PHI&preview=1`.

| Option | Effect |
|---|---|
| `team=DAL` | Team abbreviation to follow (default `DAL`) |
| `preview=1` | Dark backdrop, for looking at it in a normal browser |
| `demo=live`, `pre`, `half`, `final`, `bye` | Made-up data for checking the layout, no network needed |

## Score Bug Server (optional)
OBS doesn't need a web server, but one is handy for previewing the page in a browser, using page options in OBS
(a local file can't take `?team=`), or loading it from another machine.

```bash
./launcher/install.sh
```
That builds **Score Bug Server.app** into /Applications. Open it once to start a server for this folder on port
**8765**; it shows the local and network addresses and offers to open a preview. Open it again to stop it. The first
time, macOS may ask whether Python can accept incoming connections: allow it if other machines need the page.

Re-run `install.sh` if you move the folder.

## Known limits
- **ESPN's endpoints are unofficial.** They're free and need no key, but ESPN can change them without notice.
- **The clock isn't smooth.** It updates on each poll and runs a few seconds behind the broadcast.
- **Hidden scenes don't render** in OBS, hence the projector in step 4.
- **The stage screen** in ProPresenter 7.8.4 can't show a video input, so this is audience-side only.
- The look uses the First Baptist Church Lake Dallas brand colors and Lato. Change the `:root` colors in
  `index.html` to match your own.

## License
Free for **Christian churches and ministries** (including missions, parachurch ministries, Christian schools and
camps) under the [Church and Ministry Use License](LICENSE). In short:

- **Qualifying churches and ministries** may download it from this repository and use it for free for anything
  they do: services, events, recordings and livestreams. They use it as published, without modifying it
  (changing settings is fine).
- **AV installers and integrators** may set it up and support it for a qualifying church, and charge for their own
  time, but not for the software.
- **Anyone** may read the code, and download, modify and test it to evaluate it or to contribute changes back
  through GitHub pull requests.
- **Everything else** (other organizations, selling it, redistributing it, running modified versions in production)
  needs written permission from Millstone Solutions. Open an issue to ask.
- **Contributions** submitted to the project may be used and relicensed by Millstone Solutions.

This is a source-available license, not an open-source one. The Lato fonts keep their SIL Open Font License; ESPN
data and team logos are not included and are subject to ESPN's terms. The [LICENSE](LICENSE) file is the binding
text; this summary is for convenience.

## Credits and legal
© 2026 Millstone Solutions LLC.

Game data and logos are loaded at run time from ESPN; this project is not affiliated with or endorsed by ESPN, the
NFL or any club. Lato is © Łukasz Dziedzic (SIL OFL 1.1). OBS Studio, ProPresenter, NDI and the NFL and team marks
are trademarks of their owners. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
