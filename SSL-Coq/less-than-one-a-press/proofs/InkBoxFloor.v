(** A frozen carry command stops collision regeneration; it does not erase
    triangles that were already loaded. These are executions of generated JP
    statements, with the exact post-address-translation clone cut exposed.
    They are not a controller-history or complete object-scheduler theorem. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import jp_behavior_data
  jp_behavior_script jp_memory jp_object_helpers.
From LessThanOneAPress.Proofs Require Import GameTypes ASTFacts
  TeleporterHeldOwnership InkBuddyMovement InkCopyCaller
  ObjectContactNecessity ObjectContactReadback ContactConsumerExecution
  Area2Rank10AStallSources CleanedClightPrograms ClightLinkExecution
  JPWarpLevelEntryResolution LinkedClightPrograms SelectedClightTarget
  SecretContactExecution.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.
Module BF := jp_behavior_script.
Module BD := jp_behavior_data.
Module BM := jp_memory.

(** Actual initializer words: BEGIN(OBJ_LIST_DEFAULT), BREAK. None requests a
    callback. A native large-box loop, in contrast, names the loader. *)
Definition IBFScriptSource : Prop :=
  gvar_init BD.v_bhvCarrySomething3 =
    [Init_int32 (Int.repr 524288); Init_int32 (Int.repr 167772160)] /\
  gvar_init BD.v_bhvCarrySomething4 = gvar_init BD.v_bhvCarrySomething3 /\
  gvar_init BD.v_bhvCarrySomething5 = gvar_init BD.v_bhvCarrySomething3 /\
  nth_error (gvar_init BD.v_bhvBreakableBox) 1 =
    Some (Init_int32 (Int.repr 285278209)) /\
  Int.and (Int.repr 285278209) (Int.repr 1024) = Int.zero /\
  initializer_list_mentions_addrof BD._load_object_collision_model
    (gvar_init BD.v_bhvBreakableBox) = true.
Theorem ibf_scripts_checked : IBFScriptSource.
Proof. vm_compute; repeat split; reflexivity. Qed.

Lemma ibf_jp_break_source :
  (prog_defmap (nlist_at 14 jp_cleaned_units)) ! BF._bhv_cmd_break =
    Some (Gfun (Internal BF.f_bhv_cmd_break)).
Proof. vm_compute; reflexivity. Qed.
Local Transparent selected_clight_target.
Theorem ibf_selected_break_resolves : exists b,
  Genv.find_symbol (tho_ge VersionJP) BF._bhv_cmd_break = Some b /\
  Genv.find_funct_ptr (tho_ge VersionJP) b = Some (Internal BF.f_bhv_cmd_break).
Proof.
  unfold tho_ge, selected_clight_target.
  eapply (official_link_resolves_internal_globalenv jp_cleaned_units
    jp_official_cleaned_slice jp_cleaned_units_official_link (nlist_at 14 jp_cleaned_units)
    BF._bhv_cmd_break BF.f_bhv_cmd_break).
  - exact (nlist_at_nIn _ 14 jp_cleaned_units).
  - exact ibf_jp_break_source.
Qed.
Local Opaque selected_clight_target.

Definition IBFBreakExecutes : Prop := forall memory,
  ClightBigstep.Clight2.eval_funcall (tho_ge VersionJP) memory
    (Internal BF.f_bhv_cmd_break) [] E0 memory (Vint Int.one).
Theorem ibf_break_executes_without_erasing_memory : IBFBreakExecutes.
Proof.
  intro memory. eapply eval_funcall_internal with (e := empty_env)
    (le1 := PTree.empty val) (le2 := PTree.empty val)
    (m1 := memory) (m2 := memory)
    (out := Out_return (Some (Vint Int.one, tint))).
  - eapply function_entry2_intro; cbn [BF.f_bhv_cmd_break fn_vars fn_params fn_temps var_names]; try constructor; try reflexivity; unfold Coqlib.list_disjoint; tauto.
  - apply exec_Sreturn_some. constructor.
  - split; [discriminate|reflexivity].
  - reflexivity.
Qed.

Definition IBFBreakExact : Prop := forall memory trace after result,
  ClightBigstep.Clight2.eval_funcall (tho_ge VersionJP) memory
    (Internal BF.f_bhv_cmd_break) [] trace after result ->
  trace = E0 /\ after = memory /\ result = Vint Int.one.
Theorem ibf_every_break_preserves_memory : IBFBreakExact.
Proof.
  intros memory trace after result Hcall. inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion Hentry; subst; clear Hentry end.
  match goal with Halloc : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [BF.f_bhv_cmd_break fn_vars] in Halloc; inversion Halloc; subst end.
  match goal with Hbody : ClightBigstep.exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbn [BF.f_bhv_cmd_break fn_body] in Hbody; inversion Hbody; subst end.
  match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) ?v |- _ =>
    assert (v = Vint Int.one) by (eapply ocr_expr_unique; [exact Hv|constructor]); subst v end.
  match goal with Hfree : Mem.free_list ?before (blocks_of_env _ empty_env) = Some ?last |- _ =>
    change (Some before = Some last) in Hfree; inversion Hfree; subst end.
  match goal with Hr : outcome_result_value _ _ _ _ |- _ => destruct Hr as [_ Hcast]; cbn in Hcast; inversion Hcast; subst result end.
  repeat split; reflexivity.
