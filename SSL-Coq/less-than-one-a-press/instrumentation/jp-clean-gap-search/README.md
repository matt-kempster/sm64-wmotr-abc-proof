# JP Area-1 Graphics/Object gap search

This directory contains a bounded, reproducible runtime search for a Mario
Graphics-minus-Object Y gap in the original Japanese game.  The search was
motivated by the conditional timer-131 pyramid-top fixture: putting Mario's
collision Object in the upper-warp hitbox while retaining a Graphics floor
sample on the top requires at least a 960-unit positive Y gap.

The probe is read-only with respect to game memory.  It supplies controller
inputs, samples the live Mario State, Object, and Graphics coordinates once
per Area-1 controller poll, and reports the first positive gap above 45 and
the first gap at least 960.  A nominal zero-A run fails unless all three of
the following remain zero:

- controller A output;
- the game's `A_BUTTON_DOWN` input bit;
- the game's edge-triggered `A_BUTTON_PRESSED` input bit.

## Boundary and important caveat

`run.sh` authenticates the ROM by both hashes before starting:

```text
MD5     85d61f5525af708c9f1e84dce6dc10e9
SHA-256 9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
```

The emulator is started with `--cheats 6`, which initializes the level-select
facility by an external patch.  The plugin then navigates that menu with
controller input.  Consequently, `inputPluginMemoryWrites=zero` means exactly
that the input plugin has no game-memory write API; it does **not** mean that
the whole bootstrap performs no write.  The reported measurements cover
authentic ROM execution after the resulting Area-1 entry.  For the Timer-131
entry-prefix question, the final Area-1 `clear_objects` call reached through
this level-select path is the accepted start boundary; ordinary castle-entry
equivalence is therefore not an obligation for this route.

The samples are controller-poll boundary observations.  They do not by
themselves exclude an intraframe split that is both created and consumed
between polls.  Nor does a finite input census prove that no other clean
controller schedule can create the gap.

## Search modes

The fourth argument to `run.sh` selects a deterministic schedule:

| Mode | Post-entry schedule |
| ---: | --- |
| 0 | Acquire the stock jumping box with B, aim its automatic bounces toward the eastern shell box, then use B movement along fixed waypoints. |
| 1 | Stick-only motion toward `(7000, 6500)`, deliberately exercising deep quicksand and the fatal action. |
| 2 | Neutral gameplay input. |
| 3 | Acquire the jumping box, aim southwest toward `(-5125, -3138)`, and continue B movement toward that point.  This was an exploratory fire-source target; the observed path reached a Tweester but not fire. |
| 4 | Follow mode 3 until the first Tweester release, then steer toward the upper warp. |
| 5 | After the first Tweester release, steer west until a second capture, then steer toward the upper warp. |
| 6 | Continue west until four total Tweester captures, then steer toward the upper warp. |
| 7 | Use the jumping box and northeast Tweester to touch the northeast pillar detector, lure the southeast Tweester south, then use its lift to touch the southeast detector.  The recorded schedule then heads back toward that Tweester and terminates in quicksand. |
| 9 | From mode 7's two-pillar checkpoint, wait for the southeast Tweester to reset, capture it, relay through the northeast Tweester, then steer directly toward the west Tweester.  If that succeeds, continue through both western detectors with the west jumping box.  The recorded run failed on the direct-west leg. |
| 10 | Single-variable correction to mode 9: after the northeast release, first target `(-2200, 3500)` until `x < -2000`, then resume the same west-Tweester and four-detector continuation.  The recorded run still reflected from the central-pyramid flank before reaching `x < -2000`. |

The fire diagnostics are deliberately secondary.  The source callback reached
through `gMarioObject->prevObj` transforms the linked flame object, not Mario's
Graphics position.  The fields remain logged so that accidental fire exposure
is visible, but they are not treated as a Mario-gap writer.

## Reproduction

The script requires `mupen64plus`, its Rice video and HLE RSP plugins, `xvfb-run`,
and a C compiler.  For example:

```sh
bash run.sh /path/to/baserom.jp.z64 1800 0 0
bash run.sh /path/to/baserom.jp.z64 900 0 1
bash run.sh /path/to/baserom.jp.z64 900 0 2
bash run.sh /path/to/baserom.jp.z64 1800 0 4
bash run.sh /path/to/baserom.jp.z64 2400 0 5
bash run.sh /path/to/baserom.jp.z64 2400 0 6
bash run.sh /path/to/baserom.jp.z64 5000 0 7
bash run.sh /path/to/baserom.jp.z64 8000 0 9
bash run.sh /path/to/baserom.jp.z64 8000 0 10
```

