# GOAL 2 — pos[1] writers vs the proposed Move kinds

**Status:** 2026-09-27, research note, no Coq. Takes each writer in
`docs/goal2-posy-writer-census.md` and says which Move kind covers it: ballistic,
attach (find_floor return, at most y+239), launch, bounce, switch, GP windup, ground,
lower. Line numbers are `vendor/sm64/src/game/`. The census rows give the matching
`generated/*.v` lines.

## Covered

| census row | site | Move |
|---|---|---|
| 5,6,30,31 | `mario_step.c:420,465,476,482` perform_air_quarter_step `pos = nextPos` | ballistic |
| — | `mario_step.c:416,461` `pos = m->floorHeight` when nextPos ≤ old floorHeight (floor==NULL / ceiling branch) | attach (a stored find_floor value, and ≥ nextPos) |
| 7 | `mario_step.c:442` landing `pos = floorHeight` | attach |
| — | ceiling hit, `mario_step.c:446-452`: vel≥0 ⇒ vel:=0, y unchanged | ballistic stopped early by a ceiling. There is no y push-down in vanilla: the ceiling branch either keeps y or takes nextPos (vel<0) |
| 29 | `mario_step.c:371-377` check_ledge_grab `pos = ledgePos` | attach: `ledgePos[1] = find_floor(.., nextPos+160, ..)`. It needs vel[1] ≤ 0 (`:354`), so nextPos ≤ y and ledge ≤ y+160+78. It can RAISE y by 100–238, but it is a find_floor return, so attach covers it |
| 27,28 | `mario_step.c:292,302` ground quarter step | ground |
| 3,4 | `mario_step.c:230,249` | ground |
| 10 | `mario_actions_moving.c:89` align_with_floor | ground |
| 8 | `mario_actions_airborne.c:928` act_ground_pound | GP windup |
| 20,21 | `mario_actions_automatic.c:501,503` let_go_of_ledge | lower, then ground |
| §4 | f32_find_wall_collision / resolve_* | y-identity (switch/lower with Δ=0) |
| — | ACT_LEDGE_GRAB hang pose | no write. Gameplay y *is* the ledge floor. Only the gfx/anim is lowered. climb_up_ledge (`automatic.c:509`) writes x/z only |
| — | squish | no pos write. squishTimer only scales the model (`mario.c:1205`) |
| 19,38 | `automatic.c:333,380` hanging `= ceilHeight−160` | NOT a Move, but **A-gated**. start_hanging/hanging/hang_moving exit to freefall on `!(INPUT_A_DOWN)` (`automatic.c:398,427,451`) before any write. WMotR *does* have 38 hangable tris (`levels/wmotr/areas/1/collision.inc.c:768`), so the A-gate is load-bearing |

## Absent in WMotR / A-gated / debug

Rows 2,9,11–15,23,32–37,39,40 (water, hoot, shockwave, whirlpool, cutscenes, bounce_off_object,
grabbed, tornado, debug_free_move). Also `update_mario_pos_for_anim` (`mario.c:219`), whose only callers
are door/star cutscene actions (`mario_actions_cutscene.c:799,852,933,1881`). No moving or
stationary action calls it, and WMotR has no doors. Row 22: cannon `+120·sin` (`automatic.c:735`)
sits under `INPUT_A_PRESSED`. The cannon **entry** write in the same function, `pos[1] = cannon.y + 350`
(state 0), is NOT A-gated. It is reachable in WMotR with B only (`cannon_probe.py`) and is the
`wmotr_cannon` attach case (added 2026-09-28; it was missing from this table).

## NOT COVERED

1. **Pole: `set_pole_position`** `mario_actions_automatic.c:75`
   `y = pole.y + oMarioPolePos + offsetY`. It RAISES y through climbing
   (`oMarioPolePos += stickY/8`, `:211`) and through the anim-y offset
   (`return_mario_anim_y_translation` at `:278,295`, grab_pole/top_of_pole). It is not A-gated,
   and WMotR has poles. The bound is `polePos ≤ poleTop` (`:70`) and the ceiling clamp `:82`,
   which ties it to object data. Rows 17/18 (`:82,88`) are ceil−160 and floor clamps. It needs a new "pole" Move.
2. **OOB recovery** `mario.c:1328` `vec3f_copy(m->pos, gfx.pos)` when floor==NULL. gfx.pos is
   last frame's m->pos (`mario.c:1855`), so it can raise y back to the previous frame's y after a
   lowering in between. That is bounded by the history max, but it is not a per-step Move.
3. **Instant warp** `level_update.c:547` `pos[1] += displacement[1]`. Whether it raises y
   depends on WMotR's instant-warp data (probably none). It runs outside the action step.
4. **Spawn** `mario.c:1830,1835` spawn startPos and floor clamp. Teleport.
5. **Platform displacement** `platform_displacement.c:83`, unlinked. It RAISES y on rising
   platforms/carpets.
