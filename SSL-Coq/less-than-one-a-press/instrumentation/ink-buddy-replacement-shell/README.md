# Native shell-box approach menu

This is a finite controller-only Wafel JP search, not a shell delivery witness.
The 72 specified prefix/waypoint pairs perform 32,695 updates and release no
native shell. The closest approach is 889.00008 units from the box: Mario is
under it, not on its roof. The largest observed Mario Y is 1471.48779 during
a Crazy Box bounce elsewhere. These extrema occur in different histories.

Only the inherited debug level-selection startup is supplied. After startup,
the guard permits controller writes only and checks that A is released. Prefixes
375, 400, 425, 450, 475, 500, 600 and 656 come from the existing 2,852-input
recording; the archive embeds the first 656 inputs and all later tested inputs.
Nine waypoint choices and the exact steering/termination policy are in
`search.py`. This small menu does not establish no-A shell-box inaccessibility.

`approaches.json.gz` preserves all 72 trial histories and observations. A fresh
boot for each of trials 0, 27 and 62 reproduces all 1,500 sampled boundaries,
covering the first, nearest and highest cases. `receipt.json` lists hashes.
From the SSL project directory:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-buddy-replacement-shell/preserve.py
```

The verifier reads the archived data if present; it can regenerate its receipt.
The exploratory `inventory` mode in `search.py` scans the existing prefix only.
The final `approach` menu is authoritative: an earlier pilot mistakenly counted
an inactive box after area exit as a release. The corrected release predicate
requires the native shell-box action 4; all earlier apparent releases disappear.
Missing area/camera and death termination were also corrected before this run.
No original-ROM replay or Coq proof is claimed for this menu.

The independent source review also rejects one proposed transport shortcut:
mounting and immediately cancelling with Z leaves a free shell, because the
stop assignment overwrites its INTERACTED bit before its first callback. It
does not create a shell that follows an unmounted Mario. Later cancellation of
an already-following shell deletes it. This is a specific path analysis, not
an exclusion of every shell clone or movement history.
