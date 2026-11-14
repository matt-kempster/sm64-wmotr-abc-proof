# Conditional actor replacements after native slide entry

The main new result is a finite negative: a live Fly Guy does not replace the
pink Bob-omb's second sideways shove in the tested shell/Z/box sequence. All
4,200 contacts were advanced through the producer and acceptance update;
3,000 actually registered a Fly Guy collision, and none captured the top.
Sixty-six selected outcome-family histories were independently reconstructed
through 35 updates, with no useful Area 2 displacement.

The shell/Z constructor starts from a **supplied FREEFALL state** and supplied
shell placement. The game then creates BUTT_SLIDE. No Mario writes follow
that initializer. Later actor XYZ placements, including different positions
on different updates, remain diagnostic grants. There is no new delivered
actor, cloned-item acquisition, or complete controller route here.

The supplied-ground and supplied-clone archives are controls only. They grant
the very ground action whose acquisition the main task asks us to solve.
They demonstrate conditional downstream compatibility, not a replacement
constructor. `held-component-probe` instead starts with a real native small-box
pickup, but supplies Mario travel cuts; it fails to release the box on the
top because HOLD_IDLE enters HOLD_BUTT_SLIDE before the intended walking/Z path.

Run from `SSL-Coq/less-than-one-a-press` in PowerShell:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-replacement-handoff/verify.py
```

This reuses the durable prefix in
`instrumentation/ink-buddy-movement/original-prefix.jsonl.gz`, checks its SHA-256,
and reconstructs all 196 preserved full histories (6,303 boundaries), plus
the seven held-component trials. No ROM bytes, DLL, save states, or binaries
are redistributed in this directory. The existing local Wafel JP runtime is
required. The verifier writes only a decompressed prefix in ignored `build/`.

Re-run the finite sweeps into new output filenames (the writers refuse to
overwrite existing files):

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-replacement-handoff/experiment.py build/wafel-pilot/buddy-replacement-verification-prefix.jsonl build/wafel-pilot/replacement-substitutions-new.json.gz --mode substitutions
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-replacement-handoff/experiment.py build/wafel-pilot/buddy-replacement-verification-prefix.jsonl build/wafel-pilot/replacement-coarse-new.json.gz --mode inverse
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-replacement-handoff/experiment.py build/wafel-pilot/buddy-replacement-verification-prefix.jsonl build/wafel-pilot/replacement-refined-new.json.gz --mode refined
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-replacement-handoff/fly_contacts.py build/wafel-pilot/buddy-replacement-verification-prefix.jsonl build/wafel-pilot/replacement-fly-new.json.gz
```

`--mode ground` and `--mode clones` reproduce the expressly supplied-ground
controls. `held_component.py PREFIX OUTPUT` reproduces the native pickup and
conditional travel probe. Its pickup helper is the sibling
`ink-buddy-replacement-delivery/search.py`; hashes are in `manifest.json`.

Archive meanings:

| Archive | Coverage | Full histories |
| --- | --- | ---: |
| `substitutions.json.gz` | Original Buddy control; exact replacements; closer small-box, Bob-omb and shell controls | 18 |
| `shell-box-coarse.json.gz` | 576 air initializers, 19,924 first cuts, 70,511 producer screens | 8 |
| `shell-box-refined.json.gz` | 840 air initializers, 57,340 first cuts, 34,666 producer screens | 8 |
| `native-fly-contacts.json.gz` | 4,200 native Fly Guy/Fire Fly Guy contacts and producer/acceptance screens | 66 |
| `supplied-ground-controls.json.gz` | 24 supplied crawl/butt-slide cases; three native push actors | 24 |
| `supplied-clone-controls.json.gz` | 72 supplied crawl/butt-slide/dive-slide cases; native shell and valid non-HOLDABLE carry-script controls | 72 |
| `held-component-probe.json.gz` | Seven five-update top-entry probes after native pickup and supplied Mario travel | separate |

The coarse/refined archives preserve every accepted-warp screen and a limited
initial selection of other screens, plus counts and recipes for reproducible
searches. They do not pretend every screened candidate received a full 35-update
continuation. The Fly Guy archive preserves every contact/producer/acceptance
screen. Full histories contain action events, M/C/stored graphics, floor/cache,
top phase, actor fields, collision slots, platform and warp state, controller
inputs, and the complete write ledger.

See `../../docs/notes/ink-buddy-replacement-handoff.md` for the human-readable
verdict, exact examples, limitations and remaining predecessor questions.
