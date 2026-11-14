# Large-box collision mesh: reload, cloning and time stop

Finite JP Wafel0.8.5 experiments, with133 update boundaries reproduced exactly
from two independent fresh roots. No original-ROM or Coq result is claimed by
this package. See `../../docs/notes/ink-box-floor-runtime.md`.

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-box-floor-lifecycle/test.py --verify instrumentation/ink-box-floor-lifecycle/results.json.gz
```

`--output NEW.json.gz` records a fresh artifact and refuses to overwrite an
existing one. The script verifies the pinned runtime and existing compressed
four-pillar prefix. Its only prefix grant is the accepted debug level select;
it does not spawn the shell used by the earlier handoff test.

Five high-mesh diagnostics examine live movement, a retained transform,
carry-script freezing, time-stop retention and freezing before any high mesh
is loaded. The native conditional pickup starts an ordinary small-box grab,
then supplies only `usedObj=large box13` during the pickup animation. Native
grab selects the carry script. Separate branches test ordinary drop/throw,
and time stop followed by a native throw from supplied high HOLP. All A inputs
are off. Mario/actor positions, action preparation, pointer retarget, time-stop
flags and high HOLP are explicit grants; this is not a reachable cloning route.

`results.json.gz` records every setup edit, input, boundary, all12 owned
surface vertices/normals/flags/indices, linked partition references, actor
state/transform/throwMatrix, and Mario M/C/G/cache/platform/holding fields.
Floor probes are separate supplied-Mario full updates, not direct calls to a
new handwritten floor model. Wafel's API has no arbitrary function-call hook.

The strong check distinguishes raw actor movement from floor movement:
time stop keeps exactly the old surface bytes and partition links even after
the native throw moves the clone to high raw coordinates. At the old footprint
Mario still finds box floor251; at the high destination he finds a retained
top floor1840.88232421875, not a new box floor25000. Resuming ordinary updates
clears the box mesh. All limits and source revisions are in the note/receipt.
