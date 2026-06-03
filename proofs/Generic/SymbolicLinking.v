(* kept: cross-TU linking spike, currently unwired. *)
(* SymbolicLinking.v -- SYMBOLIC-LINKING SPIKE (de-risking, OOM-free).
 *
 * BACKGROUND. The real per-frame Mario update spans translation units and is
 * cyclic: execute_mario_action (mario.c) -> mario_execute_<group>_action
 * (mario_actions_*.c) -> act_xxx (group TU) -> set_mario_action (mario.c). In each
 * clightgen'd TU the other TU's functions are `External`, so the true frame only
 * makes sense in the LINKED program.
 *
 * The first attempt -- `vm_compute` the actual link of two full TUs -- OOM'd the
 * machine (see git history / memory linking-oom): forcing the merged whole-program
 * AST into normal form is intractable. THE FIX: never compute the link. Keep the
 * linked program ABSTRACT (a Variable with `link ... = Some lp` as a hypothesis,
 * so lp is never normalized) and recover cross-TU symbol resolution from CompCert's
 * linking METATHEORY (link_linkorder + prog_defmap_linkorder + the find_def_symbol
 * genv bridge). The merged program stays a black box with known properties.
 *
 * THIS SPIKE proves the load-bearing fact at the smallest scale: in the linked
 * program, the cross-TU symbol `act_flying` resolves to AIRBORNE's real Internal
 * body -- WITHOUT ever computing the link. If this goes through cleanly, the linked-
 * frame architecture is viable: the same three lemmas resolve every cross-TU call.
 *
 * The ONLY computation here is one single-program defmap lookup (airborne alone),
 * the same cost as the existing ActionValue.v `find_funct_*` lemmas -- bounded and
 * safe. Everything about the linked program `lp` is symbolic.
 *
 * No Admitted. NOT in _CoqProject by default (check standalone with check.sh).
 *)

From compcert Require Import Coqlib Maps AST Integers Globalenvs Ctypes Clight Linking.
From SM64.Generated Require mario mario_actions_airborne.