The generated plugin, emulator log, and filtered trace are placed under
`../../build/instrumentation/jp-clean-gap-search/mode-M-a0/`; they are build
artifacts and are not committed.

## Observed zero-A results

These results came from the commands above.  Every row had
`aPressedFrames=0`, `aDownFrames=0`, and `controllerAFrames=0`.

| Mode | Area-1 samples | Max State Y | Max Gfx−Object Y | Min Gfx−Object Y | Tweester captures | Upper warp used |
| ---: | ---: | ---: | ---: | ---: | ---: | :---: |
| 0 | 1454 | 1300 | 0 | -4.8500061 | 0 | no |
| 1 | 437 | 38 | 0 | -183.750015 | 0 | no |
| 2 | 554 | 38 | 0 | 0 | 0 | no |
| 4 | 510 | 1550.83582 | 0 | -181.100006 | 1 | no |
| 5 | 801 | 1654.52148 | 0 | -2.34999847 | 2 | no |
| 6 | 1121 | 1654.52148 | 0 | -2.34999847 | 4 | no |
| 7 | 914 | 1550.83582 | 0 | -181.100006 | 2 | no |
| 9 | 1848 | 1626 | 0 | -180.850021 | 5 | no |
| 10 | 1848 | 1626 | 0 | -181.100021 | 5 | no |

### Mode 2 entry-prefix receipt

The neutral mode-2 run now uses read-only execute breakpoints at addresses
obtained from a matching JP build: `clear_objects` at `8029ca60`,
`load_mario_area` at `8027aa0c`, `spawn_objects_from_info` at `8029c830`, and
`init_mario` at `802548bc`.  On the hash-authenticated original-JP ROM, the
last Area-1 entry sequence contains five function entries at timers `347`–`348`:
the shared spawn address is first called from `load_area` for Area-1 objects and
then from `load_mario_area` for Mario.  Immediately afterward, the read-only
entry snapshot reported
Mario as pool slot 67, the MarioState pointer equal to that slot, behavior
pointer `800eb1c0`, `oFlags=00000100`, zero graphical Y offset, and a
one-object player-list ring:

```text
PREFIX_STAGE,stage=clear_objects,sequence=1,pc=8029ca60,returnPC=8037ee68,a0=8038bd88,a1=0000000a,timer=347,area=1,marioObject=00000000,stateMarioObject=00000000
PREFIX_STAGE,stage=load_mario_area,sequence=2,pc=8027aa0c,returnPC=8024b9a8,a0=00000000,a1=00000008,timer=347,area=1,marioObject=00000000,stateMarioObject=00000000
PREFIX_STAGE,stage=spawn_objects_from_info,sequence=3,pc=8029c830,returnPC=8027a964,a0=00000000,a1=80182238,timer=347,area=1,marioObject=00000000,stateMarioObject=00000000
PREFIX_STAGE,stage=spawn_objects_from_info,sequence=3,pc=8029c830,returnPC=8027aa70,a0=00000000,a1=8033a140,timer=347,area=1,marioObject=00000000,stateMarioObject=00000000
PREFIX_STAGE,stage=init_mario,sequence=4,pc=802548bc,returnPC=8024b9b0,a0=80346052,a1=8033a146,timer=347,area=1,marioObject=80346038,stateMarioObject=00000000
ENTRY_IDENTITY,timer=348,marioObject=80346038,slot=67,stateMarioObject=80346038,activeFlags=0101,behavior=800eb1c0,oFlags=00000100,oGraphYOffsetBits=00000000,next=8033b870,prev=8033b870,sentinelNext=80346038,sentinelPrev=80346038,stateMatches=1,tailSafe=1,listRing=1,prefixStage=4
```

The probe now also converts ten virtual ranges to physical addresses and arms
read-only CPU write watchpoints for both Mario pointers, slot 67's list links,
active word, behavior pointer and protected tail, and the two embedded list-0
sentinel links.  The exact accepted epoch contains 19 stores:

