# Live large box: native slide into useful Ink

Conditional original-JP replay with supplied high FREEFALL/live large box and timed shell placement; no ground action supplied. On-screen visual commentary plus original instrumental music. G = Stored Graphics (gfx.pos), not rendered pose.

## 00:00.000–00:09.000: A live box creates the slide

CONDITIONAL ORIGINAL-JP SUCCESS

This time, Mario starts airborne. The game creates DIVE_SLIDE.
A later shell shove completes Ink and changes the Area 2 spawn.

High Mario, the live box and the shell placement are supplied. This is not a complete gameplay route.

## 00:09.000–00:20.000: What the test supplies

SETUP CUT / BEFORE UPDATE 1

Mario is supplied in FREEFALL at Y 25001, with eastward speed 32.
The large box is live at Y 24800. Its solid top reaches Y 25000.

Left: paused replay after update 1. Right: initial setup diagram. Shell availability is also supplied.

## 00:20.000–00:30.000: One unit outside the edge

GEOMETRY / ENLARGED, NOT TO SCALE

Mario starts at X -1950. The west edge of the box is X -1949.
The next air-step candidate crosses the edge and encounters its floor.

Mario and box share Z -939. This diagram shows collision coordinates, not the rendered model.

## 00:30.000–00:40.000: B makes a dive; landing makes a slide

UPDATE 1 / STORED TOP TIMER 129 TO 130

Press B once, with neutral stick. A remains released.
FREEFALL enters DIVE, then the landing result selects DIVE_SLIDE.

No ground action is written into Mario. All inputs after this B press are neutral.

## 00:40.000–00:52.000: The landing keeps the low cache

SOURCE EXPLANATION / MATCHED NATIVE BOUNDARY

The high box floor triggers LANDED, but the clearance test rejects X/Z.
Mario gets the high Y while his earlier low floor cache stays at 768.

Default no-ceiling height 20000 minus floor 25000 is not greater than 160; no physical ceiling is needed.

## 00:52.000–01:02.000: High slide, still outside the box

AFTER UPDATE 1 / NATIVE OBSERVATION

M, C and G all have Y 25000. The action is now DIVE_SLIDE.
X remains -1950, outside the box. This is not ordinary standing on top.

Cache 768; no platform. G means Stored Graphics (gfx.pos), not the visibly rendered pose.

## 01:02.000–01:12.000: Now supply only the shell position

FINAL SETUP CUT / BEFORE UPDATE 2

Place the shell at (-1971, 25000, -939), then give neutral input.
Mario is not edited again. The large box stays live and fixed.

The shell is never held, used or ridden in the observed suffix. Its job here is a fallback contact shove.

## 01:12.000–01:21.000: A sideways shove preserves the slide

UPDATE 2 / STORED TOP TIMER 130 TO 131

A fresh floor lookup keeps 768. Contact pushes Mario 68 units east.
The nonmounting shell shove reaches the slide and floor-alignment code.

The shell supplies the shove; the live box already supplied the landing result that created the action.

## 01:21.000–01:32.000: Store high graphics, then snap movement

INSIDE UPDATE 2 / EXPLANATORY DIAGRAM

The stopped ground step saves high movement into G: Stored Graphics.
Floor alignment then snaps movement Y to the cached low floor.

This is an immediate store and snap, not a visible fall of 24232 units.

## 01:32.000–01:41.000: The producer has made Ink

AFTER UPDATE 2 / NATIVE OBSERVATION

Movement and collision are now (-1882, 768, -939).
Stored Graphics is (-1882, 25000, -939): a 24232-unit Y gap.

The action ends as GROUND_BONK; alignment has run. On the next update, the box mesh unloads by distance.

## 01:41.000–01:52.000: Low contact, high floor retry

UPDATE 3 / STORED TOP TIMER 131 TO 132

Low collision contacts the real upper warp. The failed floor lookup retries at G.
The spinning top is loaded now, so the retry selects its surface.

The high live box mesh is no longer loaded. This is a floor query at Stored Graphics, not a high warp.

## 01:52.000–02:01.000: The top becomes the platform

AFTER UPDATE 3 / NATIVE OBSERVATION

The warp is accepted. Floor owner and platform both name the spinning top.
M, C and G reunite at Y 1818.9613 while Mario is DISAPPEARED.

Used warp: slot 64. Captured platform: top slot 61. A position gap alone would not establish this.

## 02:01.000–02:07.966: The reference survives the countdown

SLOW REPLAY / OBSERVED AREA 1 CONTINUATION

The recorded Area 1 samples keep the top as Mario's platform.
Its inactive reference remains at the last observed Area 1 boundary.

This section advances through joined native images; each is held longer than one game update.

## 02:07.966–02:16.966: Two transition observations are missing

EVIDENCE BOUNDARY / NO FRAMES INVENTED

Native step 27 records the inactive top and retained platform.
Steps 28 and 29 have no camera observations; we do not fill them in.

Left: paused native step 26. Wafel separately records continuous retention through the transition.

## 02:16.966–02:27.966: A different Area 2 spawn

UPDATE 26 FROM THE HIGH CUT / NATIVE STEP 30

The first Area 2 position is (365.593, 5500, -1096.803).
That differs from the ordinary warp spawn (0, 5500, 256).

The first Area 2 framebuffer is dark during transition; the coordinates come from the matched native log.

## 02:27.966–02:33.033: The original replay continues

LATER AREA 2 IMAGES / SLOWED REPLAY

The camera reveals the arrival while the recorded neutral inputs continue.
The comparison arrow marks two spawn locations, not a travelled path.

The first-spawn coordinates at right belong to update 26, not every later image in this sequence.

## 02:33.033–02:44.033: A frozen clone did not replace the floor

SEPARATE WAFEL CONTROL / NOT SHOWN AS ROM FOOTAGE

A supplied frozen carry-script box loads no high solid mesh and fails to land.
Moving raw object XYZ does not, by itself, rebuild collision triangles there.

The working box stays live. High delivery by gameplay remains unresolved; no general clone impossibility is proved.

## 02:44.033–02:56.033: A real action predecessor; delivery is open

WHAT THIS VIDEO ESTABLISHES

One original-JP positive creates the ground slide and useful displacement.
Getting Mario, a live high box and the timed shell here through play is still open.

27 supplied writes. 1035/1080 compared components match; 45 subtype differences remain. No new Coq theorem.

