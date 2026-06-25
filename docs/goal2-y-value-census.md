# GOAL 2 working notes — the Mario-y census (where can Mario's height change?)

**Status:** exploratory notetaking, 2026-06-24. Second pass — the cat-2 jump
A-gate census is now **verified** (§3b). Census is from a mechanical grep over
`vendor/sm64/src/game/*.c` plus reading the step engine; treat line numbers as of
the vendored decomp. Claims marked **[VERIFIED]** were read in source;
**[CONJECTURE]** / **[TODO]** are not yet checked. This is a notetaking doc, **not**
a proof — no Coq has been written for GOAL 2; GOAL 2 (`WMotRRequiresA/`) is unstarted.

## 0. Why this is the crux of GOAL 2

GOAL 2 = "you cannot finish *Wing Mario over the Rainbow* without pressing A."
The route argument bottoms out in a **height bound**: the star (and the red coins
gating it) sit at some y\* high in the sky; if, under "A never pressed", Mario's
gameplay y is provably bounded below y\*, he can never touch them, so the star is
unreachable. So the whole thing reduces to:

> **Bound `gMarioState->pos[1]` over all no-A reachable states.**

The bet (yours): the set of code that can *raise* Mario's y is small and
enumerable; the genuinely unbounded raisers (flight, cannon, debug) are A-gated
or out of scope; everything left is pinned to **stage geometry** (floors,
ceilings, water, ridable objects), which is bounded per level.

This doc is **only the census + categorization** of y-changing code. It does not
prove the bound. It tells us exactly what a bound proof must dominate.

## 1. What "Mario's y" is, and a trap to avoid

`struct MarioState` (`include/types.h:255`): `Vec3f pos` @0x3C, `Vec3f vel` @0x48,
`f32 forwardVel` @0x54, `ceilHeight` @0x6C, `floorHeight` @0x70, `waterLevel`
@0x76, `peakHeight` @0xBC. **`pos[1]` is gameplay y** — the value collision and
object interaction use, hence the value that determines whether Mario can touch a
red coin / the star.

**TRAP — visual vs. gameplay.** `m->marioObj->header.gfx.pos[1]` is the *graphics*
node position (the rendered model). Writing it does **not** move the gameplay
hitbox. Several hits in the grep are gfx-only and are **irrelevant to the bound**:
`mario.c:1838`, `mario.c:1552` (quicksand visual sink), `airborne.c:676` (+42 gfx),
`moving.c:774` (+45 gfx), `submerged.c:431` (bob), `cutscene.c:2473`. Likewise the
**camera** (`c->pos[1]`, `marioPos[1]`, all of `camera.c`) and the **statusForCamera**
mirror (`automatic.c:526`) are not gameplay y. The census below keeps only writes
to the real `m->pos[1]` / `gMarioStates[0].pos[1]`.

## 2. The three channels by which gameplay y changes

Every change to `m->pos[1]` is one of:

1. **Velocity integration** — the air/water step engines do `pos[1] += vel[1]/4`
   per quarter-step (`mario_step.c:620`, ×4 ⇒ `+= vel[1]` per frame). This is the
   **only channel that can climb without a geometric ceiling**, and it is driven
   entirely by `m->vel[1]` (yVel). So "bound the rise" ≈ "bound yVel and how long
   it stays positive."
2. **Terrain/object pinning** — direct writes that set y *equal to* a
   floor/ceiling/water/object-relative value. These are **self-bounding by stage
   geometry**: y is set to something already in the level, never accumulated.
3. **Whole-vector copies / scripted offsets** — `vec3f_copy(m->pos, …)` and
   cutscene/automatic scripted nudges.

### 2a. The integration bound (channel 1), made concrete  [VERIFIED]

Gravity (`mario_step.c:apply_gravity`, ~505–560): each frame `m->vel[1] -= 4`
(times a heaviness ≤ 1; special cases −1/−2/−3.2 for cannon/longjump/lavaboost),
floored at terminal `−75`. Integration: `pos[1] += vel[1]` per frame. So from a
launch yVel `V > 0`, Mario rises while vel stays positive, i.e. ~`V/4` frames, and
the apex above the launch floor is the discrete sum
`V + (V−4) + (V−8) + … ≈ V²/8`. **Bounded by the largest launch yVel.** A jump of
V=69 (triple) tops out ~600 units above its floor; even V=100 (cannon) ~1250.

