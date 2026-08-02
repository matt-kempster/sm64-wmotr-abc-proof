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
between the WhitePuff1 and WhitePuff2 pairs, so the global seed is
`R^4(seed_before_puff1)` only under the explicit no-intervening-consumer
premise.

TTC spinners are SURFACE objects and update before PLAYER, DEFAULT, and
UNIMPORTANT. A tap on `F` therefore cannot affect the spinner update already
performed on `F`; `F + 1` is the spinner's first subsequent observation
opportunity. This does not say that no other RNG call occurs before that
opportunity.

## Pool and active-bit boundary

The isolated allocation classes are DEFAULT, DEFAULT, and UNIMPORTANT. The
abstract trace succeeds exactly when `free + unimportant >= 3`. This reserve is
the reserve available to those three operations; a retail proof must also
account for any competing allocations between object-list phases.

`spawn_particle` accepts the request only when Mario's active-dust bit is clear.
The accepted branch sets the bit, and the newly executed Mist script clears it
from its parent. An already-set bit rejects the new spawner and is not treated
as a successful episode.

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
linked retail translation units. Consequently the top-level "link and execute"
and reachable-tap checklist items remain open.
