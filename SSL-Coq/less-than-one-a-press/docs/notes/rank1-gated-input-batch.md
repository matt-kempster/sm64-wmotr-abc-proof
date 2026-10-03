# Rank 1: 5,000 individual predecessor trials, then stop

3 October 2026. **The requested test is finished and the search is stopped.**
Of 5,000 one-update trials, 1,750 pass the selected comparison and 3,250 do
not. The gap remains supplied. This is a finite conditional check, not a
new gap producer, a thirty-update chain, a Coq theorem or an Ink exclusion.
Rank 1 stays at its subjective 1–2%; the 35% trial pass rate is not a route
probability.

## First, what happened to input grouping?

We have **not justified using representatives for the complete update**.
The existing generated US/JP checks establish smaller facts: the central
15-by-15 stick square becomes zero adjusted stick, and Mario's button helper
has a few output signatures. Those facts do not make all later state equal.
Raw stick values remain stored, the Controller retains its held/pressed
buttons, camera code reads inputs, and the next button edge depends on the
previous held mask. The earlier supplied-scene path check covers its 225
neutral stick encodings, not every pose or button combination in this counter.

The source review did not finish the consumer/preservation connection needed
to carry these local equivalences through this installation update. At the
user's request we stopped that work and tested each counted case separately.
No untested member of an alleged group gets a pass or failure by multiplication.
See the [earlier grouping record](rank1-input-grouping.md).

The L and four D-pad bits are excluded **by the user's chosen trial scope**,
not by a new noninterference theorem. B, Z, Start, R and all four C buttons
remain. There are 256 masks and all 65,536 signed-byte stick pairs:
16,777,216 inputs per pose. Across the original, variant and hybrid target
menus, with 7, 6 and 7 entries, that is **335,544,320 pose/input/target cases
per fixed A mode**, 32 times fewer than the ungated product. The legacy
`all-non-a` option still includes L and the D-pad.

## What ran

The real Windows Wafel 0.8.5 JP runtime tested one update for each case.
The full scene comes from the existing normally initialized SSL capture,
followed by supplied pillar completion and neutral updates to top timer 131.
The searched context is Wafel frame 492; each trial advances to 493, with
the game's global timer advancing from 493 to 494. A is released and there
are no preparation A presses in this run. Height, display, collision and
action values are conditional inverse proposals, not controller-reached poses.

All tuples remain (X,Y,Z), at X=-2200 and Z=-1024. The named supplied controls
are original movement/display Y=768/1938.8648681640625, variant
1861/768, and hybrid 1861/1938.8648681640625, each with collision Y=768.
The same real game controls still capture the top and reach its first Area-2
displacement. That neutral suffix control is not replayed for every trial.

We tried **250 distinct input samples against each of 20 menu entries**.
They contain 250 raw stick pairs and 100 distinct button masks. An invertible
ordering spreads these inputs across the selected alphabet; it does not merge
them. The 20 entries contain 12 distinct patch dictionaries, giving 3,000
distinct patch/input combinations. Thus “5,000 predecessor trials” must not
be read as 5,000 distinct complete earlier game states.

| Target menu | Trials | Passed selected checks | Different end fields | Different action-entry height | Total not matching |
| --- | ---: | ---: | ---: | ---: | ---: |
| Original | 1,750 | 1,000 | 250 | 500 | 750 |
| Variant | 1,500 | 250 | 1,250 | 0 | 1,250 |
| Hybrid | 1,750 | 500 | 250 | 1,000 | 1,250 |
| **Total** | **5,000** | **1,750** | **1,750** | **1,500** | **3,250** |

`accepted-projection` checks movement at `ACT_DISAPPEARED` entry and, after
the update, the three position records, action, depth, action argument, used
warp slot, floor height/owner and platform. It does not compare the complete
state or all nine position words at the accepted warp return. That earlier
checkpoint still uses the separate exact emulator observer.

`rejected-event` means those end fields matched but the requested entry
height did not. **It is not an Ink impossibility verdict:** a different height
can fit another installation variant. `rejected` means an end field differed;
the ledger retains the exact expected/actual values. No backend errors or
A-history failures were classified as ordinary rejection in this batch.
The successful cases still inherit their useful split. We did not search the
update that first created it.

## Batches really resume

We ran 2,500 cases, saved the checkpoint, ended that process, then resumed
for another 2,500. Cases 0 through 4,999 are recorded exactly once. The next
cursor is 5,000. Every row identifies its input, menu entry, patch recipe,
status and selected-field diagnostics. The header pins the code, capture,
DLL, targets, enumeration order and prior controller state. A resume checks
that signature, ledger hash, exact case ordering and accumulated counts.
It refuses a missing checkpoint, altered ledger or incompatible source;
those files must be preserved for recovery rather than silently discarded.
Reports checkpoint every 1,000 completed trials. A crash between checkpoints
can leave an uncheckpointed ledger tail; the checker rejects it for explicit
recovery, rather than losing or inventing tried cases.

The mixed order multiplies the input ordinal by the odd constant 13,254,001
modulo the power-of-two alphabet size. Its modular inverse exists, so the
ordering visits every selected input once if the whole stream finishes.
Each input is paired with every menu entry. This is enumeration, not an
equivalence theorem or exhaustive coverage of all possible earlier poses.

The timed trial batches took 1.8083899 and 1.9149175 seconds, totaling
**3.7233074 seconds**, about **1,343 trials/second**. Prefix preparation,
three neutral retained-top controls per process and 160 total cached/uncached
comparison controls are outside those 5,000 timed search cases. All comparison
controls agree. Forty-five code tests pass, including ledger integrity,
permutation, resume and the original backward pilot checks.

At that measured rate, the selected full one-update product would take about
**2.9 days with A released**, before interruptions and repeated preparation.
Held A is a separate pass; it was not run as part of this 5,000-case test.
Earlier timing probes suggest a comparable cost. The existing earlier
timing/prefix files have different signatures and are not silently added to
this new ledger. This does not price an exhaustive 30/90/150-update tree:
its additional predecessor states, continuous replays and branching still
need their own measurements.

## Saved output and commands

The compact, committed [receipt](../../instrumentation/concrete-ink-backward/expected-gated-product.json)
has counts for every menu entry, exact timings and hashes. The complete local
report, per-trial JSONL ledger, CSV and first-batch checkpoint remain under
`build/concrete-ink-backward/20261003-5000-ledger/`. The private site offers the
5000-row CSV for review. No ROM, DLL, full save state or conversation export
is published.

From the SSL project, these were the two actual commands:

```powershell
& './build/wafel-pilot/python/python.exe' -X utf8 instrumentation/concrete-ink-backward/product_sweep.py --buttons stock-gameplay --order mixed --a-mode released --cases 2500 --seconds 30 --output build/concrete-ink-backward/20261003-5000-ledger/report.json
& './build/wafel-pilot/python/python.exe' -X utf8 instrumentation/concrete-ink-backward/product_sweep.py --buttons stock-gameplay --order mixed --a-mode released --resume --cases 2500 --seconds 30 --output build/concrete-ink-backward/20261003-5000-ledger/report.json
```

A later authorized batch can use the second command with its own case/time
budget. **No continuation is running or scheduled by this batch.** The user
requested stopping here for review. No Coq source, Section 01 status,
conditional/full impossibility result or atlas estimate changes.
