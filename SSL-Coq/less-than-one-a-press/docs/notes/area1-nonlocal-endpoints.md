# SSL Area 1 nonlocal, failed-cast, and out-of-bounds endpoints

In this note, a coordinate outside ordinary level bounds is not automatically
an out-of-bounds *memory access*.  Nonlocal finite coordinates and defined
signed-16 casts remain analyzable in Clight.  An invalid memory dereference,
OOB store, ACE, or post-undefined-behavior machine continuation has no witness
in the current Clight model and requires separate MIPS/hardware semantics; no
retail verdict follows from that exclusion.  See
[the project execution-scope boundary](../compcert-execution-scope.md).

## Verdict

The old description mixed two materially different cases.

- **Target evidence rules out failed word conversions as continuing
  endpoints.**  NaN, positive or negative infinity, `+2^31`, and the first
  binary32 value below `-2^31` trap during the VR4300 `trunc.w.s`
  instruction.  Infinity and signed-word overflow raise Invalid, which US and
  JP initialize as enabled; a NaN conversion is also in the VR4300's trapping
  unimplemented-operation class.  The stock exception handler stops the
  faulting gameplay thread instead of resuming at `mfc1`, so there is no
  halfword store, spatial-partition selection, or continuing `find_floor`
  result.  A cached object collision
  may already exist from the earlier collision phase, but the trap does not
  turn the failed conversion into a terrain coordinate or a continuing route.
  The often-repeated masked-exception story in which `0x80000000` is narrowed
  to halfword zero does not describe that initialized retail prefix.  Inside
  Rocq, applying this conclusion to every reachable retail cast remains
  conditional on the named instruction-prefix, FPCSR-preservation, and
  handler-continuation bridges below.
- **Finite signed-32 conversions followed by signed-16 wrapping remain real.**
  The already authenticated `63488.0f -> -2048` sample is one example.  Rocq
  now checks the complete vector
  `(-1862,67314,-902) -> (-1862,1778,-902)`.
- **A finite nonlocal endpoint can be useful only through a phase split.** A
  synchronized remote Mario does not touch the local upper warp because
  object hitboxes use full binary32 coordinates.  The source schedule reads a
  separate collision Object and later State query, but clean coexistence of a
  local Object and nonlocal State in that window remains unproved.

The new Y-alias sample is now a **conditionally executed retail capability**,
not merely a numeric possibility and still not a clean route:

```text
collision MarioObject = (-2048,   768, -1024)  // upper-warp centre
pre-query MarioState  = (-1862, 67314,  -902)
terrain query         = (-1862,  1778,  -902)  // signed-16 narrowing
```

The narrowed query is exactly the checked timer-131 midpoint.  The existing
surface arithmetic accepts its top face and returns height bits `0x44defe16`
(approximately `1783.940186`).  A hash-gated original-JP replay now injects
the three views above while the live top is at timer 131.  It observes the
candidate State X/Z survive, a top-owned floor with height word `0x44defe16`,
the cached upper warp selecting `ACT_DISAPPEARED`, the floor snap, equality of
State/Object/Graphics after the copy, and final `gMarioPlatform` equal to the
same top slot.  The deliberately different Graphics X/Z do not replace State,
which is consistent with the first query succeeding and the retry branch not
running under the audited source order.  The probe does not breakpoint that
branch; an unclassified later restoration remains part of linked writer
closure.  All three recorded A counters are zero.

This closes the candidate's conditional retail *engine outcome*.  The replay
also writes the three-view prestate and arms the top; it supplies no clean
predecessor.  The candidate therefore avoids Ink's *Graphics retry* and its
`>=960` Graphics/Object gap only after replacing that problem with the harder
one: installing the three-dimensional State/Object split before collision.

## Exact cast cases

`Area1NonlocalCastSemantics.v` now gives a total CompCert-level split for one
binary32 coordinate:

1. `Float32.to_int` succeeds and the signed word lies in the recorded local
   SSL interval `[-4148,6758]`;
