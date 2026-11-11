# Video commentary: hands-free holding and the supplied Ink tests

The video uses authentic original-JP ROM frames. Text is added outside the game image.
Pauses and slow motion repeat recorded frames. Different runs are explicitly separated.
No A inputs are used; marked supplied-state edits are not controller gameplay.
This demonstrates component behavior, not a complete clean no-A SSL Pyramid route.

## 00:00:00.000–00:00:05.000: What these recordings establish

ORIGINAL JAPANESE ROM  |  THREE SEPARATE RUNS

1. A clean hands-free pickup and low crawl.
2. A supplied-position hands-free test.
3. A separate supplied Ink installation.

No complete clean no-A SSL Pyramid route is established by these clips.

## 00:00:05.000–00:00:10.000: Approach the eastern box with controller inputs

1/3  CLEAN CONTROLLER COMPONENT  |  A inputs: 0  |  slow motion

Accepted debug level-select startup and earlier travel are omitted.
No gameplay positions, actions or object references are edited.

Clean component: zero pillars; the spinning-top handoff remains open.

## 00:00:10.000–00:00:14.000: Dive pickup

1/3  CLEAN CONTROLLER COMPONENT  |  A inputs: 0  |  slow motion

Inputs create the dive and pickup.
Mario reaches a slippery slope while holding the box.

Clean component: zero pillars; the spinning-top handoff remains open.

## 00:00:14.000–00:00:19.000: Hands-free holding, without a position edit

1/3  CLEAN CONTROLLER COMPONENT  |  A inputs: 0  |  paused

The game uses a normal stomach-slide action while retaining box 47.
Hands-free means a non-holding action with a held reference.

Clean component: zero pillars; the spinning-top handoff remains open.

## 00:00:19.000–00:00:24.267: Brake toward the flat patch

1/3  CLEAN CONTROLLER COMPONENT  |  A inputs: 0  |  slow motion

This continuation keeps the box until Mario slows enough to stop.
The location remains low and far from the upper warp.

Clean component: zero pillars; the spinning-top handoff remains open.

## 00:00:24.267–00:00:28.267: Stopping releases the box at Y = 38

1/3  CLEAN CONTROLLER COMPONENT  |  A inputs: 0  |  paused

Drop Y uses Mario's height; X/Z uses the previous rendered hand position.
The box lands and is deleted one update later.

Clean component: zero pillars; the spinning-top handoff remains open.

## 00:00:28.267–00:00:32.133: Crawl is reached after the box is gone

1/3  CLEAN CONTROLLER COMPONENT  |  A inputs: 0  |  slow motion

First crawl: completed input 528, at Y = 38.
This is not the high Y = 1741 handoff.

Clean component: zero pillars; the spinning-top handoff remains open.

## 00:00:32.133–00:00:36.133: Clean pickup, hands-free slide, drop, low crawl

1/3  CLEAN CONTROLLER COMPONENT  |  A inputs: 0  |  paused

That sequence is demonstrated without gameplay edits.
A live box, high crawl and timer-130 contact are not joined.

No complete clean no-A SSL Pyramid route is established by these clips.

## 00:00:36.133–00:00:40.133: A separate test near the pyramid

NEW RUN  |  SUPPLIED-POSITION TEST

This is a new emulator run with an explicitly supplied position cut.
It is not travel from the preceding scene.

Supplied-state test: marked setup edits are not controller inputs.

## 00:00:40.133–00:00:43.867: First, inputs produce a normal dive

2/3  SUPPLIED-POSITION TEST  |  A inputs: 0  |  slow motion

Six ordinary controller inputs; no action or velocity is written.
The position edit comes next.

Supplied-state test: marked setup edits are not controller inputs.

## 00:00:43.867–00:00:49.867: Next: supply Mario and box positions

2/3  SUPPLIED-POSITION TEST  |  A inputs: 0  |  next-update setup / paused

Mario M/C/D: (-2559, 1741, -1535).
Box: (-2559, 1741, -1465).
These writes precede the next update; action and velocity stay native.

Supplied-state test: marked setup edits are not controller inputs.

## 00:00:49.867–00:00:53.467: The game performs the pickup

2/3  SUPPLIED-POSITION TEST  |  A inputs: 0  |  slow motion

After the one setup edit, only controller inputs are used.
The dive lands on a sloping face of the moving pyramid top.

