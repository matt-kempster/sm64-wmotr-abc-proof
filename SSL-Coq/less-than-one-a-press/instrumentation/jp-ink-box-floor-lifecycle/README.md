# Original-JP clone and old box floor

This finite replay validates the conditional native fake-pickup/time-stop case
from `../ink-box-floor-lifecycle`. It does not find a reachable fake pickup,
time stop, high HOLP or high floor delivery route. The 66 scalar state writes
are logged individually. No mesh, floor pointer/cache, held pointer, behavior
command, scale, interaction type or surface-partition field is written.

Run in Ubuntu-24.04 WSL from the project directory:

```sh
bash instrumentation/jp-ink-box-floor-lifecycle/run.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 build/jp-box-floor-lifecycle-new
python3 instrumentation/jp-ink-box-floor-lifecycle/archive.py build/jp-box-floor-lifecycle-new
```

The archive command deliberately refuses to overwrite the existing record.
Verify the checked-in record without an emulator:

```sh
python3 instrumentation/jp-ink-box-floor-lifecycle/check.py \
  instrumentation/jp-ink-box-floor-lifecycle/records/native-clone-stopped-old-floor --archived
```

The mode 12 controller prefix, startup level-select cheat, ROM hash gate and
Mupen64Plus 2.5.9 interpreter/Rice/HLE harness follow the earlier original-JP
experiments. The suffix uses B on updates 1 and 19, otherwise neutral. All
controller A frames and engine A-down/A-pressed counters are zero. All setup
cuts, versions, frame interpretation and strict comparison differences are
explained in `../../docs/notes/ink-box-floor-rom.md`.

Expected result: native grab on update 6 leaves 12 low box triangles; supplied
time stop retains them through native throw to high coordinates on update 25.
Native queries find the box's old floor at Y = 251, and a different object's floor
at the new high location. Resume on update 45 removes the box triangles. The
checker preserves 147 strict Wafel differences, while matching the selected
physical state, 12 triangle records and 20 partition links at 42 boundaries.

Only source, text traces, compressed logs, receipts and hashes are archived.
The ROM, compiled input plugin and incidental emulator stop screenshot are
local build artifacts. `--testshots 2820` is only the established bounded-run
stop mechanism; no video or screenshot evidence is used for this result.
