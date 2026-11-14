# High freefall bridge from a frozen initialized shell

JP Wafel finite experiment: 69 continuations and 324 one-update geometry
checks, independently repeated from a fresh runtime. The 2,610 compared
update boundaries count the continuations, their six low-mount controls,
and geometry checks; preparation/wait updates are additional and excluded
from this count. Full report: `../../docs/notes/ink-cloned-shell-bridge.md`.

From the SSL project directory in PowerShell:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-cloned-shell-bridge/search.py --verify instrumentation/ink-cloned-shell-bridge/results.json.gz
```

The dependency `../ink-shell-clone-isolation/test.py` constructs an initialized
native shell, conditional fake pickup, and native high-HOLP throw. No shell
type, hitbox, tangibility, status, carry command or floor geometry is assigned.
The native throw leaves the shell at the high contact point before Mario is
placed there. The source hashes, dependency hash, every setup edit, inputs,
native action events, and M/C/G observations are saved in `results.json.gz`.
G means stored `gfx.pos`, not rendered model position.

All 324 geometry checks mount the shell; none keeps a high ground rider at
the next update. No tested high-FREEFALL continuation captures the top or
produces useful displacement. Six separately labeled compatibility controls
first mount low, then explicitly relocate Mario high; all six do complete
the useful handoff. Those high relocations are grants, not gameplay routes.
All new inputs keep A released; no held-A dependency is used.

`verification.json` identifies the exact checked artifacts. The binary runtime
and existing prefix remain local; no ROM or runtime DLL is redistributed.
