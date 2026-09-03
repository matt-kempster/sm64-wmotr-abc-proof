# Rank 11: retaining the handstand height through ordinary damage

## Verdict

**The departure works in a staged retail test, but the clean setup is still
missing.** A normal Goomba hit makes Mario leave the second pole with all
**174 extra handstand units** intact. He crosses the aperture and lands on
the upper ring without A. However, the matched ordinary-holding test also
crosses: the handstand is useful height, not a necessary ingredient of this
particular damage route. The decisive remaining task is getting a real
damaging enemy to the right side and height through clean play.

This is not a newly discovered controller-only route, an animation-only
launch, a star collection, or a table-mutation witness. The test moves an
already spawned Goomba by writing its three position coordinates. Those
writes are a declared payoff fixture, **not an installer**.

## What was tested

The [reproducible diagnostic](../../instrumentation/jp-rank11-handstand-damage/README.md)
uses the authentic local JP ROM and inherits the existing injected Area-2
loader and 23-write second-pole fixture. Mario starts at `(0,4020,1331)`
with zero velocity. Controller input produces the handstand or reverse
animation; the test does not write an animation, a damage action, an attack
status, or a velocity to manufacture the departure.

At the selected contact, the unique regular Goomba with saved home X/Z
`(3263,3157)` is moved once to `(0, contactY, 1371)`, 40 units on the
positive-Z side. Its live object is `0x80348fb8`, its observed behavior is
`0x800eca2c`, and its saved home Y is **640**. The macro spawn names Y 778,
but its ordinary behavior drops it to the floor before saving home.
The pre-contact object is active, tangible, in walking action, and has the
ordinary far-away flag. Its behavior, home, flags, hitbox, and velocity are
not edited. All subsequent controller inputs are neutral.

| Observed result | Full handstand | Ordinary holding control | Last return-frame control |
|---|---:|---:|---:|
| Diagnostic mode | 0 | 1 | 2 |
| Contact timer | 543 | 525 | 610 |
| Contact Y | 4194 | 4020 | 4070 |
| First damage-action Y | 4194 | 4020 | 4070 |
| First damage-action forward / vertical velocity | -16 / -4 | -16 / -4 | -16 / -4 |
| First target-side timer | 550 | 530 | 615 |
| First target-side position | `(0,4110,1219)` | `(0,3980,1222.40405)` | `(0,4030,1222.40405)` |
| Ring-landing timer | 555 | 532 | 619 |
| Ring-landing Y | 3942 | 3942 | 3942 |
| Later idle on the target side | Yes | Yes | Yes |
| A edges / held-A samples / supplied-A samples | 0 / 0 / 0 | 0 / 0 / 0 | 0 / 0 / 0 |

The target test is the existing south target-air box: X `[-101,102]`,
Y `[3942,6144]`, Z `[922,1229]`. It excludes the central pole shaft. The
crossings therefore mean more than merely observing high Y. Subsequent
landing and idle samples also show that these fixtures do not immediately
fall back through the shaft. They do not establish either star suffix.

The lower two tests have some Z advances larger than 16 despite the
constant forward speed. Their complete motion therefore includes other
interaction/collision effects; controller-poll sampling alone does not
identify each intervening store or certify every collision quarter. The
handstand test's first seven observed advances are 16 units each, while
gravity lowers Y from 4194 to 4110. This agreement with simple arithmetic
is not silently substituted for a full collision proof.

## Why ordinary damage preserves the height

