# Conditional JP timer-131 State-first probe

This probe tests the numeric State-first candidate on an authenticated original
Japanese ROM.  It is **not** a gameplay-reachability witness.

At pyramid-top action timer 131, the fixture injects:

```text
Mario Object collision position = (-2048,   768, -1024)
MarioState position              = (-1862, 67314,  -902)
Mario Graphics position          = (-1641,  1456,  -783)
gMarioPlatform                   = NULL
```

The Graphics point is deliberately the older, different retry point.  In the
audited source order, a failed first `find_floor(State)` copies that Graphics
X/Z into State before retrying.  Therefore the post-frame values discriminate
the expected paths:

- post-frame State X/Z `(-1862,-902)`: the candidate State coordinates
  survived, consistent with no Graphics retry;
- post-frame State X/Z `(-1641,-783)`: consistent with first-query failure and
  the Graphics retry supplying the floor.

The probe does not breakpoint the first return or retry-copy branch, so an
unclassified later restoration remains part of the linked writer obligation.
The runner additionally requires `MarioState.floor` to name the live pyramid
top, the cached upper warp to choose `ACT_DISAPPEARED`, `usedObj` to name that
warp, the separate final platform query to capture the top, and all modeled A
fields to remain zero.

The shared probe retains the legacy output key `retryOwnerTop`; in State-first
mode it means that the post-frame `MarioState.floor` owner is the top, not that
a retry occurred.

Run:

```sh
./instrumentation/timer131-state-first/run.sh /path/to/baserom.jp.z64
```

The runner hash-gates the input ROM and writes only ignored output below
`build/instrumentation/timer131-state-first/`.

A passing trace establishes a conditional retail engine capability for the
injected split.  It does not establish a clean zero-A writer for that split,
authenticate a clean predecessor, or prove the later retained-slot chronology
in linked Clight semantics.

`proofs/Area1StateFirstRetailTrace.v` contains transparent data receipts for
this focused frame and the lifecycle continuation below.
`proofs/Area1StateFirstWallExclusion.v` separately proves the binary32
high-Y wall guards in a source-shaped traversal.  Neither file treats the
external trace as a Clight execution theorem.

## Lifecycle continuation

`run-lifecycle.sh` supplies the same fixed State/Object/Graphics boundary to
the existing JP lifecycle harness.  It checks the top's explosion and early
free, the authentic first destination-area platform-apply boundary, and the
default zero-A continuation to the upper hidden-star trigger:

```sh
./instrumentation/timer131-state-first/run-lifecycle.sh \
  /path/to/baserom.jp.z64
```

The focused, hash-gated output must exactly match
`expected-lifecycle-trace.txt`.  This is still a conditional injected replay,
not evidence that clean play can construct the State/Object split and not a
linked Clight-memory execution theorem.

The authenticated replay passes.  Its post-query state is the same
capture-preserving midpoint state as the earlier Graphics-retry fixture.  The
top remains the recorded platform through its timer-513 explosion and early
free at depth zero.  At the authentic first Area-2 apply entry, the inactive
slot remains at free-list depth 47 and `gMarioPlatform` still points to it.
The apply changes MarioState from `(0,5500,256)` to
`(365.592773,5500,-1096.802612)` before Object and Graphics synchronize.  The
fixed zero-A continuation then consumes the upper hidden-star trigger at
timer 595, changing the controller counter from zero to one.  Every recorded
A-edge, A-down, and controller-A count is zero.