Supplied-state test: marked setup edits are not controller inputs.

## 00:00:53.467–00:00:58.467: Hands-free slide from the supplied high approach

2/3  SUPPLIED-POSITION TEST  |  A inputs: 0  |  paused

Normal butt-slide action; the game still holds box 49.
Mario has already descended to about Y = 1391.

Supplied-state test: marked setup edits are not controller inputs.

## 00:00:58.467–00:01:02.667: This steering loses the roof

2/3  SUPPLIED-POSITION TEST  |  A inputs: 0  |  slow motion

Avoiding automatic bouncing does not keep Mario high.
The selected continuation slides off the pyramid.

Supplied-state test: marked setup edits are not controller inputs.

## 00:01:02.667–00:01:06.867: The example ends in quicksand

2/3  SUPPLIED-POSITION TEST  |  A inputs: 0  |  slow motion

Mario loses the box during quicksand death.
No high crawl or Ink handoff occurs in this run.

Supplied-state test: marked setup edits are not controller inputs.

## 00:01:06.867–00:01:10.867: The local exception works; this continuation fails

2/3  SUPPLIED-POSITION TEST  |  A inputs: 0  |  paused

The high starting positions were supplied.
This clip does not show gameplay reaching those positions.

No complete clean no-A SSL Pyramid route is established by these clips.

## 00:01:10.867–00:01:14.867: The 973-unit installation test

NEW RUN  |  SEPARATE SUPPLIED INK FIXTURE

This test supplies crawl action and a high Mario/box placement.
It does not continue from either preceding clip.

Supplied-state test: marked setup edits are not controller inputs.

## 00:01:14.867–00:01:18.867: Prepare the crawl hitbox

3/3  SEPARATE SUPPLIED INK FIXTURE  |  A inputs: 0  |  slow motion

Crawl action is supplied before the high-position cut.
A native update establishes the 100-unit collision height.

Supplied-state test: marked setup edits are not controller inputs.

## 00:01:18.867–00:01:24.867: Next: supply the high pose and nearby box

3/3  SEPARATE SUPPLIED INK FIXTURE  |  A inputs: 0  |  next-update setup / paused

Mario M/C/D: (-1950, 1741, -939).
Free box: (-1989, 1741, -939).
The floor cache is not edited; these writes precede the next update.

Supplied-state test: marked setup edits are not controller inputs.

## 00:01:24.867–00:01:30.867: The game produces the 973-unit split

3/3  SEPARATE SUPPLIED INK FIXTURE  |  A inputs: 0  |  paused

Trace: movement/collision Y = 768; display Y = 1741.
The solid top hides Mario in this camera view.
These values come from the recorded state, not visible pixels.

Supplied-state test: marked setup edits are not controller inputs.

## 00:01:30.867–00:01:35.867: Update at timer 131 installs the top reference

3/3  SEPARATE SUPPLIED INK FIXTURE  |  A inputs: 0  |  paused

The upper warp is accepted and the spinning top is remembered.
This follows the explicitly supplied setup.

Supplied-state test: marked setup edits are not controller inputs.

## 00:01:35.867–00:01:39.700: Warping to Area 2

3/3  SEPARATE SUPPLIED INK FIXTURE  |  A inputs: 0  |  slow motion

No A input is used.
The remembered top produces the displaced arrival.

Supplied-state test: marked setup edits are not controller inputs.

## 00:01:39.700–00:01:44.700: Area 2: outside the elevator

3/3  SEPARATE SUPPLIED INK FIXTURE  |  A inputs: 0  |  paused

Recorded arrival: (365.593, 5500, -1096.803).
The ordinary camera briefly obscures Mario during the transition.

Supplied-state test: marked setup edits are not controller inputs.

## 00:01:44.700–00:01:49.367: Mario lands on the upper walkway

3/3  SEPARATE SUPPLIED INK FIXTURE  |  A inputs: 0  |  slow motion

The conditional installation and elevator bypass work.
The missing clean approach is not supplied by this footage.

Supplied-state test: marked setup edits are not controller inputs.

## 00:01:49.367–00:01:55.367: What remains open

RESULT  |  COMPONENTS DEMONSTRATED; FULL ROUTE OPEN

One controller history must deliver a live box,
reach high crawl, and make the timer-130 handoff.
These component demonstrations do not yet establish that route.

No complete clean no-A SSL Pyramid route is established by these clips.
