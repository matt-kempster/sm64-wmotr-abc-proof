# Controller-produced western Fire Fly Guy lures

The selected 3487-input history reaches a living-Fly ledge, receives its native
flame, climbs to roofY1280, finishes burning and enters crawl. The live actor
reaches Y1735.0334 during later luring. The top is already gone, so this is
not a usable Ink handoff. The96 pre-fourth steering transfers all fail to
establish the living-enemy roof state. Read the complete
[report](../../docs/notes/ink-flyguy-native-lure.md) before treating these as
delivery, timing or arbitrary-position results.

All A inputs are off. Only inherited debug level selection is supplied.
`harness.py` rejects noncontroller writes and native held/pressed-A flags;
it is frozen from the concurrent native-manipulation harness to preserve the
observation schema. No game-state pointer, actor, Mario or timer patch is used.

Run from the SSL project directory:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-flyguy-native-lure/preserve.py
```

The verifier reads archived data and reconstructs every recorded suffix from
its actual controller prefix. It passes146 stored histories and21,181 suffix
observations. `native-flame-roof-inputs.jsonl` is the selected complete stream;
the sibling receipt identifies its exact milestones and scope. An original-ROM
comparison, if completed separately, belongs to the parent JP recorder package.
This directory's receipt claims Wafel agreement only.

| Archive | Nominal recipes | Matched suffix observations |
| --- | ---: | ---: |
| `lures.json.gz` | 32 | 7789 |
| `burn-roof.json.gz` | 18 | 6928 |
| `pre-fourth-late.json.gz` | 48 | 722 |
| `pre-fourth-early.json.gz` | 48 | 5742 |

`search.py`, `burn_roof.py` and `pre_fourth.py` contain the finite steering
policies. Original raw batch paths under ignored `build/` are used by those
exploratory generators; the durable archives and their stored inputs are
authoritative for rechecking, so they do not require the original temporary
files. The pre-fourth archives embed their entire earlier prefix and credit
the existing Box delivery route. Save-state branching is only from reached
states, never invented coordinates. Native frame counts and shared prefixes
must not be interpreted as independent full-route trials.

No ROM, DLL, emulator binary, savestate or copied video footage is distributed.
