# High unloaded-top delayed shell recovery

These are native JP Wafel experiments, not original-ROM replays or a reached
controller setup. They use actual M.Y=25000 or 67277, with the spinning top's
collision unloaded. No low-top landing is used as the entry.

Run in Windows PowerShell from `SSL-Coq/less-than-one-a-press`. Use fresh
output names; the scripts refuse to overwrite outputs.

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/ink-high-delayed-shell/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-delayed-shell.json
& ./build/wafel-pilot/python/python.exe instrumentation/ink-high-delayed-shell/early.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-early-shell.json
```

`search.py` supplies a shell-box release and one initial FREEFALL/position/
velocity cut. Native mounting receives neutral input, then the eight named
control suffixes vary Z, B+Z, analog and delayed presses. Mario's ground
action, action timer, animation progress, floor/cache, platform and top timer
are never written. After the initial airborne cut, only controller pads and
an optional declared Crazy Box XYZ cut can be written. A remains clear.
The 128 recipes cover mount phases 126/128/129 and actual Y 25000/67277,
with no box cut, a first-post-mount cut, or a phase-130 cut. Each runs70
updates. Six complete histories independently replay420 boundaries.

`early.py` runs exactly one matched phase-97 mount at Y=25000 with late Z
pulses and a box cut before 130. Shell-box release is moved to94 by a declared
box-action edit; top timing advances natively, without timer writes. Native
knockback recovery reaches IDLE before top behavior 129 and then FREEFALL
before 130, while the top is still live. Its complete70 updates independently
replay. No recipe reaches high crawl/common-slide execution, top capture or
useful Area 2 displacement.

`preserve.py` packages the checked final menu and early control into
`docs/notes/ink-high-delayed-shell-receipt.json`, retaining raw-output,
source, helper and runtime hashes. It does not rerun the tests. The older
development output remains ignored; only the final menu is counted.