2. it succeeds outside that interval, after which signed-halfword narrowing
   may alias a local terrain coordinate or remain outside useful engine
   bounds; or
3. it fails.

The interval is the project's route-local mesh envelope, not the engine's
full `[-8191,8191]` lookup range.  Thus “successful nonlocal” is broader than
“one whole Parallel Universe away.”

The target-prefix model distinguishes a coordinate result, a trap,
and a deliberately unspecified masked-invalid result.  No theorem invents a
halfword coordinate for the masked case.  The model proves generally that a
failed conversion with Invalid enabled traps before a terrain coordinate can
be produced.  Five concrete CompCert conversions are checked separately, one
opaque theorem at a time, to keep checker memory bounded:

| Binary32 input | CompCert word conversion | Enabled target-prefix result |
| --- | --- | --- |
| quiet NaN `0x7fc00000` | failure | trap (collapsed target-prefix result) |
| `+infinity` `0x7f800000` | failure | Invalid trap |
| `-infinity` `0xff800000` | failure | Invalid trap |
| `+2^31` `0x4f000000` | failure | Invalid trap |
| below `-2^31` `0xcf000001` | failure | Invalid trap |

The adjacent finite endpoints sharpen the boundary: `0x4effffff`
(`2147483520.0f`) converts successfully and narrows to `-128`, while
`0xcf000000` (`-2147483648.0f`) converts successfully and narrows to `0`.
The project also proves a total arithmetic split after narrowing for
horizontal X/Z: strictly inside `(-8192,8192)`, rejected at that boundary, or
failed word conversion.  Being inside the boundary does not prove that a floor
exists in the selected cell, and Y has no analogous horizontal-boundary test.

`Area1NonlocalYCastArithmetic.v` checks all three components of the surviving
finite sample:

```text
X: binary32 0xc4e8c000 = -1862.0f -> word -1862 -> signed16 -1862
Y: binary32 0x47837900 = 67314.0f -> word 67314 -> signed16 1778
Z: binary32 0xc4618000 =  -902.0f -> word  -902 -> signed16  -902
```

It now also checks the corresponding CompCert `Cop.sem_cast` results from
binary32 to signed `short` for all three values and the value-level target
`trunc.w.s; mfc1; sh; lh` prefix arithmetic.  These are value semantics, not
generated-statement execution or an imported target-machine small-step proof.

## Target evidence

The pinned decomp revision remains
`9921382a68bb0c865e5e45eb594d9c64db59b1af`.

`include/PR/R4300.h` defines:

```text
FPCSR_FS = 0x01000000
FPCSR_EV = 0x00000800  // enable Invalid Operation
```

`lib/src/osInitialize.c` installs `FPCSR_FS | FPCSR_EV`, and
`lib/src/osCreateThread.c` initializes every new thread context with the same
value.  The canonical ROM receipts are:

| Version | ROM SHA-1 | File offset | Three instruction words |
| --- | --- | ---: | --- |
| JP | `8a20a5c83d6ceb0f0506cfc9fa20d8f438cafe51` | `0xDD8D0` | `3c040100 0c0c9dec 34840800` |
| US | `9bef1128717f958171a4afac3ed78ee2bb4e86ce` | `0xDE800` | `3c040100 0c0ca1cc 34840800` |

The first and delay-slot words construct `0x01000800`; the middle word calls
the version-specific `__osSetFpcCsr`.  The separate
[`retail-find-floor-cast.md`](retail-find-floor-cast.md) receipt authenticates
the byte-identical `trunc.w.s; mfc1; sh; ...; lh` coordinate sequence in both
versions.  The VR4300 manual specifies that an enabled floating-point
exception traps and does not modify the destination register.  The stock path
in `lib/asm/__osExceptionPreamble.s` routes `EXC_FPE` to `panic`, marks the
faulting thread stopped/faulted, posts `OS_EVENT_FAULT`, and dispatches another
thread; it neither emulates the conversion nor resumes at `mfc1`.  The only
game fault-event consumer is compiled out for US and JP.

