# Original JP initialized frozen-shell controls

Three authenticated original-JP runs at Y25000. Full explanation:
`../../docs/notes/ink-cloned-shell-bridge-rom.md`.

| Mode | Conditional test | Result |
| --- | --- | --- |
| 1 | Native frozen-shell low mount; explicit high Mario relocation; Bob-omb and Z | Useful displaced Area2 spawn, with top capture/retention |
| 2 | High FREEFALL; native mount; Bob-omb and Z next update | Immediate ground knockback; no high rider bridge or warp |
| 3 | High FREEFALL; native mount and fresh Z together; no pusher | Large G/M split followed by ordinary warp; no displacement |

All use native shell initialization, one supplied fake-pickup `usedObj`
retarget, and native throw from supplied high HOLP. No shell interaction type,
hitbox, tangibility, status, carry command or floor is assigned. Mode1 still
supplies the missing high Mario position; none is a controller-reachable
delivery route. M/C/G denote movement/collision/stored graphics.

Run from the SSL directory under Ubuntu-24.04 with an authenticated local ROM:

```bash
bash instrumentation/jp-ink-cloned-shell-bridge/run.sh /path/to/baserom.jp.z64 /fresh/output 1 25000
python3 instrumentation/jp-ink-cloned-shell-bridge/check.py /fresh/output
```

Modes2 and3 select the negatives. The runner also accepts heights67277 and
90536, but these three archived ROM runs and this checker cover25000 only.
The separate Wafel package tests all three heights. Do not interpret accepted
runner parameters as executed ROM cases.

Recheck the complete archived package without an emulator or ROM:

```bash
python3 instrumentation/jp-ink-cloned-shell-bridge/verify.py
```

`records/` contains deterministic gzip archives of original raw logs, filtered
traces, exact probe/prefix/runner/checker sources and receipts. Per-record
manifests check compressed and uncompressed bytes. No ROM, DLL, plugin binary
or save state is included. `expected.json.gz` holds the selected Wafel records.
Its exact mode3 has no pusher; `prepare_expected.py` independently reproduced
that variant twice, instead of silently comparing a different setup.

There are 208 compared boundaries (66/77/65) across492 native camera
observations. Every compared non-clock field matches bitwise. All208 raw
clock mismatches are retained: native timer +2 equals the Wafel observation.
Two native transition observations are absent in each warping run and are
explicitly reported. This is a comparison of selected logged fields, not
full-memory equivalence.
