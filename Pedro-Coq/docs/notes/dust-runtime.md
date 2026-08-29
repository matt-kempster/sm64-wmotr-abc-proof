# Dust runtime projection

This note records exactly what the checked dust episode does and does not
establish for `VERSION_US` and `VERSION_JP`.

## Source-derived episode

The executable projection decodes the committed `clightgen` initializers for
`bhvMistParticleSpawner`, `bhvWhitePuff1`, and `bhvWhitePuff2`. It also checks
the stock non-terrain list order and the fact that list traversal reloads
`firstObj->next` after `cur_obj_update`, permitting children appended to a later
position in the current walk to execute on that frame.

With accepted dust, normal time, successful isolated allocations, and a clear
active-dust bit, the derived sequence is:

| Order | Frame | Object list | Object/site | Dust-owned `random_u16` calls |
|---:|---:|---|---|---:|
| 1 | `F` | PLAYER | Mario dispatches Mist | 0 |
| 2 | `F` | DEFAULT | Mist spawns WhitePuff1 and WhitePuff2 | 0 |
| 3 | `F` | DEFAULT | WhitePuff1 X, then Z | 2 |
| 4 | `F` | UNIMPORTANT | WhitePuff2 X, then Z | 2 |

Thus the dust-only event trace has exactly four calls on `F`. Each puff's two
calls is a consecutive pair. Pre-existing UNIMPORTANT objects may consume RNG
between the WhitePuff1 and WhitePuff2 pairs. `TTCRNGWindow.v` therefore proves
the more useful exact composition rule: if a certified finite trace contains
`k` non-dust calls before, between, and after the two pairs, the final seed is
`R^(4+k)(seed)`. The special `R^4(seed_before_puff1)` statement still requires
`k = 0`.

TTC spinners are SURFACE objects and update before PLAYER, DEFAULT, and
UNIMPORTANT. A tap on `F` therefore cannot affect the spinner update already
performed on `F`; `F + 1` is the spinner's first subsequent observation
opportunity. This does not say that no other RNG call occurs before that
opportunity. The generated prefixes before spinner 0 and spinner 7 contain 39
and 46 macro records. Their source-derived path budgets, plus the area Thwomp,
give conditional conservative bounds of 80 and 94 non-dust calls. The bounds
retain two premises: a live object/action/timer snapshot must match the prefix,
and every consumer outside that prefix must be certified absent.

## Pool and active-bit boundary

The isolated allocation classes are DEFAULT, DEFAULT, and UNIMPORTANT. The
abstract trace succeeds exactly when `free + unimportant >= 3`. This reserve is
the reserve available to those three operations; a retail proof must also
account for any competing allocations between object-list phases.

Generated TTC level-script and loader receipts now count the source inventory:
110 macro descriptors, 9 area object descriptors, and Mario. Subtracting that
inventory from the 240-slot capacity gives nominal headroom 120 and reduces a
future no-deallocation competitor certificate to at most 117 important
allocations. Descriptor filtering and unexecuted loader paths mean this is not
yet a theorem about the simultaneous live pool at a tap.

`spawn_particle` accepts the request only when Mario's active-dust bit is clear.
The accepted branch sets the bit, and the newly executed Mist script clears it
from its parent. An already-set bit rejects the new spawner and is not treated
as a successful episode. Starting from a clear boundary, the normal-frame
reduction proves that any finite request sequence ends each DEFAULT phase with
the bit clear. A retail trace must still refine its frames to that reduction
and exclude the relevant time-stop cases.

No current theorem derives the clear bit or reserve bound at a reachable TTC
Pedro tap.

## Clight link boundary

`DustClightLink.v` selects the relevant generated definitions verbatim and
proves that two disjoint symbol slices have a witness under CompCert's official
`Linking.link`. This is useful link-hygiene evidence, but the slice is
structural: it is not a complete program with every composite definition,
global, and external resolved.

`DustBehavior.v` separately executes a source-derived behavior/list model. No
theorem currently identifies that model with a Clight big-step execution of the
linked retail translation units.

`DustClightExec.v` does supply one genuine semantic foothold: in a complete
scalar program containing the exact generated seed global and `random_u16`
function, a writable zero seed cell has a silent CompCert big-step that returns
and stores `57460`. US and JP definitions are definitionally identical. This is
one zero-seed leaf execution, not arbitrary-seed refinement or execution of the
object/behavior scheduler. Consequently the top-level "link and execute" and
reachable-tap checklist items remain open.