The Rocq instruction-prefix relation is still a small model rather than an
imported VR4300 operational semantics.  The exact remaining target bridge is
named `RetailInvalidCastExecutionRefinementObligation`; for every reachable
enabled control it requires each target-prefix outcome to equal the modeled
result rather than merely requiring the modeled result to be possible.  A
whole-execution proof must also show that every reachable cast runs with
Invalid enabled;
`RetailInvalidEnablePreservationObligation` records that boundary.  The source
and ROM census make disabling it an unsupported stock hypothesis, while
`RetailInvalidTrapContinuationExclusionSchema` names the still-unimported
handler-continuation fact.  The project does not yet claim a whole-binary FPCSR
writer or MIPS exception-execution theorem.

## Can each endpoint class help?

| Class | Terrain effect | Route effect |
| --- | --- | --- |
| Local successful cast | Normal lookup | Part of ordinary movement; still needs the ordinary route proof. |
| Finite signed-32, signed-16 local alias | Can select an apparently local static or loaded dynamic surface | Potentially useful only with a view/scheduling split.  `63488 -> -2048` and `67314 -> 1778` are checked examples. |
| Finite signed-32 whose signed-16 X/Z is outside engine bounds or has no floor | First query returns no floor | Can enter Graphics fallback.  From synchronized Object/Graphics, a State-only excursion is erased by the retry; a second miss enters the fatal-latch path. |
| NaN, infinity, signed-32 overflow | No terrain coordinate under the initialized enabled-Invalid target prefix | Traps before the query; applying this exclusion to every retail cast still needs the named target refinements. |
| Nonlocal raw Object copied to the next frame | Terrain may still alias | Cannot directly touch the local warp; large X/Z also undermines full-float dynamic-collision loading. |

## Scheduling exhaustiveness

For the relevant Mario input/geometry update there is no newly discovered
ordinary schedule:

1. the first `find_floor(State)` succeeds: this is the existing State-first
   class;
2. it fails and `find_floor(Graphics)` succeeds: this is Ink's retry class,
   and the original State endpoint is overwritten;
3. both fail: the death/game-over request precedes cached upper-warp
   interaction processing; or
4. a later coordinate divergence requires the existing post-copy writer
   escape class.

Ordinary movement on a previous frame is copied to raw MarioObject, so the
next collision pass sees the remote full-float position instead of the local
warp.  On the interaction frame, selecting `ACT_DISAPPEARED` suppresses an
ordinary moving-action body.  Wall resolution can alter X/Z before the first
floor lookup, but the candidate's particular Y value removes that uncertainty:
the two real wall passes sample binary32 Y values `67374` and `67344`, both
strictly above every signed-16 `Surface.upperY`.  A pinned-source/manual
generated-body audit puts that vertical guard before any X/Z push, while the
source-shaped list theorem preserves X/Z for every list of signed-16 upper
bounds.  A linked
Clight proof must still connect valid live list traversal and memory loads to
that theorem.

The source schedule also narrows the clean installer search.  Normal Mario
actions, interaction movement, wall/level-bounds fallback, action-phase PU movement,
and the final State-to-Object copy occur after object collision; a remote
endpoint produced there becomes the next frame's remote full-float Object and
cannot touch the local warp.  Between the preceding Object synchronization and collision, the
only identified stock three-dimensional State-only writer is
`apply_mario_platform_displacement`.  Under the existing finite stock
pre-apply provenance, however, the cached platform is null at the upper-warp
Object sample.  A clean Clight installer must therefore escape that provenance
via a retained/skipped/non-stock/relocated owner, a defined valid alias, a
specified external effect, or another classified internal writer.
Whole-program writer/non-alias closure remains open, so this is a reduction
rather than an impossibility proof.  An OOB installer is deferred to a machine
model rather than counted as a successful Clight writer.

## What the new capability does and does not prove

`Area1NonlocalEndpointBoundary.v` proves at the numeric/model boundary:

