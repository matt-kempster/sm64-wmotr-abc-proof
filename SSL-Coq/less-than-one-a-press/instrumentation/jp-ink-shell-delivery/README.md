# Original-JP shell-slot timing pair

See [the source study](../../docs/notes/ink-shell-delivery-source.md) and [the original-JP report](../../docs/notes/ink-shell-delivery-rom.md).

This package preserves two no-A controller replays plus **one supplied shell-box action4 change** per replay. Native small-box expiry leaves the selected pickup slot free. Timely shell allocation lets its first callback initialize before Mario commits pickup; one-update-late allocation freezes it before initialization. Native carry/throw and walking approach mount only the initialized variant. This is neither high shell delivery nor an Ink handoff.

Rebuild expected traces on Windows from the SSL project directory:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/jp-ink-shell-delivery/prepare.py
```

Run in Ubuntu-24.04 WSL from that directory, choosing fresh output directories:

```bash
bash instrumentation/jp-ink-shell-delivery/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/jp-shell-delivery-timely-fresh timely
bash instrumentation/jp-ink-shell-delivery/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/jp-shell-delivery-late-fresh late
```

`prepare.py` checks each suffix against the independently verified Wafel search. `probe.c` extends the established read-only replay observer and adds exactly one logged write, to the native shell box's action. `run.sh` hash-checks original JP, compiles a separate local plugin, and uses the inherited level-select startup. No ROM bytes or save states are distributed. Native controller records are1894/1972 inputs, all A-off.

Each case directory contains the controller schedule, setup manifest, expected fields, compressed native raw log, archived check results, and hashes. To recheck an archived record without the emulator:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/jp-ink-shell-delivery/check.py instrumentation/jp-ink-shell-delivery/timely/native-record timely
& build/wafel-pilot/python/python.exe instrumentation/jp-ink-shell-delivery/check.py instrumentation/jp-ink-shell-delivery/late/native-record late
```

**Comparison scope matters.** The original strict expanded check found462 differences in each run: small-box subtype2 on ROM versus0 in Wafel at prefix polls372–833. Initial failed receipts are retained. All Mario position/action/floor/platform fields and all other actor fields match. From poll834 onward every compared field matches:1061 timely and1139 late observations. The revised checker explicitly reports `fullComparedFieldsMatch:false` and certifies that suffix separately, requiring the exact known prefix discrepancy. It does not suppress mismatches or modify gameplay state. The initialized native shell mounts; the uninitialized control does not.
