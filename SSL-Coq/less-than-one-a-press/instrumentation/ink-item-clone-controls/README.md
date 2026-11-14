# Initialized clone-state item controls

The user's target is a productive ground movement action: crawl, walking,
or a relevant ground slide. These controls test whether freezing a stock
actor's native callback changes its actual interaction into such an entry.
A cloned Goomba diagnostic still gives an airborne bounce or airborne
knockback; it does not create the requested ground action.

Run from `SSL-Coq/less-than-one-a-press` with an unused output filename:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-item-clone-controls/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-item-clone-controls-rerun.json
```

`fixtures.py` supplies the shared native-actor API for the separate pair and
triple studies:

```python
g, observer, base130, inventory, preparation = roots(capture)
g.load_state(base130)
# The caller enables its declared setup-write guard here.
cut = place_actor(g, slot, xyz, ledger, mode='native')
```

`carry_clone` mode requires the existing actor's HOLDABLE flag to be clear.
It supplies the actual non-HOLDABLE held-state helper's parent/script/stack
effects, without claiming a fake-pickup allocation history. `forced_frozen`
also permits a HOLDABLE actor, explicitly as a diagnostic override. Neither
mode modifies type, subtype, size, scale, tangibility, interaction status,
velocity, list membership, or the original behavior identity.

The roots helper creates the actual stock shell through its shell-box
callback. Its slot in this fixture is 126; callers must use the returned
inventory/preparation rather than another study's slot number. The complete
inventory describes live fields in this prefix, not every object available
through every later native spawn. In particular, its Tweesters currently
have zero radius/height and its Pokey parts/flames/explosions are absent.

The final run has 32 native/frozen single-actor controls at Y=25000 and
67277, with 256 matching fresh-runtime boundaries and no top capture.
The durable report and receipt are `docs/notes/ink-item-clone-controls.md`
and `docs/notes/ink-item-clone-controls-receipt.json`. All setup writes and
all eight updates per control are preserved. This is not a new original-ROM
replay, a demonstrated legitimate clone lineage, or a controller route.
