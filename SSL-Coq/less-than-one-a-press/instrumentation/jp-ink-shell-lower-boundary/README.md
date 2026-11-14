# Original JP: frozen shell, immediate Z, and the Y=19,900 actor sequence

See [the verified original-JP report](../../docs/notes/ink-shell-lower-boundary-rom.md) for all setup grants, source/runtime versions and the comparison limits.

The supplied FREEFALL Mario mounts an actually initialized shell that was frozen by native fake-pickup/throw. Immediate Z reaches butt slide and lands on the live pyramid top. Two later actor cuts reproduce the existing Box+Buddy / Box sequence and useful spawning displacement. Omitting the Buddy cut fails. This establishes a conditional local mechanism; shell cloning/delivery, Mario's high entry, and the three actor placements remain granted.

`probe.c` and `run.sh` use authenticated original JP in the existing interpreter harness. `check.py` matches every written address/width/value and repeated write against the preserved Wafel setup edits, checks A-off inputs and engine flags, native initialized-shell pickup/release, the initial split, low-floor producer, top capture/retention, and the exact displaced Area2 spawn. The negative run remains in Area1. No Mario field is edited after the initial high FREEFALL cut; actor positions are supplied on the next two updates.

The Wafel reference is `../ink-shell-lower-boundary/results.json.gz`, `results.oldSequence[0]` and `[1]`. All compared M/C/G bit patterns, action/cache/platform fields, velocities, collision lists and shell fields agree. Native global timer is two less than Wafel; raw clock mismatches are explicitly preserved instead of claiming strict equality or full-memory equivalence.

| Case | Native boundaries | Memory writes | Compared boundaries | Missing requested comparisons | Result |
|---|---:|---:|---:|---|---|
| Box+Buddy / Box | 162 | 62 | 67 | Camera transition steps154/155 | Exact spawn (365.5927734375,5500,-1096.8026123046875) |
| Box / Box, no Buddy | 164 | 59 | 77 | Final step165: probe stops at bridge35 | No warp through observed horizon |

Archived compressed raw logs, receipts, probe and inherited prefix source, launch script, checker source and hashes are under `records/`. No ROM, save state, or compiled plugin is distributed. Recheck from the SSL project directory:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/jp-ink-shell-lower-boundary/verify.py
& build/wafel-pilot/python/python.exe instrumentation/jp-ink-shell-lower-boundary/check.py instrumentation/jp-ink-shell-lower-boundary/records/positive --archived
& build/wafel-pilot/python/python.exe instrumentation/jp-ink-shell-lower-boundary/check.py instrumentation/jp-ink-shell-lower-boundary/records/no-buddy --archived
```

The native positive's first split is M/C Y=1799.2869873046875, G Y=19900. Two updates later the useful producer has M/C Y=768 and G Y=1830.177978515625. The next update accepts the warp and captures top61; the reference is retained through the observed Area1 transition. G means stored graphics `gfx.pos`, not the visible model position. All setup writes are listed in each receipt; no clean no-new-A route is claimed.
