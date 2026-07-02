(* kept: P3 slice-1 producer (linked12 LO-pin + ext-pin derivations) AND the
   machine-checked vacuity witness capstone_negative_pin_refuted; its spine
   consumer (NoAImpliesNoFlyTwelve) is blocked on the task-#95 negative-pin
   repair. *)
(* ====================================================================== *)
(* THE TWELVE-TU LINK (SPINE: P3 slice 1, director-roadmap-2026-07-01).    *)
(*                                                                        *)
(* The MWF-grounded capstone carries 12 per-TU `linkorder` pins plus the   *)
(* negative pin Hrest_ext_only as SEPARATE hypotheses about an abstract    *)
(* lp.  This file derives ALL of them from ONE structural premise:        *)
(*                                                                        *)
(*   linked12 lp  :=  link_chain mario.prog [the 11 other TUs] = Some lp  *)
(*                                                                        *)
(* i.e. lp IS a (left-associated) CompCert link of the twelve generated   *)
(* TUs.  lp itself stays ABSTRACT -- the chain equation is a hypothesis,  *)
(* never computed (computing a whole-program link OOMs; see               *)
(* Generic/SymbolicLinking.v).  Everything is recovered from the linking  *)
(* METATHEORY:                                                            *)
(*                                                                        *)
(*  - the POSITIVE direction (link_chain_linkorder_in): every member TU is*)
(*    linkorder <= lp, via link_linkorder + linkorder_trans.  Discharges  *)
(*    the capstone's LO_mario/LO_sta/.../LO_stp pins.                     *)
(*  - the NEGATIVE direction (link_chain_internal_origin): an Internal    *)
(*    resolution IN lp must originate as an Internal definition in ONE of *)
(*    the twelve TUs (link_fundef can only produce Internal from a side's *)
(*    Internal), via link_prog_inv + PTree.gcombine.  The twelve cheap    *)
(*    per-TU defmap checks (no_internal_ids, vm_compute) prove the pin    *)
(*    for SIXTEEN of the seventeen whitelist ids (linked12_ext_pin) --    *)
(*    and REFUTE it for the seventeenth: vec3f_find_ceil is Internal in   *)
(*    mario.prog, so the capstone's Hrest_ext_only AS STATED is false     *)
(*    for every twelve-TU link (capstone_negative_pin_refuted): the live  *)
(*    real_mwf capstone is VACUOUS until that pin is repaired.  THE       *)
(*    machine-checked vacuity finding of 2026-07-02.                      *)
(*                                                                        *)
(* NON-VACUITY (stated honestly): this file does NOT prove that the       *)
(* twelve TUs actually link (that `linked12` is inhabited).  That is the  *)
(* separate P3 satisfiability question -- dischargeable via               *)
(* link_prog_succeeds-style pairwise checks or an offline big-RAM         *)
(* computation.  What this file changes is the KIND of assumption: 13     *)
(* abstract properties of lp collapse into: lp is a link of THE twelve    *)
(* mechanically-generated TUs.                                             *)
(*                                                                        *)
(* WL_exempt is NOT derivable here: its `forall e` admits local envs that *)
(* shadow a function identifier, an env-hygiene fact about runs, not a    *)
(* link-time fact.  It stays on the capstone (same trust bucket as        *)
(* Hglob_valid).                                                          *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight Linking.
From SM64.Generated Require mario mario_actions_stationary
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_cutscene mario_actions_automatic mario_actions_object
  interaction behavior_actions level_update mario_step.
From SM64.Proofs Require Import SymbolicLinking CensusV2 RealFrameLinked
  EngineV2Consumer.

Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* The chain.                                                              *)
(* ---------------------------------------------------------------------- *)

Fixpoint link_chain (p : Clight.program) (l : list Clight.program)
  : option Clight.program :=
  match l with
  | nil => Some p
  | q :: l' =>
      match link p q with
      | Some pq => link_chain pq l'
      | None => None
      end
  end.

(* the eleven non-mario TUs, in the capstone's LO_* order *)
Definition tu_rest : list Clight.program :=
  [ mario_actions_stationary.prog;
    mario_actions_moving.prog;
    mario_actions_airborne.prog;
    mario_actions_submerged.prog;
    mario_actions_cutscene.prog;
    mario_actions_automatic.prog;
    mario_actions_object.prog;
    interaction.prog;
    behavior_actions.prog;
    level_update.prog;
    mario_step.prog ].

Definition linked12 (lp : Clight.program) : Prop :=
  link_chain mario.prog tu_rest = Some lp.

(* ---------------------------------------------------------------------- *)
(* Positive direction: every member TU is linkorder <= lp.                 *)
(* ---------------------------------------------------------------------- *)

Lemma link_chain_linkorder_base :
  forall l p lp, link_chain p l = Some lp -> linkorder p lp.
Proof.
  induction l as [| q l IH]; intros p lp Hc; cbn in Hc.
  - injection Hc as <-. apply linkorder_refl.
  - destruct (link p q) as [pq |] eqn:Hpq; [| discriminate].
    apply linkorder_trans with pq.
    + exact (proj1 (link_linkorder _ _ _ Hpq)).
    + exact (IH _ _ Hc).
Qed.

Lemma link_chain_linkorder_in :
  forall l p lp q, In q l -> link_chain p l = Some lp -> linkorder q lp.
Proof.
  induction l as [| r l IH]; intros p lp q Hin Hc; cbn in Hc.
  - destruct Hin.
  - destruct (link p r) as [pr |] eqn:Hpr; [| discriminate].
    destruct Hin as [-> | Hin].
    + apply linkorder_trans with pr.
      * exact (proj2 (link_linkorder _ _ _ Hpr)).
      * exact (link_chain_linkorder_base _ _ _ Hc).
    + exact (IH _ _ _ Hin Hc).
Qed.

Section Linked12LO.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.

  Lemma linked12_LO_mario : linkorder mario.prog lp.
  Proof. exact (link_chain_linkorder_base _ _ _ H12). Qed.

  Lemma linked12_LO_sta : linkorder mario_actions_stationary.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_eq _ _) H12).
  Qed.
  Lemma linked12_LO_mov : linkorder mario_actions_moving.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_eq _ _)) H12).
  Qed.
  Lemma linked12_LO_air : linkorder mario_actions_airborne.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _))) H12).
  Qed.
  Lemma linked12_LO_sub : linkorder mario_actions_submerged.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _)))) H12).
  Qed.
  Lemma linked12_LO_cut : linkorder mario_actions_cutscene.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _))))) H12).
  Qed.
  Lemma linked12_LO_aut : linkorder mario_actions_automatic.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _)))))) H12).
  Qed.
  Lemma linked12_LO_obj : linkorder mario_actions_object.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _))))))) H12).
  Qed.
  Lemma linked12_LO_int : linkorder interaction.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _)))))))) H12).
  Qed.
  Lemma linked12_LO_beh : linkorder behavior_actions.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _))))))))) H12).
  Qed.
  Lemma linked12_LO_lvl : linkorder level_update.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _)))))))))) H12).
  Qed.
  Lemma linked12_LO_stp : linkorder mario_step.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _))))))))))) H12).
  Qed.
