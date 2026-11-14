(** The whole generated held-state helper writes only its object allocation.
    This covers every successful Clight call, including the non-HOLDABLE
    branch's address translation. It does not assert that a segmented native
    address is representable by a terminating CompCert call. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import InkBoxFloor GameTypes
  TeleporterHeldOwnership InkBuddyMovement InkCopyCaller
  ObjectContactNecessity ObjectContactReadback ContactConsumerExecution
  CleanedClightPrograms ClightLinkExecution JPWarpLevelEntryResolution
  LinkedClightPrograms SelectedClightTarget SecretContactExecution.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.

(** The two clone-suffix stores occupy only curBhvCommand and bhvStackIndex.
    The arbitrary observed byte interval may be in the same object block. *)
Definition ibff_tail_cell_apart (ob : block) oo block offset chunk : Prop :=
  (block <> ob \/ offset + size_chunk chunk <= tho_address oo 460 \/
    tho_address oo 460 + 4 <= offset) /\
  (block <> ob \/ offset + size_chunk chunk <= tho_address oo 464 \/
    tho_address oo 464 + 4 <= offset).

Theorem ibff_clone_suffix_preserves_disjoint_cell :
  forall le before ob oo script block offset chunk value,
  ibf_tail_inputs le before ob oo script ->
  ibff_tail_cell_apart ob oo block offset chunk ->
  Mem.load chunk before block offset = Some value ->
  exists after,
    ocn_exec (tho_ge VersionJP) empty_env le before ibf_clone_tail E0 le after Out_normal /\
    Mem.load chunk after block offset = Some value.
Proof.
  intros le before ob oo script block offset chunk value Hinputs (Hapart1 & Hapart2) Hload.
  destruct (ibf_clone_tail_path _ _ _ _ _ Hinputs) as (middle & after & Hs1 & Hs2 & Hpath).
  exists after. split; [apply tho_path_executes; exact Hpath|].
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2 chunk block offset)
    by (cbn; intuition congruence).
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1 chunk block offset)
    by (cbn; intuition congruence).
  exact Hload.
Qed.

Definition IBFCloneKeepsLoadedCell : Prop :=
  forall le before ob oo script block offset chunk value,
  ibf_tail_inputs le before ob oo script ->
  ibff_tail_cell_apart ob oo block offset chunk ->
  Mem.load chunk before block offset = Some value ->
  exists after,
    ocn_exec (tho_ge VersionJP) empty_env le before ibf_clone_tail E0 le after Out_normal /\
    Mem.load chunk after block offset = Some value.

Lemma ibff_jp_translation_source :
  (prog_defmap (nlist_at 21 jp_cleaned_units)) ! BM._segmented_to_virtual =
    Some (Gfun (Internal BM.f_segmented_to_virtual)).
Proof. vm_compute; reflexivity. Qed.
Local Transparent selected_clight_target.
Lemma ibff_selected_translation_resolves : exists b,
  Genv.find_symbol (tho_ge VersionJP) BM._segmented_to_virtual = Some b /\
  Genv.find_funct_ptr (tho_ge VersionJP) b = Some (Internal BM.f_segmented_to_virtual).
Proof.
  unfold tho_ge, selected_clight_target.
  eapply (official_link_resolves_internal_globalenv jp_cleaned_units
    jp_official_cleaned_slice jp_cleaned_units_official_link (nlist_at 21 jp_cleaned_units)
    BM._segmented_to_virtual BM.f_segmented_to_virtual).
  - exact (nlist_at_nIn _ 21 jp_cleaned_units).
  - exact ibff_jp_translation_source.
Qed.
Local Opaque selected_clight_target.

Lemma ibff_translation_call_frame_general : forall (ge : Clight.genv),
  (exists b, Genv.find_symbol ge BM._segmented_to_virtual = Some b /\
    Genv.find_funct_ptr ge b = Some (Internal BM.f_segmented_to_virtual)) ->
  forall le before trace final after out,
  ocn_exec ge empty_env le before ibf_translation_call
    trace final after out ->
  trace = E0 /\ after = before /\ final ! THO._obj = le ! THO._obj.
