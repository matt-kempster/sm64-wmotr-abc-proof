From Coq Require Import Bool List.
From compcert Require Import AST Clight Ctypes Linking.
From Demo.Generated Require Import
  us_bbh_level_script us_ccm_level_script us_hmc_level_script us_jrb_level_script
  us_wf_level_script us_pss_level_script us_bowser_1_level_script us_bitdw_level_script
  jp_bbh_level_script jp_ccm_level_script jp_hmc_level_script jp_jrb_level_script
  jp_wf_level_script jp_pss_level_script jp_bowser_1_level_script jp_bitdw_level_script
  us_level_scripts jp_level_scripts.
Import ListNotations.

(** This is CompCert's official AST-program linker, applied to the actual eight
    generated level-script units. It does not replace the linked result with a
    hand-written merged program or assert complete gameplay linking. *)
Fixpoint demo_fold_official_ast_links (first : AST.program Clight.fundef type)
    (rest : list Clight.program) : option (AST.program Clight.fundef type) :=
  match rest with
  | [] => Some first
  | unit :: remaining =>
      match link first (Ctypes.program_of_program unit) with
      | Some linked => demo_fold_official_ast_links linked remaining
      | None => None
      end
  end.

Definition demo_us_other_level_script_units : list Clight.program :=
  [us_ccm_level_script.prog; us_hmc_level_script.prog; us_jrb_level_script.prog;
   us_wf_level_script.prog; us_pss_level_script.prog; us_bowser_1_level_script.prog;
   us_bitdw_level_script.prog].

Definition demo_jp_other_level_script_units : list Clight.program :=
  [jp_ccm_level_script.prog; jp_hmc_level_script.prog; jp_jrb_level_script.prog;
   jp_wf_level_script.prog; jp_pss_level_script.prog; jp_bowser_1_level_script.prog;
   jp_bitdw_level_script.prog].

Definition demo_official_level_script_ast_link_us :=
  demo_fold_official_ast_links
    (Ctypes.program_of_program us_bbh_level_script.prog) demo_us_other_level_script_units.
Definition demo_official_level_script_ast_link_jp :=
  demo_fold_official_ast_links
    (Ctypes.program_of_program jp_bbh_level_script.prog) demo_jp_other_level_script_units.

Definition demo_official_ast_link_accepted (result : option (AST.program Clight.fundef type)) : bool :=
  match result with Some _ => true | None => false end.

Lemma demo_official_ast_link_accepted_sound : forall result,
  demo_official_ast_link_accepted result = true -> exists linked, result = Some linked.
Proof. intros [linked |] H; [eauto | discriminate]. Qed.

Definition demo_private_level_script_link_claim_us_jp : Prop :=
  (exists linked, demo_official_level_script_ast_link_us = Some linked) /\
  (exists linked, demo_official_level_script_ast_link_jp = Some linked).

Theorem generated_demo_private_level_script_links_us_jp :
  demo_private_level_script_link_claim_us_jp.
Proof.
  split; apply demo_official_ast_link_accepted_sound; vm_compute; reflexivity.
Qed.

Lemma demo_official_clight_link_exists_from_components : forall (p q : Clight.program),
  (exists ast, link (Ctypes.program_of_program p)
                   (Ctypes.program_of_program q) = Some ast) ->
  (exists composites, link (Ctypes.prog_types p) (Ctypes.prog_types q) = Some composites) ->
  exists linked, Ctypes.link_program p q = Some linked.
Proof.
  intros p q (ast & Hast) (composites & Hcomposites).
  unfold Ctypes.link_program. rewrite Hast.
  destruct (Ctypes.lift_option (link (Ctypes.prog_types p) (Ctypes.prog_types q)))
    as [[types Htypes] | Hnone]; [| congruence].
  destruct (Ctypes.link_build_composite_env
    (Ctypes.prog_types p) (Ctypes.prog_types q) types
    (Ctypes.prog_comp_env p) (Ctypes.prog_comp_env q)
    (Ctypes.prog_comp_env_eq p) (Ctypes.prog_comp_env_eq q) Htypes)
    as [environment Henvironment].
  destruct Henvironment. eexists. reflexivity.
Qed.

Lemma demo_option_some_sound : forall A (result : option A),
  (match result with Some _ => true | None => false end) = true ->
  exists value, result = Some value.
Proof. intros A [value |] H; [eauto | discriminate]. Qed.

Definition demo_bbh_ccm_official_clight_link_claim_us_jp : Prop :=
  (exists linked,
    Ctypes.link_program us_bbh_level_script.prog us_ccm_level_script.prog = Some linked) /\
  (exists linked,
    Ctypes.link_program jp_bbh_level_script.prog jp_ccm_level_script.prog = Some linked).

Theorem generated_demo_bbh_ccm_official_clight_links_us_jp :
  demo_bbh_ccm_official_clight_link_claim_us_jp.
Proof.
  split; apply demo_official_clight_link_exists_from_components;
    apply demo_option_some_sound; vm_compute; reflexivity.
Qed.

(** Complete source linking has additional constraints. The dispatcher unit's
    incomplete external array declaration is rejected by CompCert's strict
    variable-info linker against the actual complete BBH definition. No public
    type or readonly flag is changed by private-atom freshening. *)
Definition demo_public_bbh_declaration_link_boundary_claim_us_jp : Prop :=
  link us_level_scripts.v_level_bbh_entry us_bbh_level_script.v_level_bbh_entry = None /\
  link jp_level_scripts.v_level_bbh_entry jp_bbh_level_script.v_level_bbh_entry = None.

Theorem generated_demo_public_bbh_declaration_link_boundary_us_jp :
  demo_public_bbh_declaration_link_boundary_claim_us_jp.
Proof. split; vm_compute; reflexivity. Qed.

Definition demo_private_global_link_boundary_claim_us_jp : Prop :=
  demo_private_level_script_link_claim_us_jp /\
  demo_bbh_ccm_official_clight_link_claim_us_jp /\
  demo_public_bbh_declaration_link_boundary_claim_us_jp.

Theorem generated_demo_private_global_link_boundary_us_jp :
  demo_private_global_link_boundary_claim_us_jp.
Proof.
  exact (conj generated_demo_private_level_script_links_us_jp
    (conj generated_demo_bbh_ccm_official_clight_links_us_jp
      generated_demo_public_bbh_declaration_link_boundary_us_jp)).
Qed.
