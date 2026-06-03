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

From compcert Require Import Coqlib Maps AST Integers Values Globalenvs Ctypes Clight Linking.
From SM64.Generated Require mario
  mario_actions_airborne mario_actions_moving mario_actions_stationary
  mario_actions_submerged mario_actions_cutscene mario_actions_automatic
  mario_actions_object.

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

(* THE ENGINE INTERFACE FORM. The value engine's Scall case evaluates the callee
   expression `Evar f_id` to a function pointer `Vptr b Ptrofs.zero` and resolves it
   with `Genv.find_funct (globalenv lp) (Vptr b 0)`. find_funct at a zero offset IS
   find_funct_ptr, so the resolution lifts directly to the shape the engine consumes
   -- this is exactly what routes a dispatcher Scall to the Internal/funcall-IH case
   (NOT eval_funcall_external + the false Hext) once the engine is re-rooted at lp. *)
Lemma linkorder_resolves_funct :
  forall (lp q : Clight.program) (id : ident) (f : Clight.function),
    linkorder q lp ->
    (prog_defmap q) ! id = Some (Gfun (Internal f)) ->
    exists b,
      Genv.find_symbol (globalenv lp) id = Some b /\
      Genv.find_funct (globalenv lp) (Vptr b Ptrofs.zero) = Some (Internal f).
Proof.
  intros lp q id f LOq Hdm.
  destruct (linkorder_resolves_internal lp q id f LOq Hdm) as (b & Hsym & Hfp).
  exists b. split; [ exact Hsym | ].
  unfold Genv.find_funct.
  destruct (Ptrofs.eq_dec Ptrofs.zero Ptrofs.zero) as [_ | Hne];
    [ exact Hfp | exfalso; apply Hne; reflexivity ].
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

