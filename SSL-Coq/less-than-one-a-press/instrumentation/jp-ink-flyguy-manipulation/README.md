# Original-JP native Fire Fly Guy predecessor records

Three A-off histories reproduce the specified trajectories. Their expanded
strict internal-field comparisons **fail** on the documented Fly Guy subtype
130-versus128 difference. Do not report all-field equality or an Ink success.
Read `../../docs/notes/ink-flyguy-native-rom.md` for the exact scope and counts.

From the SSL project directory, for each of `roof`, `flame-roof`, `high-slide`:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/jp-ink-flyguy-manipulation/check.py instrumentation/jp-ink-flyguy-manipulation/records/high-slide instrumentation/jp-ink-flyguy-manipulation/records/high-slide --output build/flyguy-strict-recheck.json
& build/wafel-pilot/python/python.exe instrumentation/jp-ink-flyguy-manipulation/diagnose.py instrumentation/jp-ink-flyguy-manipulation/records/high-slide instrumentation/jp-ink-flyguy-manipulation/records/high-slide
```

The first command intentionally exits nonzero on the preserved difference.
The second checks exact trajectory agreement and explicitly classifies that
subtype difference; it rewrites the identical diagnostic report. Native log
compression is handled by both commands. No emulator is needed for this archived
field comparison.

To create a new native replay, use the established recorder in Ubuntu-24.04:

```sh
WAFEL_PILOT_PROBE=instrumentation/jp-ink-flyguy-manipulation/native-probe.c \
  bash instrumentation/wafel-jp-pilot/capture.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 \
  instrumentation/jp-ink-flyguy-manipulation/records/high-slide/controller.inputs
```

`prepare.py INPUTS_JSONL NEW_DIRECTORY` freshly reconstructs the Wafel observer
trace from controller inputs, with strict A-off/write guards. The only startup
grant is the project's existing debug level-selection entry. `archive.py`
preserves a prepared/native pair, authenticates existing immutable input/log
bytes on refresh, and stores source hashes. The C observer only reads memory.
Raw words have explicit pinned Object offsets; `fields.json` gives their order.

These records do not include any of the separately supplied high-coordinate
Fly Guy tests or the supplied small-box compatibility controls. Their own
scripts and ledgers distinguish those experiments.
