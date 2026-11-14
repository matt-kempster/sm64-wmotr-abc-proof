# High airborne damage and recovery controls

This small JP Wafel test isolates ordinary enemy damage as a possible way
to enter a ground action in the high window. It supplies FREEFALL pose and
velocity, and optionally moves an existing stock SSL Goomba to overlap
Mario. No ground action, cache, platform, collision list, or behavior is
supplied. After setup only neutral, A-off controls are written.

Run from `SSL-Coq/less-than-one-a-press`, with an unused output filename:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-high-other-entry/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-high-other-entry-rerun.json
```

Eight histories cover Y=21778 for one update, and Y=25000/32767/67277 for
40 updates each, with and without the Goomba. The script asserts that no
pyramid-top surfaces are loaded at every retained boundary and reconstructs
all histories from a fresh runtime. The final run has 242 matching boundaries,
no ground-action handler execution, and no top capture. The one-update limit
at 21778 keeps the later naturally reloaded top outside this experiment.

The exact source analysis is in `docs/notes/ink-high-other-entry.md`; the
durable machine receipt is `docs/notes/ink-high-other-entry-receipt.json`.
The source/runtime/prefix hashes and every setup write are recorded there.
These are conditional local tests, not original-ROM replays or a completed
controller route.
