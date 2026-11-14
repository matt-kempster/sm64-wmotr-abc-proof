# Native landing before the slide producer

14 November 2026. A supplied airborne Mario lands on the actual top, enters
butt slide through native landing cancellation, then makes a 1106.9208984375
movement/stored-graphics gap. The box can be placed before that landing;
native upward box motion delays contact until the following update. The warp
is accepted, but the low query still finds the static pad and Area 2 arrival
is ordinary. Initial airborne Mario and actor placement are supplied.

Run from `SSL-Coq/less-than-one-a-press` in Windows PowerShell, using fresh
output names (scripts refuse to overwrite existing results):

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-supported-slide-preparation/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-landing-search.json
& build/wafel-pilot/python/python.exe instrumentation/ink-supported-slide-preparation/targeted.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-landing-targeted.json
& build/wafel-pilot/python/python.exe instrumentation/ink-supported-slide-preparation/earlier_box.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-landing-earlier-box.json
```

`search.py` checks 2736 airborne cuts over two phases and derives actor
positions from observed native platform carry. `targeted.py` refines the
important signed-integer terrain edge with six targets and preserves their
full continuations. `earlier_box.py` tests 97 explicitly listed early actor
placements, retaining the exact failing same-height case, six successes
with earlier placement, and two earlier-phase negatives. Every selected
case is reconstructed from a second independent native boot and prefix.

The write guard permits only controller input after initial Mario setup,
except for an explicitly declared actor XYZ cut. For `earlier_box.py`, that
actor cut is before the Mario cut or at the same boundary. Actor velocity,
action, held state and active flags remain native. Every observed field,
action/movement event, controller input and setup write is in the receipts.
No script writes a cached floor, platform, top phase or surface.

`probe.py` is the retained diagnostic that reads a `search.py` BEST log and
expands the last four selected cases; it helped identify that a proposed
X=-1946 target can become -1945.95 and select the Y=1280 roof after truncation.

See [the study](../../docs/notes/ink-supported-slide-preparation.md), its
three archived JSON receipts, and the independent original-JP modes 4/5 in
[jp-ink-mario-entry](../jp-ink-mario-entry/README.md).
