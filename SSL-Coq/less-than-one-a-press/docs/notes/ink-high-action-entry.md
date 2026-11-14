# High-air shell entry: action conversion is not a useful handoff

14 November 2026. **These finite searches found no useful spawning
displacement.** They do create a ground slide natively from a supplied high
airborne Mario, including at Y25000 and Y67277. The no-box version makes the
fresh low cache and large gap but stays over the pad, so it takes the ordinary
warp. A separate earlier shell conversion can create a supported slide on
the moving top without writing a ground action. Its later single box shove
still does not provide the required fresh low cache.

This study starts at proof revision
`651c180e594e45c6825f9c4800da11f4afef0773` and decompile revision
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, preserving existing local changes.
It uses Wafel0.8.5 JP under Python3.9.13, DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The accepted 2548-input prefix, including disclosed pre-game debug level
selection, has SHA256
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
The [combined receipt](ink-high-action-entry-receipt.json) pins all scripts,
support helpers, relevant source files, raw outputs and selected traces.
No new original-JP ROM replay, Coq theorem or controller-reachable initial
air/shell state is claimed here.

## Shell conversion in the high working windows

The prior [shell study](ink-airborne-shell-entry.md) explains why mounting
ends interaction processing before a later Crazy Box handler. The new test
removes that box and asks whether a different starting X/Z plus next-update
wall resolution can supply the missing crossing by itself.

The existing shell-box slot32 is supplied action4 before behavior128; two
native updates create shell126. Before130 the initial cut supplies M=C=D
`(X,Y,Z)`, FREEFALL, action state/timer0, forward20, velocity `(20,-16,0)`,
facing `(0,16384,0)`, and shell XYZ `(X,Y-10,Z)`. Nothing writes ground action,
slide velocity, floor/cache, platform, top phase, RNG or collision surfaces.
One neutral-stick Z press follows, then all input is neutral. A remains
released. The initial air pose and actual high shell coordinates are grants.

Interaction processing natively selects RIDING_SHELL_GROUND, then Z selects
CROUCH_SLIDE; Wafel action events show the actual slide handler executing.
The high stopped quarter cannot commit X/Z. For fresh pad-cache cases it
saves high stored graphics D, aligns M/C to768 and bonks. D is `gfx.pos`,
not a statement about the model's rendered matrix or visible height.

| Supplied center height at X/Z=(-1950,-939) | Producer M/C Y | Stored D Y | Result |
| --- | ---: | ---: | --- |
| 1741 | 768 | 1741 | Ordinary Area2 `(0,5500,256)` |
| 21777 | 1914.344482421875 | 21777 | Top still loaded; native butt slide on top, no useful arrival within34 updates |
| 21778 | 768 | 21778 | Ordinary Area2 |
| 25000 | 768 | 25000 | Ordinary Area2 |
| 32767 | 768 | 32767 | Ordinary Area2 |
| 67277 | 768 | 67277 | Ordinary Area2 |

Thus the default integer high window begins at21778, not21777. The earlier
height map's adjacent-float threshold21777.658203125 is not replaced by this
table. High Y can make the fresh cache and action conversion work without
making the later retry or displacement work.

At the successful-gap center controls, the next low geometry update moves
Mario to `(-1995,768,-971)`, finds the real pad, accepts the ordinary warp
and retains no top. The high graphics retry is not needed. Shell-only search
therefore must find a different geometric result, not merely repeat that gap.

## Pad and boundary coverage

The first grid checks X=-2140..-1840 and Z=-1170..-790 in steps4, at Y25000
and67277: **14,592 initial-air recipes**,29,184 screened updates. Its4,998
producer cases with floor768 all have an ordinary accepted warp at the next
boundary and no top platform. All candidate recipes follow from the recorded
menu; detailed two-update projections are retained for the low-pad cases.