(* CHEAP single-TU fact (the one bounded computation): airborne's OWN program
   defines act_flying as an Internal function. One program's defmap lookup. *)
Lemma airborne_defmap_act_flying :
  (prog_defmap mario_actions_airborne.prog) ! mario_actions_airborne._act_flying
    = Some (Gfun (Internal mario_actions_airborne.f_act_flying)).
Proof. vm_compute. reflexivity. Qed.

Section SymbolicLink.
  (* The linked program is ABSTRACT -- introduced as a variable, with linking as a
     hypothesis. It is NEVER computed, so it cannot OOM. *)
  Variable lp : Clight.program.
  Hypothesis Hlink : link mario.prog mario_actions_airborne.prog = Some lp.

  (* THE PAYOFF: in the linked genv, the cross-TU symbol act_flying resolves to
     airborne's real Internal body -- proved purely from the linking metatheory,
     with lp opaque. *)
  Theorem linked_resolves_act_flying :
    exists b,
      Genv.find_symbol (globalenv lp) mario_actions_airborne._act_flying = Some b /\
      Genv.find_funct_ptr (globalenv lp) b
        = Some (Internal mario_actions_airborne.f_act_flying).
  Proof.
    (* 1. Linking gives linkorder airborne <= lp (and mario <= lp). *)
    destruct (link_linkorder _ _ _ Hlink) as [_ LOab].
    (* 2. linkorder_program = AST linkorder (+ composite preservation); take the
          AST part. Unfold the (opaque) Clight linker instance to expose it. *)
    Local Transparent Linker_program.
    unfold linkorder, Linker_program, linkorder_program in LOab.
    destruct LOab as [LOast _Hcomp].
    (* 3. The AST defmap entry transfers up the linkorder (possibly upgraded). *)
    destruct (prog_defmap_linkorder _ _ _ _ LOast airborne_defmap_act_flying)
      as (gd' & Hgd' & Hlo).
    (* spent: drop LOast/_Hcomp so the only `linkorder _ _` left is Hlo's residue. *)
    clear LOast _Hcomp.
    (* 4. An Internal source can only map to the SAME Internal target: invert the
          two linkorder layers (globdef then fundef). The External-below-Internal
          case is impossible because the source is already Internal. After `inv Hlo`
          the inner premise has head `linkorder` (the class method), not the
          syntactic `linkorder_fundef`, so match on `linkorder _ _`. *)
    inv Hlo.
    match goal with H : linkorder _ _ |- _ => inv H end.
    (* now gd' = Gfun (Internal f_act_flying); Hgd' is the linked defmap entry. *)
    (* 5. Bridge defmap -> (find_symbol, find_def) in the linked genv. *)
    apply (proj1 (Genv.find_def_symbol _ _ _)) in Hgd'.
    destruct Hgd' as (b & Hsym & Hdef).
    exists b. split.
    - exact Hsym.
    - (* find_def -> find_funct_ptr via the iff. *)
      apply (proj2 (Genv.find_funct_ptr_iff _ _ _)). exact Hdef.
  Qed.

End SymbolicLink.

(* ====================================================================== *)
(* FROM SPIKE TO THE REAL DISPATCH CHAIN.                                  *)
(*                                                                        *)
(* The spike above resolved ONE toy symbol (act_flying). Generalize the    *)
(* exact same metatheory script to a reusable lemma, then instantiate it   *)
(* for the REAL symbols the GOAL-1 discharge needs: the airborne action    *)
(* DISPATCHER (mario_execute_airborne_action -- the underspecified         *)
(* External that execute_mario_action calls, the one the FALSE             *)
(* reach_ext_action_cell currently papers over) and the two airborne       *)
(* FLYING write-site handlers (act_flying_triple_jump, act_shot_from_      *)
(* cannon). Resolving them to real Internal bodies is the foundation for    *)
(* moving them out of the false unchanged_on external bucket and into the   *)
(* engine's Internal-body traversal. lp stays ABSTRACT throughout (no      *)
(* OOM); the only computations are per-TU (airborne-alone) defmap lookups.  *)
(* ====================================================================== *)

(* THE REUSABLE PRIMITIVE: any TU q with linkorder q lp contributes its Internal
   defs to lp's genv, resolved purely by linking metatheory with lp OPAQUE. Stated
   over `linkorder q lp` (not a fixed 2-way link) so it scales to the eventual
   N-way link of all action TUs -- each member TU is linkorder <= the full link.
   The single bounded computation is the per-TU defmap lookup the caller supplies
   as Hdm (a q-alone lookup, never anything about lp). *)
Lemma linkorder_resolves_internal :
  forall (lp q : Clight.program) (id : ident) (f : Clight.function),
    linkorder q lp ->
    (prog_defmap q) ! id = Some (Gfun (Internal f)) ->
    exists b,
      Genv.find_symbol (globalenv lp) id = Some b /\
      Genv.find_funct_ptr (globalenv lp) b = Some (Internal f).
Proof.
  intros lp q id f LOq Hdm.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LOq.
  destruct LOq as [LOast _Hcomp].
  destruct (prog_defmap_linkorder _ _ _ _ LOast Hdm) as (gd' & Hgd' & Hlo).
  clear LOast _Hcomp.
  inv Hlo.
  match goal with H : linkorder _ _ |- _ => inv H end.
  apply (proj1 (Genv.find_def_symbol _ _ _)) in Hgd'.
  destruct Hgd' as (b & Hsym & Hdef).
  exists b. split.
  - exact Hsym.
  - apply (proj2 (Genv.find_funct_ptr_iff _ _ _)). exact Hdef.
Qed.

(* 2-way corollary (the airborne group's minimal closed link), via link_linkorder. *)
Lemma linked_resolves_internal :
  forall (lp q : Clight.program) (id : ident) (f : Clight.function),
    link mario.prog q = Some lp ->
    (prog_defmap q) ! id = Some (Gfun (Internal f)) ->
    exists b,
      Genv.find_symbol (globalenv lp) id = Some b /\
      Genv.find_funct_ptr (globalenv lp) b = Some (Internal f).
Proof.
  intros lp q id f Hlink Hdm.
  destruct (link_linkorder _ _ _ Hlink) as [_ LOq].
  eapply linkorder_resolves_internal; eauto.
Qed.

(* The bounded per-TU (airborne-alone) defmap facts for the REAL symbols. *)
Lemma airborne_defmap_execute :
  (prog_defmap mario_actions_airborne.prog)
    ! mario_actions_airborne._mario_execute_airborne_action
    = Some (Gfun (Internal mario_actions_airborne.f_mario_execute_airborne_action)).
Proof. vm_compute. reflexivity. Qed.

Lemma airborne_defmap_flying_triple_jump :
  (prog_defmap mario_actions_airborne.prog)
    ! mario_actions_airborne._act_flying_triple_jump
    = Some (Gfun (Internal mario_actions_airborne.f_act_flying_triple_jump)).
Proof. vm_compute. reflexivity. Qed.

Lemma airborne_defmap_shot_from_cannon :
  (prog_defmap mario_actions_airborne.prog)
    ! mario_actions_airborne._act_shot_from_cannon
    = Some (Gfun (Internal mario_actions_airborne.f_act_shot_from_cannon)).
Proof. vm_compute. reflexivity. Qed.

Section AirborneRealSymbols.
  (* The linked program of mario.c (caller) + airborne (the called group). The
     dependency is genuinely CYCLIC -- mario.execute calls airborne.dispatcher,
     airborne.act_* call back into mario.set_mario_action -- so this 2-TU link is
     the minimal closed unit for the airborne group, and BOTH directions resolve. *)
  Variable lp : Clight.program.
  Hypothesis Hlink : link mario.prog mario_actions_airborne.prog = Some lp.

  (* The airborne DISPATCHER -- the symbol execute_mario_action invokes, an
     underspecified External in mario.prog -- resolves in the linked genv to its
     REAL Internal body. This is the resolution that lets the value engine TRAVERSE
     the dispatcher instead of assuming the (false) unchanged_on for it. *)
  Theorem linked_resolves_execute_airborne :
    exists b,
      Genv.find_symbol (globalenv lp)
        mario_actions_airborne._mario_execute_airborne_action = Some b /\
      Genv.find_funct_ptr (globalenv lp) b
        = Some (Internal mario_actions_airborne.f_mario_execute_airborne_action).
  Proof. eapply linked_resolves_internal; [ exact Hlink | exact airborne_defmap_execute ]. Qed.

  (* The two airborne FLYING write-site handlers resolve to their real bodies --
     the functions in which ACT_FLYING_TRIPLE_JUMP / ACT_SHOT_FROM_CANNON are set
     (the leaf-B A-gating obligations land here, over real code). *)
  Theorem linked_resolves_flying_triple_jump :
    exists b,
      Genv.find_symbol (globalenv lp)
        mario_actions_airborne._act_flying_triple_jump = Some b /\
      Genv.find_funct_ptr (globalenv lp) b
        = Some (Internal mario_actions_airborne.f_act_flying_triple_jump).
  Proof. eapply linked_resolves_internal; [ exact Hlink | exact airborne_defmap_flying_triple_jump ]. Qed.

  Theorem linked_resolves_shot_from_cannon :
    exists b,
      Genv.find_symbol (globalenv lp)
        mario_actions_airborne._act_shot_from_cannon = Some b /\
      Genv.find_funct_ptr (globalenv lp) b
        = Some (Internal mario_actions_airborne.f_act_shot_from_cannon).
  Proof. eapply linked_resolves_internal; [ exact Hlink | exact airborne_defmap_shot_from_cannon ]. Qed.

End AirborneRealSymbols.
