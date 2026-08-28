# Conditional JP lower-route one-A controller reconstruction

This hash-gated original-JP fixture corrects an important route-boundary
mistake: the published lower-entrance route's sole A press is the jump from the
upper second pole, not an independent jump used to mount the horizontal
Grindel.  The recovered full transcript identifies this as trial 3 of the
lower route's five trials; trials 1, 2, 4, and 5 have zero-A methods.

The fixture imports the existing Area-2 downstream controller and stages the
live Mario object on the live second pole at `(0,3200,1331)` in
`ACT_TOP_OF_POLE`.  It supplies one controller-A rising edge, holds that same
press through 34 polls in total, and then releases it.  A held sample is A
down, but is not another press.  This matters mechanically: immediate release
activates Mario's strengthened ascent gravity and cuts the pole-jump arc short.
The fixture logs `ACT_TOP_OF_POLE_JUMP`, the first Y=`3840` Grindel-base
landing, every subsequent input change, trigger progress, and target
observations.  The generated CSV is written to:

```text
build/instrumentation/jp-lower-one-a-route/controller-input-changes.csv
```

The checked-in [`pole-segment-inputs.csv`](pole-segment-inputs.csv) records the
exact conditional controller changes from the injected pole-top boundary
through the first Grindel-base receipt.  The short
[`verified-pole-receipt.txt`](verified-pole-receipt.txt) binds those inputs to
the authentic-JP ROM hash and observed endpoint.

Run it with:

```sh
./instrumentation/jp-lower-one-a-route/run.sh \
  /path/to/authentic/baserom.jp.z64 2200
```

## Scope

This is a conditional input reconstruction, not a clean lower-entrance movie.
The inherited lifecycle fixture loads Area 2, and this wrapper injects the
pole-top state so the input suffix can be tested independently.  It does not
claim that the prior thin-pillar clip, reverse teleporter, 100-coin-star dance,
climbing, or pole-grab sequence has been reproduced.  Nor does it convert the
supplied edited video into an `.m64`.  A clean proof must replace the staged
pole-top boundary with one continuous retail prefix and preserve the same
controller history.

The controller fixture is still valuable because it gives the exact logical
installation needed by the route proof: one A edge belongs to
`SecondPoleJumpOffGate`, its held continuation adds no edge, and all later Amp,
Grindel, elevator, trigger, and target work is downstream.  If the route fails
after the pole jump, the first logged input, action, floor, trigger, or target
mismatch identifies the portion that still needs tuning rather than
relocating the A press.

## Current authenticated result

On the authentic JP ROM accepted by `run.sh`, the fixture observed:

```text
LOWER_ONE_A_STAGE,timer=516,pole=80350418,mario=80346e78,grindel=8034ff58,grindelPos=(-870,3840,105),action=00100345,pos=(0,4020,1331),faceYaw=9e57
LOWER_POLE_JUMP,timer=517,relative=1,action=0300088d,pos=(-21.434082,4082,1307.7124),forwardVel=31.6499996
LOWER_GRINDEL_BASE,timer=552,relative=36,action=04000471,pos=(-828.599365,3840,429.973511)
```

The final counters were `injectedAFrames=34`, `aPressedFrames=1`,
`aDownFrames=34`, and `controllerAFrames=34`.  This proves the conditional
retail-machine pole segment has exactly the intended one-A edge and identifies
the first downstream Grindel-base landing.  The Rocq companion independently
checks the same button shape: one edge, 33 further held samples, release, then
A up.

An earlier one-frame tap followed by immediate release reached only the
Y=`3942` ring.  That is retained as a diagnostic of the stock short-jump
gravity branch, not as the reconstructed route.

The current continuation is deliberately recorded as incomplete rather than
presented as the published route.  It lands near the live Grindel and explores
the source-derived far-corner floor band, but its tested analog approach does
not select the Grindel as Mario's platform.  The full transcript specifies the
remaining homing-Amp, Grindel-misalignment, and undescended-elevator stages;
what remains missing is the `.m64` or fresh frame-exact tuning for those
stages.  The video alone does not reveal those controller samples.