Proof.
  intros ge Hresolved le before trace final after out Hrun.
  unfold ibf_translation_call in Hrun. inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ => cbn in Hclass; inversion Hclass; subst end.
  destruct Hresolved as (fb & Hsymbol & Hfunction).
  match goal with Hr : eval_expr ?ge ?env ?temps ?memory (Evar ?id (Tfunction ?tys ?ret ?cc)) ?vf |- _ =>
    assert (vf = Vptr fb Ptrofs.zero) by
      (exact (sce_function_name_value ge env temps memory id tys ret cc fb vf eq_refl Hsymbol Hr));
    subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr ge fb = Some fd) in Hfind;
    rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  assert (Hframe : trace = E0 /\ after = before) by
    (eapply ibf_segment_translation_preserves_memory; eassumption).
  destruct Hframe as (-> & ->).
  repeat split; try reflexivity.
  apply PTree.gso. discriminate.
Qed.

Lemma ibff_translation_call_frame : forall le before trace final after out,
  ocn_exec (tho_ge VersionJP) empty_env le before ibf_translation_call
    trace final after out ->
  trace = E0 /\ after = before /\ final ! THO._obj = le ! THO._obj.
Proof.
  exact (ibff_translation_call_frame_general (tho_ge VersionJP)
    ibff_selected_translation_resolves).
Qed.

Inductive ibff_cell : expr -> Prop :=
| ibff_parent : ibff_cell tho_parent
| ibff_held : ibff_cell (tho_raw_word VersionJP 39)
| ibff_command : ibff_cell ibf_command_field
| ibff_stack : ibff_cell ibf_stack_field.

Lemma ibff_cell_location : forall lhs, ibff_cell lhs ->
  forall le memory ob oo, le ! THO._obj = Some (Vptr ob oo) ->
  exists offset,
    eval_lvalue (tho_ge VersionJP) empty_env le memory lhs ob offset Full /\
    access_mode (typeof lhs) = By_value Mint32.
Proof.
  intros lhs Hcell le memory ob oo Hobj. destruct Hcell.
  - eexists. split; [eapply tho_parent_location_construct; exact Hobj|reflexivity].
  - eexists. split.
    + eapply tho_raw_location_construct; [exact Hobj|right; left; reflexivity].
    + reflexivity.
  - eexists. split.
    + eapply ibf_clone_field_location; [exact Hobj|exact (proj1 (ibm_buddy_layout VersionJP))].
    + reflexivity.
  - eexists. split.
    + eapply ibf_clone_field_location; [exact Hobj|exact (proj2 (ibm_buddy_layout VersionJP))].
    + reflexivity.
Qed.

Inductive ibff_statement : statement -> Prop :=
| ibff_readonly : forall s, cce_readonly_keep THO._obj s = true -> ibff_statement s
| ibff_assign : forall lhs rhs, ibff_cell lhs -> ibff_statement (Sassign lhs rhs)
| ibff_translate : ibff_statement ibf_translation_call
| ibff_seq : forall a b, ibff_statement a -> ibff_statement b ->
    ibff_statement (Ssequence a b)
| ibff_if : forall cond yes no, ibff_statement yes -> ibff_statement no ->
    ibff_statement (Sifthenelse cond yes no).

Lemma ibff_whole_generated_helper_classified :
  ibff_statement (fn_body (tho_function VersionJP)).
Proof.
  rewrite (proj2 (proj2 (proj2 (tho_generated_shape VersionJP)))).
  rewrite ibf_clone_tail_is_generated.
  unfold tho_effects, tho_parent_assignment.
  repeat first [apply ibff_readonly; reflexivity | apply ibff_translate |
    apply ibff_seq | apply ibff_if | apply ibff_assign; constructor].
Qed.

Definition ibff_other_block_loads before after ob : Prop :=
  forall block offset chunk, block <> ob ->
  Mem.load chunk after block offset = Mem.load chunk before block offset.

Lemma ibff_statement_frame : forall s, ibff_statement s ->
  forall le before trace final after out ob oo,
  le ! THO._obj = Some (Vptr ob oo) ->
  ocn_exec (tho_ge VersionJP) empty_env le before s trace final after out ->
  trace = E0 /\ final ! THO._obj = le ! THO._obj /\
  ibff_other_block_loads before after ob.
