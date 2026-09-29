# experiments/symexec — exploratory symbolic executor over the generated Clight

**Unverified exploration. Nothing here is proved, trusted, or on the spine.**
It is a Python prototype that de-risks step 2 of
`docs/goal2-value-walk-plan.md` (a symbolic executor, later to be written and
proved sound in Coq). It learns the shape of the per-handler summaries:
how many paths a dispatched action handler has, what the Φ cells become as
terms, and which external functions and world data each path reads.

It reads the **real** clightgen output (`generated/<tu>.v`) of the 12 frame TUs
(mario, mario_step, mario_actions_*, interaction, behavior_actions,
level_update). There is no hand-written model of SM64 code. The only
hand-written parts are the value contracts for code outside the frame (in `run.py`,
`CONTRACTS`), and those are listed below.

## Files

| file | what |
|---|---|
| `clight_parse.py` | Tokenizer and parser for the Coq text of `generated/*.v`: idents, composites, global vars, functions, `global_definitions`. It caches pickles in `.cache/` (safe to delete). `python3 clight_parse.py [tu...]` prints per-TU counts. |
| `clight_types.py` | Clight types, CompCert ppc32 layout (natural alignment, 4-byte pointers, bitfields), and chunks. Offsets match the proof's pins: action@12, actionState@24, actionTimer@26, pos@60, vel@72, floorHeight@112, marioObj@136, controller@156, Object gfx.pos@32, Controller.buttonPressed@18. |
| `terms.py` | Symbolic terms, and concrete binary32/binary64/int arithmetic (numpy.float32, so every single-precision op rounds to binary32). Also canonical literals for path facts. |
| `symexec.py` | The executor (`Explorer`). It covers the statements, expressions, casts and operators of the Clight subset the generated files use, plus memory regions, forking, joins, and a world-invariant domain hook. |
| `run.py` | The driver. It builds a symbolic MarioState, runs one function and prints per-path and summary reports. |

## Running

```bash
python3 experiments/symexec/run.py perform_air_step --arg 0 --action 0x0100088C --input 0 \
        --join-loops --merge '*' --world wmotr --shapes
python3 experiments/symexec/run.py apply_gravity   --action 0x0100088C --input 0
python3 experiments/symexec/run.py act_freefall    --action 0x0100088C --input 0 --join-loops --merge '*' --world wmotr --shapes
python3 experiments/symexec/run.py act_slide_kick  --action 0x018008AA --input 0 --join-loops --merge '*' --world wmotr --shapes
python3 experiments/symexec/run.py execute_mario_action --action 0x0100088C --noA --join-loops --merge '*' --world wmotr --shapes
```

Useful flags:
- `--action/--state/--timer/--input` make those cells concrete. Otherwise they are the symbols `A`, `ST`, `TM`, or lazily symbolic.
- `--arg N|sym` sets the extra int arguments after `m`, for example `stepArg`.
- `--merge f,g` or `--merge '*'` joins a call's outcomes that agree on the return value and all Φ cells. `--join-loops` joins states at every loop head and loop exit that agree on Φ and on all non-`t'` temps. Without these, `perform_air_step` explodes past 200k forks.
- `--world wmotr` assumes part of the world invariant W (see below).
- `--noA` masks the A bit (0x8000) out of `m->controller->buttonDown/buttonPressed`.
- `--opaque f,...` treats internal functions as externals. The default is `set_mario_animation,set_mario_anim_with_accel`.
- `--group` prints each distinct Φ result. `--shapes` prints them normalised (`#k`, `mrg`). `--show N` prints the first N paths with their path conditions.
- `SYMEXEC_DEBUG=1` or `2` prints the state count at each loop head.

The initial symbols are `Y` = pos[1], `V` = vel[1], `FH` = floorHeight,
`GY` = marioObj->header.gfx.pos[1], `A` = action, `ST` = actionState and
`TM` = actionTimer. Any other cell that is read before it is written becomes a
fresh symbol named by its access path, such as `m->floor->type` or
`floor#2->normal.y`. That read is logged as a *world read*. External results
are `floorY#k`, `ceilY#k`, `waterY#k`, `wallX#k`, `numWalls#k` and so on. Joined
values are `mrgN`.

## Semantics implemented (following CompCert 3.15 Clight / Cop)