⇒ The rise from any single launch is a constant above the launch floor. So if
launch yVel is bounded **and** the launch floor is bounded, channel-1 rise is
bounded. The work is (a) enumerate every yVel-positive setter, (b) show each is
either A-gated or a bounded constant, (c) bound the floor (channel 2).

## 3. Census A — yVel setters (`m->vel[1] = …`), the climb fuel

`mario.c:set_mario_y_vel_based_on_fspeed` (763) is the jump hub:
`vel[1] = initialVelY + get_additive_y_vel_for_jumps() + forwardVel*mult`.
Jump-action → initial yVel table (`mario.c:786–883`):

| action | yVel | A-gated? |
|---|---|---|
| ACT_JUMP / HOLD_JUMP | 42 +0.25·fwd | **A** (set_jumping_action, `mario.c:1118`) |
| ACT_DOUBLE_JUMP | 52 +0.25·fwd | **A** |
| ACT_TRIPLE_JUMP | 69 | **A** |
| ACT_BACKFLIP | 62 | **A** |
| ACT_FLYING_TRIPLE_JUMP | 82 | **A** — and in taint set **T** (GOAL 1) |
| ACT_WATER_JUMP / HOLD | 42 | **A** |
| ACT_BURNING_JUMP | 31.5 | **A** |
| ACT_RIDING_SHELL_JUMP | 42 +0.25·fwd | **A** |
| ACT_WALL_KICK_AIR / TOP_OF_POLE_JUMP | 62 | **A** |
| ACT_SIDE_FLIP | 62 | **A** |
| ACT_STEEP_JUMP | 42 +0.25·fwd | **A** |
| ACT_LONG_JUMP | 30 | **A** |
| ACT_SLIDE_KICK | 12 | **A** (B/crouch-A; needs care) |
| ACT_JUMP_KICK | 20 | **A** |
| **ACT_LAVA_BOOST** | **84** | **NOT A** — hazard launch (touch lava) |
| ACT_SHOT_FROM_CANNON | 100·sin(pitch) (`automatic.c:732`) | **A** (fire) + taint **T** |
| ACT_FLYING | forwardVel·sin(pitch) (`airborne.c:364`) | taint **T** — the **unbounded** climb |

Non-jump positive yVel impulses found:
- `interaction.c:bounce_off_object(velY)` (510) — bounce off enemy head; velY set
  by caller. `interaction.c:592` `vel[1]=20`, `:1148` `vel[1]=12`. **NOT A-gated.**
  Small constants. [TODO: enumerate every `bounce_off_object` caller + its velY.]
- `automatic.c:732` tornado `vel[1]=100·sin`, `:778` `+=1`, `:786` `=20` — the
  **tornado** lift. **NOT A-gated** (object-driven). Bounded per encounter. [TODO]
- `cutscene.c:1303/1377/1701` `vel[1]=60` etc. — cutscene-scripted (e.g. star
  grab launch). In cutscene actions; bounded, scripted.

**Reading:** the big climbers (≥52) are **all A-gated jumps or taint-set
flight/cannon**. The non-A survivors are small constants (≤20 bounce, 84 lava
boost one-shot) or object-driven lifts (tornado), each a bounded impulse → bounded
apex by §2a. **Flight is the only unbounded one, and it's taint-set T.**

### 3b. The jump A-gate is a ONE-WRITER invariant  [VERIFIED 2026-06-24]

The cat-2 claim ("every yVel-positive jump needs A") resolves to a single,
mechanically-checkable fact, much cleaner than gate-by-gate enumeration:

> **`INPUT_A_PRESSED` (`0x0002`, `sm64.h:53`) is set at exactly ONE site in the
> entire game source: `mario.c:1255`, inside `update_mario_button_inputs`, guarded
> by `if (m->controller->buttonPressed & A_BUTTON)`.**

