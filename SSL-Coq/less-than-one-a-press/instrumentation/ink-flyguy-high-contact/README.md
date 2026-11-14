# Supplied high airborne Mario / Fire Fly Guy contact

This finite JP Wafel diagnostic supplies an **airborne FREEFALL** state, never a ground slide or crawl. Native Fly Guy45 XYZ is moved near Mario at Y25000/67277; native Crazy Box49 XYZ is optionally moved nearby. All writes are preserved in `results.json.gz`, and a guard rejects non-controller writes after setup.

Run from `SSL-Coq/less-than-one-a-press`:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-flyguy-high-contact/test.py
```

`prefix.jsonl.gz` is the accepted A-off four-pillar controller prefix, credited to the existing `ink-buddy-movement/original-prefix.jsonl.gz`. The script reconstructs two independent roots at native top action1/timer129 and checks every trial for equality. It asserts the decompressed prefix hash. Existing results are compared, not overwritten.

Results: **24 initial recipes**, all contact the Fly Guy and refresh floor cache to768. Eight produce TWIRLING and sixteen BACKWARD_AIR_KB; zero productive ground actions or stored-graphics splits through45 updates. Four extended continuations reach an ordinary low landing or terminal Mario-object removal. **28 trials /3504 boundary observations PASS** across the two roots. No top capture or useful spawning displacement. These are supplied-state results, not reachable gameplay or original-ROM replays.

The detailed setup, endpoints, limitations and version hashes are in `docs/notes/ink-flyguy-high-contact.md`. `results.json.gz` includes per-update M/C/D, action, floor/cache, top identity/phase, Fly/Box snapshots, collision slots, warp fields, input stream and setup write ledger. No fire behavior is forced and no high flame contact is demonstrated.