| Phase | Exact watched effect |
| --- | --- |
| `clear_objects` | Clear `gMarioObject`, link slot 67 into the free list, reset both list-0 links to the sentinel, and clear slot 67's active half-word. |
| Mario spawn/allocation | Link slot 67 as the only player object, write active value `0x0101`, clear all raw words including `oFlags` and `oGraphYOffset`, install `bhvMario` twice along the constructor/spawn path, and set `gMarioObject` to slot 67. |
| `init_mario` | Set `MarioState.object` to the same slot. |
| First object/behavior update | Make one disjoint half-word write at `Object+0x76`, then execute the behavior-table `OR_INT` store that writes exactly `0x100` to `oFlags`. |

`expected-prefix-write-receipt.txt` fixes every store PC, instruction word,
effective address, width, source value, phase, and endpoint line; its SHA-256 is
`BDDEF78B337F090B21A904760F8871E95F2F8D861DD80756709C0F6ECA5BF295`.
The runner rejects any missing, additional, reordered, or changed watched
store.  `InkTimer131RealEntryPrefix.v` replays the 19 stores from arbitrary old
watched values and proves by computation that they produce the recorded two
Mario pointers, slot/list identity, behavior, active word, `oFlags=0x100`, and
zero graphical offset; it also proves every store overlapping either protected
word is a checked safe full-word write.  This corrects two earlier informal
shortcuts: `clear_objects` does not clear every raw word, and the endpoint lies
after Mario's first behavior pass because allocation itself leaves `oFlags=0`.

The same neutral run now carries a separate, address-bound control-flow
receipt.  The authenticated ROM disassembles as follows: each allocation
attempt's result is tested by `bnez` at `802c9144`, whose taken target `802c91a4`
skips the exhaustion path; that path would call `unload_object` at `802c9174`;
`unload_object` would call `stop_sounds_from_source` at `802c90b0`; and
`load_mario_area` unconditionally calls
`stop_sounds_in_continuous_banks` at `8027aa14`.  Execute breakpoints are also
placed at both callee entries.  The exact receipt is:

```text
PREFIX_BREAKPOINT_ARM,clear=8029ca60,load=8027aa0c,spawn=8029c830,init=802548bc,allocate=802c9120,allocatorFallback=802c9174,unload=802c9088,stopSource=803206f8,stopContinuous=80320890,writeWatchCount=10
PREFIX_CALL_REACH,epoch=8,timer=348,allocateObject=73,allocatorFallback=0,unloadObject=0,stopSoundsFromSource=0,sourceEntrySP=00000000,stopSoundsContinuous=1,continuousEntrySP=80207128
```

`expected-prefix-call-reach-receipt.txt` has SHA-256
`CFB33E9CBE6AE0493897222BEEB1FBA8880A3E8BEC995DF6716AC7B07D48BDC1`.
The runner rejects any address or counter change.  Coq independently decodes
the exact branch and three JAL words and proves that the statically listed
`unload_object -> stop_sounds_from_source` edge is not reached during this
entry.  It therefore needs no protected-memory effect specification.  The
continuous-bank sound call is reached once, and the receipt fixes its first
entry stack pointer at `0x80207128`; this receipt does not eliminate `sqrtf`.
The separate
[`../jp-mips-external-frames/`](../jp-mips-external-frames/) certificate
authenticates the complete retail bodies: `sqrtf` has no store, and every path
through the continuous sound call and its transitive callees writes outside
the entire object pool, including the recorded stack envelope.

The complete filtered trace has SHA-256
`8341AA389D255ABA50BA534A1E95F1A80215E479903C8CC11E8E5450FCE4CE7E`
for the documented 900-frame neutral run.
The probe calls debugger read and execute-breakpoint APIs only; `run.sh`
rejects a probe containing the game-memory write API names used by this
instrumentation suite.  `run.sh` also rejects a trace unless these five exact
callsite lines and the exact slot-67 endpoint occur in order.  This is an
authentic MIPS execution receipt, not a CompCert small-step certificate: it
does not classify every memory-silent instruction between breakpoints or give
Clight semantics to outside calls.  The write receipt does classify every
retail instruction that actually changes a watched range—including code reached
by indirect dispatch or an outside machine-code routine—and the project accepts
its replayed checkpoint, identity, and safe-tail result as
`JPInkTimer131AcceptedEntryTheorem`.  It still is not an IDO-MIPS-to-Clight
simulation theorem; the uninhabited native `JPInkTimer131RealEntryPrefix` is an
optional stronger certificate, not the chosen entry boundary.