Grep over all of `vendor/sm64/src/` confirms: the only `|= INPUT_A_PRESSED` is
`mario.c:1255`; every other mention is a *read* (`m->input & INPUT_A_PRESSED`) or a
*clear* (`&= ~INPUT_A_PRESSED` at `stationary.c:915`, `moving.c:1856/1883/1899`).
So under **no-A** (the controller never reports `A_BUTTON` in `buttonPressed`), the
bit is **identically 0 for the whole run**, and every `if (m->input &
INPUT_A_PRESSED)` branch is dead. (The `mario.c:1255` site is *not* a spurious
synthesis — it **is** the definition of the bit. The doc's earlier worry about
"`m->input |= INPUT_A_PRESSED` synthesis sites" was a false alarm: there are none
besides the controller translation.)

**This is the same primitive GOAL 1 already proves** as `input_grounds_noA` (see
`AGates.v` / [[taint-invariant-grounded]]). GOAL 2's jump exclusion *reuses GOAL 1's
no-A→A_PRESSED-clear fact verbatim* — no new trust.

Every positive-yVel jump action is reached through one of **three** A_PRESSED-guarded
routes, all bottoming out on that one bit:

1. **Direct guard** — `if (m->input & INPUT_A_PRESSED) set_mario_action(m,
   ACT_*_JUMP, …)` in the action handlers (`mario.c:1118/1139`
   = `check_common_{,hold_}action_exits`; and the per-action gates listed in §3's
   A-column: moving/stationary/automatic/airborne/submerged).
2. **`set_jump_from_landing`** (`mario.c:1018`, the double/triple/flying-triple
   chain) — **all 3 callers are A_PRESSED-gated**: `moving.c:791`, `moving.c:1081`,
   `stationary.c:848`.
3. **`common_landing_cancels`** (`moving.c:1758`) — invokes its jump callback only
   under `INPUT_A_PRESSED` (`:1781`); the callback parameter is *literally* named
   `setAPressAction`, the table field `aPressedAction`. This is the GOAL-1 AGates
   landing keystone (already a walked, gated lemma).

The sub-routines `set_jumping_action` (`:1074`), `set_steep_jump_action` (`:741`,
⇒ ACT_STEEP_JUMP, yVel 42), and `set_triple_jump_action` (`moving.c:150`) are
reached **only** through routes (1)–(3) — grep shows `set_steep_jump_action` has
exactly two call sites (`mario.c:1028`, `:1087`), both inside the A-gated hubs. So
steep jump is A-gated too. ⇒ **The entire standard-jump set is A-gated.**

**Residual non-A positive-yVel actions** (survive no-A, but each already lands in
cat 1/3/5, never the unbounded integration channel):
- *Taint T (excluded by GOAL 1):* ACT_FLYING (unbounded), ACT_SHOT_FROM_CANNON
  (100·sin), ACT_FLYING_TRIPLE_JUMP (82).
- *Hazard impulse, NOT A, bounded constant:* ACT_LAVA_BOOST (84, lava contact),
  ACT_BURNING_JUMP (31.5, `interaction.c:1159` fire contact).
- *B/dive/kick, NOT A_PRESSED, bounded ≤20:* ACT_JUMP_KICK (20; `moving.c:846`
  gates on `INPUT_A_DOWN` — see caveat — `airborne.c:110`, `object.c:157`).
- *Object/enemy driven:* enemy bounces (≤20), tornado lift (cat 5).
- *[TODO] ACT_WATER_JUMP (42):* `submerged.c:502` is A_PRESSED-gated; `submerged.c:1318`
  guard not yet read. Bounded by 42 regardless.

**Caveat — INPUT_A_DOWN is muddier than A_PRESSED.** `INPUT_A_DOWN` (the "A held"
bit) is set at `mario.c:1259` (`buttonDown & A_BUTTON`) **and unconditionally** at
two cutscene sites (`cutscene.c:1813`, `:2005`). So A_DOWN is *not* a clean
one-writer-controller fact. But **jumps gate on A_PRESSED, not A_DOWN** — A_DOWN
feeds glide/hold/hang holds (e.g. `mario_step.c:566` wing-cap descent slow,
`airborne.c:684` hold-jump), none of which *raise* y. The only positive-yVel
A_DOWN consumer is ACT_JUMP_KICK (bounded 20). So the A_DOWN murkiness does not
leak into the height bound.

