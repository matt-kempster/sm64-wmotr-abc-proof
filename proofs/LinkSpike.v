(* LinkSpike.v -- SYMBOLIC-LINKING SPIKE (de-risking, OOM-free).
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
    (* 4. An Internal source can only map to the SAME Internal target: invert the
          two linkorder layers (globdef then fundef). The External-below-Internal
          case is impossible because the source is already Internal. *)
    inv Hlo.
    match goal with H : linkorder_fundef _ _ |- _ => inv H end.
    (* now gd' = Gfun (Internal f_act_flying); Hgd' is the linked defmap entry. *)
    (* 5. Bridge defmap -> (find_symbol, find_def) in the linked genv. *)
    apply (proj1 (find_def_symbol _ _ _)) in Hgd'.
    destruct Hgd' as (b & Hsym & Hdef).
    exists b. split.
    - exact Hsym.
    - (* find_def -> find_funct_ptr via the iff. *)
      apply (proj2 (find_funct_ptr_iff _ _ _)). exact Hdef.
  Qed.

End SymbolicLink.