The neutral post-entry receipt above exercises the unactivated top's action 0.
The separate [JP lifecycle receipt](../jp-lifecycle/README.md) starts at the
same accepted endpoint, isolates one disjoint pillar-counter fixture, and
checks the real spinning action through timer 131.

### Mode 7 two-pillar checkpoint

The exact command above was run against the hash-authenticated original-JP
ROM with `allow-setup-a=0`.  The trace recorded these counter transitions:

```text
TOP,timer=800,pillars=1,action=0,objectTimer=453,position=(-2047,1536,-1023),platform=00000000
TOP,timer=1109,pillars=2,action=0,objectTimer=762,position=(-2047,1536,-1023),platform=00000000
```

Its exact result line was:

```text
RESULT,area1Frames=914,gapSamples=914,gap45=0,gap960=0,maxGfxMinusObjectY=0,minGfxMinusObjectY=-181.100006,maxStateMinusObjectY=0,maxGfxMinusStateY=0,maxGapTimer=348,maxGapAction=0c400201,maxGapStateY=38,maxGapObjectY=38,maxGapGraphicsY=38,maxCleanStateY=1550.83582,maxStateYTimer=625,maxStateYAction=108008a4,maxStateYX=960.84375,maxStateYZ=4355.40674,maxMarioGraphYOffset=0,fireFrames=14,sawFirePrevObj=1,sawFireParticle=1,usedTornado=1,tornadoCaptures=2,pillars=2,topAction=0,topTimer=914,sawShell=0,rodeShell=0,bPressedFrames=4,warpDisappeared=0,warpUsedObj=0,platformTop=0,aPressedFrames=0,aDownFrames=0,controllerAFrames=0
```

This is a positive clean-reachability witness for the two eastern detectors:
the pillar counter is not inherently blocked by zero-A play.  It does **not**
reach either western detector, start or explode the pyramid top, capture the
top as Mario's platform, use the upper warp, or create a sampled positive
Graphics/Object gap.  In particular, `maxGfxMinusObjectY=0` only rejects the
recorded controller schedule at poll boundaries.  It neither excludes an
intraframe collision/query mismatch nor proves that another controller
schedule cannot complete the remaining two detectors or install the rank-1
payload.  The level-select boundary caveat above also still applies.

### Mode 9 bounded failed relay

Mode 9 was run once for 8,000 emulator test frames against the authenticated
original-JP ROM with `allow-setup-a=0`.  It reproduced the two eastern pillar
touches, then added two pointer-identified relay successes:

```text
MODE9_STAGE,timer=1480,stage=3,label=source-tweester,state=(1888.67126,1,-402.484985),usedObj=803443b8
MODE9_STAGE,timer=1680,stage=4,label=east-north-tweester,state=(1045.80835,7,3501.60718),usedObj=80344618
```

The direct westward leg did not reach the west Tweester.  After a repeat
northeast-Tweester capture, Mario was still moving west at timer 1937 at
`(-1437.07202, 398.532227, 3004.63647)`.  The unchanged twirling action then
reflected from the central-pyramid flank, landed at timer 1974 near
`(-1016.50854, -62.4765, 3282.38281)`, and entered quicksand death at timer
2121.  The bounded result therefore remained `pillars=2`, `topAction=0`,
`mode9WestTweesterCaptured=0`, `mode9WestBoxContact=0`, and
`mode9NorthwestDetectorReached=0`.  All three A counters were zero, and the
largest sampled Graphics-minus-Object Y value was zero.

The preserved build artifacts for that historical run were:

```text
build/instrumentation/jp-clean-gap-search/mode-9-a0/preserved/attempt-1.trace.txt
  SHA-256 E34A8315C7C1297F26348EBB7FF93B4F67EABDDEE88D2595A596854A0CAF8518
build/instrumentation/jp-clean-gap-search/mode-9-a0/preserved/attempt-1.raw.log
  SHA-256 11A55A7494E7DB3F042B024946CA4586A028544D990480BAA4EDD901DA7D484D
```

These files are ignored build artifacts rather than committed evidence; the
mode-9 source and command above are the reproducible artifact.  Mode 9 does
not reach either western detector, activate the pyramid top, or close the
collision/query-sample question.

### Mode 10 bounded failed northern correction

