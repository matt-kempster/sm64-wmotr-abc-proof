# Fixed collision-only actor diagnostic

Run from `SSL-Coq/less-than-one-a-press` in Windows PowerShell with a fresh
output name:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-collision-clone/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-collision-clone.json
```

The script uses the authenticated JP Wafel runtime and established prefix.
It compares six native box controls with1,024 fixed-collider diagnostics,
then independently replays12 retained histories across384 matched boundaries.
The receipt retains every candidate recipe and its four-update screen,
all retained full histories, initial writes, inputs, actor states and hashes.
It refuses to overwrite an existing output. No random seed is introduced.

The fixed cases explicitly write the existing Crazy Box's `curBhvCommand`
to `bhvCarrySomething5` and `bhvStackIndex=0`. This is an inert-collider
diagnostic, **not a controller-reached Crazy Box clone**: a normally held,
thrown or dropped Crazy Box remains on its native held-state behavior.
The diagnostic preserves hitbox/type/flags/list membership, and real
collision and Mario interaction processing continue. It does not zero
velocity or repeatedly freeze the position; the flags contain no automatic
position-motion bits. XYZ equality is asserted after every trial.

After the initial supplied Mario/actor cut, the guard permits controller
input only. All input is neutral and A remains released. No floor/platform,
top timer, RNG or collision mesh is written.

The report is `docs/notes/ink-collision-clone-runtime.md`, with durable
receipt `ink-collision-clone-runtime-receipt.json`. The original ignored
output is `build/wafel-pilot/ink-collision-clone-20261114.json`.
