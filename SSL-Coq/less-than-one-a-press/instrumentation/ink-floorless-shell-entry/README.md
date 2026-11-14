# Floorless shell / pending death control

This small JP Wafel diagnostic uses only two actual world-edge positions,
(8192,25000,0) and (-8192,25000,0). Mario's initial FREEFALL and an existing
native Koopa shell's position are supplied. Shell contact selects the real
riding action, but the floorless geometry update has already queued death.

A third history repeats the positive edge and makes one later Crazy Box
XYZ cut. The native shove returns Mario to X=8124, where a real static floor
is found on the next update. The death queue persists. No Mario edits follow
the first cut, and no warp fields are edited anywhere.

Run from `SSL-Coq/less-than-one-a-press` with an unused output filename:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-floorless-shell-entry/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-floorless-shell-entry-rerun.json
```

All three 49-update histories matched a fresh-runtime reconstruction (147
boundaries). The durable receipt and explanation are
`docs/notes/ink-floorless-shell-entry-receipt.json` and
`docs/notes/ink-floorless-shell-entry.md`. The recorder stops when the death
transition clears Mario's object, rather than dereferencing that object
after the level has been cleared. These supplied-state tests are not a
controller route or an original-ROM replay.