Mode 10 was run once for 8,000 emulator test frames against the same
hash-authenticated original-JP ROM with `allow-setup-a=0`.  It changes only
mode 9's post-northeast-release target: Mario aims at `(-2200, 3500)` until
his X coordinate is below `-2000`, after which the unchanged west-Tweester
and four-detector continuation would take over.

The run again reached `pillars=2`, captured the source Tweester at timer 1480,
and captured the northeast Tweester at timer 1680.  It recaptured that same
Tweester at timer 1789.  At timer 1907 Mario was at
`(-882.784668, 773.532227, 3690.56396)`, about 101 units farther north than
mode 9 at the same sample.  The path nevertheless reflected from the
central-pyramid flank between the timer-1907 and timer-1937 samples.  The
westernmost X was only `-1432.26611`, so the `x < -2000` transition never
armed (`mode10NorthAvoidanceReached=0`).  Mario moved back east by timer 1967,
landed at timer 1973, and entered quicksand death at timer 2121.

The exact result line was:

```text
RESULT,area1Frames=1848,gapSamples=1848,gap45=0,gap960=0,maxGfxMinusObjectY=0,minGfxMinusObjectY=-181.100021,maxStateMinusObjectY=0,maxGfxMinusStateY=0,maxGapTimer=348,maxGapAction=0c400201,maxGapStateY=38,maxGapObjectY=38,maxGapGraphicsY=38,maxCleanStateY=1626,maxStateYTimer=1542,maxStateYAction=108008a4,maxStateYX=1633.14771,maxStateYZ=-603.912964,maxMarioGraphYOffset=0,fireFrames=85,sawFirePrevObj=1,sawFireParticle=1,usedTornado=1,tornadoCaptures=5,mode9Stage=4,mode9WestRimStage=0,mode9DetectorDiveInputs=1,mode9RolloutInputs=1,mode9SurvivalBInputs=2,mode9WestBoxContact=0,mode9WestDetectorReached=0,mode9NorthwestDetectorReached=0,mode9SourceTweesterCaptured=1,mode9EastNorthTweesterCaptured=1,mode9WestTweesterCaptured=0,mode10NorthAvoidanceReached=0,mode9WestmostX=-1432.26611,pillars=2,topAction=0,topTimer=1848,sawShell=0,rodeShell=0,bPressedFrames=8,warpDisappeared=0,warpUsedObj=0,platformTop=0,aPressedFrames=0,aDownFrames=0,controllerAFrames=0
```

The preserved build artifacts for this historical run are:

```text
build/instrumentation/jp-clean-gap-search/mode-10-a0/preserved/attempt-1.trace.txt
  SHA-256 C4B21301B55A515F7711ACFB5CAADFA2AE73ACEDF9CE01650F11037819B0E661
build/instrumentation/jp-clean-gap-search/mode-10-a0/preserved/attempt-1.raw.log
  SHA-256 58B68E1283FC6AC39BD7855849AC9A292A401004F98B52E96214A1D439D4430D
```

As with mode 9, these are ignored build artifacts; the committed source and
command are the reproducible artifact.  This finite failure rejects only the
recorded northern waypoint.  It does not prove that every controller route to
the western detectors is impossible, and it supplies no collision/query
sample mismatch or pyramid-top activation.

No row produced even a positive gap above 45, much less 960.  Mario's sampled
`oGraphYOffset` remained zero.  Mode 1 also gives a useful signed check: as
quicksand depth grew to `183.75`, Graphics Y was *below* Object Y by
`183.750015`; this stock sink moved in the wrong direction for the proposed
payload.

Modes 4–6 establish a real zero-A elevation primitive.  The jumping box can
reach a stock Tweester, and repeated captures reached a synchronized peak of
`1654.52148`.  The schedules nevertheless did not use the Area-1 upper warp,
did not make the spinning pyramid top Mario's platform, and did not create a
positive Graphics/Object split.  Modes 5 and 6 eventually entered a
disappeared state through a different interaction (`usedObj` was not the
recorded upper-warp object).

## Conclusion

This is a bounded rejection, not a retail impossibility proof.  It rules out
the exact recorded schedules as installers of the 960-unit payload and shows
that jumping-box/Tweester height alone keeps State, Object, and Graphics
synchronized at the sampled boundaries.  The decisive remaining work is the
linked-Clight writer-coverage proof (including intraframe phases) or a genuine
clean controller trace that reaches a positive 960-unit split or installs an
equivalent stale-platform payload by another mechanism.
