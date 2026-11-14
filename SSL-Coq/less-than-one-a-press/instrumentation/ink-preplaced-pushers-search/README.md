# Both pushers already present before the shell contact

The exact existing Bob-omb and Crazy Box coordinates work when both positions
are supplied **before update 128**, before the initial airborne Mario cut.
There are no later gameplay-state edits: Z is pressed on 128, followed by
neutral input. Mario reaches the same useful Area 2 spawn as the prior staged
test: `(365.5927734375, 5500, -1096.8026123046875)`.

This package independently reconstructs that one case twice. It compares all
27 recorded rich boundaries and frame events against the separate
[`ink-preplaced-pushers-controls`](../ink-preplaced-pushers-controls/) case.
It also checks the initial producer floor cache in a restored diagnostic
branch. No compensation grid or broader placement search was run: the exact
preplacement succeeded first.

A separate bounded extension also succeeds with both pushers and the shell
placed **one or two updates earlier**, before top phase 127 or 126. It makes
no actor write at the phase-128 Mario cut. These three lead-time cases
(0/1/2) were each reconstructed twice and all reach the exact useful spawn.

## What is supplied

The existing conditional frozen-shell preparation is replayed, including its
fake pickup-pointer and high-HOLP grants. The existing Bob39 receives the exact
native `released91` donor profile before the initial Mario cut. This is a
documented transplant of native fields, not a joined delivery history. Its
32 fields contain 34 scalar components; the native Bob behavior and callbacks
remain active. The Crazy Box's behavior, velocity and other fields are not
changed.

Before update 128, supply only these actor positions in addition to that
already documented profile and shell preparation:

| Object | Slot | Initial XYZ |
|---|---:|---|
| Enlarged black Bob-omb | 39 | `(-2080.06005859375, 1809.2066650390625, -1230.322021484375)` |
| Live Crazy Box | 49 | `(-2102.720703125, 1839.447265625, -1119.5618896484375)` |

Then the single initial Mario cut supplies M/C/G at `(-1960, 19900, -1230)`,
FREEFALL, speed zero and velocity `(0,-16,0)`, with the initialized frozen
shell71 ten units below. The full write ledger is in `positive-case.json`;
the shell preparation, native donor reconstruction and their grants are in
`results.json.gz`. The case has an empty `cuts` array. Nothing is relocated,
refrozen or given a reset fuse after the initial cut.

## Actual native runtime behavior

| Completed update | Mario movement Y | Stored graphics Y | Collision slots | Bob radius / fuse | Crazy Box Y |
|---:|---:|---:|---|---|---:|
| 128 | 1809.206665 | 19900 | 71 | 91 / 170 | 1839.447266 |
| 129 | 1839.447266 | 1809.206665 | 39 | 91 / 171 | 1852.873535 |
| 130 | 768 | 1839.447266 | 49, 39 | 65 / 172 | 1923.485229 |
| 131 | 1914.854980 | 1914.854980 | 64 | 78 / 173 | 1961.437012 |

The Bob stays at its supplied position through 128; its fuse is still 170.
Its distance guard uses stored graphics position, which remains high after
the shell/Z step. The native movement and fuse update begin after Mario's
update 129. The Crazy Box moves naturally, but does not collide with Mario
on 129. It is first in the GRABBABLE interaction list on 130, when both
pushers are registered. Their shared type does not require two pushes in one
pass: the useful pushes occur on consecutive updates.

The initial producer query is
`(-2117.02685546875, 1839.447265625, -1113.008544921875)`.
The isolated cache diagnostic returns static floor 768 and ceiling 1523.
This fork temporarily substitutes DISAPPEARED, reads the refreshed cache,
then restores the whole original save state. Its writes and results are
recorded separately; no diagnostic state enters the real history. Prior
native-query checks support this scoped diagnostic, but it is not a general
action-equivalence theorem. Original-ROM hooks are owned by the separate
preplacement replay packet, not this Wafel package.

The real history reaches the stopped slide split on 130, warp64 with top61
as floor/platform on 131, retains that top through the observed Area 1
suffix, and reaches the exact displaced Area 2 spawn on recorded update 27.
G means stored `gfx.pos`, not the position visibly rendered on screen.

## Reproduce

From `SSL-Coq/less-than-one-a-press` in PowerShell:

```powershell
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-preplaced-pushers-search/check.py' --verify
```

This rebuilds two independent roots and verifies every saved data value.
JSON object-key ordering may differ between Python processes; the archive
checker separately verifies the saved file bytes. The
runtime is Wafel 0.8.5 / Python 3.9.13 with the JP DLL hash
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The proof checkout at reconstruction start was
`0605d842cedb55151e70952d56064553c4970f60`;
the applicable JP source pin remains
`9921382a68bb0c865e5e45eb594d9c64db59b1af`.
`verification.json` records package and input hashes.

This removes the need for two timed actor-position cuts inside this local
handoff. It does not establish how gameplay delivers the frozen shell,
initial airborne Mario, the enlarged Bob with this lifetime, and the Crazy
Box to their initial positions together. Nor does a placement immediately
before 128 show that the actors could wait there for an arbitrary duration.

## Bounded earlier-placement extension

`waiting.py` installs the native Bob profile and supplies all three actor
positions at top phase `128 - lead`, for lead values 0, 1 and 2. It advances
the ordinary conditional preparation with neutral input until 128, then
supplies Mario's airborne state only. This avoids even a redundant shell
position write at the cut. All later real-history writes are controller
input; the restored diagnostic forks remain separate.

The wait is spent with Mario far from the target. His M/C/G positions are
`(5913.544921875,51,3320.7841796875)` at126,
`(5919.318359375,51,3309.181640625)` at127, and
`(5924.513671875,51,3298.7392578125)` at128 before the initial air cut.
The actors keep their supplied XYZ throughout these short waits. Each case
then has the same initial130 floor query selecting768 and reaches the exact
useful spawn after27 recorded updates. The unchanged Mario preparation does
not naturally reach the initial high position: that cut remains explicit.

`waiting-results.json.gz` preserves every profile write, placement, waiting
boundary, Mario-only cut, input, full subsequent boundary and diagnostic.
These finite tests do not establish longer waits or approaches while Mario
is nearby. They are Wafel results; do not relabel the extra lead times as
original-ROM replays unless separately replayed there.

```powershell
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-preplaced-pushers-search/waiting.py' --verify
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-preplaced-pushers-search/archive.py' --verify
```
