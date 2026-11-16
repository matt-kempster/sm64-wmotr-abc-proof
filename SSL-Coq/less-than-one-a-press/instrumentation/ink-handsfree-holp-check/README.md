# Actual hands-free box holding still refreshes HOLP

**The existing controller-reached hands-free stomach slide does not preserve
an old remote HOLP.** Its held box is still drawn, so the native graphics
callback refreshes HOLP every tested update. This is a narrow check of this
real hands-free state, not a universal exclusion of every state called
hands-free or every way to avoid rendering an object.

## Reached state, without Mario or actor edits

`check.py` replays the first436 controls of the existing610-input eastern
Crazy Box history retained in `docs/notes/ink-clean-handsfree-receipt.json`.
The complete610-input canonical LF hash is
`f1cb547ac44de4044c6f174ce972fac23610a8fa3f2429347e9af4d84e919cb8`.
The only non-controller initialization is the accepted pre-entry debug-level-
select flag. Actual dive pickup obtains stock Box47 at input424, lands in
DIVE_PICKING_UP at435, and enters STOMACH_SLIDE at436 while preserving the
held reference and the object's HELD_HELD state.

Two branches then execute the next20 original no-A inputs:

1. **Unedited control:** observe the actual state and HOLP.
2. **Remote-HOLP diagnostic:** immediately after actual input436, change only
   HOLP to `(-1962.4404296875,67277,-1243.34130859375)`, then execute those same
   inputs. No action, Mario position, actor position or held pointer is supplied.

Each branch remains STOMACH_SLIDE, holding Box47 in HELD_HELD, with native
handState0 and grabPos1. Each contains21 different HOLP values across its
initial boundary and20 updates. The remote value is overwritten on the very
next update. Every recorded field after that update matches the unedited
control exactly.

| Completed inputs | Action / held actor | HOLP |
|---|---|---|
|424|DIVE / Box47|`(1143.915527,146.860687,6433.403320)`|
|435|DIVE_PICKING_UP / Box47|`(1139.394165,40.949066,5944.427734)`|
|436|STOMACH_SLIDE / Box47|`(1129.502319,87.352814,5919.535645)`|
|436 diagnostic only|Same genuinely reached state|Supplied `(-1962.440430,67277,-1243.341309)`|
|437, both branches|STOMACH_SLIDE / Box47|`(1127.732910,102.540359,5884.484375)`|
|456, both branches|STOMACH_SLIDE / Box47|`(1051.584839,94.644775,5890.546875)`|

## Source explanation and limits

The applicable native `geo_switch_mario_hand_grab_pos` in `mario_misc.c`
assigns the held-object graph node whenever `marioState->heldObj` is non-null.
Its GEO_CONTEXT_HELD_OBJ callback refreshes `heldObjLastPosition` from the
render transform. This path does not require an ordinary holding action ID.
That matches the prior project's meaning of this hands-free state: an action
and held-reference disagreement, with the object still visibly attached.

An actor left in HELD_HELD while Mario's held pointer is null is a different
state. Camera culling or other circumstances that prevent the held-object
render callback are also separate conditions. They are not tested here and
should not be collapsed into the observed clean hands-free slide.

Both branches and their436-input acquisition were independently reconstructed
twice. The packet retains the full acquisition controls,27 acquisition
observations covering inputs410–436, both20-input continuations, their42
boundary snapshots and the one optional HOLP-write ledger. Every controller
input keeps A released; the runtime also checks the Mario A-input flags.
This is fresh JP Wafel evidence, not a new original-ROM replay or Coq theorem.
It adds no claim of useful Ink handoff or completed actor delivery.

## Reproduction

From `SSL-Coq/less-than-one-a-press`:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-handsfree-holp-check/check.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-handsfree-holp-check/archive.py --verify
```

Start proof revision `ea1a4994f5157636f481723a89c6411a53e6e6d4`; applicableJP
source pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`; local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Wafel0.8.5/Python3.9.13 uses
JP DLL SHA256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
