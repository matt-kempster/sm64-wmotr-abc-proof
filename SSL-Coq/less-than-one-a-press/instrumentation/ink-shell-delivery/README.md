# Native pending pickup and shell initialization timing

See [the source report](../../docs/notes/ink-shell-delivery-source.md).

`pending_slot.py` reuses the existing real no-A small-box acquisition/carry prefix, then uses only controllers for drop, native expiry, pickup, carry, release, and walking remount. **One shell-box action4 grant remains in every trial.** The guard forbids object/Mario relocation, action grants to Mario, pointer edits, donor timer/deletion edits, and interaction/hitbox fabrication. Debug-level-select startup is inherited. This is not high delivery or an Ink handoff.

Run from `SSL-Coq/less-than-one-a-press` in Windows:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-delivery/pending_slot.py --output build/shell-delivery-fresh.json.gz
```

The destination must be fresh. The default run creates two independent games and requires exact equality of the 49 trials and six followups before writing results. `--pilot` skips that second replay and should not replace the checked record.

`pending-results.json.gz` contains all input suffixes, the prior prefix path/hash, detailed update boundaries, and the exact grant. `verification.log` indexes successes and outcomes. Forty-nine timing cases yield one already-initialized carry-script pickup, four cases where a shell initializes after allocation into an already-held vacant slot, two uninitialized frozen shells, and 42 cases without shell acquisition. The selected timely and post-commit variants survive native drop/throw and walking mount; the uninitialized control fails both mount tests. These are finite observations, not exhaustive route bounds.

Original JP validation of the selected timely/late throw pair is in `../jp-ink-shell-delivery`.
