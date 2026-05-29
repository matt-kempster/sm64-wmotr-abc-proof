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
From SM64.Generated Require mario mario_actions_airborne mario_actions_moving level_update.

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