- **Statements:** `Ssequence`, `Sskip`, `Sset`, `Sassign` (a struct assignment copies its scalar leaves), `Scall`, `Sifthenelse`, `Sloop` (s1 then s2, with break and continue), the `Swhile` notation, `Sbreak`, `Scontinue`, `Sreturn`, and `Sswitch` with `LScons` fallthrough and default. `Sbuiltin`, `Sgoto` and `Slabel` do not occur in the frame TUs and are rejected.
- **Expressions:** every `Econst_*`, `Etempvar`, `Evar` (locals, then globals, then functions), `Eaddrof`, `Ederef`, `Efield`, `Eunop`, `Ebinop`, `Ecast`, `Esizeof` and `Ealignof`. Access modes: arrays, structs and functions are by reference; scalars are loaded with their chunk.
- **Operators:** `classify_binarith` / `add` / `sub` / `cmp` / `shift` / `cast`, with the usual integer promotions. Pointer arithmetic is scaled by the element size. Under ptr32, casting a pointer to an int keeps the pointer, and int add/sub on a pointer stay pointers. Comparisons with NULL give a `nonnull(r)` literal. Float→int conversion out of range is stuck, as in CompCert. Every single-precision op is exact binary32.
- **Memory:** each region maps offsets to (chunk, value). A same-size read of a different chunk reinterprets the bits. Partial overlaps are rebuilt from concrete bytes (big-endian), or else become fresh symbols with a warning.
- **Globals:** a global with an initializer that no loaded function writes or lets escape (a conservative syntactic scan) is taken at its initializer, for example `sTerrainSounds`. The report lists these. All other globals are lazily symbolic world data. `gMarioState`, `gMarioObject` and `gMarioStates` are bound to the `M` and `OBJ` regions.
- **Calls:** a function defined in the 12 TUs is executed. So are the vec3f/vec3s helpers of `generated/math_util.v`, which *is* generated, so `vec3f_copy`, `vec3f_set` and `vec3s_to_vec3f` are not hand-written. Every other function is an external. It returns a fresh symbol and is logged. The value contracts are:
  - `find_floor` / `find_ceil` / `vec3f_find_ceil` return a fresh height and write a fresh nullable `Surface*` to their out-param.
  - `find_wall_collisions` havocs x, z, numWalls and walls[] of the `WallCollisionData`.
  - `f32_find_wall_collision` havocs *x and *z.
  - `find_water_level` returns a fresh value.
  - `set_mario_animation*` is opaque. It havocs `marioObj->header.gfx.animInfo`, because its real body adds a pointer to a `(uintptr_t)` of DMA'd animation data, which a lazily symbolic world cannot represent.
  - Every other external is assumed to have **no memory effect**. When one of them receives a pointer to M, OBJ or a local, the report prints an `UNMODELLED external ... with pointer args` warning.
- **Forking:** a branch on a symbolic condition forks and records the literal. A canonical-literal fact table (`canon`) decides a repeat of the same test. `x == c` on a plain variable substitutes `c`. There is **no solver**, so infeasible combinations survive (for example `!(V < 0)` together with `(V - 4) < -75`). Path counts are therefore upper bounds.
- **Limits:** `--max-paths` caps the number of forks. Loop fuel, call depth and a step count are also capped. Every truncation is reported.

## World invariant W (`--world wmotr`), modelled part

Each of these is an assumption the Coq proof would need as a world fact. The first six come from `docs/goal2-value-walk-plan.md` §1.
- The `type` of every `Surface` Mario touches is in {DEFAULT, HANGABLE, DEATH_PLANE, NOT_SLIPPERY, HARD_NOT_SLIPPERY}.
- `m->floor != NULL`.
- `m->heldObj == m->riddenObj == NULL`.
- `quicksandDepth == 0`.
- `gCurrLevelNum == 31` (LEVEL_WMOTR).
- `m->area->terrainType == TERRAIN_SNOW` (2), from `levels/wmotr/script.c:61`.

Domains flow through joins: a joined variable gets the union of the joined values' domains.

## Known unsoundness / imprecision (deliberate, for a prototype)

- **Joins over-approximate.** Cells on which the joined states disagree become fresh symbols. Only the path facts on which all the joined states agree are kept.
- **Aliasing.** Two lazily created world pointers are assumed not to alias. The exception is an explicit `==` test, which forks on an `alias(...)` literal, and even then the two regions are not unified.
- **Symbolic offsets.** A store at a symbolic offset is **ignored**, with a warning. A load at a symbolic offset from a pointer array held in a local (`collisionData.walls[numWalls-1]`) becomes a fresh pointer.
- **Unmodelled externals** are assumed to have no memory effect (see the warning above).
- **Bitfields** are laid out but not accessed. Nothing in the frame's Mario path uses them.
- **Floating point.** No path condition is checked for feasibility. Float→int overflow on a symbolic value is not flagged. It would be a side condition.
- **Static helpers.** If two TUs define a static helper with the same name, the first one wins. None occur in the 12 TUs.
