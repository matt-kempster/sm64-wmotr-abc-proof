(* ActionGraph.v -- P1 of the R3 action-value plan (docs/r3-action-value-plan.md).
 *
 * The SYNTACTIC, decidable half of "no flight without A": extract the action
 * TRANSITION GRAPH from the real clightgen'd handler bodies. Nodes are action
 * constants; an out-edge X -> Y means "the handler reached when m->action == X can
 * call a set_mario_action-family function with action argument Y". We extract,
 * per internal function, the list of action arguments it feeds to the setter
 * family, splitting each into a literal target (Some z) or a COMPUTED argument
 * (None -- a variable/expression, sized below as an honest leak).
 *
 * Deliverables (all reflexivity / vm_compute):
 *   - action_out_edges : the per-function edge list (literal targets + computed).
 *   - flying_edges = exactly the known R1 flying sites, now pinned by VALUE
 *     (50333844 = ACT_FLYING_TRIPLE_JUMP, 277350553 = ACT_FLYING) -- cross-checks
 *     Flying.flying_setters and refines it from "a flying literal occurs somewhere
 *     in the args" to "the action ARGUMENT (2nd positional) is this flying value".
 *   - computed_count : the number of setter calls whose action argument is NOT a
 *     literal, per TU -- the size of the dataflow gap P4 must close.
 *
 * SCOPE / leaks (named, no buried ledes):
 *   - The setter family taking an action argument is
 *     {set_mario_action, drop_and_set_mario_action, hurt_and_set_mario_action,
 *      set_jumping_action} (each takes action as its 2nd positional arg and
 *     ultimately routes to set_mario_action). FIXED-target wrappers that take NO
 *     action arg (e.g. set_water_plunge_action -> ACT_WATER_PLUNGE internally) are
 *     NOT edges here; they introduce no flying action (none is a Flying.flying_setter)
 *     so they are sound to omit for the FLYING claim, but P3's full reachability
 *     must fold them in -- tracked, not closed.
 *   - COMPUTED action arguments (None) are a genuine syntactic gap: a variable
 *     holding 277350553 would be missed. We SIZE the gap here (computed_count) and
 *     leave ruling it out to P4 (the value-tracking semantics). The hope, borne out
 *     below, is that every FLYING edge passes the bare literal.
 *   - Idents are clightgen's string-encoding (`$"set_mario_action"`), identical as
 *     VALUES across modules, so the setter family is defined once from mario.
 *)

From Coq Require Import List ZArith PArith.BinPos.
Import ListNotations.
Local Open Scope Z_scope.
From compcert Require Import AST Integers Ctypes Cop Clight.
From SM64.Proofs Require Import CallgraphReach Flying.
From SM64.Generated Require mario
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_stationary mario_actions_cutscene mario_actions_object
  mario_actions_automatic level_update.

(* --- the setter family (action is the 2nd positional arg) -------------------- *)

Definition setter_idents : list ident :=
  [ mario._set_mario_action
  ; mario._drop_and_set_mario_action
  ; mario._hurt_and_set_mario_action
  ; mario._set_jumping_action ].

Definition is_setter_callee (e : expr) : option ident :=
  match e with
  | Evar id _ => if existsb (Pos.eqb id) setter_idents then Some id else None
  | _ => None
  end.

(* the action ARGUMENT of a setter call = its 2nd positional argument (m, action, ..) *)
Fixpoint setter_args_s (s : statement) : list expr :=
  match s with
  | Scall _ ef args =>
      match is_setter_callee ef, args with
      | Some _, _ :: act :: _ => [ act ]
      | _, _ => []
      end
  | Ssequence s1 s2     => setter_args_s s1 ++ setter_args_s s2
  | Sifthenelse _ s1 s2 => setter_args_s s1 ++ setter_args_s s2
  | Sloop s1 s2         => setter_args_s s1 ++ setter_args_s s2
  | Slabel _ s1         => setter_args_s s1
  | Sswitch _ ls        => setter_args_ls ls
  | _                   => []
  end
with setter_args_ls (ls : labeled_statements) : list expr :=
  match ls with
  | LSnil           => []
  | LScons _ s rest => setter_args_s s ++ setter_args_ls rest
  end.

(* literal action target (Some z) vs computed argument (None) *)
Definition action_arg_const (e : expr) : option Z :=
  match e with
  | Econst_int n _ => Some (Int.unsigned n)
  | _              => None
  end.

(* per-function out-edge action arguments, classified *)
Definition fn_edges (f : function) : list (option Z) :=
  map action_arg_const (setter_args_s (fn_body f)).

(* the LITERAL targets only (the resolved out-edges) *)
Definition fn_literal_targets (f : function) : list Z :=
  fold_right (fun o acc => match o with Some z => z :: acc | None => acc end) []
             (fn_edges f).

(* count of COMPUTED (non-literal) setter arguments in f *)
Definition fn_computed_count (f : function) : nat :=
  length (filter (fun o => match o with None => true | Some _ => false end) (fn_edges f)).

(* the FLYING literal targets of f (using Flying.is_flying_int on the value) *)
Definition fn_flying_targets (f : function) : list Z :=
  filter (fun z => is_flying_int (Int.repr z)) (fn_literal_targets f).

(* --- whole-program rollups (per TU) ------------------------------------------ *)

(* internal functions of p that have at least one flying literal target, paired
   with those flying targets -- the refined flying-edge enumeration. *)
Definition flying_edges (p : program) : list (ident * list Z) :=
  fold_right
    (fun idf acc =>
       match fn_flying_targets (snd idf) with
       | []     => acc
       | tgts   => (fst idf, tgts) :: acc
       end)
    [] (internal_funcs (prog_defs p)).

