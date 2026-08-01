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
authentic ROM execution after the resulting Area-1 entry.  Equivalence between
this level-select-initialized state and a castle-entered `CleanPyramidEntry`
has not been proved.

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
