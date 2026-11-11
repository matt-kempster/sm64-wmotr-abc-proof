# Video commentary: below the cap, a 632-unit gap

The video uses authentic original-JP ROM frames. Text is added outside the game image.
Pauses and slow motion repeat recorded frames. The ordinary capture and render-only coordinate illustration are explicitly separated.
No A inputs are used; crawl and initial positions are supplied. The display illustration also overrides render transforms.
This demonstrates component behavior, not a complete clean no-A SSL Pyramid route.

## 00:00:00.000–00:00:05.000: A smaller gap works, but does not install the top

ORIGINAL JAPANESE ROM | CONDITIONAL TEST | paused

The game creates a 632-unit position disagreement.
Crawl and the initial Mario/box positions are supplied.
This is a local mechanism demonstration, not a clean gameplay route.

Normal gameplay image. Exact coordinates come from the recorded trace.

## 00:00:05.000–00:00:09.000: Prepare an established crawl before the position cut

NORMAL CAMERA | SUPPLIED CRAWL | slow motion

The earlier no-A four-pillar controller replay is omitted.
Crawl action is supplied; a native update makes its hitbox 100 high.
Next, all three Mario positions and the box position are supplied.

No floor cache, velocity, timer, held reference or display gap is written.

## 00:00:09.000–00:00:18.000: Y = 1400 is a supplied hover, 120 above the roof

RENDER-ONLY STARTING-COORDINATE ILLUSTRATION | paused

Mario: (-2132, 1400, -1024). Box: (-2093, 1400, -1024).
Roof Y = 1280. The 100-high body would end at Y = 1500.
The loaded cap underside is 1518, then 1523 on the next update.

Camera, render positions and render matrices changed for this illustration only.

## 00:00:18.000–00:00:21.000: The box pushes Mario 68 units west

RENDER-ONLY COORDINATE ILLUSTRATION | two recorded frames

The actual next input is Z plus stick (0, 64), with no A.
The native push takes X from -2132 to -2200.
The stopped crawl then retains the earlier display height.

Render edits are restored before input; the logged gameplay matches the stock run.

## 00:00:21.000–00:00:29.000: Movement/collision Y = 768; stored display Y = 1400

RENDER-ONLY DISPLAY-COORDINATE VIEW | paused

Both now use X/Z = (-2200, -1024). The difference is 632.
A stopped ground quarter preserves the low floor cache.
Display refresh precedes crawl alignment and the collision copy.

Mario is drawn at the stored display coordinates by clearing his render matrix.

## 00:00:29.000–00:00:36.000: Stored display coordinates are not the final model transform

BACK TO NORMAL CAMERA AND NATIVE RENDER MATRIX | paused

Crawl also supplies a separate floor-alignment render matrix.
The ordinary game image therefore differs from the illustration.
The 632-unit disagreement is verified in memory, not measured in pixels.

The stock run has no render edits. The illustration is a separate matching replay.

## 00:00:36.000–00:00:44.000: The raised retry reaches the roof, not the top

NORMAL CAMERA | NEXT UPDATE | paused

The low floor query misses; the retry uses the raised display.
It selects the static roof at Y = 1280.
Mario accepts the upper warp, but remembers no spinning-top platform.

The starting hover and box placement remain supplied assumptions.

## 00:00:44.000–00:00:47.800: The continuation gives an ordinary Area-2 arrival

NORMAL CAMERA | CONTINUOUS WARP CONTINUATION | slow motion

All later controller inputs are neutral; A-input counters stay zero.
First Area-2 position: (0, 5500, 256).
Mario lands inside the elevator rather than bypassing it.

The two warp-transition inputs without camera callbacks are recorded in the trace.

## 00:00:47.800–00:00:53.800: A gap alone is not enough

NORMAL CAMERA | ORDINARY ELEVATOR OUTCOME | paused

This supplied below-cap setup makes a smaller gap successfully.
Its retry does not capture the top, so the useful displacement is absent.

Observed finite example; not an exclusion of other positions, phases or mechanisms.

## 00:00:53.800–00:01:02.800: What still has to be produced through gameplay

RENDER-ONLY STARTING-COORDINATE ILLUSTRATION | OPEN PREDECESSOR

There is no standing floor at this supplied Y = 1400.
Reach an established high crawl with an available pushing actor,
then create enough retained display height at useful warp timing.

This test supplies the hover and action. A complete clean no-A route remains open.