Qed.

Lemma ibf_translation_readonly :
  cce_readonly_keep BM._addr (fn_body BM.f_segmented_to_virtual) = true.
Proof. reflexivity. Qed.
Theorem ibf_segment_translation_preserves_memory : forall ge before args trace after result,
  ClightBigstep.Clight2.eval_funcall ge before
    (Internal BM.f_segmented_to_virtual) args trace after result ->
  trace = E0 /\ after = before.
Proof.
  intros ge before args trace after result Hcall. inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion Hentry; subst; clear Hentry end.
  match goal with Halloc : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [BM.f_segmented_to_virtual fn_vars] in Halloc; inversion Halloc; subst end.
  match goal with Hbody : ClightBigstep.exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (cce_readonly_frame _ _ _ _ _ _ _ _ _ _ Hbody ibf_translation_readonly)
      as (-> & -> & _) end.
  match goal with Hfree : Mem.free_list ?body (blocks_of_env _ empty_env) = Some ?last |- _ =>
    change (Some body = Some last) in Hfree; inversion Hfree; subst end.
  split; reflexivity.
Qed.

Definition ibf_command_field := Efield tho_object THO._curBhvCommand (tptr tuint).
Definition ibf_stack_field := Efield tho_object THO._bhvStackIndex tuint.
Definition ibf_clone_tail := Ssequence
  (Sassign ibf_command_field (Etempvar THO._t'1 (tptr tvoid)))
  (Sassign ibf_stack_field (Econst_int Int.zero tint)).
Definition ibf_translation_call := Scall (Some THO._t'1)
  (Evar THO._segmented_to_virtual (Tfunction [tptr tvoid] (tptr tvoid) cc_default))
  [Etempvar THO._heldBehavior (tptr tuint)].
Lemma ibf_clone_tail_is_generated :
  tho_nonholdable VersionJP = Ssequence
    (Ssequence ibf_translation_call
      (Sassign ibf_command_field (Etempvar THO._t'1 (tptr tvoid))))
    (Sassign ibf_stack_field (Econst_int Int.zero tint)).
Proof. reflexivity. Qed.

Lemma ibf_clone_field_location : forall e le memory ob oo field ty delta,
  le ! THO._obj = Some (Vptr ob oo) ->
  ibcc_field_ok (tho_ge VersionJP) THO._Object field delta = true ->
  eval_lvalue (tho_ge VersionJP) e le memory (Efield tho_object field ty)
    ob (Ptrofs.add oo (Ptrofs.repr delta)) Full.
Proof.
  intros e le memory ob oo field ty delta Hobj Hlayout.
  destruct (ibcc_field_ok_sound _ _ _ _ Hlayout) as (co & Hco & Hoff).
  unfold tho_object. eapply eval_Efield_struct with (co := co).
  - eapply eval_Elvalue.
    + apply eval_Ederef. apply eval_Etempvar. exact Hobj.
    + apply deref_loc_copy. reflexivity.
  - reflexivity.
  - exact Hco.
  - exact Hoff.
Qed.

Definition ibf_tail_inputs le memory ob oo script : Prop :=
  le ! THO._obj = Some (Vptr ob oo) /\
  le ! THO._t'1 = Some script /\
  Mem.valid_access memory Mint32 ob (tho_address oo 460) Writable /\
  Mem.valid_access memory Mint32 ob (tho_address oo 464) Writable /\
  (exists sb so, script = Vptr sb so).

Lemma ibf_clone_tail_path : forall le before ob oo script,
  ibf_tail_inputs le before ob oo script ->
  exists middle after,
    Mem.store Mint32 before ob (tho_address oo 460) script = Some middle /\
    Mem.store Mint32 middle ob (tho_address oo 464) (Vint Int.zero) = Some after /\
    tho_path (tho_ge VersionJP) empty_env le before ibf_clone_tail le after.
Proof.
  intros le before ob oo script (Hobj & Hscript & Hw1 & Hw2 & Hpointer).
  destruct (Mem.valid_access_store _ _ _ _ script Hw1) as (middle & Hs1).
  assert (Mem.valid_access middle Mint32 ob (tho_address oo 464) Writable) as Hwm
    by (eapply Mem.store_valid_access_1; eauto).
  destruct (Mem.valid_access_store _ _ _ _ (Vint Int.zero) Hwm) as (after & Hs2).
  exists middle, after. split; [exact Hs1|]. split; [exact Hs2|].
  unfold ibf_clone_tail. eapply tho_seq.
  - eapply tho_assign with (value := script) (cast := script).
    + reflexivity.
    + apply ibf_clone_field_location; [exact Hobj|exact (proj1 (ibm_buddy_layout VersionJP))].
    + apply eval_Etempvar. exact Hscript.
    + destruct Hpointer as (sb & so & ->); reflexivity.
    + exact Hs1.
  - eapply tho_assign with (value := Vint Int.zero) (cast := Vint Int.zero).
    + reflexivity.
    + apply ibf_clone_field_location; [exact Hobj|exact (proj2 (ibm_buddy_layout VersionJP))].
    + constructor.
    + reflexivity.
    + exact Hs2.
Qed.

(** This actual post-translation cut is constructive: no effect predicate is
    assumed. It proves that a loaded triangle/partition cell in a distinct
    allocation block survives the script replacement. Same-block object data
    needs the corresponding nonoverlap fact, not a claim that all objects freeze. *)
Definition IBFCloneTailPreservesOtherBlocks : Prop :=
  forall le before ob oo script block offset chunk,
  ibf_tail_inputs le before ob oo script -> block <> ob ->
  exists after,
    ocn_exec (tho_ge VersionJP) empty_env le before ibf_clone_tail E0 le after Out_normal /\
    (forall trace final actual out,
      ocn_exec (tho_ge VersionJP) empty_env le before ibf_clone_tail trace final actual out ->
      trace = E0 /\ actual = after /\ out = Out_normal) /\
    Mem.load chunk after block offset = Mem.load chunk before block offset.
Theorem ibf_clone_tail_preserves_loaded_cells : IBFCloneTailPreservesOtherBlocks.
Proof.
  intros le before ob oo script block offset chunk Hinputs Hapart.
  destruct (ibf_clone_tail_path _ _ _ _ _ Hinputs) as (middle & after & Hs1 & Hs2 & Hpath).
  exists after. split; [apply tho_path_executes; exact Hpath|]. split.
  - intros trace final actual out Hrun.
    destruct (tho_path_forces_execution _ _ _ _ _ _ _ Hpath _ _ _ _ Hrun)
      as (-> & -> & -> & ->). repeat split; reflexivity.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2 chunk block offset)
      by (left; congruence).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1 chunk block offset)
      by (left; congruence). reflexivity.
Qed.

Definition InkBoxFloorBoundary : Prop :=
  IBFScriptSource /\ IBFBreakExecutes /\ IBFBreakExact /\
  IBFCloneTailPreservesOtherBlocks /\ Rank10TTimeStopPreservesCollisionMemory.
Theorem ibf_clone_floor_boundary_checked : InkBoxFloorBoundary.
Proof.
  split; [exact ibf_scripts_checked|].
  split; [exact ibf_break_executes_without_erasing_memory|].
  split; [exact ibf_every_break_preserves_memory|].
  split; [exact ibf_clone_tail_preserves_loaded_cells|].
  exact rank10t_time_stop_does_not_erase_collision.
Qed.
