(* Taint.v -- the no-A TAINT SET T, concrete and read off the generated ASTs.
 *
 * GOAL-1's carried invariant cannot be "action is not flying": the cannon
 * breaks it. ACT_SHOT_FROM_CANNON is NOT a flying action, yet its handler
 * act_shot_from_cannon writes ACT_FLYING on a LATER, A-FREE frame (wing cap +
 * pure physics; airborne.c:1710 -- machine-checked below as a tainted edge).
 * So "non-flying -> flying requires A THIS frame" is FALSE of the real code.
 *
 * The right inductive invariant is `action notin T`, where T is the no-A
 * reachability closure of the flying set F:
 *
 *   T = { ACT_FLYING, ACT_FLYING_TRIPLE_JUMP, ACT_SHOT_FROM_CANNON }
 *
 * This file makes T concrete (is_tainted / not_tainted) and machine-checks,
 * by reflexivity over the real clightgen'd TUs, the SYNTACTIC closure facts:
 *
 *   (1) tainted_edges: the COMPLETE per-TU enumeration of functions that feed
 *       a T-literal into a setter-family call (ActionGraph's edge extraction,
 *       refiltered at T). Exactly SIX in the whole linked program -- the five
 *       Flying.v flying-setters plus act_in_cannon (the cannon fire,
 *       automatic.c:743, the edge that forces T to strictly contain F).
 *   (2) tainted_action_writers: NO function raw-writes a T-constant to
 *       MarioState.action -- the only route into T is a setter call (the
 *       choke point of Flying.v, upgraded from F to T).
 *   (3) the caller/escape census for the two T-feeders whose A-gate lives in
 *       their CALLERS (set_jump_from_landing, set_triple_jump_action): every
 *       direct call site and every function-pointer escape, enumerated.
 *   (4) the input-writer census: every write to MarioState.input, classified
 *       by whether it can SET bit 1 (INPUT_A_PRESSED = 0x0002). Exactly ONE
 *       write in the whole linked program can -- the `m->input |= 2` in
 *       update_mario_button_inputs, which sits under the controller A-gate
 *       `if (m->controller->buttonPressed & A_BUTTON)` (mario.c:1254).
 *
 * GROUND TRUTH: ACT_SHOT_FROM_CANNON = 0x00880898 = 8915096, read off the
 * generated AST (the set_mario_action literal inside f_act_in_cannon), same
 * trust model as Flying.v's constants.
 *
 * SCOPE / honesty (the leaks, named):
 *   - Syntactic & literal-flow, like Flying.v: a T-value reaching a setter
 *     through a COMPUTED argument would be missed here; ActionGraph sizes that
 *     gap (computed_count). Ruling it out is the value-tracking semantics.
 *   - The A-gates themselves (the `if (m->input & INPUT_A_PRESSED)` guards at
 *     the entry sites, and the buttonPressed gate in update_mario_button_inputs)
 *     are SEMANTIC facts proved separately -- this file pins where they live.
 *   - level_update's set_mario_initial_action is OUTSIDE execute_mario_action
 *     (the spawn path); the capstone excludes it via no_spawn_flying_run.
 *)

From Coq Require Import Bool List ZArith PArith.BinPos.
Import ListNotations.
Local Open Scope Z_scope.
From compcert Require Import AST Integers Ctypes Cop Clight.
From SM64.Proofs Require Import CallgraphReach Flying ActionGraph.
From SM64.Generated Require mario
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_stationary mario_actions_cutscene mario_actions_object
  mario_actions_automatic level_update behavior_actions interaction mario_step.

(* ====================================================================== *)
(* T -- the taint set.                                                     *)
(* ====================================================================== *)

Definition ACT_SHOT_FROM_CANNON : int := Int.repr 8915096.   (* 0x00880898 *)

Definition is_tainted (n : int) : bool :=
  is_flying_int n || Int.eq n ACT_SHOT_FROM_CANNON.

(* the value predicate the capstone carries (the Q of action_sat). *)
Definition not_tainted (v : int) : Prop := is_tainted v = false.

(* not-tainted is STRONGER than not-flying: carrying T through the frame
   yields the no-fly conclusion for free. *)