Proof.
  intros s Hshape. induction Hshape;
    intros le before trace final after out ob oo Hobj Hrun.
  - destruct (cce_readonly_frame _ _ _ _ _ _ _ _ _ _ Hrun H) as (-> & -> & Hkeep).
    repeat split; auto.
  - destruct (ibff_cell_location lhs H le before ob oo Hobj) as (offset & Hloc & Hmode).
    inversion Hrun; subst.
    match goal with Ha : assign_loc _ _ _ ?b ?ofs ?bf _ _ |- _ =>
      assert (ob = b /\ offset = ofs /\ Full = bf) as Hplaces by
        (eapply (proj2 (ocr_expression_lvalue_unique _ _ _ _)); [exact Hloc|eassumption]);
      destruct Hplaces as [? [? ?]]; subst end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
      inversion Ha; subst; try congruence end.
    all: match goal with Haccess : access_mode _ = By_value ?chunk |- _ =>
      assert (chunk = Mint32) by congruence; subst chunk end.
    all: match goal with Hstore : Mem.storev _ _ _ _ = Some _ |- _ => cbn [Mem.storev] in Hstore end.
    all: repeat split; try reflexivity.
    all: intros observed_block observed_offset observed_chunk Hapart;
      eapply Mem.load_store_other; eauto; left; congruence.
  - destruct (ibff_translation_call_frame _ _ _ _ _ _ Hrun) as (-> & -> & Hkeep).
    repeat split; auto.
  - inversion Hrun; subst.
    + match goal with Ha : ClightBigstep.exec_stmt _ _ _ _ _ a _ ?midle _ _,
        Hb : ClightBigstep.exec_stmt _ _ _ _ _ b _ _ _ _ |- _ =>
        destruct (IHHshape1 _ _ _ _ _ _ _ _ Hobj Ha) as (Ht1 & Hle1 & Hmem1);
        assert (Hobj2 : midle ! THO._obj = Some (Vptr ob oo)) by (rewrite Hle1; exact Hobj);
        destruct (IHHshape2 _ _ _ _ _ _ _ _ Hobj2 Hb) as (Ht2 & Hle2 & Hmem2) end.
      subst. split; [reflexivity|]. split; [congruence|].
      intros block offset chunk Hapart. rewrite Hmem2, Hmem1; auto.
    + eapply IHHshape1; eauto.
  - inversion Hrun; subst. destruct b; [eapply IHHshape1|eapply IHHshape2]; eauto.
Qed.

Definition IBFWholeHelperPreservesOtherBlocks : Prop :=
  forall before ob oo carry trace after result,
  ClightBigstep.Clight2.eval_funcall (tho_ge VersionJP) before
    (Internal (tho_function VersionJP)) [Vptr ob oo; Vptr carry Ptrofs.zero]
    trace after result ->
  trace = E0 /\ ibff_other_block_loads before after ob.

Theorem ibff_whole_helper_preserves_loaded_cells : IBFWholeHelperPreservesOtherBlocks.
Proof.
  intros before ob oo carry trace after result Hcall. inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    destruct (tho_actual_entry VersionJP _ _ _ _ _ _ _ _ Hentry) as (-> & -> & ->) end.
  assert (Hobj : (tho_entry_temps VersionJP ob oo carry) ! THO._obj = Some (Vptr ob oo)).
  { unfold tho_entry_temps. rewrite PTree.gso by discriminate. apply PTree.gss. }
  match goal with Hbody : ClightBigstep.exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (ibff_statement_frame _ ibff_whole_generated_helper_classified
      _ _ _ _ _ _ ob oo Hobj
      Hbody) as (Ht & _ & Hframe) end.
  match goal with Hfree : Mem.free_list ?body (blocks_of_env _ empty_env) = Some ?last |- _ =>
    change (Some body = Some last) in Hfree; inversion Hfree; subst end.
  auto.
Qed.

Definition InkBoxFloorFrameBoundary : Prop :=
  InkBoxFloorBoundary /\ IBFWholeHelperPreservesOtherBlocks /\ IBFCloneKeepsLoadedCell.
Theorem ibff_clone_floor_frame_boundary_checked : InkBoxFloorFrameBoundary.
Proof.
  split; [exact ibf_clone_floor_boundary_checked|].
  split; [exact ibff_whole_helper_preserves_loaded_cells|].
  exact ibff_clone_suffix_preserves_disjoint_cell.
Qed.
