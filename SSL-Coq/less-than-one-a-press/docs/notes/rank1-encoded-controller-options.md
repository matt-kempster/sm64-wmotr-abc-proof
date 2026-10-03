# The backward search now has the larger controller ranges

3 October 2026. The concrete Ink search can now generate every signed-byte
stick pair and every combination of the declared non-A buttons. It also has
an already-held-A mode. These are working search options, checked in Wafel;
the broader ranges have not been exhaustively searched. No gameplay gap
producer, new Coq result or route exclusion follows.

## What changed

Previously, the input adapter could accept arbitrary signed-byte stick values,
but the Ink proposal generator only offered nine stick poses with four B/Z
combinations. The large sequence counts in the earlier input-budget comparison
described possible alphabets, not enabled options in this concrete search.
The default remains those 36 samples. The new switches enlarge the inputs
attached to both installation proposals and earlier proposals.

| Option | Choices |
| --- | --- |
| `--sticks sampled` | The existing nine poses: center, four axes and four diagonals, using components 0 or +/-127. |
| `--sticks encoded` | All 65,536 pairs with each raw axis from -128 through 127. |
| `--buttons bz` | No button, B, Z or B+Z. |
| `--buttons all-non-a` | All 8,192 combinations of the 13 declared buttons other than A. |
| `--a-mode released` | A is up throughout the searched suffix; this is the default. |
| `--a-mode held` | A was pressed during preparation and is already down before the searched suffix. The validator rejects a new A edge or release in that suffix. |

The full button mode includes B, Z, Start, L, R, all four C buttons and all
four D-pad buttons. Reserved bits 6 and 7 are excluded. The pinned C controller
header declares these bits, and the actual generated US/JP controller code
retains them through its valid-button mask. We keep L and the D-pad rather
than assuming that an apparently inactive button can never matter. Start can
pause; camera controls can affect later movement. No button-equivalence
theorem is used to discard them.

| Stick range | Button range | Inputs per proposed pose |
| --- | --- | ---: |
| Sampled | B/Z | 36 |
| Encoded | B/Z | 262,144 |
| Sampled | All non-A | 73,728 |
| Encoded | All non-A | 536,870,912 |

A is fixed up or held for a run, so it does not multiply those counts. Both
modes can be run separately. This option does not enumerate release/repress
histories. Every count is for raw encodings; the game's dead zone and stick
normalization can give different encodings the same immediate effect. We
have not shown that every raw pair is attainable by a physical controller.

The generator streams the product instead of allocating hundreds of millions
of inputs. It tries the old 36 representatives first, then the remaining
inputs. Wider modes try every pose template for one input before moving to
the next input. Candidate and time limits still stop the run. A configured
alphabet is not a completed search of that alphabet.

## Holding A needs an earlier press

The actual input reader marks a button pressed when it changes from up to
down. Writing an A-down input after an A-up context therefore introduces a
new physical A edge; it is not an already-held-A test. The held mode uses a
real A-down controller input during preparation, beginning at frame 361,
then continues holding it. All searched saved contexts already record A
down. The validator checks A down and A not newly pressed after every update
of the continuously replayed suffix. It does not patch the controller history.

In the runtime diagnostic, the earliest context for the 30-update window is
frame 463, after that preparation edge. The one-update installation tests use
frame 491. This isolates holding A without a new press in the searched suffix.
It is not a witness for never pressing A, and the surrounding installation
setup remains supplied.

## What was actually checked

All 22 concrete-search tests and all 15 original backward-pilot tests pass.
Enumeration checks all 262,144 encoded B/Z inputs without a duplicate or
missing pair. Separate checks cover all 8,192 non-A masks, confirm the huge
product is lazy, and confirm the selected inputs reach both installation and
earlier generators. The held-history controls reject a new A edge and an
unexplained A-up predecessor. These are application tests, not Coq proofs.

The actual Windows x64 Python 3.9.13 / Wafel 0.8.5 JP runtime consumes 38
finite input probes: six stick pairs and each of the 13 non-A buttons, with
A released and held. The stick probes include `(13,-27)` and all four
signed-byte corners. Raw axes and button fields match exactly. Holding A
introduces no new edge in these probes; a separate A-down-after-A-up control
does produce the expected edge. The diagnostic passes within its 60-second limit.

Five bounded one-update searches start from the supplied low-display
installation variant: movement Y=1861, collision/display Y=768 and depth
zero. Each rechecks its endpoint and a continuous retained-top continuation
through the first Area-2 apply. Their measured search intervals are:

| Inputs / A mode | Proposals tested | Matching proposals | Search seconds |
| --- | ---: | ---: | ---: |
| Sampled, B/Z, released | 216 | 36 | 2.277 |
| Sampled, B/Z, held | 216 | 36 | 2.008 |
| Encoded, B/Z, released | 240 | 40 | 2.351 |
| Sampled, all non-A, held | 270 | 45 | 1.822 |
| Encoded, all non-A, held | 240 | 40 | 1.375 |

The first two finish their six-pose input menus. The wider three stop at
their candidate budgets; they do not exhaust the selected alphabets. Every
run retains one pose group, still the supplied installation relationship.
Matching controls need not agree on omitted state. These small timings are
not an exhaustive one-second price or a three/five-second forecast.

## What remains unchanged

The five proposal families in the [move inventory](rank1-concrete-move-inventory.md)
remain the same. Earlier proposals inherit collision position and keep
movement X/Z fixed. Moving support, horizontal approaches, earlier message
construction and other gap-producing inverses are still absent. Saved
contexts supply the surrounding scene; matching and pose grouping still
compare only selected fields. More input encodings do not supply those
missing mechanisms or make an empty frontier a gameplay impossibility proof.
All 45 atlas estimates and existing proof verdicts remain unchanged.

## Commands and receipts

Run from `SSL-Coq/less-than-one-a-press` using the installed Windows runtime:

```powershell
& './build/wafel-pilot/python/python.exe' -m unittest discover -s instrumentation/concrete-ink-backward -p 'test_*.py' -v
& './build/wafel-pilot/python/python.exe' -m unittest discover -s instrumentation/wafel-jp-pilot -p 'test_backward*.py' -v
& './build/wafel-pilot/python/python.exe' instrumentation/concrete-ink-backward/input_options_check.py --output build/concrete-ink-backward/20261003-input-options/runtime.json
& './build/wafel-pilot/python/python.exe' instrumentation/concrete-ink-backward/search.py --target low-display --depth 1 --sticks encoded --buttons all-non-a --a-mode held --candidates 240 --seconds 30 --output build/concrete-ink-backward/20261003-input-options/encoded-all-held.json
```

The [compact receipt](../../instrumentation/concrete-ink-backward/expected-input-options.json)
preserves the actual configuration, results and source hashes. The full
runtime and search reports remain in ignored
`build/concrete-ink-backward/20261003-input-options/`. No ROM, DLL, full save
state, conversation export or credentials are included in the publication.
