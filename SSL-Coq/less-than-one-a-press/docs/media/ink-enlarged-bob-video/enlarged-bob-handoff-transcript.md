# Three actors, one useful Ink handoff

Conditional original-JP three-actor handoff. Actual ROM footage, explanatory diagrams, on-screen commentary and original instrumental music. No spoken narration. Setup grants remain explicit; no complete gameplay route is claimed.

On-screen commentary with original instrumental music. No spoken narration. G means Stored Graphics (gfx.pos), not the visibly drawn pose.

## 00:00:00.000–00:00:10.000: Three actors, three different jobs

CONDITIONAL ORIGINAL-JP SUCCESS

A frozen shell, an enlarged black Bob-omb, and a Crazy Box work together.
The original Japanese game reaches a useful displaced Area 2 spawn.

High entry, actor positions and copied Bob state are supplied. This demonstrates a local handoff, not a complete gameplay route.

## 00:00:10.000–00:00:24.000: The supplied airborne starting point

SETUP CUT / BEFORE TOP UPDATE 128

The test places airborne Mario at Y 19900, ten units above the shell.
His ground-slide action is not supplied. The game must create it.

Initial FREEFALL at (-1960,19900,-1230); horizontal speed 0, vertical speed -16. High shell delivery remains a setup grant.

## 00:00:24.000–00:00:37.000: Shell contact, then Z in the same update

TOP UPDATE 128 / NATIVE ACTION TRANSITIONS

Shell contact mounts Mario; Z cancels riding into a butt slide.
The slide's floor alignment puts Movement on the real spinning top.

One Z update, then neutral controls. M=C.Y 1809.207; G.Y 19900. This immediate alignment is not a long visible fall.

## 00:00:37.000–00:00:48.000: Three positions to watch

POSITION LEGEND / STORED GAME STATE

M is Movement. C is the Mario object's Collision position.
G is Stored Graphics: gfx.pos, not the visibly drawn model.

Diagrams show stored coordinates, not the rendered pose. G is always a labelled coordinate marker, never a model-placement claim.

## 00:00:48.000–00:01:02.000: The rotating top separates M and C

INSIDE TOP UPDATE 129 / EXPLANATORY TOP VIEW

The top moves Movement sideways before Mario's actor interactions.
Collision still uses the earlier position when the game checks the Bob.

The enlarged Bob reaches old C while sitting near shifted M. Radius 91+37 registers; stock 65+37 misses this exact placement.

## 00:01:02.000–00:01:14.000: Bob supplies the earlier shove

TOP UPDATE 129 / SUPPLIED ACTOR POSITION, NATIVE RESPONSE

The Bob pushes Mario toward the low pad's footprint.
Mario stays in butt slide at Y 1839.447, with no platform carried forward.

Bob position is supplied before 129. Its callback and fuse remain live; its radius changes normally after this useful contact.

## 00:01:14.000–00:01:25.000: First save the low floor

START OF TOP UPDATE 130 / DIRECT ROM QUERY CHECK

A fresh floor lookup saves height 768 while Movement is still high.
This happens before the Crazy Box's shove. The order matters.

Native hook confirms the initial query and saved cache 768. A shove's separate floor check does not overwrite Mario's cache.

## 00:01:25.000–00:01:37.000: Crazy Box supplies the final shove

TOP UPDATE 130 / FINAL ACTOR POSITION CUT

The Crazy Box now pushes Mario farther sideways.
Bob and Box act on different updates, not as two same-type pushes at once.

Normal interaction ordering chooses the Crazy Box here. Bob remains present. There is no collision-list or floor-cache edit.

## 00:01:37.000–00:01:50.000: Save high G, then snap low

INSIDE TOP UPDATE 130 / STORE, STOP AND ALIGN

The stopped ground step saves high coordinates in G.
Floor alignment snaps Movement to 768; Collision also finishes low.

M=C (-2200.002,768,-1075.004); G.Y 1839.447. Gap 1071.447. The top underside stops the quarter; cached 768 survives.

## 00:01:50.000–00:02:03.000: Low warp contact, high floor retry

TOP UPDATE 131 / ACCEPTED WARP AND TOP CAPTURE

Low Collision overlaps the real warp.
The failed floor lookup retries at Stored Graphics and selects the top.

Warp 64 is accepted; floor and platform name top 61 at Y 1914.855. The floor query is high; the real warp remains low.

## 00:02:03.000–00:02:14.000: The top reference survives

SLOW REPLAY / OBSERVED AREA 1 CONTINUATION

The recorded Area 1 boundaries retain the top as Mario's platform.
That retained reference is needed for the later spawning displacement.

Two transition camera observations are unavailable. We disclose the gap; first Area 2 coordinates come from the native log.

## 00:02:14.000–00:02:26.000: A useful Area 2 arrival

USEFUL SPAWN / CHECKED LOG + LATER JP REPLAY

The original Japanese ROM reaches (365.593,5500,-1096.803).
The ordinary upper-warp arrival is (0,5500,256).

First-arrival coordinates come from the checked native log. Later replay images may show movement. Diagram compares spawn points.

## 00:02:26.000–00:02:38.000: Without the final Crazy Box

SEPARATE ORIGINAL-JP CONTROL / ORDINARY WARP

Omitting only the final Crazy Box still makes a gap and fresh floor 768.
But it reaches the ordinary spawn without capturing the top.

Both runs accept the warp. The control keeps the live Bob and its later nudge; only the final Crazy Box placement is omitted.

## 00:02:38.000–00:02:55.000: The handoff works; joining the route is open

WHAT THIS FILM ESTABLISHES

A black Bob-omb can replace the Buddy's local job in this revised setup.
Joining Mario's entry, actor delivery and timing through play is still open.

Supplied: shell spawn/fake-pickup pointer/high HOLP, copied Bob state, high Mario/shell and actor positions. No later Mario edits.
