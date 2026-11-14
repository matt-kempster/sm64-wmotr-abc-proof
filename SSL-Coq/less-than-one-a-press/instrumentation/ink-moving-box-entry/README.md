# Native moving Crazy Box entry comparisons

This bounded JP Wafel search tests an actual `HELD_THROWN` callback followed
by native box motion. It supplies the release state and an airborne Mario
seed; it does not demonstrate throwing or reaching either seed through
controller inputs. No Crazy Box writes follow release, and no Mario writes
follow the airborne cut. Shell placement, when used, is part of that later
airborne cut. No floor cache or platform pointer is supplied.

Run from `SSL-Coq/less-than-one-a-press` in Windows PowerShell, choosing an
unused output filename:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-moving-box-entry/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-moving-box-entry-rerun.json
```

The shell seed receipt must already exist at
`build/wafel-pilot/ink-high-shell-seeds-20261114.json`; its generator is
`instrumentation/ink-high-action-entry/seeds.py`. This study credits that
native shell-entry work and imports its initialization helper.

The final run screened 1,692 air/shell seeds, retained 1,066 low supported
states, and found no geometrically eligible single-box push into the eight
specified pad corners. It nevertheless ran 160 native throw comparisons on
the two nearest NE-corner predecessors. None produced a fresh low-cache
gap, top-capturing warp, or useful Area 2 arrival. Ten full histories were
reconstructed in a fresh runtime and matched over 340 boundaries.

The durable receipt is `docs/notes/ink-moving-box-entry-receipt.json`.
It includes all 160 release recipes and four-update observations, the 1,066
retained predecessor records, exact setup writes for the ten full histories,
and source/runtime/input hashes. The report is
`docs/notes/ink-moving-box-entry.md`. These are finite conditional results,
not a global exclusion of moving actors or a new original-ROM replay.
