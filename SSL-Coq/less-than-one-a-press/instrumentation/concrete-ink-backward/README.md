# Concrete backward experiment from Ink

This separate prototype extends Dot's concrete Wafel loop to a real Ink
target. It does not change the symbolic search or the freefall pilot. The
first backward move proposes a low collision record and raised display from
the accepted-warp relationship. The full game validates the candidate.
Earlier inverse moves propose ordinary ground copy/sinking, four freefall
quarters, and the final automatic-dialog update. The game decides floor
queries, collisions, cancellation, clamps and every callback.

The target is successful upper-warp acceptance inside the update, followed by
capture and retention of the original top and the first Area-2 displacement.
Wafel's action log exposes movement at disappeared-action entry. The separate
emulator observer reads **all nine position words at the accepted return**, before
the action executes, and watches the true first Area-2 apply. Two named controls
pass: supplied movement Y=768 and Y=1861, with collision Y=768 and display
Y=1938.8648681640625. The second is a useful installation variant and is kept;
requiring identical movement height at acceptance would discard it.

## Measured result, 2 October 2026

The 30-update horizon's finite tree empties at depth two. Of 216 last-update
proposals, 180 reproduce the selected installation/capture fields, grouped
into five retained pose cases; 36 fail. All 6,300 earlier proposals fail to reproduce those parents. Search
takes 41.0987075 seconds; preparation and controls bring the run to 42.5552236
seconds. Median trial time is 6.0912 milliseconds. **Only one backward update
is validated; no thirty-edge chain was obtained.** This prices this pruned
finite tree, not exhaustive one-second coverage or a larger-horizon search.
Five additional neutral controls replay the retained pose cases through Area 2
from one initial patch, with no intermediate state operations; all reproduce
the displacement. Those controls are outside the timed search. Other input
variants are not proved equivalent in omitted state.

## Conditions and limitations

The full scene contexts come from normally initialized SSL after supplied
four-pillar completion and neutral updates to timer 131. Mario is unmounted.
Pose, vertical speed, action fields and selected negative-depth values are
conditional patches. No action constructor, negative seed, valid reward
contact or route to these patches is proved. The original context's omitted
state is supplied, not independently compared.

Parent equality compares movement, collision, display, action and depth.
The final comparison additionally checks action argument, used warp, floor
height/owner and captured platform, plus movement at action entry. Other
observed fields support restore checks but are not suffix equality claims.
Each extended trial restores its earliest full context, patches once, and
advances continuously. It stops on a mismatching checkpoint and restores the
caller; it never patches or restores an intermediate state.

The finite move menu samples six last-query heights, five freefall speeds,
three ground heights, selected zero/negative depths, and 36 released-A input
representatives (neutral/B/Z/B+Z with nine stick directions). It does not
enumerate all binary32 values, controller samples, action histories, moving
support, late writers or other scene contexts. A beam limit can discard
additional distinct parents; none were discarded in the checked run. Empty
frontier means **nothing survives this menu in these contexts**, not that Ink
or these entire gameplay mechanisms are impossible. No Coq result is claimed.

## Commands

Use the installed Windows x64 Python 3.9.13 / Wafel 0.8.5 runtime for the DLL:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/concrete-ink-backward/search.py --depth 30 --candidates 7500 --seconds 60 --beam 5 --output build/concrete-ink-backward/20261002-final/report.json
& './build/wafel-pilot/python/python.exe' -m unittest discover -s instrumentation/concrete-ink-backward -p 'test_*.py' -v
```

Use Ubuntu-24.04's existing Mupen64Plus 2.5.9 pure interpreter for the exact
checkpoint controls. The runner authenticates the ROM and instruction ranges,
compiles with warnings as errors and imposes a 90-second emulator limit:

```sh
bash instrumentation/concrete-ink-backward/capture.sh /path/to/baserom.jp.z64 768
bash instrumentation/concrete-ink-backward/capture.sh /path/to/baserom.jp.z64 1861
```

Ten new bookkeeping, inverse-map and receipt controls pass. The original
fifteen pilot tests still pass. The test backend is not a game model.
`expected-result.json` preserves the compact measured receipt and hashes.
Full reports and emulator logs remain in ignored build output; no ROM, DLL,
save state, conversation export or credentials are published. See
[the experiment note](../../docs/notes/rank1-concrete-ink-backward.md).
