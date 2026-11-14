# Pink Bob-omb Buddy: exact scope of the movement proof

The stock SSL cannon Buddy is not proved permanently immovable. Ordinary
movement and delivery remain gameplay questions. The new proof instead
separates what the real pickup/drop helpers do from whether a player can make
them operate on the Buddy, and closes one tempting native-dialog pickup path.

Source baseline: proof fork `9229f9e2466782a142b595fda6d5cc64ee4c1016`, using the
existing selected US/JP generated Clight (the gameplay question is JP). Coq
8.16.1 and CompCert 3.15, Ubuntu WSL `sm64-item-proof` switch, established
pipeline and memory limits. The [source](ink-buddy-movement-source.md),
[runtime](ink-buddy-movement-runtime.md), and
[combined verdict](ink-buddy-movement.md) records give the gameplay
observations; this record describes only the formal boundary.

`proofs/InkBuddyMovement.v` is registered in `_CoqProject` and exported by
`MainTheorem.current_ink_buddy_movement_boundary`. Its statements are:

- `ibm_stock_buddy_holdable_source`: the actual generated stock cannon-Buddy
  initializer contains `OR_INT(oFlags, 0x6449)`, including HOLDABLE `0x400`,
  and the native Buddy loop. This is a finite source certificate; it does not
  pretend to execute the behavior interpreter or establish every later flag.
- `ibm_holdable_pickup_preserves_position_and_script`: given the concrete
  readable/writable storage and script-address inputs required by the existing
  complete `obj_set_held_state` proof, an actual HOLDABLE pickup call preserves
  object XYZ, `curBhvCommand` and `bhvStackIndex`. The proof consumes the exact
  two stores of that real helper: parent at offset 104 and held state at 292.
  It checks the selected script-field layouts at 460 and 464 and requires a
  nonwrapping object address. Thus calling the helper on a HOLDABLE Buddy does
  not replace its callback with the inert carry script. This statement alone
  says nothing about later callbacks moving or preserving the object.
- `ibm_pickup_actions_cannot_pass_npc_readiness`: an actual execution of the
  generated `mario_ready_to_speak` body returns zero, emits no trace and leaves
  memory unchanged when live Mario action is PICKING_UP (899),
  DIVE_PICKING_UP (901), or PICKING_UP_BOWSER (912). The proof constructs the
  selected path from the real global-pointer and action-field loads. The
  action group is OBJECT, not STATIONARY or MOVING; the presence of a separate
  stationary *flag* does not change that group. This closes the readiness
  gate during those actions, not all possible ways of corrupting `usedObj`.
- `ibm_actual_drop_changes_actor_height`: if an actual reached drop-placement
  tail holds an actor in a valid object slot and its old Y differs from live
  Mario movement Y, the real tail changes actor Y to that movement Y. It
  requires explicit object-pool bounds, separation of Mario/object storage,
  pointer and coordinate loads, and actual tail execution. It is applicable
  to a Buddy when that Buddy is the held slot. It neither constructs a legal
  pickup history nor asserts that the subsequent native callback preserves
  the deposited position. The stronger existing drop boundary, including
  exposure of the actual placement cut from the full helper call, is also
  included in the exported conjunction.

These proofs do not turn a supplied `usedObj`/`heldObj` pointer into a reachable
clone, do not prove a normal grab of the TEXT-interaction Buddy, and do not
prove arbitrary Buddy delivery to the Ink producer. Conversely, permanent
immobility is too strong: the real generic coordinate writer has no
Buddy-exclusion check once its live pointer identifies that actor. The precise
remaining route obligation is to obtain the necessary pointer and positioning
history through permitted gameplay and retain a useful collision actor at the
required phase.

The targeted `InkBuddyMovement.vo` pipeline build passed. The final selected
audit also passed at `build/audit/20261114-074322-qt2hydth`, including the actual
`MainTheorem.vo` build, proof-hole scan, link hygiene, and integration. It
inventoried 720 sources and found 554/640 modules in MainTheorem's import
closure, with 86 standalone modules and zero integration problems.

The established three assumption checks remain at 9, 7 and 4 allowed
foundations. The new exported Buddy boundary reports seven allowed
foundations: classical excluded middle, two standard real-number decision
principles, proof irrelevance, dependent functional extensionality, and
CompCert's external-function and inline-assembly semantic parameters. It adds
no project axiom or admission. These foundations are not a claim that the
explicit gameplay premises have been discharged. The complete commands,
logs and assumption lists are archived under
[`instrumentation/ink-buddy-proof`](../../instrumentation/ink-buddy-proof/README.md).

Initial development builds failed on local tactic/name/import issues; these
were corrected. Slow temporary-map rewriting was replaced by syntax-directed
lookup. One attempt failed during imports after interrupted WSL wrappers
briefly left earlier compiler processes alive; the stale processes were
verified gone before the successful sole-compiler build. No memory limit was
raised, and the final audit was run after the proof source was stable.
