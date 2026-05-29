# The in-game frame: anatomy, loop taxonomy, and a formalization plan

> Research capture (2026-05-29) toward **R3** of the "must press A to fly" goal (see
> [must-press-a-to-fly.md](must-press-a-to-fly.md)). The claim "you cannot enter `ACT_FLYING`
> without a prior A press" is a *temporal trace property*; it needs a formal notion of **one
> frame**. This documents what a frame actually is in the decomp, classifies the loops in the
> way, and proposes a model. It is the foundation R3 stands on. See also
> [whole-program-and-the-interpreters.md](whole-program-and-the-interpreters.md) (the dragon)
> and [trust-model.md](trust-model.md).

## TL;DR

A frame is **linear**: read input → run the game update → render → wait for vblank. The only
control-flow complexity is a handful of loops, and they split cleanly into three classes —
(a) a linear backbone, (b) **bounded** loops (object pool ≤ 240, the per-frame action-shift
loop), and (c) **interpreter** loops that *can* jump but in steady-state gameplay execute a
fixed small command set per frame. The one genuinely-unbounded spot is **dev-acknowledged and
never observed to trigger**. So a frame is a solidifiable step function, and R3 becomes an
induction over frames with one nested (bounded) induction inside.

## 1. The frame = one iteration of the game-loop thread

`thread5_game_loop` (`game_init.c:643`) is, after setup, an infinite `while (TRUE)` whose body
**is** the frame:

```c
while (TRUE) {
    if (gResetTimer != 0) { draw_reset_bars(); continue; }   // reset path
    ...
    read_controller_inputs();             // (1) sample inputs, ONCE
    addr = level_script_execute(addr);     // (2) the entire game update + render
    display_and_vsync();                   // (3) block until the next vblank = frame boundary
}
```

Read → update → render → vsync. Inputs are sampled exactly once, at the top; everything the
game does for that frame happens inside `level_script_execute`; `display_and_vsync` is the
hardware frame boundary. This is the linear backbone.

## 2. Input model: a rising edge, sampled once

`read_controller_inputs` (`game_init.c:522`) computes, per controller:

```c
controller->buttonPressed = controller->controllerData->button
                            & (controller->controllerData->button ^ controller->buttonDown);
controller->buttonDown    = controller->controllerData->button;
```

`buttonPressed` is exactly the **rising edge**: bits that are down now and were *not* down last
frame. So:

> **"Mario presses A on frame n" ⟺ `A_BUTTON ∈ gPlayer1Controller->buttonPressed` on frame n
> ⟺ a 0→1 transition of the A button.**

That controller value flows into Mario once per frame via `update_mario_inputs` (`mario.c:1373`),
which **resets `m->input = 0`** and then `update_mario_button_inputs` (`mario.c:1253`) sets:

```c
if (m->controller->buttonPressed & A_BUTTON) m->input |= INPUT_A_PRESSED;
```

So `m->input & INPUT_A_PRESSED` is *freshly recomputed every frame* and is **true iff A was
newly pressed this frame**. Crucially (see §4) it is set *before* the action-shift loop and never
touched inside it — so within one frame "is A pressed" is a **loop-invariant constant**.

## 3. From the frame to Mario's action: the call path

```
thread5_game_loop                       (game_init.c:643, the frame loop)
  └ level_script_execute                (engine/level_script.c, the level interpreter)
      └ ... play-mode command ...        (steady-state: runs the area/object update, then yields)
          └ object update loop           (object_list_processor.c, over the active object lists)
              └ bhvMario → execute_mario_action   (mario.c:1699, called ONCE/frame for Mario)
                  └ while (inLoop) { mario_execute_<group>_action(gMarioState); }
                      └ act_flying_triple_jump / act_shot_from_cannon / ...  (the R1 sites)
```

The level-script interpreter is the "dragon," but for this property it acts as a **scheduler**
that calls `execute_mario_action` exactly once per frame during normal play. That is the seam
where we abstract it (§6).

