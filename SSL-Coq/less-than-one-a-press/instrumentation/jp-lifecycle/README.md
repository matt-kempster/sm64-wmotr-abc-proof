# JP Timer-131 lifecycle and protected-memory receipt

This fixture starts from the project's accepted level-select endpoint and
tests the route-relevant spinning-top prefix.  It writes `4` only to the
pyramid top's pillar-counter word in object-pool slot 61, then lets the
hash-authenticated original-JP game run normally until the top reaches action
1, timer 131.  The write is logged separately at `0x803452ec`; it is disjoint
from Mario's slot 67 and every protected range.

The probe arms CPU write watchpoints for both Mario pointers, Mario's list
links, active halfword, behavior, `oFlags`, graphical Y offset, the list-0
sentinel links, all 14 `bhvMario` words, and all 56 behavior-dispatch entries.
It also counts the three Mario callbacks, allocation and unload functions,
the two sound functions, the two print callees, and the two debug-specific
print call instructions.  `run.sh` rejects any changed endpoint line or any
missing, extra, reordered, or altered watched write.

Run the canonical receipt with:

```sh
bash instrumentation/jp-lifecycle/run.sh /path/to/baserom.jp.z64
```

The accepted interval is global timer 348 through 492.  It contains 145
poll-boundary samples and 144 complete updates.  Every update produces exactly
one watched event: `sh $zero, 0x76(object)` at `0x802c88c4`.  That halfword is
immediately after, and does not overlap, the protected `activeFlags` halfword
at offset `0x74`.  At action 1 timer 131, Mario is still slot 67, both Mario
pointers agree, the one-node player-list ring and `bhvMario` persist,
`oFlags=0x100`, the graphical offset is zero, and both command-array hashes
are unchanged.

The interval executes each Mario callback 144 times, enters allocation 93
times, unloads 71 objects, and reaches `stop_sounds_from_source` 71 times,
without allocator fallback or a protected write.  The separate retail-MIPS
certificate gives the sound routine an all-path object-pool frame and proves
`sqrtf` store-free.  HUD rendering reaches `print_text` 864 times and
`print_text_fmt_int` 432 times; the watched receipt covers those machine calls.
The two conservative debug callsites at `0x802c99dc` and `0x802c9a08` have
zero hits, and their authentic JAL words decode to the recorded print callees.

This is a conditional execution receipt, not a clean four-pillar witness or a
universal theorem over all controller histories.  It also relies on the
debugger's CPU-watchpoint behavior rather than a formal semantics of the whole
N64.  Its valid conclusion is precise: no corruption producer occurs in this
selected route-specific machine timeline.  Universal exclusion still needs
all-history protected-step coverage (or the CompCert
`InkTimer131ReachableStepCoverage` theorem) and a machine-step refinement of
watchpoint completeness.
