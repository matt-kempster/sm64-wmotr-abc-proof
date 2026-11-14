# Controller-only small-box delivery studies

Native SSL Area 1 small box23 can be acquired, carried and released with A
off. The selected 1149-input carry/throw history is confirmed on original JP
with 801 matching field observations. It does not reach Ink or useful
spawning displacement. The higher uphill carry and HOLP observations are
separate Wafel results; all remain below/away from the desired setup.

The sole startup grant is existing debug level selection. `search.Guard`
rejects every post-startup noncontroller write; `advance` rejects A in both
the pad and native Mario input flags. No positions, actions, actor fields,
pickup pointers, HOLP, collision caches or RNG values are supplied.

`inputs.jsonl` and `controller.inputs` preserve the exact selected original-ROM
history. `wafel-trace.json.gz` records 801 before-poll states. `records/`
contains ten finite batches with their actual controls and samples; those
inputs are authoritative for older search policies. `verify.py` freshly
replays every preserved non-beam trial and each beam's selected history,
then checks the selected native-replay stream. It does not call a beam's
negative search exhaustive.

Run from `SSL-Coq/less-than-one-a-press` in PowerShell:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-replacement-delivery/verify.py
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-replacement-delivery/holp-observations.py
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-replacement-delivery/check-native.py instrumentation/ink-buddy-replacement-delivery/native-record --output build/smallbox-delivery-archive-recheck.json
```

The original replay uses the shared authenticated recorder in Ubuntu-24.04:

```sh
WAFEL_PILOT_PROBE=instrumentation/ink-buddy-replacement-delivery/native-probe.c \
  bash instrumentation/wafel-jp-pilot/capture.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 \
  instrumentation/ink-buddy-replacement-delivery/controller.inputs
python3 instrumentation/ink-buddy-replacement-delivery/check-native.py \
  build/wafel-pilot/capture.PRINTED_SUFFIX
```

The selected run is `capture.D8QKUc`. `native-record/` keeps its compressed
emulator log, receipt and provenance/source hashes. No ROM, Wafel DLL or
compiled emulator plugin is included. HOLP was not part of the native observer;
`holp-observations.json` labels its supplementary Wafel measurements explicitly.
The native comparison covers the actual released actor's raw XYZ and other
listed fields, not all memory.

Search scripts and records:

- `search.py`: four successful native pickup approaches and direct carry menu;
  earlier menus are preserved as actual histories in `smallbox-v1/v2/v3`.
- `beam.py`: finite held-object carry beam; width/step/round bounds are in each
  `smallbox-beam` record.
- `perimeter.py`, `continue-perimeter.py`: southern carry and actual uphill
  stick/neutral continuations.
- `pulse.py`: the nearest beam endpoint immediately enters quicksand death;
  it never tests a stable high floor.
- `release.py`, `holp-release.py`: native Z/B comparisons at reached carried
  positions; actor fields and HOLP are not supplied.
- `prepare-native.py`: constructs the selected input/trace package from the
  preserved high-carry release. It was run before archival; ordinary rechecking
  uses `verify.py`, not regeneration from ignored build outputs.

Read [the complete delivery report](../../docs/notes/ink-buddy-replacement-delivery.md)
for exact coordinates, controls, source pin, counts, height distinctions and
remaining reachability/Ink obligations.