The pinned source revision is `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
The relevant generated US/JP bodies and retail observation agree on this
mechanism:

1. The handstand's height is in Mario's physical position, not just the
   rendered skeleton. Ordinary pole positioning produced Y 4194.
2. A damaging interaction is processed before another pole-position reset.
   `determine_knockback_action` classifies `ACT_FLAG_ON_POLE` with the air
   cases, even though Mario was not already in an airborne action.
3. Normal damage selects a stock airborne knockback action. No action-table
   edit or A input is needed. This differs from an Amp's shock action,
   which zeroes horizontal motion.
4. The normal airborne initializer does not reset position or add upward
   velocity for these knockback actions. The first movement update retains
   the incoming height and then applies gravity, explaining the first
   sampled vertical velocity of -4 rather than a positive launch velocity.
5. The ordinary backward-air-knockback handler supplies forward speed -16,
   carrying Mario away from the enemy toward the opening.

These statements describe the inspected source and tested suffix. The new
Coq execution proof covers the precise subpieces below, not all five steps
as one already-connected live execution.

## What Coq now proves

[`Area2Rank11HandstandDamage.v`](../../proofs/Area2Rank11HandstandDamage.v)
extracts the actual terrain-selection fragment from
`determine_knockback_action`. The extended
[`Area2Rank11BodyResolution.v`](../../proofs/Area2Rank11BodyResolution.v)
proves that this body resolves in each selected linked program.

From a real `MarioState.action` read at byte offset 12 containing holding,
handstand transition, or steady handstand, the proof constructs a connected
`Clight.step2` execution of both generated action reads and tests. It derives
terrain row **1** with unchanged memory. It does not assume that an
arbitrary callback reached the fragment or that the earlier angle/health
calculations were harmless.

The normal forward/backward air-table initializer entries are checked
directly. This is a receipt for the initializer bytes; the existing
private-table invariant, not the receipt alone, supplies persistence. The
strength and direction computations and the actual reached table load are
not yet executed in this new proof.

[`Area2Rank11FallingInitializer.v`](../../proofs/Area2Rank11FallingInitializer.v)
now also covers `ACT_BACKWARD_AIR_KB` and `ACT_FORWARD_AIR_KB`. The existing
real-call proof executes their complete `set_mario_action_airborne` body
under its explicit zero-squish/zero-quicksand entry conditions. Only
`peakHeight` and `flags` are written; all seven Float32 position, velocity,
and forward-speed cells are preserved. This is how the proof permits
retaining an already obtained Y 4194 without inventing an upward impulse.

The new package is
`MainTheorem.current_rank11_handstand_damage_boundary`. Neither that theorem
nor the separate retail receipt is a clean Goomba-placement theorem,
whole-caller execution, IDO-to-Clight bridge, exhaustive collision proof,
or counterexample to a target-star theorem.

## What remains worth doing

The next useful search is a **clean damage-contact installer**, not another
attempt to squeeze a little more height out of the same Z release. It must
bring an actual damaging object to the required side and vertical overlap,
preserve a nonlethal, tangible contact, and reach that contact from the
accepted no-A start without the loader, pole, or Goomba-position writes.
The ordinary-holding control means the search need not insist on a full
handstand. The existing [Goomba-raising investigation](goomba-raising.md)
does not currently supply this transport.

If that installer exists, follow the same live memory through damage,
action selection, every collision phase, the ring landing, and an Act-3
or Act-6 star continuation. If no such installer is possible, this conditional
damage payoff remains true but is unusable as a clean route. Other clips,
supports, and outside effects are still separate Rank-11 obligations.

The [50-unit Z-release audit](rank11-pole-exit-live-audit.md) remains valid:
both of its enemy-free tests fail. The
[hypothetical long-jump mutation](hypothetical-pole-long-jump-mutation.md)
also remains a separate, machine-level idea. **Normal damage does not need
that mutation.**

## Verification

The active SSL Coq build and the new registered capstone's assumption audit
passed; only the project's existing standard Coq/CompCert assumptions occur.
The no-hole, generated-link-hygiene, and repository proof-discipline checks
also passed. All three final damage modes validated, including Float32
position bits, exact logged 23+3 fixture writes, neutral post-placement
inputs, ring landing, and idle recovery. Seven deliberately altered receipts
were rejected per mode. Both original enemy-free Z-release modes were rerun
unchanged and reproduced their prior failures. These checks validate the
stated local proof and staged observations, not a clean no-A counterexample.

[Back to Rank 11](../no-a-route-atlas.md#route-rank-11)
