# Concrete backward experiment from Ink

The 3 October variant-only mode uses `--target low-display`. It requires
movement Y=1861 at the action-entry checkpoint with collision/display Y=768
and a supplied depth-zero setup. Its thirty-update horizon checks 1,476
proposals in 9.947622 seconds, keeps one last-update pose and empties at depth
two. All 1,260 sampled earlier moves fail. The final-dialog near match copies
collision Y to 1861. See [the follow-up note](../../docs/notes/rank1-low-display-backward.md)
and `expected-low-display-result.json`; the earlier measurements below are
preserved separately. The current fifteen search tests and fifteen original
pilot tests pass. No thirty-edge chain or gameplay producer is claimed.

The separate `dialog_continuation.py` check advances the supplied neutral
final-dialog near match for 24 updates from one patch. It confirms no warp or
Area-2 entry: dialog blocks interaction, then collision Y=1861 is above the
upper warp's Y=768..818 hitbox, and the next update refreshes display as well.
`expected-dialog-continuation.json` records that finite check; it is not a new
backward search, gameplay witness or Coq exclusion.

"Dialog" here is the automatic milestone-message action, supplied at action
state 24 before its final update. The candidate already has movement Y=1861,
collision/display Y=768 and depth zero. No star pickup or opened message is
used to construct it; that predecessor's gameplay validity remains conditional.

This separate prototype extends Dot's concrete Wafel loop to a real Ink
target. It does not change the symbolic search or the freefall pilot. The
first backward move proposes a low collision record and candidate display from
the accepted-warp relationship. The full game validates the candidate.
Earlier inverse moves propose ordinary ground copy/sinking, four freefall
quarters, and the final automatic-dialog update. The game decides floor
queries, collisions, cancellation, clamps and every callback.

The target is successful upper-warp acceptance inside the update, followed by
capture and retention of the original top and the first Area-2 displacement.
Wafel's action log exposes movement at disappeared-action entry. The separate
emulator observer reads **all nine position words at the accepted return**, before
the action executes, and watches the true first Area-2 apply. Three named
controls pass: supplied movement Y=768 and Y=1861 with collision Y=768 and
display Y=1938.8648681640625, plus movement Y=1861 with both collision and
display Y=768. The last works at depth zero: its first query finds the top,
then disappeared-action alignment, copying and capture retain it. No raised
display is needed in this supplied variant. Its 1,093-unit movement/collision
split still needs a gameplay producer.

## Measured result, 2 October 2026

The 30-update horizon's finite tree empties at depth two. Of 252 last-update
proposals, 216 reproduce the selected installation/capture fields, grouped
into six retained pose cases; 36 fail. All 7,560 earlier proposals fail to reproduce those parents. Search
takes 50.9505891 seconds; preparation and controls bring the run to 52.0510664
seconds. Median trial time is 5.97185 milliseconds. **Only one backward update
is validated; no thirty-edge chain was obtained.** This prices this pruned
finite tree, not exhaustive one-second coverage or a larger-horizon search.
Six additional neutral controls replay the retained pose cases through Area 2
from one initial patch, with no intermediate state operations; all reproduce
the displacement. Those controls are outside the timed search. Other input
variants are not proved equivalent in omitted state.

## Conditions and limitations

The full scene contexts come from normally initialized SSL after supplied
four-pillar completion and neutral updates to timer 131. Mario is unmounted.
Pose, vertical speed, action fields and selected depth values are
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

The finite move menu samples seven last-update poses across six heights,
including the low-display Y=1861 variant, five freefall speeds, three ground
heights, selected depth values, and 36 released-A input
representatives (neutral/B/Z/B+Z with nine stick directions). It does not
enumerate all binary32 values, controller samples, action histories, moving
support, late writers or other scene contexts. A beam limit can discard
additional distinct parents; none were discarded in the checked run. Empty
frontier means **nothing survives this menu in these contexts**, not that Ink
or these entire gameplay mechanisms are impossible. No Coq result is claimed.

## Commands

Use the installed Windows x64 Python 3.9.13 / Wafel 0.8.5 runtime for the DLL:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/concrete-ink-backward/search.py --depth 30 --candidates 9000 --seconds 90 --beam 6 --output build/concrete-ink-backward/20261002-expanded/report.json
& './build/wafel-pilot/python/python.exe' instrumentation/concrete-ink-backward/search.py --target low-display --depth 30 --candidates 9000 --seconds 90 --beam 6 --output build/concrete-ink-backward/20261003-low-display/report.json
& './build/wafel-pilot/python/python.exe' instrumentation/concrete-ink-backward/dialog_continuation.py --output build/concrete-ink-backward/20261003-low-display/dialog-continuation.json
& './build/wafel-pilot/python/python.exe' -m unittest discover -s instrumentation/concrete-ink-backward -p 'test_*.py' -v
```

Use Ubuntu-24.04's existing Mupen64Plus 2.5.9 pure interpreter for the exact
checkpoint controls. The runner authenticates the ROM and instruction ranges,
compiles with warnings as errors and imposes a 90-second emulator limit:

```sh
bash instrumentation/concrete-ink-backward/capture.sh /path/to/baserom.jp.z64 768
bash instrumentation/concrete-ink-backward/capture.sh /path/to/baserom.jp.z64 1861
bash instrumentation/concrete-ink-backward/capture.sh /path/to/baserom.jp.z64 1861 low
```

Twelve new bookkeeping, inverse-map and receipt controls pass. The original
fifteen pilot tests still pass. The test backend is not a game model.
`expected-result.json` preserves the compact measured receipt and hashes.
Full reports and emulator logs remain in ignored build output; no ROM, DLL,
save state, conversation export or credentials are published. See
[the experiment note](../../docs/notes/rank1-concrete-ink-backward.md).
