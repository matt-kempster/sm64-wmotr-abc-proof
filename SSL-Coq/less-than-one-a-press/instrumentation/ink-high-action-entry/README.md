# Native high-air shell entry searches

Run in Windows PowerShell from `SSL-Coq/less-than-one-a-press`, with fresh
output names. Each script refuses to overwrite an existing output.

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/ink-high-action-entry/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-shell-pad.json
& ./build/wafel-pilot/python/python.exe instrumentation/ink-high-action-entry/edges.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-shell-edges.json
& ./build/wafel-pilot/python/python.exe instrumentation/ink-high-action-entry/prelude.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-shell-prelude.json
& ./build/wafel-pilot/python/python.exe instrumentation/ink-high-action-entry/seeds.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-shell-seeds.json
```

`search.py` uses the existing native shell-spawn helper at top behavior128
and samples the source-guided pad region at Y25000/Y67277, then follows
six center controls. `edges.py` refines signed-coordinate truncation and
binary32 neighbors around the actual static pad bounds, retaining twelve
full controls across the real floor-selection transitions. These two menus
screen the intended two-update producer/acceptance sequence. Negative labels
do not exclude arbitrary later inputs or installations.

`prelude.py` spawns the shell at125, then supplies an airborne Mario/shell
pose at127/128/129. Its first Z input natively enters a slide; subsequent
updates have neutral input. At130 it permits only a declared Crazy Box XYZ
cut. No ground action, floor/cache, platform, collision or timer is supplied.
This menu finds no low-cache gap or top capture. `seeds.py` separately exports
native butt-slide/top-platform states at local Y1740–1801 before129 for the
companion moving-actor investigation. They are components, not handoffs.

Every initial airborne state remains supplied. The shell box action4 and
shell placement are supplied too. The native action conversion is observed,
not written. All controller suffixes keep A held/pressed clear. Guards reject
non-controller writes outside the explicit initial and actor-only cuts.
Full cases independently replay from a second fresh boot and input prefix.

The durable combined receipt is `docs/notes/ink-high-action-entry-receipt.json`.
`preserve.py` records exact source/helper hashes and combines the four named
ignored outputs without rerunning experiments. The first edge run selected
less informative corner controls; the final edge run uses the same grid but
retains the actual 768/1280 transition neighbors. Only the final run is counted.
No new original-ROM replay or Coq claim is made by this instrumentation.

The actor-only follow-up supplies shell/box XYZ before 129 after a native
slide has been created, and permits a second box XYZ cut before 130 only if
the first stage reaches the target pad. It consumes the exact seed-export
file named above. It found no grounded pad endpoint in the bounded menu;
the second cut was therefore never executed. Twelve complete histories
independently match 432 boundaries. See the separate actor-cut note/receipt.

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/ink-high-action-entry/actor_cuts.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-actor-cuts.json
```

`preserve_actor_cuts.py` preserves the checked final actor-cut output and its
source hashes without rerunning it. The later actor cuts are delivery grants,
not a claim that a player can place either actor that way.

Two final 48-recipe velocity refinements are preserved separately. The direct
variant changes only initial air forward/Cartesian velocity before 128 and
demonstrates why that does not initialize a fast slide. The corrected variant
supplies Mario FREEFALL before 127 at Y=21716, runs 127 neutral with no nearby
shell, then supplies ONLY shell XYZ ten units below actual Mario before 128
and presses Z. Native air code initializes slide velocity. No Mario fields
are edited after 127. Both reuse the exact two 129 actor pairs; neither reaches
the pad or runs a second box cut. Eight full histories per batch independently
match 288/296 boundaries, respectively.

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/ink-high-action-entry/speed_refine.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-speed-diagnostic.json
& ./build/wafel-pilot/python/python.exe instrumentation/ink-high-action-entry/native_speed_refine.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-native-speed.json
```

These consume the checked actor-cut output named
`build/wafel-pilot/ink-high-shell-actor-cuts-20261114-preserved.json`.
`preserve_speed_refine.py` packages both checked outputs, exact script/source
hashes and complete retained histories without rerunning them.