## 4. Census B — direct `m->pos[1]` writes (gameplay), categorized

**(B-geom) pinned to stage geometry — self-bounding:**
- `= m->floorHeight` — snap to floor: `mario.c:1835`, `moving.c:89`,
  `mario_step.c:230,249,416,442,461`, `automatic.c:88,503,819`,
  `stationary.c:819/821` (`= sins·amp + floorHeight`, sleeping bob).
- `= m->ceilHeight − 160` — pole/ceiling clamp: `automatic.c:82,332,380`.
- `= m->waterLevel − {80,100}` — water surface: `mario.c:1178`, `submerged.c:185,1503`.
- `= m->usedObj->oPosY ± …` — riding pole/tree/whirlpool/hoot:
  `automatic.c:75,92,690`, `airborne.c:1863` (hoot −92.5), `submerged.c:1086`.
- `= o->oPosY + o->hitboxHeight` — stand on interacted object: `interaction.c:516`.
- `= find_floor(...)` — `cutscene.c:2162`.

**(B-step) the integration result — channel 1:**
- `mario_step.c:420,465` `m->pos[1] = nextPos[1]` where
  `intendedPos[1] = m->pos[1] + m->vel[1]/4` (`:620`). This is where yVel turns
  into height. Everything in §3 funnels here.

**(B-impulse / special) — the residual to bound by geometry/objects:**
- `mario.c:219` `m->pos[1] += translation[1]` — **animation y-translation**
  (`return_mario_anim_y_translation`); a per-frame anim-data offset. Bounded by
  anim data magnitude. [TODO: confirm bound — anim translations are small.]
