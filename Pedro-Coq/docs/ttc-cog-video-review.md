# TTC cog video review — 2026-09-06

The user supplied `YTDown.com_YouTube_TTC-Pedro-Spot-on-Cogs-Update_Media_X4k5NGUjTWs_001_1080p.mp4`.
Its SHA-256 is `5e2673ec71721d3c1bea0df8391b2b93b136ec11c016c8a5229d672a1990e302`.
`ffprobe` reports 1920×1080, 30000/1001 video frames per second, and duration
502.828118 seconds. Extracted review images are local discovery artifacts in
`build/cog-video-review/`; neither the video nor those images enter the Coq
trusted base. The source game's version and setup provenance are unverified.

## Observations

The opening begins on the ledge near the lower staircase of hexagonal cogs,
not at the level entrance. Mario crosses toward the small cog and wire mesh.
By about 9 seconds he is visually stationary beside the mesh. The displayed
coordinates are approximately X=1455.803, Y=-2088, Z=-1178.19; displayed facing
angle is 62083. The overlay reports vertical speed -16, horizontal speed
about 1.11867, and a field labeled Cog Angle equal to 6600 at that instant.

At the sampled frames from roughly 12 through 39 seconds, the position stays
fixed while the displayed horizontal speed increases from about 38.6 toward
630. The field labeled Cog Angle changes later in this sequence. The clip
does not identify which object that field observes, so it does not establish
that every nearby cog is frozen. Mario subsequently leaves the location and
travels up the level.

The captions discuss keeping one cog still for 1200 game frames (40 seconds)
to build speed for an A-press-saving strategy. That duration and the claimed
A-press saving are the video's objective, not additional requirements from
the user. At roughly 42–51 seconds, the captions explicitly assume Mario
cannot manipulate RNG in the Pedro spot. Later material estimates state counts
and waiting times and describes a simulator.

## What this does and does not settle

- The footage provides a nearby starting location and a candidate maneuver.
  It supplies neither a complete controller replay nor normal-entry provenance.
- The position overlay is not the wall-resolved attempted quarter-step point
  passed to the floor/ceiling queries. The queried surface and Mario's retained
  floor reference must be recorded separately.
- Action IDs, intended input, RNG seed, accepted dust events, and cog speed and
  target values are absent. The flat-floor speed-17 dust calculation cannot be
  assumed to apply to the high-speed maneuver shown here.
- The video's probability estimates are not an exhaustive impossibility
  proof. Conversely, the current conditional Clight lemmas do not refute its
  premise about this particular in-spot controller behavior.
- The checked geometry at query `(1330,-1025)` and yaws `(57344,0)` is a separate
  source-derived candidate. It must not be relabeled as the video's setup.

## Next experiment

The user authorized spawning Mario near the cogs after reporting that a full
approach video was unavailable. Start a separately identified test build near
the opening ledge, using the video's initial approximate position
`(1742,-2088,-125)` and facing about 188 degrees. Configure RANDOM mode once
as part of that declared initial setup. Preserve the stock movement, collision,
cog, dust, and RNG behavior; observe the resulting controller trials without
forcing any cog pose, speed, or RNG value. Such a trace can establish local
experimental behavior, while normal entry remains a formal obligation.