Lemma not_tainted_not_flying : forall v, not_tainted v -> is_flying_int v = false.
Proof.
  intros v H; unfold not_tainted, is_tainted in H.
  apply orb_false_iff in H; tauto.
Qed.

(* T strictly contains F: the cannon value is tainted but NOT flying. *)
Example taint_strictly_contains_flying :
  is_tainted ACT_FLYING = true /\
  is_tainted ACT_FLYING_TRIPLE_JUMP = true /\
  is_tainted ACT_SHOT_FROM_CANNON = true /\
  is_flying_int ACT_SHOT_FROM_CANNON = false.
Proof. repeat split; reflexivity. Qed.

(* ====================================================================== *)
(* (1) The tainted out-edges: ActionGraph's setter-family edge extraction,  *)
(*     refiltered at T.                                                     *)
(* ====================================================================== *)

Definition fn_tainted_targets (f : function) : list Z :=
  filter (fun z => is_tainted (Int.repr z)) (fn_literal_targets f).

Definition tainted_edges (p : program) : list (ident * list Z) :=
  fold_right
    (fun idf acc =>
       match fn_tainted_targets (snd idf) with
       | []   => acc
       | tgts => (fst idf, tgts) :: acc
       end)
    [] (internal_funcs (prog_defs p)).

(* --- the per-TU enumeration: SIX tainted-edge functions in the whole
   linked program, and no other. --- *)

(* mario.c: set_jump_from_landing (wing-cap double-jump-land -> FTJ). Its
   A-gate lives in its CALLERS -- enumerated in (3) below. *)
Example mario_tainted_edges :
  tainted_edges mario.prog = [(mario._set_jump_from_landing, [50333844])].
Proof. reflexivity. Qed.

(* moving.c: set_triple_jump_action (wing-cap -> FTJ). A-gated at its callers
   (it escapes as a function pointer into common_landing_cancels -- (3)). *)
Example moving_tainted_edges :
  tainted_edges mario_actions_moving.prog =
    [(mario_actions_moving._set_triple_jump_action, [50333844])].
Proof. reflexivity. Qed.

(* airborne.c: the two F-INTERNAL edges -- act_shot_from_cannon and
   act_flying_triple_jump both -> ACT_FLYING. Both handlers are dispatched
   only when m->action is ALREADY in T, so `action notin T` kills them with
   no local A-gate needed (exactly why T must contain the cannon). *)
Example airborne_tainted_edges :
  tainted_edges mario_actions_airborne.prog =
    [(mario_actions_airborne._act_shot_from_cannon,   [277350553]);
     (mario_actions_airborne._act_flying_triple_jump, [277350553])].
Proof. reflexivity. Qed.

(* automatic.c: act_in_cannon -> ACT_SHOT_FROM_CANNON (the cannon FIRE,
   automatic.c:743). THE edge that forces T to strictly contain F. Its A-gate
   is IN-BODY: `Sset _t'6 (m->input); if (_t'6 & 2) { ... fire ... }`. *)
Example automatic_tainted_edges :
  tainted_edges mario_actions_automatic.prog =
    [(mario_actions_automatic._act_in_cannon, [8915096])].
Proof. reflexivity. Qed.

(* level_update.c: the spawn path (outside the frame; excluded by
   no_spawn_flying_run). *)
Example level_update_tainted_edges :
  tainted_edges level_update.prog =
    [(level_update._set_mario_initial_action, [277350553])].
Proof. reflexivity. Qed.

(* ...and NO other TU linked into the frame has ANY tainted edge. *)
Example stationary_no_tainted_edges :
  tainted_edges mario_actions_stationary.prog = [].
Proof. reflexivity. Qed.
Example submerged_no_tainted_edges :
  tainted_edges mario_actions_submerged.prog = [].
Proof. reflexivity. Qed.
Example cutscene_no_tainted_edges :
  tainted_edges mario_actions_cutscene.prog = [].
Proof. reflexivity. Qed.
Example object_no_tainted_edges :
  tainted_edges mario_actions_object.prog = [].
Proof. reflexivity. Qed.
Example mario_step_no_tainted_edges :
  tainted_edges mario_step.prog = [].
Proof. reflexivity. Qed.
Example interaction_no_tainted_edges :
  tainted_edges interaction.prog = [].
Proof. reflexivity. Qed.
Example behavior_no_tainted_edges :
  tainted_edges behavior_actions.prog = [].
Proof. reflexivity. Qed.

(* ====================================================================== *)
(* (2) The raw-write choke point, upgraded from F to T: NO function in any   *)
(*     linked TU assigns a T-constant directly to MarioState.action.         *)
(* ====================================================================== *)

Fixpoint expr_has_tainted (e : expr) : bool :=
  match e with
  | Econst_int n _   => is_tainted n
  | Ederef e1 _      => expr_has_tainted e1
  | Eaddrof e1 _     => expr_has_tainted e1
  | Eunop _ e1 _     => expr_has_tainted e1
  | Ecast e1 _       => expr_has_tainted e1
  | Efield e1 _ _    => expr_has_tainted e1
  | Ebinop _ e1 e2 _ => expr_has_tainted e1 || expr_has_tainted e2
  | _                => false
  end.

Fixpoint writes_tainted_action_s (sid fld : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs     => lhs_is_mario_action sid fld lhs && expr_has_tainted rhs
  | Ssequence s1 s2     => writes_tainted_action_s sid fld s1 || writes_tainted_action_s sid fld s2
  | Sifthenelse _ s1 s2 => writes_tainted_action_s sid fld s1 || writes_tainted_action_s sid fld s2
  | Sloop s1 s2         => writes_tainted_action_s sid fld s1 || writes_tainted_action_s sid fld s2
  | Slabel _ s1         => writes_tainted_action_s sid fld s1
  | Sswitch _ ls        => writes_tainted_action_ls sid fld ls
  | _                   => false
  end
with writes_tainted_action_ls (sid fld : ident) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => false
  | LScons _ s rest => writes_tainted_action_s sid fld s || writes_tainted_action_ls sid fld rest
  end.

Definition tainted_action_writers (sid fld : ident) (p : program) : list ident :=
  map fst (filter (fun idf => writes_tainted_action_s sid fld (fn_body (snd idf)))
                  (internal_funcs (prog_defs p))).

Example no_raw_tainted_write_mario :
  tainted_action_writers mario._MarioState mario._action mario.prog = [].
Proof. reflexivity. Qed.
Example no_raw_tainted_write_moving :
  tainted_action_writers mario_actions_moving._MarioState
    mario_actions_moving._action mario_actions_moving.prog = [].
Proof. reflexivity. Qed.
Example no_raw_tainted_write_airborne :
  tainted_action_writers mario_actions_airborne._MarioState
    mario_actions_airborne._action mario_actions_airborne.prog = [].
Proof. reflexivity. Qed.
Example no_raw_tainted_write_stationary :
  tainted_action_writers mario_actions_stationary._MarioState
    mario_actions_stationary._action mario_actions_stationary.prog = [].
Proof. reflexivity. Qed.
Example no_raw_tainted_write_submerged :
  tainted_action_writers mario_actions_submerged._MarioState
    mario_actions_submerged._action mario_actions_submerged.prog = [].
Proof. reflexivity. Qed.
Example no_raw_tainted_write_cutscene :
  tainted_action_writers mario_actions_cutscene._MarioState
    mario_actions_cutscene._action mario_actions_cutscene.prog = [].
Proof. reflexivity. Qed.
Example no_raw_tainted_write_object :
  tainted_action_writers mario_actions_object._MarioState
    mario_actions_object._action mario_actions_object.prog = [].
Proof. reflexivity. Qed.
Example no_raw_tainted_write_automatic :
  tainted_action_writers mario_actions_automatic._MarioState
    mario_actions_automatic._action mario_actions_automatic.prog = [].
Proof. reflexivity. Qed.
Example no_raw_tainted_write_interaction :
  tainted_action_writers interaction._MarioState interaction._action
    interaction.prog = [].
Proof. reflexivity. Qed.
Example no_raw_tainted_write_mario_step :
  tainted_action_writers mario_step._MarioState mario_step._action
    mario_step.prog = [].
Proof. reflexivity. Qed.
Example no_raw_tainted_write_behavior :
  tainted_action_writers behavior_actions._MarioState behavior_actions._action
    behavior_actions.prog = [].
Proof. reflexivity. Qed.
Example no_raw_tainted_write_level_update :
  tainted_action_writers level_update._MarioState level_update._action
    level_update.prog = [].
Proof. reflexivity. Qed.

(* ====================================================================== *)
(* (3) Caller/escape census for the two feeders whose A-gate lives in the   *)
(*     CALLERS.                                                             *)
(* ====================================================================== *)

(* direct calls: Scall whose callee expression is `Evar target`. *)
Fixpoint calls_ident_s (target : ident) (s : statement) : bool :=
  match s with
  | Scall _ ef _ =>
      match ef with Evar id _ => Pos.eqb id target | _ => false end
  | Ssequence s1 s2     => calls_ident_s target s1 || calls_ident_s target s2
  | Sifthenelse _ s1 s2 => calls_ident_s target s1 || calls_ident_s target s2
  | Sloop s1 s2         => calls_ident_s target s1 || calls_ident_s target s2
  | Slabel _ s1         => calls_ident_s target s1
  | Sswitch _ ls        => calls_ident_ls target ls
  | _                   => false
  end
with calls_ident_ls (target : ident) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => false
  | LScons _ s rest => calls_ident_s target s || calls_ident_ls target rest
  end.

Definition callers_of (target : ident) (p : program) : list ident :=
  map fst (filter (fun idf => calls_ident_s target (fn_body (snd idf)))
                  (internal_funcs (prog_defs p))).

(* function-pointer escapes: `target` mentioned in ANY expression position
   OTHER than a direct-call callee (call/builtin arguments, assignments,
   guards, returns) -- the sites where the feeder could leak as a funptr. *)
Fixpoint expr_mentions (target : ident) (e : expr) : bool :=
  match e with
  | Evar id _        => Pos.eqb id target
  | Ederef e1 _      => expr_mentions target e1
  | Eaddrof e1 _     => expr_mentions target e1
  | Eunop _ e1 _     => expr_mentions target e1
  | Ecast e1 _       => expr_mentions target e1
  | Efield e1 _ _    => expr_mentions target e1
  | Ebinop _ e1 e2 _ => expr_mentions target e1 || expr_mentions target e2
  | _                => false
  end.

Fixpoint funptr_escape_s (target : ident) (s : statement) : bool :=
  match s with
  | Sassign a1 a2       => expr_mentions target a1 || expr_mentions target a2
  | Sset _ e            => expr_mentions target e
  | Scall _ _ args      => existsb (expr_mentions target) args
  | Sbuiltin _ _ _ args => existsb (expr_mentions target) args
  | Ssequence s1 s2     => funptr_escape_s target s1 || funptr_escape_s target s2
  | Sifthenelse e s1 s2 => expr_mentions target e
                           || funptr_escape_s target s1 || funptr_escape_s target s2
  | Sloop s1 s2         => funptr_escape_s target s1 || funptr_escape_s target s2
  | Sreturn (Some e)    => expr_mentions target e
  | Slabel _ s1         => funptr_escape_s target s1
  | Sswitch e ls        => expr_mentions target e || funptr_escape_ls target ls
  | _                   => false
  end
with funptr_escape_ls (target : ident) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => false
  | LScons _ s rest => funptr_escape_s target s || funptr_escape_ls target rest
  end.

Definition funptr_escapers (target : ident) (p : program) : list ident :=
  map fst (filter (fun idf => funptr_escape_s target (fn_body (snd idf)))
                  (internal_funcs (prog_defs p))).

(* which direct calls receive `target` as an ARGUMENT (the funptr sink): the
   callee idents of every call whose argument list mentions target. *)
Fixpoint funptr_sink_callees (target : ident) (s : statement) : list (option ident) :=
  match s with
  | Scall _ ef args =>
      if existsb (expr_mentions target) args
      then [match ef with Evar id _ => Some id | _ => None end]
      else []
  | Ssequence s1 s2     => funptr_sink_callees target s1 ++ funptr_sink_callees target s2
  | Sifthenelse _ s1 s2 => funptr_sink_callees target s1 ++ funptr_sink_callees target s2
  | Sloop s1 s2         => funptr_sink_callees target s1 ++ funptr_sink_callees target s2
  | Slabel _ s1         => funptr_sink_callees target s1
  | Sswitch _ ls        => funptr_sink_callees_ls target ls
  | _                   => []
  end
with funptr_sink_callees_ls (target : ident) (ls : labeled_statements) : list (option ident) :=
  match ls with
  | LSnil           => []
  | LScons _ s rest => funptr_sink_callees target s ++ funptr_sink_callees_ls target rest
  end.

(* --- set_jump_from_landing: exactly THREE direct call sites in the whole
   linked program -- check_common_landing_cancels (stationary.c:850),
   act_walking (moving.c:792), act_decelerating (moving.c:1082) -- and it
   NEVER escapes as a function pointer. Each site sits under
   `if (m->input & INPUT_A_PRESSED)`; those guards are the semantic A-gate
   lemmas, proved separately. --- *)
Example sjfl_callers :
  ( callers_of mario._set_jump_from_landing mario.prog
  , callers_of mario._set_jump_from_landing mario_actions_stationary.prog
  , callers_of mario._set_jump_from_landing mario_actions_moving.prog
  , callers_of mario._set_jump_from_landing mario_actions_airborne.prog
  , callers_of mario._set_jump_from_landing mario_actions_submerged.prog
  , callers_of mario._set_jump_from_landing mario_actions_cutscene.prog
  , callers_of mario._set_jump_from_landing mario_actions_object.prog
  , callers_of mario._set_jump_from_landing mario_actions_automatic.prog
  , callers_of mario._set_jump_from_landing interaction.prog
  , callers_of mario._set_jump_from_landing mario_step.prog
  , callers_of mario._set_jump_from_landing behavior_actions.prog )
  = ( []
    , [mario_actions_stationary._check_common_landing_cancels]
    , [mario_actions_moving._act_walking; mario_actions_moving._act_decelerating]
    , [], [], [], [], [], [], [], [] ).
Proof. reflexivity. Qed.

Example sjfl_no_funptr_escape :
  ( funptr_escapers mario._set_jump_from_landing mario.prog
  , funptr_escapers mario._set_jump_from_landing mario_actions_stationary.prog
  , funptr_escapers mario._set_jump_from_landing mario_actions_moving.prog
  , funptr_escapers mario._set_jump_from_landing mario_actions_airborne.prog
  , funptr_escapers mario._set_jump_from_landing mario_actions_submerged.prog
  , funptr_escapers mario._set_jump_from_landing mario_actions_cutscene.prog
  , funptr_escapers mario._set_jump_from_landing mario_actions_object.prog
  , funptr_escapers mario._set_jump_from_landing mario_actions_automatic.prog
  , funptr_escapers mario._set_jump_from_landing interaction.prog
  , funptr_escapers mario._set_jump_from_landing mario_step.prog
  , funptr_escapers mario._set_jump_from_landing behavior_actions.prog )
  = ([], [], [], [], [], [], [], [], [], [], []).
Proof. reflexivity. Qed.

(* --- set_triple_jump_action: NEVER called directly anywhere; escapes as a
   function pointer EXACTLY once -- act_double_jump_land passes it into
   common_landing_cancels (moving.c:1875), whose indirect call of the passed
   setter sits under `if (m->input & INPUT_A_PRESSED)` (semantic A-gate). --- *)
Example stja_never_called_directly :
  ( callers_of mario_actions_moving._set_triple_jump_action mario.prog
  , callers_of mario_actions_moving._set_triple_jump_action mario_actions_stationary.prog
  , callers_of mario_actions_moving._set_triple_jump_action mario_actions_moving.prog
  , callers_of mario_actions_moving._set_triple_jump_action mario_actions_airborne.prog
  , callers_of mario_actions_moving._set_triple_jump_action mario_actions_submerged.prog
  , callers_of mario_actions_moving._set_triple_jump_action mario_actions_cutscene.prog
  , callers_of mario_actions_moving._set_triple_jump_action mario_actions_object.prog
  , callers_of mario_actions_moving._set_triple_jump_action mario_actions_automatic.prog
  , callers_of mario_actions_moving._set_triple_jump_action interaction.prog
  , callers_of mario_actions_moving._set_triple_jump_action mario_step.prog
  , callers_of mario_actions_moving._set_triple_jump_action behavior_actions.prog )
  = ([], [], [], [], [], [], [], [], [], [], []).
Proof. reflexivity. Qed.

Example stja_escapes_only_in_act_double_jump_land :
  ( funptr_escapers mario_actions_moving._set_triple_jump_action mario.prog
  , funptr_escapers mario_actions_moving._set_triple_jump_action mario_actions_stationary.prog
  , funptr_escapers mario_actions_moving._set_triple_jump_action mario_actions_moving.prog
  , funptr_escapers mario_actions_moving._set_triple_jump_action mario_actions_airborne.prog
  , funptr_escapers mario_actions_moving._set_triple_jump_action mario_actions_submerged.prog
  , funptr_escapers mario_actions_moving._set_triple_jump_action mario_actions_cutscene.prog
  , funptr_escapers mario_actions_moving._set_triple_jump_action mario_actions_object.prog
  , funptr_escapers mario_actions_moving._set_triple_jump_action mario_actions_automatic.prog
  , funptr_escapers mario_actions_moving._set_triple_jump_action interaction.prog
  , funptr_escapers mario_actions_moving._set_triple_jump_action mario_step.prog
  , funptr_escapers mario_actions_moving._set_triple_jump_action behavior_actions.prog )
  = ([], [], [mario_actions_moving._act_double_jump_land], [], [], [], [], [], [], [], []).
Proof. reflexivity. Qed.

(* ...and the ONE escape flows into common_landing_cancels (the funptr sink). *)
Example stja_sink_is_common_landing_cancels :
  funptr_sink_callees mario_actions_moving._set_triple_jump_action
    (fn_body mario_actions_moving.f_act_double_jump_land)
  = [Some mario_actions_moving._common_landing_cancels].
Proof. reflexivity. Qed.

(* ====================================================================== *)
(* (4) The input-writer census: who writes MarioState.input, and can the    *)
(*     write SET bit 1 (INPUT_A_PRESSED = 0x0002)?                          *)
(* ====================================================================== *)

(* rhs shapes that CANNOT set bit 1: a constant with the bit clear; a
   constant with the bit clear OR'd into a temp (preserves bit-1-clear of the
   temp); any AND mask (can only clear bits). Everything else counts UNSAFE
   (conservative). *)
Definition rhs_a_clear (e : expr) : bool :=
  match e with
  | Econst_int c _ => negb (Z.testbit (Int.unsigned c) 1)
  | Ebinop Oor (Etempvar _ _) (Econst_int c _) _ =>
      negb (Z.testbit (Int.unsigned c) 1)
  | Ebinop Oand _ _ _ => true
  | _ => false
  end.

(* collect the rhs of every write to <MarioState>.<fld>. *)
Fixpoint field_write_rhss (sid fld : ident) (s : statement) : list expr :=
  match s with
  | Sassign lhs rhs     => if lhs_is_mario_action sid fld lhs then [rhs] else []
  | Ssequence s1 s2     => field_write_rhss sid fld s1 ++ field_write_rhss sid fld s2
  | Sifthenelse _ s1 s2 => field_write_rhss sid fld s1 ++ field_write_rhss sid fld s2
  | Sloop s1 s2         => field_write_rhss sid fld s1 ++ field_write_rhss sid fld s2
  | Slabel _ s1         => field_write_rhss sid fld s1
  | Sswitch _ ls        => field_write_rhss_ls sid fld ls
  | _                   => []
  end
with field_write_rhss_ls (sid fld : ident) (ls : labeled_statements) : list expr :=
  match ls with
  | LSnil           => []
  | LScons _ s rest => field_write_rhss sid fld s ++ field_write_rhss_ls sid fld rest
  end.

Definition fn_a_unsafe_input_writes (sid fld : ident) (f : function) : nat :=
  length (filter (fun e => negb (rhs_a_clear e))
                 (field_write_rhss sid fld (fn_body f))).

(* the functions with at least one A-UNSAFE input write, with the count. *)
Definition a_unsafe_input_writers (sid fld : ident) (p : program)
    : list (ident * nat) :=
  fold_right
    (fun idf acc =>
       match fn_a_unsafe_input_writes sid fld (snd idf) with
       | O => acc
       | n => (fst idf, n) :: acc
       end)
    [] (internal_funcs (prog_defs p)).

(* ALL input writers (safe or not), for the record. *)
Definition input_writers (sid fld : ident) (p : program) : list ident :=
  map fst (filter
             (fun idf =>
                match field_write_rhss sid fld (fn_body (snd idf)) with
                | [] => false | _ => true end)
             (internal_funcs (prog_defs p))).

(* --- the complete input-writer map of the linked program. mario.c holds the
   four update_mario_*_inputs writers; the landing handlers in moving/
   stationary write input only through AND masks (they CLEAR
   INPUT_A_PRESSED -- e.g. act_long_jump_land's `m->input &= ~INPUT_A_PRESSED`
   unless Z is held); two end-cutscene handlers and interact_grabbable OR in
   non-A flags. --- *)
Example input_writer_map :
  ( input_writers mario._MarioState mario._input mario.prog
  , input_writers mario._MarioState mario._input mario_actions_moving.prog
  , input_writers mario._MarioState mario._input mario_actions_stationary.prog
  , input_writers mario._MarioState mario._input mario_actions_airborne.prog
  , input_writers mario._MarioState mario._input mario_actions_submerged.prog
  , input_writers mario._MarioState mario._input mario_actions_cutscene.prog
  , input_writers mario._MarioState mario._input mario_actions_object.prog
  , input_writers mario._MarioState mario._input mario_actions_automatic.prog
  , input_writers mario._MarioState mario._input interaction.prog
  , input_writers mario._MarioState mario._input mario_step.prog
  , input_writers mario._MarioState mario._input behavior_actions.prog
  , input_writers mario._MarioState mario._input level_update.prog )
  = ( [mario._update_mario_button_inputs; mario._update_mario_joystick_inputs;
       mario._update_mario_geometry_inputs; mario._update_mario_inputs]
    , [mario_actions_moving._act_long_jump_land;
       mario_actions_moving._act_triple_jump_land;
       mario_actions_moving._act_backflip_land]
    , [mario_actions_stationary._act_backflip_land_stop;
       mario_actions_stationary._act_lava_boost_land;
       mario_actions_stationary._act_long_jump_land_stop]
    , [], []
    , [mario_actions_cutscene._jumbo_star_cutscene_falling;
       mario_actions_cutscene._end_peach_cutscene_mario_falling]
    , [], []
    , [interaction._interact_grabbable]
    , [], [], [] ).
Proof. reflexivity. Qed.

(* THE A-GATE CENSUS RESULT: in the WHOLE linked program there is EXACTLY ONE
   write to MarioState.input that can SET bit 1 (INPUT_A_PRESSED) -- the
   `m->input |= 0x0002` inside update_mario_button_inputs, which sits under
   `if (m->controller->buttonPressed & A_BUTTON)` (mario.c:1254; the semantic
   half of that gate is proved separately). Every other input write in every
   linked TU is A-clear by shape. *)
Example the_one_a_unsafe_input_write :
  ( a_unsafe_input_writers mario._MarioState mario._input mario.prog
  , a_unsafe_input_writers mario._MarioState mario._input mario_actions_moving.prog
  , a_unsafe_input_writers mario._MarioState mario._input mario_actions_stationary.prog
  , a_unsafe_input_writers mario._MarioState mario._input mario_actions_airborne.prog
  , a_unsafe_input_writers mario._MarioState mario._input mario_actions_submerged.prog
  , a_unsafe_input_writers mario._MarioState mario._input mario_actions_cutscene.prog
  , a_unsafe_input_writers mario._MarioState mario._input mario_actions_object.prog
  , a_unsafe_input_writers mario._MarioState mario._input mario_actions_automatic.prog
  , a_unsafe_input_writers mario._MarioState mario._input interaction.prog
  , a_unsafe_input_writers mario._MarioState mario._input mario_step.prog
  , a_unsafe_input_writers mario._MarioState mario._input behavior_actions.prog
  , a_unsafe_input_writers mario._MarioState mario._input level_update.prog )
  = ( [(mario._update_mario_button_inputs, 1%nat)]
    , [], [], [], [], [], [], [], [], [], [], [] ).
Proof. reflexivity. Qed.