(* ====================================================================== *)
(* THE FULL DISPATCH-RESOLUTION LAYER.                                     *)
(*                                                                        *)
(* execute_mario_action switches on the action group and calls one of the *)
(* SEVEN mario_execute_<group>_action dispatchers -- every one an          *)
(* underspecified External in mario.prog. Over the eventual N-way linked   *)
(* program lp (mario + the 7 action TUs + step/interaction), each resolves *)
(* to its real Internal body. Parameterized by per-member `linkorder       *)
(* <group>.prog lp` -- exactly what `link_list`'s link_linkorder chain      *)
(* yields for each member -- so this layer is independent of the precise    *)
(* link association/order. lp stays abstract; the only computations are     *)
(* per-TU defmap lookups.                                                  *)
(* ====================================================================== *)
Section AllDispatchers.
  Variable lp : Clight.program.
  Hypothesis LO_air : linkorder mario_actions_airborne.prog lp.
  Hypothesis LO_mov : linkorder mario_actions_moving.prog lp.
  Hypothesis LO_sta : linkorder mario_actions_stationary.prog lp.
  Hypothesis LO_sub : linkorder mario_actions_submerged.prog lp.
  Hypothesis LO_cut : linkorder mario_actions_cutscene.prog lp.
  Hypothesis LO_aut : linkorder mario_actions_automatic.prog lp.
  Hypothesis LO_obj : linkorder mario_actions_object.prog lp.

  Theorem resolves_dispatch_airborne :
    exists b,
      Genv.find_symbol (globalenv lp)
        mario_actions_airborne._mario_execute_airborne_action = Some b /\
      Genv.find_funct_ptr (globalenv lp) b
        = Some (Internal mario_actions_airborne.f_mario_execute_airborne_action).
  Proof. eapply linkorder_resolves_internal; [ exact LO_air | vm_compute; reflexivity ]. Qed.

  Theorem resolves_dispatch_moving :
    exists b,
      Genv.find_symbol (globalenv lp)
        mario_actions_moving._mario_execute_moving_action = Some b /\
      Genv.find_funct_ptr (globalenv lp) b
        = Some (Internal mario_actions_moving.f_mario_execute_moving_action).
  Proof. eapply linkorder_resolves_internal; [ exact LO_mov | vm_compute; reflexivity ]. Qed.

  Theorem resolves_dispatch_stationary :
    exists b,
      Genv.find_symbol (globalenv lp)
        mario_actions_stationary._mario_execute_stationary_action = Some b /\
      Genv.find_funct_ptr (globalenv lp) b
        = Some (Internal mario_actions_stationary.f_mario_execute_stationary_action).
  Proof. eapply linkorder_resolves_internal; [ exact LO_sta | vm_compute; reflexivity ]. Qed.

  Theorem resolves_dispatch_submerged :
    exists b,
      Genv.find_symbol (globalenv lp)
        mario_actions_submerged._mario_execute_submerged_action = Some b /\
      Genv.find_funct_ptr (globalenv lp) b
        = Some (Internal mario_actions_submerged.f_mario_execute_submerged_action).
  Proof. eapply linkorder_resolves_internal; [ exact LO_sub | vm_compute; reflexivity ]. Qed.

  Theorem resolves_dispatch_cutscene :
    exists b,
      Genv.find_symbol (globalenv lp)
        mario_actions_cutscene._mario_execute_cutscene_action = Some b /\
      Genv.find_funct_ptr (globalenv lp) b
        = Some (Internal mario_actions_cutscene.f_mario_execute_cutscene_action).
  Proof. eapply linkorder_resolves_internal; [ exact LO_cut | vm_compute; reflexivity ]. Qed.

  Theorem resolves_dispatch_automatic :
    exists b,
      Genv.find_symbol (globalenv lp)
        mario_actions_automatic._mario_execute_automatic_action = Some b /\
      Genv.find_funct_ptr (globalenv lp) b
        = Some (Internal mario_actions_automatic.f_mario_execute_automatic_action).
  Proof. eapply linkorder_resolves_internal; [ exact LO_aut | vm_compute; reflexivity ]. Qed.

  Theorem resolves_dispatch_object :
    exists b,
      Genv.find_symbol (globalenv lp)
        mario_actions_object._mario_execute_object_action = Some b /\
      Genv.find_funct_ptr (globalenv lp) b
        = Some (Internal mario_actions_object.f_mario_execute_object_action).
  Proof. eapply linkorder_resolves_internal; [ exact LO_obj | vm_compute; reflexivity ]. Qed.

End AllDispatchers.

(* ====================================================================== *)
(* RE-ROOTING INTERFACE, PART 2: COMPOSITE-ENV PRESERVATION.               *)
(*                                                                        *)
(* Part 1 (above) is FUNCALL resolution: a dispatcher Scall over          *)
(* globalenv lp hits the real Internal body (linkorder_resolves_funct).    *)
(* Part 2 is the OTHER thing the frame engine consumes from its genv: the  *)
(* COMPOSITE ENVIRONMENT, used to compute field offsets (RealFrameValue's   *)
(* cenv_eq rewrites genv_cenv mario_ge -> mario_ce, where field_offset is   *)
(* a cheap lookup giving action@12, marioObj@..). Over globalenv lp the     *)
(* composite env is the MERGED prog_comp_env lp -- NOT mario_ce -- so       *)
(* cenv_eq's *equality* is FALSE at lp. What IS true, and is all the engine *)
(* actually needs, is that the field OFFSETS agree: linking never moves     *)
(* Mario's fields. That is exactly CompCert's field_offset_stable applied   *)
(* to the composite-preservation conjunct that linkorder_program carries.   *)
(* This is the soundness crux of re-rooting: if linking could relocate the  *)
(* action cell, the whole no-fly argument would be about the wrong byte.    *)
(* lp stays ABSTRACT; the only computation is over mario.prog's OWN cenv.   *)
(* ====================================================================== *)

(* The composite-preservation half of linkorder_program (Clight programs):
   every composite a TU q defines is present, VERBATIM, in any lp >= q. This
   is the second conjunct of linkorder_program -- exposed by unfolding the
   (opaque) Clight Linker instance, exactly as the resolution primitive does
   for the AST half. *)
Lemma linkorder_comp_env_extends :
  forall (lp q : Clight.program) id co,
    linkorder q lp ->
    (prog_comp_env q) ! id = Some co ->
    (prog_comp_env lp) ! id = Some co.
Proof.
  intros lp q id co LOq Hco.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LOq.
  destruct LOq as [_ Hext]. apply Hext. exact Hco.
Qed.

(* THE FIELD-OFFSET AGREEMENT (generic, reusable for every linked TU): for any
   members list complete in q's own composite env, the offset computed in the
   merged genv lp EQUALS the one computed in q's cenv. Pure CompCert metatheory
   (field_offset_stable) fed by composite preservation -- lp opaque. This is the
   lemma that lets a re-rooted engine keep using mario_ce's cheap concrete
   offsets even though its genv is now globalenv lp. *)
Lemma linkorder_field_offset_agree :
  forall (lp q : Clight.program) f ms,
    linkorder q lp ->
    complete_members (prog_comp_env q) ms = true ->
    field_offset (prog_comp_env lp) f ms = field_offset (prog_comp_env q) f ms.
Proof.
  intros lp q f ms LOq Hcomp.
  eapply field_offset_stable; [ | exact Hcomp ].
  intros id co Hco. eapply linkorder_comp_env_extends; eauto.
Qed.

(* --- The concrete headline, instantiated at Mario's action field. --- *)

(* Mario's MarioState members, straight from mario.c's OWN composite env. *)
Definition mario_state_members : members :=
  match (prog_comp_env mario.prog) ! mario._MarioState with
  | Some co => co_members co
  | None => nil
  end.

Lemma mario_state_members_complete :
  complete_members (prog_comp_env mario.prog) mario_state_members = true.
Proof. vm_compute. reflexivity. Qed.

Lemma mario_action_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._action mario_state_members
    = Errors.OK (12, Full).
Proof. vm_compute. reflexivity. Qed.

(* HEADLINE: linking the action TUs does NOT move Mario's action field. Over
   ANY linked program lp >= mario.prog, the action cell stays at byte offset 12 --
   the very cell mem_flying / the no-fly theorem reads. Re-rooting the engine at
   globalenv lp is therefore offset-faithful: it still reasons about offset 12. *)
Lemma linking_preserves_action_offset :
  forall lp, linkorder mario.prog lp ->
    field_offset (prog_comp_env lp) mario._action mario_state_members
      = Errors.OK (12, Full).
Proof.
  intros lp Hlo.
  rewrite (linkorder_field_offset_agree lp mario.prog mario._action
             mario_state_members Hlo mario_state_members_complete).
  exact mario_action_offset_concrete.
Qed.

(* ====================================================================== *)
(* RE-ROOTING INTERFACE, PART 3: SYMBOL PRESERVATION.                      *)
(*                                                                        *)
(* The THIRD and last thing the frame engine reads from its genv: symbol  *)
(* addresses (find_symbol gMarioState -- the root of the Mario pointer     *)
(* chase the eval bricks evaluate). Every symbol a TU q DEFINES survives    *)
(* into lp's genv (with SOME block; the carried *_wf invariants abstract    *)
(* the exact block, so identity isn't needed -- existence is). Same AST     *)
(* metatheory as the funcall primitive, stopping at find_symbol. With this, *)
(* all three genv-consumed quantities -- funcalls (part 1), field offsets   *)
(* (part 2), symbols (part 3) -- are proved preserved by linking, lp        *)
(* abstract: the complete interface a re-rooted engine needs from lp.       *)
(* ====================================================================== *)

Lemma linkorder_resolves_symbol :
  forall (lp q : Clight.program) (id : ident) (gd : globdef (Ctypes.fundef Clight.function) type),
    linkorder q lp ->
    (prog_defmap q) ! id = Some gd ->
    exists b, Genv.find_symbol (globalenv lp) id = Some b.
Proof.
  intros lp q id gd LOq Hdm.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LOq.
  destruct LOq as [LOast _Hcomp].
  destruct (prog_defmap_linkorder _ _ _ _ LOast Hdm) as (gd' & Hgd' & _Hlo).
  apply (proj1 (Genv.find_def_symbol _ _ _)) in Hgd'.
  destruct Hgd' as (b & Hsym & _). exists b. exact Hsym.
Qed.

(* Concrete: gMarioState (a defined, uninitialized gvar in mario.c -- the global
   pointer the eval bricks read) resolves to SOME block in any lp >= mario.prog.
   So the re-rooted gMarioState_wf invariant is satisfiable over globalenv lp. *)
Lemma mario_defines_gMarioState :
  exists gd, (prog_defmap mario.prog) ! mario._gMarioState = Some gd.
Proof.
  destruct ((prog_defmap mario.prog) ! mario._gMarioState) as [gd|] eqn:E.
  - exists gd; reflexivity.
  - vm_compute in E; discriminate E.
Qed.

Lemma linking_resolves_gMarioState :
  forall lp, linkorder mario.prog lp ->
    exists b, Genv.find_symbol (globalenv lp) mario._gMarioState = Some b.
Proof.
  intros lp Hlo. destruct mario_defines_gMarioState as (gd & Hgd).
  eapply linkorder_resolves_symbol; eauto.
Qed.