End Linked12LO.

(* ---------------------------------------------------------------------- *)
(* Negative direction: an Internal in the link came from one side.         *)
(* ---------------------------------------------------------------------- *)

(* one link step: an Internal entry of the linked defmap originates in     *)
(* p1's or p2's defmap.  By link_prog_inv the linked defs are the          *)
(* PTree.combine of the two defmaps under link_prog_merge, and             *)
(* link_fundef produces an Internal only from a side that is already that  *)
(* Internal (External+External links to External; Internal+Internal        *)
(* doesn't link).                                                          *)
(* the linker instances are Global Opaque (Ctypes/Linking); the analysis
   below needs their bodies for cbn/unfold -- file-locally transparent.
   GOTCHA: TWO Linker_fundef instances exist (Linking.v's for AST.fundef,
   Ctypes.v's for Ctypes.fundef) and Linking shadows Ctypes in this file's
   import order -- the Clight globdefs use CTYPES's, so qualify it. *)
Local Transparent Ctypes.Linker_fundef Linker_program Linker_prog Linker_def
  Linker_vardef Linker_varinit.

Lemma link_program_internal_origin :
  forall (p1 p2 p : Clight.program) (fid : ident) (f : Clight.function),
    link p1 p2 = Some p ->
    (prog_defmap p) ! fid = Some (Gfun (Internal f)) ->
    (prog_defmap p1) ! fid = Some (Gfun (Internal f)) \/
    (prog_defmap p2) ! fid = Some (Gfun (Internal f)).
Proof.
  intros p1 p2 p fid f Hlink Hdm.
  Local Transparent Linker_program.
  unfold link, Linker_program, link_program in Hlink.
  destruct (link (program_of_program p1) (program_of_program p2))
    as [p0 |] eqn:HLP; [| discriminate].
  destruct (lift_option (link (prog_types p1) (prog_types p2)))
    as [[typs EQ] | ]; [| discriminate].
  destruct (link_build_composite_env (prog_types p1) (prog_types p2) typs
              (prog_comp_env p1) (prog_comp_env p2)
              (prog_comp_env_eq p1) (prog_comp_env_eq p2) EQ)
    as [env [P Q]].
  injection Hlink as <-.
  (* the Clight-level defmap of the built record IS p0's defmap -- by
     kernel conversion (prog_defs of the built record projects to
     AST.prog_defs p0), no tactic-level unfolding needed *)
  assert (Hdm0 : (prog_defmap p0) ! fid = Some (Gfun (Internal f)))
    by exact Hdm.
  clear Hdm.
  (* now decompose the AST-level link p0 *)
  Local Transparent Linker_prog.
  unfold link, Linker_prog in HLP.
  apply link_prog_inv in HLP.
  destruct HLP as (_ & _ & ->).
  rewrite prog_defmap_elements in Hdm0.
  rewrite PTree.gcombine in Hdm0 by reflexivity.
  unfold link_prog_merge in Hdm0.
  rename Hdm0 into Hdm.
  destruct ((prog_defmap (program_of_program p1)) ! fid) as [gd1 |] eqn:H1;
    destruct ((prog_defmap (program_of_program p2)) ! fid) as [gd2 |] eqn:H2.
  - (* both sides: link_def analysis.  All scrutinees become constructors
       after the destructs and every argument is a variable, so cbn fully
       iota-reduces the (Transparent'd) instance projections safely. *)
    destruct gd1 as [fd1 | v1]; destruct gd2 as [fd2 | v2];
      try (cbn in Hdm; discriminate).
    + (* Gfun/Gfun: link_fundef *)
      destruct fd1 as [f1 | ef1 targs1 tres1 cc1];
        destruct fd2 as [f2 | ef2 targs2 tres2 cc2].
      * cbn in Hdm; discriminate.
      * (* Internal/External: survives only for EF_external, as fd1.
           NOTE the destruct..eqn:H1 above generalized the defmap lookup
           in the CONCLUSION too (destruct-rewrites-hypotheses), so the
           left disjunct is literally Hdm's statement. *)
        destruct ef2; cbn in Hdm; try discriminate.
        left. exact Hdm.
      * (* External/Internal: survives only for EF_external, as fd2 *)
        destruct ef1; cbn in Hdm; try discriminate.
        right. exact Hdm.
      * (* External/External: links to an External, never Internal *)
        cbn in Hdm.
        destruct (external_function_eq ef1 ef2 && typelist_eq targs1 targs2 &&
                  type_eq tres1 tres2 && calling_convention_eq cc1 cc2);
          cbn in Hdm; discriminate.
    + (* Gvar/Gvar: links to a Gvar, never Gfun.  Extract the vardef-link
         scrutinee SYNTACTICALLY from Hdm (naming it via `destruct (link
         v1 v2)` re-elaborates the typeclass instance and can pick a
         different one, leaving Hdm untouched). *)
      cbn in Hdm.
      match type of Hdm with
      | context [match ?X with Some _ => _ | None => _ end] => destruct X
      end; cbn in Hdm; discriminate.
  - (* left only: the merge is Some gd1 itself *)
    left. exact Hdm.
  - (* right only *)
    right. exact Hdm.
  - discriminate.
Qed.

(* restore opacity: downstream lemmas' cbn/destruct must see the same
   stuck `link p q` projection form the pre-Transparent lemmas saw. *)
Local Opaque Ctypes.Linker_fundef Linker_program Linker_prog Linker_def
  Linker_vardef Linker_varinit.

(* the whole chain: an Internal in lp originates in the base or a member. *)
Lemma link_chain_internal_origin :
  forall l (p lp : Clight.program) (fid : ident) (f : Clight.function),
    link_chain p l = Some lp ->
    (prog_defmap lp) ! fid = Some (Gfun (Internal f)) ->
    (prog_defmap p) ! fid = Some (Gfun (Internal f)) \/
    (exists q, In q l /\ (prog_defmap q) ! fid = Some (Gfun (Internal f))).
Proof.
  induction l as [| r l IH]; intros p lp fid f Hc Hdm; cbn in Hc.
  - injection Hc as <-. left. exact Hdm.
  - destruct (link p r) as [pr |] eqn:Hpr; [| discriminate].
    destruct (IH _ _ _ _ Hc Hdm) as [Hpr' | (q & Hq & Hqdm)].
    + destruct (link_program_internal_origin _ _ _ _ _ Hpr Hpr')
        as [Hp | Hr].
      * left. exact Hp.
      * right. exists r. split; [left; reflexivity | exact Hr].
    + right. exists q. split; [right; exact Hq | exact Hqdm].
Qed.

(* ---------------------------------------------------------------------- *)
(* The decidable per-TU check + the exempt-whitelist discharge.            *)
(* ---------------------------------------------------------------------- *)

(* boolean: program p defines NO ident of l as an Internal function *)
Definition no_internal_ids (p : Clight.program) (l : list ident) : bool :=
  forallb (fun fid =>
             match (prog_defmap p) ! fid with
             | Some (Gfun (Internal _)) => false
             | _ => true
             end) l.

Lemma no_internal_ids_correct :
  forall p l fid f,
    no_internal_ids p l = true ->
    mem_id fid l = true ->
    (prog_defmap p) ! fid <> Some (Gfun (Internal f)).
Proof.
  intros p l fid f Hall Hmem Hdm.
  unfold no_internal_ids in Hall.
  rewrite forallb_forall in Hall.
  unfold mem_id in Hmem.
  apply existsb_exists in Hmem.
  destruct Hmem as (fid' & Hin & Heq).
  apply Pos.eqb_eq in Heq. subst fid'.
  specialize (Hall fid Hin).
  rewrite Hdm in Hall. discriminate.
Qed.

(* THE VACUITY FINDING (2026-07-02).  The capstone's negative pin
   Hrest_ext_only ranges over ALL of exempt_callees + the music helper.
   But vec3f_find_ceil is an INTERNAL function of mario.prog itself
   (vendor/sm64/src/game/mario.c:547, generated/mario.v f_vec3f_find_ceil)
   -- so LO_mario forces an Internal resolution into lp and the pin as
   stated is REFUTABLE (capstone_negative_pin_refuted below): the live
   real_mwf capstone's hypothesis set is JOINTLY UNSATISFIABLE for the
   intended link.  RestSurface's "checked: no Definition f_<sym> anywhere
   under generated/" claim was wrong for this one symbol.  The repair
   (route vec3f_find_ceil through a pinned 13th rest case with a gated,
   non-phantom obligation) is tracked as the top follow-up task; until
   then this file proves the pin for the SIXTEEN genuinely-external ids
   (truly_ext_pin_ids). *)
Definition truly_ext_pin_ids : list ident :=
  mario._play_infinite_stairs_music
    :: filter (fun i => negb (Pos.eqb i mario._vec3f_find_ceil))
         exempt_callees.

(* the twelve cheap computations (each a per-TU defmap sweep) *)
Lemma no_internal_mario :
  no_internal_ids mario.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma no_internal_sta :
  no_internal_ids mario_actions_stationary.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma no_internal_mov :
  no_internal_ids mario_actions_moving.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma no_internal_air :
  no_internal_ids mario_actions_airborne.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma no_internal_sub :
  no_internal_ids mario_actions_submerged.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma no_internal_cut :
  no_internal_ids mario_actions_cutscene.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma no_internal_aut :
  no_internal_ids mario_actions_automatic.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma no_internal_obj :
  no_internal_ids mario_actions_object.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma no_internal_int :
  no_internal_ids interaction.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma no_internal_beh :
  no_internal_ids behavior_actions.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma no_internal_lvl :
  no_internal_ids level_update.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma no_internal_stp :
  no_internal_ids mario_step.prog truly_ext_pin_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* resolves_lp -> defmap entry (the genv->defmap bridge, spike-style) *)
Lemma resolves_defmap :
  forall (lp : Clight.program) (fid : ident) (fd : Clight.fundef),
    resolves_lp lp fid fd ->
    (prog_defmap lp) ! fid = Some (Gfun fd).
Proof.
  intros lp fid fd (b & Hsym & Hff).
  rewrite Genv.find_funct_find_funct_ptr in Hff.
  apply (proj2 (Genv.find_def_symbol _ _ _)).
  exists b. split.
  - exact Hsym.
  - apply (proj1 (Genv.find_funct_ptr_iff _ _ _)). exact Hff.
Qed.

(* the pin, PROVED for the sixteen genuinely-external ids: none of them
   has an Internal body in ANY of the twelve TUs, so none resolves
   Internal in any twelve-TU link. *)
Theorem linked12_ext_pin :
  forall lp, linked12 lp ->
  forall (fid : ident) (f : Clight.function),
    mem_id fid truly_ext_pin_ids = true ->
    ~ resolves_lp lp fid (Internal f).
Proof.
  intros lp H12 fid f Hmem Hres.
  apply resolves_defmap in Hres.
  destruct (link_chain_internal_origin _ _ _ _ _ H12 Hres)
    as [Hbase | (q & Hq & Hqdm)].
  - exact (no_internal_ids_correct _ _ _ _ no_internal_mario Hmem Hbase).
  - destruct Hq as [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]]]]]].
    + exact (no_internal_ids_correct _ _ _ _ no_internal_sta Hmem Hqdm).
    + exact (no_internal_ids_correct _ _ _ _ no_internal_mov Hmem Hqdm).
    + exact (no_internal_ids_correct _ _ _ _ no_internal_air Hmem Hqdm).
    + exact (no_internal_ids_correct _ _ _ _ no_internal_sub Hmem Hqdm).
    + exact (no_internal_ids_correct _ _ _ _ no_internal_cut Hmem Hqdm).
    + exact (no_internal_ids_correct _ _ _ _ no_internal_aut Hmem Hqdm).
    + exact (no_internal_ids_correct _ _ _ _ no_internal_obj Hmem Hqdm).
    + exact (no_internal_ids_correct _ _ _ _ no_internal_int Hmem Hqdm).
    + exact (no_internal_ids_correct _ _ _ _ no_internal_beh Hmem Hqdm).
    + exact (no_internal_ids_correct _ _ _ _ no_internal_lvl Hmem Hqdm).
    + exact (no_internal_ids_correct _ _ _ _ no_internal_stp Hmem Hqdm).
Qed.

(* ---------------------------------------------------------------------- *)
(* THE VACUITY WITNESS: the capstone's Hrest_ext_only, AS STATED, is       *)
(* FALSE for every twelve-TU link -- mario.prog itself defines             *)
(* vec3f_find_ceil internally, and linkorder forces that body into lp.     *)
(* Consequence: the live real_mwf capstone's hypothesis set (LO_mario +    *)
(* Hrest_ext_only) is jointly unsatisfiable for the intended link, i.e.   *)
(* the theorem is VACUOUS until the pin is repaired.                       *)
(* ---------------------------------------------------------------------- *)

Lemma mario_defmap_vfc :
  (prog_defmap mario.prog) ! mario._vec3f_find_ceil
    = Some (Gfun (Internal mario.f_vec3f_find_ceil)).
Proof. vm_compute. reflexivity. Qed.

Lemma vfc_in_exempt :
  mem_id mario._vec3f_find_ceil exempt_callees = true.
Proof. vm_compute. reflexivity. Qed.

Theorem capstone_negative_pin_refuted :
  forall lp, linked12 lp ->
    ~ (forall (fid : ident) (f : Clight.function),
         mem_id fid exempt_callees = true \/
         fid = mario._play_infinite_stairs_music ->
         ~ resolves_lp lp fid (Internal f)).
Proof.
  intros lp H12 Hpin.
  destruct (linkorder_resolves_funct lp mario.prog mario._vec3f_find_ceil
              mario.f_vec3f_find_ceil (linked12_LO_mario lp H12)
              mario_defmap_vfc)
    as (b & Hsym & Hff).
  apply (Hpin mario._vec3f_find_ceil mario.f_vec3f_find_ceil
           (or_introl vfc_in_exempt)).
  exists b. split.
  - exact Hsym.
  - rewrite Genv.find_funct_find_funct_ptr. exact Hff.
Qed.