## 4. `execute_mario_action`: the per-frame action step (the heart of R3)

`execute_mario_action` (`mario.c:1699`):

```c
if (gMarioState->action) {
    ...
    update_mario_inputs(gMarioState);          // m->input (incl. INPUT_A_PRESSED) set HERE, once
    mario_handle_special_floors(gMarioState);
    mario_process_interactions(gMarioState);
    if (gMarioState->floor == NULL) return 0;  // OOB early-out

    // The function can loop through many action shifts in one frame ...
    // Could potentially hang if a loop of actions were found, but there has
    // not been a situation found.
    while (inLoop) {
        switch (gMarioState->action & ACT_GROUP_MASK) {
            case ACT_GROUP_AIRBORNE: inLoop = mario_execute_airborne_action(gMarioState); break;
            ... // one case per action group
        }
    }
    ... // post-update: health, camera, hitbox, etc.
}
```

The inner `while (inLoop)` is the **sub-frame action-shift loop**: an action handler returns
`TRUE` to mean "I changed `action`; run the new action's handler again *this same frame*", and
`FALSE` to mean "settled for this frame." A single A-press can therefore drive several action
transitions within one frame (e.g. land → set a new action → that action's handler runs).

This is the structure R3 must reason about, and two facts make it tractable:

1. **Inputs are constant across the inner loop.** `update_mario_inputs` runs *before* the loop;
   no handler re-reads the controller. So `INPUT_A_PRESSED` is fixed for the whole frame — the
   inner induction reasons about transitions under a *fixed* input.
2. **The loop is bounded in practice and the unboundedness is named.** The dev comment is explicit:
   it could "potentially hang if a loop of actions were found, but there has not been a situation
   found." For the proof we either (a) carry a **fuel bound** (as `Reach.reach` already does) and
   prove the relevant runs terminate within it, or (b) prove a measure/no-cycle lemma for the
   action-shift graph. Either way it is a *bounded* induction, not an open-ended one.

## 5. The loop taxonomy (the "grand structure")

| Class | Examples | For the proof |
|-------|----------|---------------|
| **Linear backbone** | the frame body itself (read→update→render→vsync) | sequencing; trivial |
| **Bounded loops** | object lists are linked-list walks over the **≤ 240**-slot pool (`object_list_processor.c`); the update order is a static `-1`-terminated array; the inner action-shift loop (§4) | terminate by a pool-size / fuel bound |
| **Interpreter loops** | `level_script_execute`'s `while (SCRIPT_RUNNING)` over the static `LevelScriptJumpTable`; the behavior-script engine | jump-capable so not statically bounded, but in **steady-state gameplay** each frame runs a fixed small command set then yields (`SCRIPT_PAUSED`). The unbounded/looping part is **level loading**, which happens at transitions, not every frame. Abstract as a scheduler (§6). |
| **Rare / genuine infinite loops** | the `gResetTimer` `continue` (reset bars); the dev-acknowledged action-shift hang | edge cases: either excluded by precondition (not resetting) or shown unreachable under our scenario |

This matches the intuition exactly: *frames are very linear; a few bounded loops; rare infinite
loops that are documented and not normally reachable.*

## 6. Proposed formal model

Model the per-frame Mario step and quotient out the interpreter/scheduler:

```coq
(* A frame's external input is just the rising-edge button word (+ stick, unused here). *)
Record FrameInput := { buttonPressed : int; buttonDown : int; (* stick... *) }.

(* The Mario-relevant world (subset of global state we track). *)
Record World := { w_mario : MarioState; w_pool : ObjectPool; (* ... *) }.

(* The per-frame Mario step: set inputs from the controller, then run the action-shift loop to
   a fixpoint. `fuel` bounds the inner loop (§4.2). This is execute_mario_action, abstracted. *)
Definition mario_frame_step (fuel : nat) (in_ : FrameInput) (w : World) : World := ...

(* The whole frame, with the interpreter+object loop abstracted to "call mario_frame_step once".
   Justified because the object update calls execute_mario_action exactly once per frame for
   Mario; everything else in the frame is framed off Mario's action by separation (Havoc.v). *)
Definition frame_step (fuel : nat) (in_ : FrameInput) (w : World) : World := ...
```

### The property (R3), stated over traces

Let a *run* be a list of `FrameInput`s. Define `a_pressed in_ := Int.testbit in_.(buttonPressed) 1`
(bit 1 = `A_BUTTON >> ...`; INPUT_A_PRESSED = 0x2). Then:

> **R3.** For any run and any reachable world `w` produced by folding `frame_step` over it from a
> fresh WMotR spawn, if `w.(w_mario).(action)` is a flying value, then some input in the run
> satisfies `a_pressed`.

Contrapositive, which is the clean inductive form (the "no-A run"):

> If `a_pressed` is false on **every** frame of the run, then `INPUT_A_PRESSED` is never set
> (m->input = 0 then only OR'd from A_BUTTON), so the jump-sequence guards never fire, so the
> reachable-action set never includes a flying action.

The proof is an **invariant** `Φ(w)` ("action ∉ the flying-reachable set, and flags/timers
consistent with that") shown to be:
- established at the WMotR spawn (R4: spawn is `ACT_SPAWN_NO_SPIN_AIRBORNE`, not flying; no
  `bhvFlyingWarp`), and
- preserved by `frame_step` whenever `a_pressed = false`, by induction — outer over frames, inner
  (bounded) over the action-shift loop, using R1 (only the 5 sites set flying) + R2 (none of those
  transitions is enabled without `INPUT_A_PRESSED`, once the upstream jump-sequence guards are
  pinned).

### What each existing rung buys this

- **R1 (`Flying.v`)** — the inner loop can only *reach* a flying action through one of 5 call
  sites: bounds the case analysis of the inner induction.
- **R2 (`Flying.v`)** — those sites are not locally input-gated, so the enabling A-condition is a
  *predecessor action*: tells us `Φ` must track the **jump-sequence actions** (JUMP / DOUBLE /
  triple), not just flying. `Φ` is really "action ∉ {flying ∪ the jump-sequence states reachable
  without A}".
- **R4** — discharges the base case for WMotR and removes the warp escape hatch.
- **Havoc.v / Escape.v** — justify abstracting the rest of the frame: writes outside Mario's
  state don't perturb `action` (separation), so `frame_step` need only track `World`.

## 7. Honest risks (why R3 is still the hard rung)

1. **Defining `Φ` precisely** is the real work: it must be an *inductive* invariant (closed under
   one no-A frame), which means enumerating every action the jump-sequence states can transition
   to without A and showing none escapes the set. That is a finite but **large** action-graph
   exploration — the action analogue of `Reach`, but over runtime transitions, not the static
   call graph.
2. **Leak #2 on the path:** `set_triple_jump_action` is reached via a function pointer
   (`common_landing_cancels(m, &sDoubleJumpLandAction, set_triple_jump_action)`). The frame model
   must resolve that indirect call (its target set is static and enumerable — same move as the
   `CALL_NATIVE` discussion in the interpreters doc).
3. **The interpreter abstraction is a trusted step** until discharged: "the scheduler calls
   `execute_mario_action` once per frame and otherwise doesn't touch `m->action`" is a frame-spec
   we either prove (an interpreter frame meta-theorem) or list as a named assumption.
4. **Demo/automatic actions:** some actions are entered by cutscene/automatic groups
   (`ACT_GROUP_AUTOMATIC`, `ACT_GROUP_OBJECT`) not driven by `m->input`; `Φ` must show none of
   those reaches flying either (R1 already says they don't *set* flying, which helps).

None of these is the dev-comment hang; they are ordinary (if substantial) verification work. The
frame abstraction itself — the thing this doc set out to assess — **is** solidifiable.