- `airborne.c:928` `m->pos[1] += yOffset` — twirl/ground-pound? [TODO identify].
- `automatic.c:501` `m->pos[1] -= 100`, `:735` `+= 120·sin(pitch)` — pole / tornado.
- `level_update.c:547` `gMarioState->pos[1] += warp->displacement[1]` — **warp
  displacement** (paintings/doors). Tied to warp dest = level data, bounded but
  **cross-area** (a warp can teleport to any height in the dest area — relevant to
  the "no flying spawn-warp" GOAL-1 exclusion's GOAL-2 analogue).
- `platform_displacement.c:83` `gMarioStates[0].pos[1] = y` (`set_mario_pos`) —
  **moving platform / elevator carries Mario.** y follows the platform. **NOT
  A-gated.** Bounded only by the platform's own vertical travel = **stage-specific
  geometry.** This is the hard, level-data-dependent case.
- `cutscene.c:553/556/569` scripted ±16·speed / `= floorHeight`.

## 5. The categorization that matters for the bound

Under **A-never-pressed**, partition the raisers:

1. **Excluded by GOAL 1 (taint closure T = flying ∪ FTJ ∪ cannon).** The
   *unbounded* climb (flight, `vel[1]=fwd·sin(pitch)` with no geometric ceiling)
   and the cannon launch (100·sin) live entirely in T. GOAL 1 already proves
   `action ∉ T` under no-A. **GOAL 2 inherits "never flying/cannon/FTJ" for
   free** — this is the single biggest leverage point and the reason GOAL 1 is the
   engine GOAL 2 sits on.
2. **Excluded by "jumps are A-gated."  [VERIFIED 2026-06-24 — see §3b.]** Resolved
   to a **one-writer invariant**: `INPUT_A_PRESSED` is raised at exactly one site
   (`mario.c:1255`, `buttonPressed & A_BUTTON`), so under no-A the bit is
   identically 0 and every jump-entry branch is dead. The three A-gated routes into
   the jump set (direct guard, `set_jump_from_landing`, `common_landing_cancels`)
   are all enumerated and confirmed in §3b. **This reuses GOAL 1's `input_grounds_noA`
   verbatim** — not a new trust assumption. The earlier `mario.c:1255`-"synthesis"
   worry was a false alarm: that site *is* the definition of the bit, not a synthesis.
   Remaining sliver: confirm `ACT_WATER_JUMP` `submerged.c:1318` guard (bounded 42).
3. **Bounded constants, not A-gated** — lava boost (84, one-shot off lava
   surface), enemy bounces (≤20). By §2a each gives a bounded apex above a bounded
   floor. Need: enumerate, confirm each is a bounded impulse from a bounded launch
   height.
4. **Geometry-pinned (B-geom)** — y set equal to floor/ceil/water/object. Bounded
   by the **highest such surface in the level**. This is a **level-data property**,
   not a code property: the proof here is "the max floor/water/ridable-object y in
   WMotR's area is < y\*." Stage-specific.
5. **Object-carried (platforms/elevators/tornado/hoot)** — y follows a moving
   object. Bounded by the object's vertical range = **level + behavior data**. The
   genuinely hard, stage-specific residual. (Hoot: reaching it needs a jump ⇒ may
   fold into (2). Elevators in WMotR: bounded by their script.)

## 6. The honest hard part

Categories 1–3 are **code properties** — finite censuses + the integration bound,
the same flavor of work GOAL 1 already does, and reusing GOAL 1's taint closure.
**Categories 4–5 are level-data properties.** "Fits within bounds due to stage
geometry" means: read WMotR's actual collision mesh / object layout and show the
max standable/ridable height is below the star. That needs the **level data**
(collision triangles, object spawn table) in scope — which the current pipeline
(`mario.c` + action files + interaction/step/warps) does **not** yet ingest. The
geometry bound is a *new kind of fact* for this project (data, not control flow).

Possible softening: maybe the route never needs Mario to *stand* high — only to
*reach* y\*. If even the highest ridable object + the biggest non-A impulse apex is
< y\*, geometry detail collapses to a single number per area. Worth checking the
actual WMotR heights early; it may be that **no non-A mechanism clears the gap by a
wide margin**, making the bound crude and robust rather than tight and fragile.

## 7. Suggested next steps (in order)

1. ~~**Jump A-gate census** (cat 2).~~ **DONE — §3b.** Resolved to the one-writer
   invariant + three enumerated A-gated routes, reusing GOAL-1 `input_grounds_noA`.
   Tiny sliver left: `submerged.c:1318` ACT_WATER_JUMP guard (bounded anyway).
2. **Bounce/lava enumeration** (cat 3): list `bounce_off_object` callers + velY;
   bound the lava-boost (84) and burning-jump (31.5) launch *heights* (they fire on
   contact with a hazard surface whose y is itself geometry-bounded). ← next.
3. **Formalize the integration bound** (§2a) as a reusable lemma: positive yVel `V`
   from floor `h` ⇒ `pos[1] ≤ h + V²/8 + ε` for the air/water step engines. This is
   a clean, stage-independent arithmetic lemma over the *already-walked*
   `perform_air_step` body. The single most reusable GOAL-2 brick.
4. **Then** confront level geometry (cats 4–5): scope the WMotR collision/object
   data and bound the max ridable/standable y. Defer — it needs new pipeline input.

### 7a. How this maps onto the proof architecture (for when formalization starts)

GOAL 2's height bound decomposes exactly as GOAL 1's no-fly did — a taint/census
control-flow layer feeding a small set of real residuals:
- **Reuse from GOAL 1, no new trust:** `input_grounds_noA` (no-A ⇒ A_PRESSED clear,
  §3b's linchpin) and the taint closure T (kills flight/cannon/FTJ, cat 1).
- **New control-flow census (cheap, GOAL-1 flavored):** "no positive-yVel jump
  action is reachable under A_PRESSED-clear" — provable from §3b's three-route
  enumeration over the *already-walked* handler bodies. No new engine.
- **New arithmetic lemma (self-contained):** the §2a integration bound. Stage-
  independent; over `perform_air_step`/`perform_water_step`, both already walked.
- **The genuinely new input (cats 4–5):** per-level geometry (max standable/ridable
  y). Not control flow — *data*. This is the part the current pipeline doesn't
  ingest, and the honest hard residual (§6).

## 8. One-line summary

Under no-A, the *unbounded* y-raiser (flight) is already gone via GOAL 1's taint
closure; the *large* raisers (jumps) reduce to a new but ordinary "jumps need A"
control-flow census; what's left is small bounded impulses plus y pinned to stage
geometry — so GOAL 2's height bound = **GOAL 1's taint result + a jump-A-gate
census + the integration arithmetic + one per-level geometry number.**
