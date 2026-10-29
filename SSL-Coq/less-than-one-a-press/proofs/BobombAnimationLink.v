(** Fail-closed audit of the Bob-omb animation dependency in the ACTUAL
    selected US/JP targets. No generated data or source semantics is changed.
    Symbol existence alone does not imply a readable animation-table entry. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Clightdefs Coqlib Ctypes Globalenvs
  Integers Linking Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_behavior_data jp_behavior_data
  us_graph_node jp_graph_node.
From LessThanOneAPress.Proofs Require Import GameTypes SelectedClightTarget
  LinkedClightPrograms NormalizedClightPrograms CleanedClightPrograms
  JPSourceSymbolTransport USWarpLevelSourceUnionReceipt LinkedGlobalInitialMemory
  ClightLinkExecution
  USWholeASTTagRepair USViewportRepairedProgramSelection ClightAllocationBounds.
Import ListNotations.
Local Open Scope Z_scope.

Definition bal_table_id : ident := us_behavior_data._bobomb_seg8_anims_0802396C.
Definition bal_source_table version := match version with
| VersionUS => us_behavior_data.v_bobomb_seg8_anims_0802396C
| VersionJP => jp_behavior_data.v_bobomb_seg8_anims_0802396C end.
Definition bal_source_script version := match version with
| VersionUS => us_behavior_data.v_bhvBobomb
| VersionJP => jp_behavior_data.v_bhvBobomb end.
Definition bal_geo_function version := match version with
| VersionUS => us_graph_node.f_geo_obj_init_animation
| VersionJP => jp_graph_node.f_geo_obj_init_animation end.

Theorem bal_generated_dependency_checked : forall version,
  gvar_init (bal_source_table version) = [] /\
  nth_error (gvar_init (bal_source_script version)) 2 =
    Some (Init_int32 (Int.repr 656801792)) /\
  nth_error (gvar_init (bal_source_script version)) 3 =
    Some (Init_addrof bal_table_id (Ptrofs.repr 0)) /\
  nth_error (gvar_init (bal_source_script version)) 5 =
    Some (Init_int32 (Int.repr 671088640)).
Proof. intros []; repeat split; reflexivity. Qed.

Definition bal_empty_variable (definition : globdef Clight.fundef type) : bool :=
  match definition with
  | Gvar variable => match gvar_init variable with [] => true | _ => false end
  | _ => false end.

(** Early identifier rejection avoids evaluating unrelated function bodies. *)
Lemma bal_us_source_census :
  forallb (identifier_definition_shape_ok bal_table_id bal_empty_variable)
    (unit_global_definitions us_units) = true.
Proof. vm_compute; reflexivity. Qed.
Lemma bal_jp_source_census :
  forallb (identifier_definition_shape_ok bal_table_id bal_empty_variable)
    (unit_global_definitions jp_units) = true.
Proof. vm_compute; reflexivity. Qed.

Lemma bal_generated_table_member : forall version,
  In (bal_table_id, Gvar (bal_source_table version))
    (unit_global_definitions (selected_original_units version)).
Proof.
  intros [].
  - eapply source_unit_definition_enters_source_union
      with (unit := us_nlist_at 26%nat us_units).
    + exact (us_nlist_at_nIn _ 26%nat us_units).
    + change (In (bal_table_id, Gvar (bal_source_table VersionUS))
        us_behavior_data.global_definitions).
      eapply nth_error_In with (n := 645%nat). reflexivity.
  - eapply source_unit_definition_enters_source_union
      with (unit := us_nlist_at 26%nat jp_units).
    + exact (us_nlist_at_nIn _ 26%nat jp_units).
    + change (In (bal_table_id, Gvar (bal_source_table VersionJP))
        jp_behavior_data.global_definitions).
      eapply nth_error_In with (n := 644%nat). reflexivity.
Qed.

(** The normalizer cannot drop a key. This is a structural proof, not a
    reduction of the full linked program. *)
Lemma bal_insert_domain : forall definitions entry id,
  (exists value, definitions ! id = Some value) \/ fst entry = id ->
  exists value, (insert_preferred_global_definition_map definitions entry) ! id =
    Some value.
Proof.
  intros definitions [key candidate] id Hdomain.
  unfold insert_preferred_global_definition_map.
  destruct (definitions ! key) as [incumbent|] eqn:Hkey.
  - destruct (Nat.ltb (global_definition_strength incumbent)
      (global_definition_strength candidate)).
    + destruct (peq id key) as [->|Hneq].
      * exists candidate. apply PTree.gss.
      * rewrite PTree.gso by exact Hneq.
        destruct Hdomain as [Hdomain|Heq]; [exact Hdomain|cbn in Heq; congruence].
    + destruct Hdomain as [Hdomain|Heq]; [exact Hdomain|].
      cbn in Heq. subst key. eauto.
  - destruct (peq id key) as [->|Hneq].
    + exists candidate. apply PTree.gss.
    + rewrite PTree.gso by exact Hneq.
      destruct Hdomain as [Hdomain|Heq]; [exact Hdomain|cbn in Heq; congruence].
Qed.

Lemma bal_fold_domain : forall entries definitions id,
  (exists value, definitions ! id = Some value) \/
  (exists value, In (id, value) entries) ->
  exists value,
    (fold_left insert_preferred_global_definition_map entries definitions) ! id =
      Some value.
Proof.
  induction entries as [|[key candidate] rest IH]; intros definitions id Hdomain.
  - cbn. destruct Hdomain as [Hdomain|[value Hin]]; [exact Hdomain|contradiction].
  - change (exists value,
      (fold_left insert_preferred_global_definition_map rest
        (insert_preferred_global_definition_map definitions (key, candidate)))
        ! id = Some value).
    apply IH. destruct Hdomain as [Hdomain|[value [Heq|Hin]]].
    + left. apply bal_insert_domain. now left.
    + left. apply bal_insert_domain. right. inversion Heq. reflexivity.
    + right. eauto.
Qed.

Lemma bal_us_normalized_symbol : exists definition,
  In (bal_table_id, definition) us_normalized_global_definitions.
Proof.
  destruct (bal_fold_domain (unit_global_definitions us_units)
      (PTree.empty _) bal_table_id) as [definition Hget].
  - right. exists (Gvar (bal_source_table VersionUS)).
    exact (bal_generated_table_member VersionUS).
  - exists definition. apply PTree.elements_correct. exact Hget.
Qed.

Local Opaque unit_global_definitions normalize_global_definition_map.

Lemma bal_repair_empty_shape : forall entry,
  fst (repair_us_selected_global_definition entry) = fst entry /\
  bal_empty_variable (snd (repair_us_selected_global_definition entry)) =
    bal_empty_variable (snd entry).
Proof.
  intros [id definition]. unfold repair_us_selected_global_definition.
  destruct (us_selected_definition_needs_viewport_repair (id, definition));
    split; try reflexivity. destruct definition; reflexivity.
Qed.

Lemma bal_repaired_list_shape : forall source id definition,
  (forall candidate, In (id, candidate) source ->
    bal_empty_variable candidate = true) ->
  In (id, definition) (map repair_us_selected_global_definition source) ->
  bal_empty_variable definition = true.
Proof.
  intros source id definition Hsource Hin.
  apply in_map_iff in Hin. destruct Hin as [entry [Heq Hentry]].
  pose proof (proj1 (bal_repair_empty_shape entry)) as Hid.
  pose proof (proj2 (bal_repair_empty_shape entry)) as Hshape.
  rewrite Heq in Hid, Hshape. cbn in Hid, Hshape.
  rewrite Hshape. destruct entry as [key candidate]. cbn in Hid. subst key.
  exact (Hsource candidate Hentry).
Qed.

Theorem bal_selected_symbol_exists : forall version, exists block,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    bal_table_id = Some block.
Proof.
  intros [].
  - destruct bal_us_normalized_symbol as [definition Hin].
    pose proof (in_map repair_us_selected_global_definition _ _ Hin) as Hmapped.
    destruct (repair_us_selected_global_definition (bal_table_id, definition))
      as [id repaired] eqn:Hrepair.
    pose proof (proj1 (bal_repair_empty_shape (bal_table_id, definition))) as Hid.
    rewrite Hrepair in Hid. cbn in Hid. subst id.
    change (In (bal_table_id, repaired) us_viewport_repaired_global_definitions)
      in Hmapped.
    rewrite <- us_viewport_repaired_program_definitions_checked in Hmapped.
    eapply Genv.find_symbol_exists. exact Hmapped.
  - eapply source_unit_definition_has_official_link_symbol
      with (source_units := jp_units) (cleaned_units := jp_cleaned_units)
           (unit := us_nlist_at 26%nat jp_units)
           (definition := Gvar (bal_source_table VersionJP)).
    + exact (us_nlist_at_nIn _ 26%nat jp_units).
    + eapply nth_error_In with (n := 644%nat). reflexivity.
    + exact jp_source_union_identifier_coverage_for_cleaned_units.
    + exact jp_cleaned_units_official_link.
Qed.

Local Opaque us_viewport_repaired_program jp_official_cleaned_slice.

Lemma bal_program_shape_transport : forall program definitions id,
  prog_defs program = definitions ->
  (forall definition, In (id, definition) definitions ->
    bal_empty_variable definition = true) ->
  forall definition, In (id, definition) (prog_defs program) ->
    bal_empty_variable definition = true.
Proof.
  intros program definitions id Hdefs Hshape definition Hin.
  rewrite Hdefs in Hin. exact (Hshape definition Hin).
Qed.

Theorem bal_selected_definitions_empty : forall version definition,
  In (bal_table_id, definition) (prog_defs (selected_clight_target version)) ->
  bal_empty_variable definition = true.
Proof.
  intros [] definition Hin.
  - change (In (bal_table_id, definition)
      (prog_defs us_viewport_repaired_program)) in Hin.
    eapply (bal_program_shape_transport us_viewport_repaired_program
      us_viewport_repaired_global_definitions bal_table_id
      us_viewport_repaired_program_definitions_checked); [|exact Hin].
    intros selected Hselected.
    unfold us_viewport_repaired_global_definitions in Hselected.
    eapply (bal_repaired_list_shape us_normalized_global_definitions
      bal_table_id selected); [|exact Hselected].
    intros candidate Hentry.
    eapply checked_identifier_definition_shape_sound; [exact bal_us_source_census|].
    unfold us_normalized_global_definitions in Hentry.
    exact (normalized_definitions_have_source_provenance _ _ Hentry).
  - change (In (bal_table_id, definition)
      (prog_defs jp_official_cleaned_slice)) in Hin.
    eapply checked_identifier_definition_shape_sound; [exact bal_jp_source_census|].
    exact (jp_official_source_definition_provenance bal_table_id definition Hin).
Qed.

(** This is deliberately the nonempty-data obligation, NOT just a symbol
    obligation. A future repair must make this actual-program check pass. *)
Definition selected_bobomb_animation_data_linked version : bool :=
  existsb (fun entry => Pos.eqb (fst entry) bal_table_id &&
    match snd entry with
    | Gvar variable => 0 <? init_data_list_size (gvar_init variable)
    | _ => false end) (prog_defs (selected_clight_target version)).

Theorem selected_bobomb_animation_data_check_fails : forall version,
  selected_bobomb_animation_data_linked version = false.
Proof.
  intro version. apply Bool.not_true_is_false. intro Hchecked.
  apply existsb_exists in Hchecked. destruct Hchecked as [[id definition] [Hin Hcheck]].
  apply andb_true_iff in Hcheck. destruct Hcheck as [Hid Hsize].
  apply Pos.eqb_eq in Hid. cbn in Hid. subst id.
  pose proof (bal_selected_definitions_empty version definition Hin) as Hempty.
  destruct definition as [fd|variable]; [discriminate|].
  cbn [bal_empty_variable] in Hempty. cbn in Hsize.
  destruct (gvar_init variable); [discriminate Hsize|discriminate Hempty].
Qed.

Theorem selected_bobomb_animation_table_empty : forall version,
  exists block variable,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_table_id = Some block /\
    Genv.find_var_info (Clight.globalenv (selected_clight_target version))
      block = Some variable /\ gvar_init variable = [].
Proof.
  intro version. eapply linked_symbol_with_definition_shape_has_variable
    with (shape := bal_empty_variable).
  - exact (bal_selected_definitions_empty version).
  - intros [fd|variable] Hshape; [discriminate|].
    exists variable. split; [reflexivity|].
    cbn [bal_empty_variable] in Hshape.
    destruct (gvar_init variable) eqn:Hinit; [reflexivity|discriminate].
  - exact (bal_selected_symbol_exists version).
Qed.

Lemma bal_empty_global_has_no_load : forall (program : Clight.program) memory block variable,
  Genv.init_mem program = Some memory ->
  Genv.find_var_info (Clight.globalenv program) block = Some variable ->
  gvar_init variable = [] -> forall chunk offset,
  Mem.load chunk memory block offset = None.
Proof.
  intros program memory block variable Hinit Hvar Hempty chunk offset.
  destruct (Mem.load chunk memory block offset) as [value|] eqn:Hload; [|reflexivity].
  exfalso. pose proof (Mem.load_valid_access _ _ _ _ _ Hload) as [Hrange _].
  assert (Hperm : Mem.perm memory block offset Cur Readable).
  { apply Hrange. generalize (size_chunk_pos chunk). lia. }
  pose proof (@Genv.init_mem_characterization Clight.fundef type program
    block variable memory Hvar Hinit) as [_ [Hbounds _]].
  specialize (Hbounds offset Cur Readable Hperm).
  rewrite Hempty in Hbounds. cbn in Hbounds. lia.
Qed.

(** This rules out the actual pointer-table load in initial memory at EVERY
    offset. Later memory/address conversion is not silently assumed equal. *)
Theorem selected_bobomb_animation_initial_load_fails : forall version,
  exists block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_table_id = Some block /\
    forall memory chunk offset,
      Genv.init_mem (selected_clight_target version) = Some memory ->
      Mem.load chunk memory block offset = None.
Proof.
  intro version. destruct (selected_bobomb_animation_table_empty version)
    as [block [variable [Hsymbol [Hvar Hempty]]]].
  exists block. split; [exact Hsymbol|]. intros memory chunk offset Hinit.
  eapply bal_empty_global_has_no_load; eauto.
Qed.

(** The zero-sized block cannot acquire permissions later in a defined
    Clight2 execution. This uses the existing CompCert old-block bound, not
    an animation frame, object-lifetime, or retail-machine assumption. *)
Theorem selected_bobomb_animation_reached_load_fails : forall version,
  exists block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_table_id = Some block /\
    forall initial start trace last,
      Genv.init_mem (selected_clight_target version) = Some initial ->
      clight_bound_memory start = initial ->
      Smallstep.star Clight.step2
        (Clight.globalenv (selected_clight_target version)) start trace last ->
      forall chunk offset,
        Mem.load chunk (clight_bound_memory last) block offset = None.
Proof.
  intro version. destruct (selected_bobomb_animation_table_empty version)
    as [block [variable [Hsymbol [Hvar Hempty]]]].
  exists block. split; [exact Hsymbol|].
  intros initial start trace last Hinit Hstart Hsteps chunk offset.
  destruct (Mem.load chunk (clight_bound_memory last) block offset)
    as [value|] eqn:Hload; [|reflexivity].
  exfalso. pose proof (Mem.load_valid_access _ _ _ _ _ Hload) as [Hrange _].
  assert (Hperm : Mem.perm (clight_bound_memory last) block offset Max Readable).
  { apply Mem.perm_cur_max. apply Hrange. generalize (size_chunk_pos chunk). lia. }
  pose proof (initialized_global_bound_persists_through_clight
    (selected_clight_target version) initial start trace last block variable
    Hinit Hvar Hstart Hsteps offset Readable Hperm) as Hbounds.
  rewrite Hempty in Hbounds. cbn in Hbounds. lia.
Qed.

(** Extract, rather than invent, the table-read expression from the generated
    geometry helper. The helper performs this read before comparing curAnim. *)
Definition bal_geo_table_read version : expr :=
  match fn_body (bal_geo_function version) with
  | Ssequence _ (Ssequence (Ssequence (Ssequence (Sset _ read) _) _) _) => read
  | _ => Econst_int Int.zero tint end.

Theorem bal_geo_table_read_checked : forall version,
  bal_geo_table_read version = Ederef
    (Etempvar us_graph_node._animSegmented
      (tptr (tptr (Tstruct us_graph_node._Animation noattr))))
    (tptr (Tstruct us_graph_node._Animation noattr)).
Proof. intros []; reflexivity. Qed.

Definition BobombAnimationLinkBoundary : Prop :=
  (forall version, selected_bobomb_animation_data_linked version = false) /\
  (forall version, exists block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_table_id = Some block /\
    forall memory chunk offset,
      Genv.init_mem (selected_clight_target version) = Some memory ->
      Mem.load chunk memory block offset = None) /\
  (forall version, exists block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_table_id = Some block /\
    forall initial start trace last,
      Genv.init_mem (selected_clight_target version) = Some initial ->
      clight_bound_memory start = initial ->
      Smallstep.star Clight.step2
        (Clight.globalenv (selected_clight_target version)) start trace last ->
      forall chunk offset,
        Mem.load chunk (clight_bound_memory last) block offset = None).

Theorem bobomb_animation_link_boundary_checked : BobombAnimationLinkBoundary.
Proof.
  split; [exact selected_bobomb_animation_data_check_fails|].
  split; [exact selected_bobomb_animation_initial_load_fails|
    exact selected_bobomb_animation_reached_load_fails].
Qed.
