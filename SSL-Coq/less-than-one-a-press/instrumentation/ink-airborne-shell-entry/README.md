# Airborne shell entry and the skipped Crazy Box push

`search.py` tests eight supplied-freefall controls and repeats two successful
supplied-butt-slide controls in the existing Wafel 0.8.5 JP runtime. The shell
is created using the existing `shell_root`: one declared shell-box action
write followed by two native updates. Every subsequent Mario/actor setup
write and input is recorded. After each pose cut, only controller input is
written; all inputs keep A released.

From `SSL-Coq/less-than-one-a-press`, use a new output filename:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/ink-airborne-shell-entry/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-airborne-shell-entry-NEW.json
```

The script reboots and reconstructs the complete root independently, matching
every recorded boundary and event for all ten trials. It never replaces an
existing output. The retained receipt is
`docs/notes/ink-airborne-shell-entry-receipt.json`; the human-readable result
is `docs/notes/ink-airborne-shell-entry.md`.

The combined shell+box control detects both objects but does not apply the
box shove: successful shell mounting terminates the interaction loop before
the later grabbable handler. The following Z cancellation creates the vertical
split but leaves X on the low pad. This is a narrow failed transition, not
an exclusion of every actor-mediated airborne entry or a controller route.

No new original-ROM recording is produced by this script. The parent
investigation's separate original-JP observer, if run, has its own receipt.