(* total number of computed setter arguments across a TU (sizes the dataflow gap). *)
Definition computed_count (p : program) : nat :=
  fold_right (fun idf acc => (fn_computed_count (snd idf) + acc)%nat)
             0%nat (internal_funcs (prog_defs p)).

(* total number of resolved (literal) edges across a TU. *)
Definition literal_edge_count (p : program) : nat :=
  fold_right (fun idf acc => (length (fn_literal_targets (snd idf)) + acc)%nat)
             0%nat (internal_funcs (prog_defs p)).

(* ======================================================================
   Machine-checked facts.
   ====================================================================== *)

(* --- sanity: the extractor matches the probe ground truth (moving TU) -------- *)

(* set_triple_jump_action emits exactly these three literal action targets, the
   first of which is ACT_FLYING_TRIPLE_JUMP = 50333844 (the flying edge). *)
Example moving_triple_jump_targets :
  fn_literal_targets mario_actions_moving.f_set_triple_jump_action
  = [50333844; 16779394; 50333824].
Proof. reflexivity. Qed.

Example moving_triple_jump_flying :
  fn_flying_targets mario_actions_moving.f_set_triple_jump_action = [50333844].
Proof. reflexivity. Qed.

(* an ordinary handler (act_walking) has only non-flying literal edges. *)
Example moving_act_walking_no_flying :
  fn_flying_targets mario_actions_moving.f_act_walking = [].
Proof. reflexivity. Qed.

(* ======================================================================
   THE FLYING-EDGE ENUMERATION, refined by VALUE (the P1 deliverable).
   ======================================================================
   Per TU, the internal functions with a flying out-edge, paired with the flying
   action VALUE(S) they target. This is exactly the 5 R1 sites of Flying.v, now
   pinned at the level of the action ARGUMENT (2nd positional), not merely "a
   flying literal occurs somewhere in the args" -- a strictly sharper statement.
   ACT_FLYING_TRIPLE_JUMP = 50333844, ACT_FLYING = 277350553.

   CRUCIAL for P4: every flying edge's target is a LITERAL (the value appears
   here), so no flying transition hides behind a computed argument. *)

(* ======================================================================
   THE FLYING-EDGE ENUMERATION, refined by VALUE (the P1 deliverable).
   ======================================================================
   Per TU, the internal functions with a flying out-edge, paired with the flying
   action VALUE(S) they target. Exactly the 5 R1 sites of Flying.v, now pinned at
   the level of the action ARGUMENT (2nd positional), not merely "a flying literal
   occurs somewhere in the args" -- a strictly sharper statement.
   ACT_FLYING_TRIPLE_JUMP = 50333844, ACT_FLYING = 277350553.

   CRUCIAL for P4: every flying edge's target is a LITERAL (the value appears
   here), so no flying transition hides behind a computed argument.

   (Edge-list order = prog_defs order, matching Flying.flying_setters.) *)

Example moving_flying_edges :
  flying_edges mario_actions_moving.prog
  = [(mario_actions_moving._set_triple_jump_action, [50333844])].
Proof. reflexivity. Qed.

Example airborne_flying_edges :
  flying_edges mario_actions_airborne.prog
  = [(mario_actions_airborne._act_shot_from_cannon,   [277350553]);
     (mario_actions_airborne._act_flying_triple_jump, [277350553])].
Proof. reflexivity. Qed.

Example mario_flying_edges :
  flying_edges mario.prog
  = [(mario._set_jump_from_landing, [50333844])].
Proof. reflexivity. Qed.

Example level_update_flying_edges :
  flying_edges level_update.prog
  = [(level_update._set_mario_initial_action, [277350553])].
Proof. reflexivity. Qed.

(* The other four group TUs introduce NO flying edge whatsoever. *)
Example submerged_no_flying_edges :
  flying_edges mario_actions_submerged.prog = [].
Proof. reflexivity. Qed.
Example stationary_no_flying_edges :
  flying_edges mario_actions_stationary.prog = [].
Proof. reflexivity. Qed.
Example cutscene_no_flying_edges :
  flying_edges mario_actions_cutscene.prog = [].
Proof. reflexivity. Qed.
Example object_no_flying_edges :
  flying_edges mario_actions_object.prog = [].
Proof. reflexivity. Qed.
Example automatic_no_flying_edges :
  flying_edges mario_actions_automatic.prog = [].
Proof. reflexivity. Qed.

(* ======================================================================
   THE COMPUTED-ARGUMENT GAP, sized (the honest dataflow leak for P4).
   ======================================================================
   Number of setter calls whose action argument is NOT a literal, per TU. These
   are the call sites P4's value-tracking must reason about (a variable could in
   principle carry a flying value). The flying-edge enumeration above shows none
   of them is CURRENTLY a flying edge -- but only dataflow (P4) makes that sound.
   Order: moving, airborne, submerged, stationary, cutscene, object, automatic,
   mario, level_update. *)

Example computed_counts_per_tu :
  ( computed_count mario_actions_moving.prog
  , computed_count mario_actions_airborne.prog
  , computed_count mario_actions_submerged.prog
  , computed_count mario_actions_stationary.prog
  , computed_count mario_actions_cutscene.prog
  , computed_count mario_actions_object.prog
  , computed_count mario_actions_automatic.prog
  , computed_count mario.prog
  , computed_count level_update.prog )
  = (16, 6, 2, 3, 8, 5, 2, 3, 1)%nat.
Proof. reflexivity. Qed.
