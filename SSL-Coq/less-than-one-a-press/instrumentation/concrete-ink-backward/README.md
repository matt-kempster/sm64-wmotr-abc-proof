# Concrete backward experiment from Ink

## Latest: an individual, resumable one-update counter

`product_sweep.py` tests all three target menus with a cached, fully restored
scene for each actual Wafel update. `--buttons stock-gameplay` gates L and the
four D-pad bits at the user's request, retaining B/Z/Start/R/all C buttons and
all 65,536 stick pairs. The selected product has 335,544,320 menu/input cases
per fixed A mode. This does not assert those excluded buttons are formally
equivalent in every history. Legacy full-button options remain available.

The [stopped 5,000-trial check](../../docs/notes/rank1-gated-input-batch.md)
passes 1,750 selected-field comparisons and rejects 3,250. It uses two resumed
2,500-case batches, with 3.7233 seconds of timed trials. All 45 code tests pass.
No whole-update input grouping, gameplay gap producer or full-state match
is established. `rejected-event` may fit another installation height; it is
not a whole-Ink exclusion. The exact accepted-return observer and Area-2
suffix checks remain separate from per-trial matching.

```powershell
& './build/wafel-pilot/python/python.exe' -X utf8 instrumentation/concrete-ink-backward/product_sweep.py --buttons stock-gameplay --order mixed --cases 2500 --seconds 30 --output build/concrete-ink-backward/20261003-5000-ledger/report.json
& './build/wafel-pilot/python/python.exe' -X utf8 instrumentation/concrete-ink-backward/product_sweep.py --buttons stock-gameplay --order mixed --resume --cases 2500 --seconds 30 --output build/concrete-ink-backward/20261003-5000-ledger/report.json
```

`--cases` and `--seconds` bound each invocation. `--order mixed` is an exact
permutation of the alphabet, so short batches spread through it; no input
representative stands in for another. The report and adjacent `.trials.jsonl`
ledger checkpoint every 1,000 completed cases. Resume verifies source/runtime
hashes, prior controller state, exact enumeration and counts. A mismatched
or uncheckpointed tail is rejected for explicit recovery; preserve it.
`--benchmark` is a timing sample and cannot resume this coverage stream.
The compact `expected-gated-product.json` records the stopped result.
No continuation is running; start a later batch only on user instruction.

The [implemented move inventory](../../docs/notes/rank1-concrete-move-inventory.md)
lists both installation setups and the three earlier action families. Its
original default-mode enumeration checks 252/216 installation proposals and 1,260 earlier
proposals per parent. Every earlier proposal inherits collision position and
keeps movement X/Z fixed; no horizontal or moving-support inverse exists yet.
This inventory is not a new gameplay search or broader coverage result.

## Controller options

Both installation and earlier generators now accept the following options:

| Switch | Default | Other mode |
| --- | --- | --- |
| `--sticks` | `sampled`: nine raw stick poses | `encoded`: all 65,536 signed-byte pairs |
| `--buttons` | `bz`: four B/Z combinations | `all-non-a`: all 8,192 combinations of B, Z, Start, L, R, C buttons and D-pad |
| `--a-mode` | `released` | `held`: real preparation press before the searched contexts, then hold without a new edge |

The full product has 536,870,912 choices per pose and is generated lazily.
The old 36 controls come first; wider modes then try all pose templates for
each remaining input. Candidate/time limits still apply, so the configured
alphabet need not be exhausted. Reserved bits 6/7 are excluded. Raw encoding
coverage is not physical-controller realizability or gameplay-history coverage.

Held mode does not patch button history: it makes one real preparation press
at frame 361, verifies A is already down in every searched context, and
rejects a release or new A-pressed flag during every continuously replayed
suffix. This is not an A-never-pressed route. No release/repress mode is added.

Thirty-eight real Wafel input probes and 37 application tests pass. The
default released-A and held-A one-update low-display menus each test 216
proposals and match 36. Wider one-update smoke tests exercise the switches
but stop at candidate limits. See the [checked input-options note](../../docs/notes/rank1-encoded-controller-options.md)
and `expected-input-options.json` for exact scope, timings and source hashes.
This adds input choices to the same five move families; it does not discover
a gap producer or complete an exhaustive one-second search.

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/concrete-ink-backward/search.py --target low-display --depth 1 --sticks encoded --buttons all-non-a --a-mode held --candidates 240 --seconds 30 --output build/concrete-ink-backward/20261003-input-options/encoded-all-held.json
& './build/wafel-pilot/python/python.exe' instrumentation/concrete-ink-backward/input_options_check.py --output build/concrete-ink-backward/20261003-input-options/runtime.json
```

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

The original measured finite move menu samples seven last-update poses across six heights,
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
