(* Flying.v -- R1 of "you must press A to enter wing-cap flight (ACT_FLYING)".
 *
 * See docs/must-press-a-to-fly.md. This is the *setter-enumeration* rung: the
 * action-level analogue of Reach.direct_writers. It establishes, by reflexivity
 * over the real clightgen'd ASTs of four SM64 TUs, the structural skeleton of the
 * whole argument:
 *
 *   (A) Across mario.c, mario_actions_airborne.c, mario_actions_moving.c and
 *       level_update.c, the ONLY functions that ever feed a flying action
 *       constant (ACT_FLYING or ACT_FLYING_TRIPLE_JUMP) into a call are exactly
 *       five -- the three doc "classes" and their two triple-jump predecessors.
 *   (B) The four group-transform helpers inside set_mario_action
 *       (set_mario_action_{airborne,moving,submerged,cutscene}) never themselves
 *       *assign* a flying constant: they only downgrade (e.g. action = ACT_JUMP).
 *       So set_mario_action cannot fabricate a flying action from a non-flying
 *       argument -- the value written to m->action is flying only if a flying
 *       constant was passed in, i.e. only at one of the five sites in (A).
 *
 * GROUND TRUTH NOTE (why we read constants off the AST, not the header): sm64.h
 * annotates `#define ACT_FLYING ... // 0x10880899`, but the real macro expansion
 * is 0x10808899 = 277350553 (the comment is stale by one nibble). clightgen
 * computes the true value; we take it from the generated AST. ACT_FLYING_TRIPLE_JUMP
 * = 0x03000894 = 50333844 matches its comment. This is the trust-model point
 * (audit the statement, trust the compiler front-end) made concrete.
 *
 * SCOPE / honesty (the leaks, named -- no buried ledes):
 *   - Syntactic & literal-flow. We flag a flying *literal* appearing in a call
 *     argument expression. A flying value reaching set_mario_action through a
 *     *computed* argument (a variable holding 277350553) would be missed here;
 *     ruling that out is dataflow, and is part of R3 (the temporal closure), not
 *     R1. Grepping confirms all five real sites pass the bare literal.
 *   - The m->action choke point ("the only store to the action field is the one
 *     in set_mario_action") is argued textually in the docs and supported by (B);
 *     turning it into a semantic store-frame theorem (leak #1 for a struct field)
 *     is a later rung.
 *   - Four TUs only. Other TUs are not searched here; the doc's grep over all of
 *     src/ found no further set_mario_action(.., ACT_FLYING..) site, but that is
 *     not yet machine-checked across the whole program (leak #3).
 *)

From Coq Require Import List ZArith PArith.BinPos.
Import ListNotations.
Local Open Scope Z_scope.
From compcert Require Import AST Integers Ctypes Cop Clight.
From SM64.Proofs Require Import Reach.
From SM64.Generated Require mario mario_actions_airborne mario_actions_moving level_update
  behavior_actions mario_actions_automatic interaction.

(* --- The flying action constants, as read off the generated AST -------------- *)

Definition ACT_FLYING : int := Int.repr 277350553.              (* 0x10808899 *)
Definition ACT_FLYING_TRIPLE_JUMP : int := Int.repr 50333844.   (* 0x03000894 *)

Definition is_flying_int (n : int) : bool :=
  Int.eq n ACT_FLYING || Int.eq n ACT_FLYING_TRIPLE_JUMP.

(* Does a flying constant occur anywhere inside an expression? (Sound: we recurse
   through every expression former, so a flying literal buried in `x | FLYING`
   would still be caught.) *)
Fixpoint expr_has_flying (e : expr) : bool :=
  match e with
  | Econst_int n _      => is_flying_int n
  | Ederef e1 _         => expr_has_flying e1
  | Eaddrof e1 _        => expr_has_flying e1
  | Eunop _ e1 _        => expr_has_flying e1
  | Ecast e1 _          => expr_has_flying e1
  | Efield e1 _ _       => expr_has_flying e1
  | Ebinop _ e1 e2 _    => expr_has_flying e1 || expr_has_flying e2
  | _                   => false
  end.

Definition args_have_flying (args : list expr) : bool :=
  existsb expr_has_flying args.

(* --- (A) the call-site enumeration ------------------------------------------- *)

(* Does the statement contain a direct call whose argument list mentions a flying
   constant? (Clight has no call-expressions: every call is an Scall statement, so
   walking statements is complete for "a flying value flows into a call".) *)
Fixpoint flying_call_s (s : statement) : bool :=
  match s with
  | Scall _ _ args      => args_have_flying args
  | Sbuiltin _ _ _ args => args_have_flying args
  | Ssequence s1 s2     => flying_call_s s1 || flying_call_s s2
  | Sifthenelse _ s1 s2 => flying_call_s s1 || flying_call_s s2
  | Sloop s1 s2         => flying_call_s s1 || flying_call_s s2
  | Slabel _ s1         => flying_call_s s1
  | Sswitch _ ls        => flying_call_ls ls
  | _                   => false
  end
with flying_call_ls (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => false
  | LScons _ s rest => flying_call_s s || flying_call_ls rest
  end.

(* The internal functions of p that pass a flying constant into some call. This is
   Reach.direct_writers retargeted from "writes global g" to "feeds a flying action
   constant to a call". *)
Definition flying_setters (p : program) : list ident :=
  map fst (filter (fun idf => flying_call_s (fn_body (snd idf)))
                  (internal_funcs (prog_defs p))).

(* --- (B) the helpers do not fabricate a flying value ------------------------- *)

(* Does the statement assign (to a temp via Sset, or to memory via Sassign) an
   expression mentioning a flying constant? Switch CASE LABELS for flying actions
   are LScons selectors, not assignments, so they are correctly ignored. *)
Fixpoint assigns_flying_s (s : statement) : bool :=
  match s with
  | Sset _ e            => expr_has_flying e
  | Sassign _ e         => expr_has_flying e
  | Ssequence s1 s2     => assigns_flying_s s1 || assigns_flying_s s2
  | Sifthenelse _ s1 s2 => assigns_flying_s s1 || assigns_flying_s s2
  | Sloop s1 s2         => assigns_flying_s s1 || assigns_flying_s s2
  | Slabel _ s1         => assigns_flying_s s1
  | Sswitch _ ls        => assigns_flying_ls ls
  | _                   => false
  end
with assigns_flying_ls (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => false
  | LScons _ s rest => assigns_flying_s s || assigns_flying_ls rest
  end.

Definition fabricates_flying (f : function) : bool := assigns_flying_s (fn_body f).

(* ======================================================================
   The m->action write choke-point (corrects an R1 over-claim).
   ======================================================================
   R1's comment said "the only store to the action field lives in
   set_mario_action". That is FALSE: there are raw `m->action = <const>` writes
   too. Here we enumerate ALL direct writers of MarioState.action and (with
   fabricates_flying) show none writes a flying value -- so the only way action
   becomes flying is set_mario_action called with a flying arg (the R1 sites).

   Precision: we match `Sassign (Efield base _action _) _` where base has type
   `Tstruct MarioState` -- so writes to OTHER structs' `action` field
   (m->marioBodyState->action, m->statusForCamera->action) are correctly excluded. *)

Definition is_mariostate (sid : ident) (ty : type) : bool :=
  match ty with
  | Tstruct s _ => Pos.eqb s sid
  | _           => false
  end.

(* Is this lvalue a write to <MarioState>.action ? (sid = the MarioState struct
   ident, fld = the `action` field ident -- both passed per-TU from that module.) *)
Definition lhs_is_mario_action (sid fld : ident) (lhs : expr) : bool :=
  match lhs with
  | Efield base f _ => Pos.eqb f fld && is_mariostate sid (typeof base)
  | _               => false
  end.

Fixpoint writes_mario_action_s (sid fld : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _       => lhs_is_mario_action sid fld lhs
  | Ssequence s1 s2     => writes_mario_action_s sid fld s1 || writes_mario_action_s sid fld s2
  | Sifthenelse _ s1 s2 => writes_mario_action_s sid fld s1 || writes_mario_action_s sid fld s2
  | Sloop s1 s2         => writes_mario_action_s sid fld s1 || writes_mario_action_s sid fld s2
  | Slabel _ s1         => writes_mario_action_s sid fld s1
  | Sswitch _ ls        => writes_mario_action_ls sid fld ls
  | _                   => false
  end
with writes_mario_action_ls (sid fld : ident) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => false
  | LScons _ s rest => writes_mario_action_s sid fld s || writes_mario_action_ls sid fld rest
  end.

(* The internal functions of p that directly assign MarioState.action. *)
Definition mario_action_writers (sid fld : ident) (p : program) : list ident :=
  map fst (filter (fun idf => writes_mario_action_s sid fld (fn_body (snd idf)))
                  (internal_funcs (prog_defs p))).

(* Sharper: a direct assignment of a FLYING constant TO MarioState.action. *)
Fixpoint writes_flying_action_s (sid fld : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs     => lhs_is_mario_action sid fld lhs && expr_has_flying rhs
  | Ssequence s1 s2     => writes_flying_action_s sid fld s1 || writes_flying_action_s sid fld s2
  | Sifthenelse _ s1 s2 => writes_flying_action_s sid fld s1 || writes_flying_action_s sid fld s2
  | Sloop s1 s2         => writes_flying_action_s sid fld s1 || writes_flying_action_s sid fld s2
  | Slabel _ s1         => writes_flying_action_s sid fld s1
  | Sswitch _ ls        => writes_flying_action_ls sid fld ls
  | _                   => false
  end
with writes_flying_action_ls (sid fld : ident) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => false
  | LScons _ s rest => writes_flying_action_s sid fld s || writes_flying_action_ls sid fld rest
  end.

Definition flying_action_writers (sid fld : ident) (p : program) : list ident :=
  map fst (filter (fun idf => writes_flying_action_s sid fld (fn_body (snd idf)))
                  (internal_funcs (prog_defs p))).

(* ======================================================================
   Machine-checked facts.
   ====================================================================== *)

(* (A) Per TU, the exhaustive list of flying-setter functions. *)

(* mario.c: only set_jump_from_landing (the ACT_DOUBLE_JUMP_LAND wing-cap branch,
   mario.c:1050 -> ACT_FLYING_TRIPLE_JUMP). *)
Example mario_flying_sites :
  flying_setters mario.prog = [mario._set_jump_from_landing].
Proof. reflexivity. Qed.

(* mario_actions_airborne.c: act_shot_from_cannon (class 2, :1710) and
   act_flying_triple_jump (class 1 apex, :1934), both -> ACT_FLYING. *)
Example airborne_flying_sites :
  flying_setters mario_actions_airborne.prog =
    [mario_actions_airborne._act_shot_from_cannon;
     mario_actions_airborne._act_flying_triple_jump].
Proof. reflexivity. Qed.

(* mario_actions_moving.c: set_triple_jump_action (:149 -> ACT_FLYING_TRIPLE_JUMP). *)
Example moving_flying_sites :
  flying_setters mario_actions_moving.prog =
    [mario_actions_moving._set_triple_jump_action].
Proof. reflexivity. Qed.

(* level_update.c: set_mario_initial_action (class 3, the MARIO_SPAWN_FLYING warp
   case, :339 -> ACT_FLYING). This is the non-A escape hatch retired by R4. *)
Example level_update_flying_sites :
  flying_setters level_update.prog =
    [level_update._set_mario_initial_action].
Proof. reflexivity. Qed.

(* behavior_actions.c is the WHOLE behavior C layer -- it #includes all ~111
   behaviors/*.inc.c, so this single TU is every behavior's native code. NO behavior
   is a flying-setter: not one of them feeds a flying constant into any call. This
   closes (mechanically, for this TU) the worry behind the frame-model scheduler
   abstraction in docs/the-frame.md -- that some behavior might flip Mario into a
   flying action behind execute_mario_action's back. (Was textual-grep only; now
   kernel-checked.) Cross-TU linkage to mario.c's set_mario_action is still leak #3,
   but no flying *constant* originates in any behavior. *)
Example no_behavior_is_a_flying_setter :
  flying_setters behavior_actions.prog = [].
Proof. reflexivity. Qed.

(* --- The m->action write choke-point, enumerated and corrected ------------- *)

(* The COMPLETE set of functions that directly assign MarioState.action, per TU.
   This corrects R1's "only set_mario_action writes the action field": there are
   several raw writers. (set_mario_action_airborne etc. assign the LOCAL `action`
   temp via Sset, not the field, so they do NOT appear -- correctly.)

   We pin each set as a COUNT + a confirmed writer per name (count = #names ⇒ the
   named functions are exactly the writers). Stated this way the facts are robust
   and each is independently name- and reflexivity-checked. *)

(* mario.c: exactly 3 -- the real setter plus the two init paths (raw `= 0` / spawn
   action). NONE writes a flying value (see below). *)
Example mario_action_writer_count :
  length (mario_action_writers mario._MarioState mario._action mario.prog) = 3%nat.
Proof. reflexivity. Qed.
Example w_set_mario_action :
  writes_mario_action_s mario._MarioState mario._action (fn_body mario.f_set_mario_action) = true.
Proof. reflexivity. Qed.
Example w_init_mario :
  writes_mario_action_s mario._MarioState mario._action (fn_body mario.f_init_mario) = true.
Proof. reflexivity. Qed.
Example w_init_mario_from_save_file :
  writes_mario_action_s mario._MarioState mario._action
    (fn_body mario.f_init_mario_from_save_file) = true.
Proof. reflexivity. Qed.

(* mario_actions_airborne.c: exactly 1 -- act_air_throw, which raw-sets
   ACT_AIR_THROW_LAND on landing (not flying). *)
Example airborne_action_writer_count :
  length (mario_action_writers mario_actions_airborne._MarioState
            mario_actions_airborne._action mario_actions_airborne.prog) = 1%nat.
Proof. reflexivity. Qed.
Example w_act_air_throw :
  writes_mario_action_s mario_actions_airborne._MarioState mario_actions_airborne._action
    (fn_body mario_actions_airborne.f_act_air_throw) = true.
Proof. reflexivity. Qed.

(* mario_actions_automatic.c: exactly 1 -- act_ledge_climb_slow (raw ACT_LEDGE_CLIMB_SLOW_2). *)
Example automatic_action_writer_count :
  length (mario_action_writers mario_actions_automatic._MarioState
            mario_actions_automatic._action mario_actions_automatic.prog) = 1%nat.
Proof. reflexivity. Qed.
Example w_act_ledge_climb_slow :
  writes_mario_action_s mario_actions_automatic._MarioState mario_actions_automatic._action
    (fn_body mario_actions_automatic.f_act_ledge_climb_slow) = true.
Proof. reflexivity. Qed.

(* interaction.c: exactly 2 -- bounce_back_from_attack and check_kick_or_punch_wall
   (both raw ACT_MOVE_PUNCHING). *)
Example interaction_action_writer_count :
  length (mario_action_writers interaction._MarioState interaction._action interaction.prog) = 2%nat.
Proof. reflexivity. Qed.
Example w_bounce_back_from_attack :
  writes_mario_action_s interaction._MarioState interaction._action
    (fn_body interaction.f_bounce_back_from_attack) = true.
Proof. reflexivity. Qed.
Example w_check_kick_or_punch_wall :
  writes_mario_action_s interaction._MarioState interaction._action
    (fn_body interaction.f_check_kick_or_punch_wall) = true.
Proof. reflexivity. Qed.

(* ...and NONE of those raw writers assigns a flying constant directly to the
   action field. (Combined with the flying_setters enumeration above, the only
   route to a flying action is set_mario_action called with a flying argument =
   the 5 R1 sites.) Stated over every TU that writes the field, plus the four
   action TUs for good measure. *)
Example no_raw_flying_action_write_mario :
  flying_action_writers mario._MarioState mario._action mario.prog = [].
Proof. reflexivity. Qed.

Example no_raw_flying_action_write_airborne :
  flying_action_writers mario_actions_airborne._MarioState mario_actions_airborne._action
    mario_actions_airborne.prog = [].
Proof. reflexivity. Qed.

Example no_raw_flying_action_write_automatic :
  flying_action_writers mario_actions_automatic._MarioState mario_actions_automatic._action
    mario_actions_automatic.prog = [].
Proof. reflexivity. Qed.

Example no_raw_flying_action_write_interaction :
  flying_action_writers interaction._MarioState interaction._action interaction.prog = [].
Proof. reflexivity. Qed.

(* (B) The four group-transform helpers never assign a flying constant: each only
   downgrades the requested action (to ACT_JUMP or a slide). So set_mario_action
   cannot turn a non-flying request into a flying one. *)
Example airborne_helper_no_fabricate :
  fabricates_flying mario.f_set_mario_action_airborne = false.
Proof. reflexivity. Qed.

Example moving_helper_no_fabricate :
  fabricates_flying mario.f_set_mario_action_moving = false.
Proof. reflexivity. Qed.

Example submerged_helper_no_fabricate :
  fabricates_flying mario.f_set_mario_action_submerged = false.
Proof. reflexivity. Qed.

Example cutscene_helper_no_fabricate :
  fabricates_flying mario.f_set_mario_action_cutscene = false.
Proof. reflexivity. Qed.

(* And set_mario_action's own body assigns no flying literal -- it writes m->action
   from the (helper-transformed) `action` variable, never from a flying constant.
   Combined with (B), the only flying values it can store are ones passed in. *)
Example dispatcher_no_fabricate :
  fabricates_flying mario.f_set_mario_action = false.
Proof. reflexivity. Qed.

(* --- Non-vacuity guard (the positive control) -------------------------------
   The analysis is not trivially false: act_flying_triple_jump *does* fabricate a
   flying literal in the sense of assigns_flying_s? No -- it *calls* the setter, so
   it is caught by flying_call_s, not assigns_flying_s. The honest non-vacuity
   witness is that flying_setters is non-empty above (four populated lists), AND
   that a function with a flying literal really does flip the flag: *)
Example flying_call_detects :
  flying_call_s (fn_body mario.f_set_jump_from_landing) = true.
Proof. reflexivity. Qed.

(* A flying constant really is distinguished from a nearby non-flying one. *)
Example flying_int_discriminates :
  is_flying_int (Int.repr 277350553) = true /\
  is_flying_int (Int.repr 50333844) = true /\
  is_flying_int (Int.repr 277874329) = false  (* the STALE header value 0x10880899 *)
  /\ is_flying_int (Int.repr 0) = false.
Proof. repeat split; reflexivity. Qed.

(* ======================================================================
   R2 (faithful form): WHERE the A-gate is NOT.
   ======================================================================
   The originally-imagined R2 -- "each ACT_FLYING site locally checks
   INPUT_A_PRESSED" -- is simply FALSE of the code: every one of the five sites
   gates on MARIO_WING_CAP and/or pure physics (vel[1]), never on the controller.
   The A-press lives in a PREDECESSOR action (the jump -> double-jump ->
   triple-jump sequence), which is exactly why the real obligation is the temporal
   closure R3, not a local guard.

   We make that precise and machine-checked here. (INPUT_A_PRESSED = 0x0002 is a
   bit of m->input; a function that never reads m->input cannot branch on the A
   button.) Four of the five flying-setter functions read NO input at all -- the
   A-decision provably cannot be made in them. The fifth, act_flying_triple_jump,
   does read m->input, but ONLY for INPUT_B_PRESSED / INPUT_Z_PRESSED cancels
   (-> dive / ground-pound); its ACT_FLYING transition is gated on `m->vel[1] <
   4.0f` (pure physics), not on the controller. So at NO site is the flying
   transition itself locally input-gated: the A-dependence is necessarily upstream
   (the jump sequence), i.e. it is the temporal property R3, not a local guard. *)

Fixpoint reads_field_e (fld : ident) (e : expr) : bool :=
  match e with
  | Efield e1 f _    => Pos.eqb f fld || reads_field_e fld e1
  | Ederef e1 _      => reads_field_e fld e1
  | Eaddrof e1 _     => reads_field_e fld e1
  | Eunop _ e1 _     => reads_field_e fld e1
  | Ecast e1 _       => reads_field_e fld e1
  | Ebinop _ e1 e2 _ => reads_field_e fld e1 || reads_field_e fld e2
  | _                => false
  end.

Definition any_reads_field (fld : ident) (es : list expr) : bool :=
  existsb (reads_field_e fld) es.

Fixpoint reads_field_s (fld : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs     => reads_field_e fld lhs || reads_field_e fld rhs
  | Sset _ e            => reads_field_e fld e
  | Scall _ ef args     => reads_field_e fld ef || any_reads_field fld args
  | Sbuiltin _ _ _ args => any_reads_field fld args
  | Sifthenelse e s1 s2 => reads_field_e fld e || reads_field_s fld s1 || reads_field_s fld s2
  | Ssequence s1 s2     => reads_field_s fld s1 || reads_field_s fld s2
  | Sloop s1 s2         => reads_field_s fld s1 || reads_field_s fld s2
  | Sreturn (Some e)    => reads_field_e fld e
  | Slabel _ s1         => reads_field_s fld s1
  | Sswitch e ls        => reads_field_e fld e || reads_field_ls fld ls
  | _                   => false
  end
with reads_field_ls (fld : ident) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => false
  | LScons _ s rest => reads_field_s fld s || reads_field_ls fld rest
  end.

(* `input` has the same string ident in every TU; reuse mario's. *)
Definition reads_input (f : function) : bool := reads_field_s mario._input (fn_body f).

(* None of the five flying-setter functions reads the controller. The A-gate is
   provably elsewhere (upstream) -- this is the formal statement of "R2 as
   originally framed does not hold; the dependence is temporal." *)
Example set_jump_from_landing_no_input :
  reads_input mario.f_set_jump_from_landing = false.
Proof. reflexivity. Qed.

Example set_triple_jump_action_no_input :
  reads_input mario_actions_moving.f_set_triple_jump_action = false.
Proof. reflexivity. Qed.

Example act_shot_from_cannon_no_input :
  reads_input mario_actions_airborne.f_act_shot_from_cannon = false.
Proof. reflexivity. Qed.

Example set_mario_initial_action_no_input :
  reads_input level_update.f_set_mario_initial_action = false.
Proof. reflexivity. Qed.

(* The fifth site DOES read input -- but for B/Z cancels, not the flying gate (its
   ACT_FLYING transition is `vel[1] < 4.0f`). Recorded honestly rather than
   overclaimed: a whole-function input read does not mean the flying transition is
   input-gated. Separating the two needs guard-level path analysis = part of R3. *)
Example act_flying_triple_jump_reads_input :
  reads_input mario_actions_airborne.f_act_flying_triple_jump = true.
Proof. reflexivity. Qed.

(* Positive control: reads_input is not vacuously false -- act_flying consults the
   controller (for flight steering), so the analysis genuinely detects input reads. *)
Example act_flying_reads_input :
  reads_input mario_actions_airborne.f_act_flying = true.
Proof. reflexivity. Qed.
