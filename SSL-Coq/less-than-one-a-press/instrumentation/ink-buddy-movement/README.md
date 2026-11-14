# Pink Bob-omb Buddy movement controls

These JP Wafel tests distinguish ordinary contact, a supplied fake-pickup
reference, and native movement after drop/throw. They do not construct a
legitimate cloning history or a no-A delivery route.

From `SSL-Coq/less-than-one-a-press`, using the existing pinned Wafel 0.8.5
Python/runtime installation:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-movement/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/buddy-rerun.json
```

The complete original controller capture is preserved as
`original-prefix.jsonl.gz`. To reconstruct it if the local capture is absent:

```powershell
& build/wafel-pilot/python/python.exe -c "import gzip,pathlib; pathlib.Path('build/wafel-pilot/buddy-prefix-restored.jsonl').write_bytes(gzip.decompress(pathlib.Path('instrumentation/ink-buddy-movement/original-prefix.jsonl.gz').read_bytes()))"
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-movement/search.py build/wafel-pilot/buddy-prefix-restored.jsonl build/wafel-pilot/buddy-rerun-restored.json
```

The script independently reconstructs two runtimes and checks 3,323 recorded
boundaries for exact equality. Its write guard forbids every Buddy slot-15
field write, including during setup; controller-only writes are enforced
outside explicit setup cuts. The one fake-pickup reference write targets
Mario's `usedObj`, after an actual small-box pickup starts. Thus native
pickup/drop/throw code performs all subsequent changes to Buddy's parent,
held state and position. This is a conditional reference test, not proof
that gameplay can create that reference.

The full trace, every supplied edit, and every trial input are retained in
`runtime-traces.json.gz`. It is ordinary UTF-8 JSON compressed with gzip;
no ROM or executable is included. The human report and compact receipt are
`docs/notes/ink-buddy-movement-runtime.md` and
`docs/notes/ink-buddy-movement-runtime-receipt.json`. The receipt records
hashes of the script, imported helpers, runtime, capture, source files,
and both compressed artifacts.

The tested root is just before the stock top's action-1 timer-125 update,
global timer 2675. A separate original-ROM test may use a different phase;
do not require bit-identical HOLP coordinates across those different roots.