- modeled upper-warp contact forces X/Y/Z into the local SSL interval;
- a nonlocal synchronized position therefore cannot directly contact it;
- the exact `67314 -> 1778` binary32/signed-halfword result;
- equality of the narrowed query with the checked timer-131 midpoint;
- the existing midpoint face, edge, plane, and partition-cell arithmetic; and
- arbitrary State-only motion still cannot manufacture Ink's Object/Graphics
  split from synchronized views.

`Area1StateFirstWallExclusion.v` additionally proves the exact two binary32
wall-sample words, the signed-16 upper-bound inequality, bilateral generated
guard-shape receipts, and a source-shaped list traversal that cannot reach an
X/Z push.  `Area1StateFirstRetailTrace.v` checks a transparent copy of the
one-frame JP receipt: exact pre/post words, timers, pointers, action/argument,
branch-result booleans, and zero-A counters.  The latter is deliberately only
a data certificate; ROM/log authentication and linked Clight execution are
named, uninhabited obligations.  A second record checks the focused lifecycle
copy: inactive/free slot 61 at timer 513, free-list depth 47 and retained
platform at the authentic first Area-2 apply, the exact before/after words,
and upper-trigger counter `0 -> 1` at timers 594/595 with zero A counts.

The candidate is not presently easier to install than the local timer-131
sample, but the exact displacement is no longer arithmetically mysterious.
`Area1NonlocalPlatformMirror.v` now constructs the complete payload from the
actual synchronized upper-warp centre.  `apply_platform_displacement` first
adds X/Z velocity, so `(186,122)` maps `(-2048,768,-1024)` to
`(-1862,768,-902)`; a pitch change from `0` to `180` degrees around pivot
`(-1862,34041,-902)` then yields exactly `(-1862,67314,-902)`.  The proof
checks the exact sine-table entries in both versions and the raw signed-angle
truncations.  It also corrects the earlier interpretation: the rotation-only
input `(-1862,768,-902)` is outside the upper-warp radius, so that receipt by
itself already assumed a horizontal State/Object split.

`Area1NonlocalPlatformInstallationClosure.v` proves the negative result at the
current stock boundary.  Every finite trace constructed from the audited seed,
completed final query, preserving frozen carry, US clear, and checked JP
inbound cases has a null platform when the raw Object touches the upper warp.
The exact payload therefore cannot run in that model.  The source/finite
receipts also find no direct required pitch-velocity writer in the canonical
surface callbacks, distinguish the checked fragment values from `-32768`, and
exclude pivot Y `34041` from the complete stock-top timer model and checked
fragments.  A classified successful installation must contain an alias or
external pointer write, owner/surface projection failure, post-query Object
writer, moving skipped query, unchecked retained entry, or unclassified
scheduler shape.  Those live projection escapes remain the boundary between
this stock-model disproof and an unconditional retail impossibility result.

The following remain open and prevent a clean counterexample claim:

1. realize one of the six explicit stock-projection escapes with a clean zero-A
   platform object/pointer and the checked remote-pivot payload, or eliminate
   every escape in linked execution;
2. linked wall execution refining the now-closed source-shaped no-push
   theorem;
3. linked dynamic-list insertion, ownership, traversal, and exact
   `find_floor` selection, despite the conditional runtime observation of the
   right top owner and height;
4. linked Clight execution of cached upper-warp interaction, floor snap,
   State/Graphics/Object copy, and final platform capture, despite the
   conditional runtime observation of all four outcomes;
5. no post-copy overwrite, unload, relocation, clone, or external/aliased
   writer invalidating the sample; and
6. linked Clight refinement of the now-authenticated exact State-first JP
   retained-pointer chronology and first destination apply.

The bounded stock pre-apply model already says a stock platform pointer is
null when the old Mario Object overlaps node `0x1E`.  Lifting that result to
all linked retail states remains open.  Consequently, this work eliminates
failed casts from the checked initialized target prefix, preserves finite PU
aliases as a real primitive, and validates the new State-first candidate from
an injected boundary through its one-frame retail outcome, retained-slot
destination apply, and upper-trigger continuation.  Clean installation and
whole-execution refinement remain open, so it does not prove or refute a clean
zero-A route.
