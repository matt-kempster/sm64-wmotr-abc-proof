# The object set, glitches, and why "a small fixed set of gamepieces" must be stated carefully

> A faithful capture of a discussion prompted by **Spiny Adoption** (a real SM64 memory-
> manipulation glitch). The y-bound endgame (and similar arguments) wants to lean on "only a
> small, fixed set of objects -- 'gamepieces' -- is ever loaded, and nothing can produce
> objects outside that set." The worry: glitches that corrupt objects might falsify that.
> This works out *what* is actually true, what isn't, and how to phrase the claim so it is
> robust to glitches instead of accidentally assuming them away. See also
> [pointer-writes-and-block-disjointness.md](pointer-writes-and-block-disjointness.md) and
> [trust-model.md](trust-model.md).

## Spiny Adoption, traced in the code

`src/game/behaviors/spiny.inc.c:49` (and :173), inside `spiny_check_active`:

```c
//! It's possible for the lakitu to despawn while the spiny still references it.
//  This line allows us to decrement the 0x1B field in an object that loads into
//  the lakitu's former slot. [dev comment -- the glitch is documented in-source]
o->parentObj->oEnemyLakituNumSpinies--;
```

- `oEnemyLakituNumSpinies` = `object_fields.h:648` = `OBJECT_FIELD_S32(0x1B)` = **`rawData.asS32[0x1B]`**. Every object's fields are slots of one `union rawData` in `struct Object`.
- `o->parentObj` is a genuine `struct Object *` into `gObjectPool`. Lakitu uses it to track how many spinies it has thrown. If Lakitu is killed and another object loads into its pool slot, `parentObj` now points at that object, and the `--` lands on **word 0x1B of whatever object now occupies the slot** (e.g. a goomba's size field; a bob-omb respawner's model id).

Mechanism in one line: a **stale but valid** `Object*` aliasing a reused pool slot, plus an ordinary decrement.

## The key realization: this is well-defined C, and a faithful model reproduces it for free

At the C/Clight level this is **not** a wrong-function jump and **not** UB. The pointer targets a
live `struct Object` of the right type; reading/writing its fields is defined. The only spicy
part -- reading `asS32` of a slot last written as `asF32`/a pointer (union type-pun) -- is
modeled faithfully by CompCert: its memory model is concrete and byte-based with **no**
type-based alias analysis, and the decomp assumes `-fno-strict-aliasing`. So CompCert and the
real ROM agree; **Spiny Adoption lives inside our trusted semantics, not in the IDO-vs-CompCert
seam.**

Therefore a faithful model -- object pool as a real array, `parentObj` as a pointer that can
hold any slot's address -- **reproduces Spiny Adoption automatically.** It is exactly the
leak-#1 / regime-2 aliasing case (one array, runtime/data-chosen index, cross-object pointers).

> The ONLY way we "disprove" the glitch is by **cheating on precision**: assuming `parentObj`
> points to the intended spawner, or that object fields are private/non-aliasing. That
> assumption is unsound and would falsely make the glitch impossible.

So **Spiny Adoption is a free red-team test**: any object-system abstraction we build is correct
only if the glitch remains *possible* under it. We do not model glitches; we refuse to assume
them away. The conservative (havoc / over-approximation) direction keeps them in scope for free.

## What is actually, provably bounded (glitch-proof)

- **Slot count is fixed by construction.** `gObjectPool[OBJECT_POOL_CAPACITY]`,
  `OBJECT_POOL_CAPACITY = 240` (`object_list_processor.c:69`, `.h:26`). A static array: **no
  glitch can add a slot.** Cloning-type glitches duplicate *into existing slots*, bounded by the
  same 240. "Object count is bounded" is an unbreakable theorem.
- **Level load wipes the pool.** `object_list_processor.c:549-551` deactivates all 240 slots on
  init. Corrupted object state **cannot survive a level transition.** The gamepiece set is
  re-established per level.

## What Spiny Adoption does and does *not* do

- It does **not** add a slot and does **not** create an out-of-set object.
- It writes **one data field** (`rawData.asS32[0x1B]`) by a **bounded** amount (a decrement, a
  finite number of times: <=3 spinies, Lakitu in 2 courses, no respawn).
- It writes a *data* word, **not** the object's `behavior`/`curBhvCommand` pointer -- so the
  corrupted object keeps running the **same behavior code**; only a field shifts (goomba size;
  the respawner's *model* id, which is cosmetic -- it still spawns a bob-omb-behaved object).

So it **does not expand the set of behaviors that can run.** It is a bounded perturbation of data
within existing behaviors.

## The robust phrasing: bound *behaviors + perturbation*, not *exact state*

The fragile claim -- "exactly these objects exist with pristine intended field values" -- is the
one glitches break. The robust claim, provable and glitch-resistant, is a conjunction:

1. **<=240 slots** (pool array; hard).
2. **The behavior set is closed**: the only behaviors that ever run are those reachable from
   spawn calls in reachable code (static, enumerable) -- **provided** no reachable store corrupts
   the `behavior`/`curBhvCommand` offsets. That clause is a **proof obligation**, not an
   assumption (Spiny proves writes *can* alias other slots). Discharge it by **offset-level frame
   analysis on `struct Object`**: enumerate which `rawData` offsets reachable pool-aliasing writes
   can hit, and show the control-pointer offsets are not among them.
3. **Fields are perturbable only within achievable bounds**: the y-bound (etc.) is proved against
   "in-set behaviors running with fields perturbed within reachable limits," not pristine objects.

Spiny Adoption *passes* this conjunction (bounded data perturbation, no control-pointer touch),
which is the signal that the phrasing is sound.

## Per-level constructibility (a method, not a fixed fact)

Whether a given glitch can even be set up is a property of the **target level's reachable object
set**: check whether the glitch's prerequisites (here: an enemy Lakitu to sacrifice) can be
present. Worked example of the method: grepping the Hazy Maze Cave level tree finds **no** enemy
Lakitu/spiny, so Spiny Adoption is not constructible there.

> CAVEAT (correction during the discussion): do **not** assume which level a given star/challenge
> lives in. The HMC example above is only an illustration of the *method*; it is independently
> true (HMC places no Lakitu) and is **not** a claim about where any particular challenge resides.
> The relevant level must be pinned separately before using this kind of fact.

## The honest residual

The catastrophic version -- a glitch corrupting `behavior`/`curBhvCommand` into arbitrary code
(true ACE) -- would break the behavior-set bound entirely. SM64 has no *known* general ACE (the
Spiny Adoption writeup itself judges ACE "unlikely" from it). But "no known" is not a proof:
obligation #2 above **is** that proof, and it is tractable with the offset-level frame machinery,
not a new dragon.

## Standing design constraints for the object model

1. Model `gObjectPool` as a **single, index-addressed array** -- distinct objects are distinct
   *offsets in one block*; block-level disjointness buys nothing inside the pool.
2. Treat cross-object pointers (`parentObj`, `prevObj`, `gMarioObject`, ...) as **freely
   aliasing** any slot.
3. Treat `behavior`/`curBhvCommand` and other control fields as **mutable, corruptible memory**,
   not static properties (see the dragon discussion in
   [whole-program-and-the-interpreters.md](whole-program-and-the-interpreters.md)).