The selected pad triangles have vertices at X=-2149/-1945 and Z=-1125/-921.
The refined menu tests their signed-integer truncation transitions: exact
binary32 neighbors of -2150,-2149,-1946,-1945 in X and
-1126,-1125,-922,-921 in Z, quarter/half/three-quarter offsets, integer
samples along each edge, and the corner crossproducts. Deduplication gives
13,200 X/Z pairs per height, or **26,400 recipes /52,800 updates**. This is
a finite boundary menu, not every real point in the pad region.

The refined screen has7,434 fresh768-cache cases, all taking the ordinary
warp without top capture. The other18,966 start with roof1280 rather than
the desired cache;4,256 of those show floor768 at the following boundary
but do not install the top. Those later floor changes are not successes.
No candidate captures the top at the intended acceptance update.

The exact neighboring pair at Z=-939 illustrates why coarse grids were not
treated as an exhaustive result: X=-1946.0001220703125 uses768 and the next
update moves to `(-1995,768,-971)`, while X=-1945.9998779296875 selects1280.
The pair around Z=-922 behaves analogously. Just inside the opposite edges,
X=-2148.999755859375 and Z=-1124.9998779296875, low wall resolution clamps
to X=-2099 or Z=-1075 and still finds the pad. Exact selected corner/neighbor
traces are retained through34 updates or Area2.

Six center controls independently match159 full boundaries; twelve final
edge controls match336 from separate fresh boots. These controls, not all
screen negatives, receive the longer continuation. No finite negative is
promoted into an all-history exclusion.

## Earlier shell conversion into a real supported slide

This branch intentionally uses initial **Y21700**, below the phase-specific
collision-unloading threshold but above the no-ceiling stop threshold. It
is an action initializer, not a claim that21700 is a useful handoff height.
The native shell cancellation aligns Mario onto the actual loaded top and
can leave BUTT_SLIDE/platform61. The following producer is at the local top
height, no longer at21700 or in a VPU.

The shell spawn is supplied before125 and initialized normally. Initial air
cuts at127/128/129 vary X=-2240..-1760 and Z=-1260..-780 in steps20, four
cardinal headings, speed20, and shell10 below. First input is Z; later input
is neutral. Before130 only the Crazy Box XYZ may be supplied. Its targets
are combinations of X=-1890/-1882/-1874 and Z=-970/-939/-925, using the real
107-unit push radius and the observed native pre-action position; impossible
overlaps are rejected. Neither Mario's later position nor action is edited.

The7,500 air seeds yield7,364 eligible native walking/ground-slide states;
3,873 actor-only placements pass the proposal checks. **None produces the
fresh768-cache/high-position gap or intended top capture.** The best retained
case independently matches37 boundaries. Its native supported slide still
has platform61 before130, and the actor shove ends at Y1836.052734375 with
that high floor cache, rather than at the warp. Native platform carry and
the new floor refresh must be handled before the later shove can help.

A separate export checks3,844 one-update initializers at128 and finds892
native BUTT_SLIDE/platform61 states at local Y1740–1801 before129. Twelve
selected states match from fresh boots. For example, supplied air
`(-1880,21700,-870)`, yaw0, speed20 with the shell10 below yields native
`(-1880,1798.105712890625,-870)`. The source action transition is real, but
the initial air/shell placement remains supplied. These recipes were passed
to the moving-actor study as predecessors; they are not handoff successes.

## Remaining question

This narrows two named branches without answering all usable positions.
Same-update shell cancellation lacks a later box shove, and the tested wall
resolution alone does not create the retry. An earlier shell conversion can
create the ground action, but a single late box shove from an intact carried
top state has the wrong fresh cache. A moving actor that first removes support
and then supplies a later crossing is a separate joined-history experiment.
Any positive must retain the top through the warp and actually reach useful
Area2 displacement. A ground action, a large gap, or a later low cache alone
does not meet that criterion. No route-estimate change is justified here.

The subsequent [native throw comparison](ink-moving-box-entry.md) and
[two-actor/speed refinement](ink-high-action-entry-actor-cuts.md) test those
more specific repairs. They confirm native two-type pushes and fast slide
velocities but still do not produce a useful handoff. Their separate menus,
grants, nearest failures and fresh replay counts should not be folded into
the four original batches reported above.
