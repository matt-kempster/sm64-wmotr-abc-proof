(** Semantic results for the four legitimate terminal action-table reads. *)

From Coq Require Import List Lia ZArith.
From compcert Require Import
  AST Clight Clightdefs Coqlib Cop Ctypes Globalenvs Integers Linking Maps
  Memory Values.
From LessThanOneAPress.Proofs Require Import
  GameTypes CleanedClightPrograms ClightLinkExecution LinkedClightPrograms
  NormalizedClightPrograms SelectedClightTarget
  WritableActionTableAliasExternalClosure
  WritableActionTableWholeGameAliases
  WritableActionTablePrivateInitialization.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Lemma watpr_mem_getN_self_inject :
  forall injection contents start count,
    (forall address,
      start <= address < start + Z.of_nat count ->
      memval_inject injection (ZMap.get address contents)
        (ZMap.get address contents)) ->
    list_forall2 (memval_inject injection)
      (Mem.getN count start contents) (Mem.getN count start contents).
Proof.
  intros injection contents start count.
  revert start.
  induction count as [| count IH]; intros start Hpointwise;
    cbn [Mem.getN].
  - constructor.
  - constructor.
    + apply Hpointwise. rewrite Nat2Z.inj_succ. lia.
    + apply IH. intros address Hrange.
      apply Hpointwise. rewrite Nat2Z.inj_succ in *. lia.
Qed.

Lemma watpr_private_initial_global_load_inject :
  forall program protected_identifiers initial_memory identifier variable block
      chunk offset value,
    ActionTableInitializersAvoid program protected_identifiers ->
    Genv.init_mem program = Some initial_memory ->
    Genv.find_symbol (Clight.globalenv program) identifier = Some block ->
    Genv.find_var_info (Clight.globalenv program) block = Some variable ->
    Mem.load chunk initial_memory block offset = Some value ->
    Val.inject
      (watpi_private_initial_injection program protected_identifiers)
      value value.
Proof.
  intros program protected_identifiers initial_memory identifier variable block
    chunk offset value Havoids Hinitial Hsymbol Hvariable Hload.
  pose proof (@Genv.init_mem_characterization
    Clight.fundef type program block variable initial_memory
    Hvariable Hinitial) as Hcharacterization.
  destruct Hcharacterization as
    [Hrange [Hpermissions [Hstored Hbytes]]].
  assert (Hnot_volatile : gvar_volatile variable = false).
  {
    destruct (gvar_volatile variable) eqn:Hvolatile; [| reflexivity].
    pose proof (Mem.load_valid_access _ _ _ _ _ Hload) as [Hreadable _].
    specialize (Hreadable offset).
    assert (Hinside : offset <= offset < offset + size_chunk chunk).
    { generalize (size_chunk_pos chunk). lia. }
    specialize (Hreadable Hinside).
    specialize (Hpermissions offset Cur Readable Hreadable).
    destruct Hpermissions as [_ Horder].
    unfold Genv.perm_globvar in Horder. rewrite Hvolatile in Horder.
    inversion Horder.
  }
  specialize (Hbytes Hnot_volatile).
  Local Transparent Mem.load Mem.loadbytes.
  unfold Mem.load in Hload.
  destruct Mem.valid_access_dec as [Haccess | Haccess]; [| discriminate].
  injection Hload as Hvalue.
  subst value.
  apply decode_val_inject.
  apply watpr_mem_getN_self_inject.
  intros address Haddress.
  pose proof Haccess as [Hreadable _].
  assert (Haddress_range :
    offset <= address < offset + size_chunk chunk).
  { rewrite size_chunk_conv. exact Haddress. }
  specialize (Hreadable address Haddress_range).
  specialize (Hpermissions address Cur Readable Hreadable).
  destruct Hpermissions as [Hinitializer_range _].
  unfold Mem.loadbytes in Hbytes.
  destruct Mem.range_perm_dec as [Hfull_range | Hfull_range]; [| discriminate].
  injection Hbytes as Hcontents.
  eapply watpi_mem_getN_forall2 with
    (start := 0)
    (count := Z.to_nat (init_data_list_size (gvar_init variable))).
  - rewrite Hcontents.
    apply watpi_bytes_of_init_data_list_inject.
    intros protected_identifier pointer_offset Hprotected Hin.
    assert (Hdefinition :
      In (identifier, Gvar variable) (prog_defs program)).
    {
      apply Genv.find_var_info_iff in Hvariable.
      assert (Hdefinition_map :
        (prog_defmap (Ctypes.program_of_program program)) ! identifier =
          Some (Gvar variable)).
      { apply (proj2
          (Genv.find_def_symbol program identifier (Gvar variable))).
        exists block. split; assumption. }
      exact (@in_prog_defmap Clight.fundef type
        (Ctypes.program_of_program program) identifier (Gvar variable)
        Hdefinition_map).
    }
    exact (Havoids identifier variable protected_identifier pointer_offset
      Hdefinition Hprotected Hin).
  - lia.
  - rewrite Z2Nat.id by
      (apply Z.ge_le; apply init_data_list_size_pos).
    lia.
Qed.

Lemma watpr_framed_private_global_load_inject :
  forall program protected_identifiers protected_blocks initial_memory memory
      identifier variable block chunk offset value injection,
    ActionTableInitializersAvoid program protected_identifiers ->
    Genv.init_mem program = Some initial_memory ->
    Genv.find_symbol (Clight.globalenv program) identifier = Some block ->
    Genv.find_var_info (Clight.globalenv program) block = Some variable ->
    In block protected_blocks ->
    Mem.unchanged_on
      (fun candidate_block _ => In candidate_block protected_blocks)
      initial_memory memory ->
    inject_incr
      (watpi_private_initial_injection program protected_identifiers)
      injection ->
    Mem.load chunk memory block offset = Some value ->
    Val.inject injection value value.
Proof.
  intros program protected_identifiers protected_blocks initial_memory memory
    identifier variable block chunk offset value injection Havoids Hinitial
    Hsymbol Hvariable Hin Hframe Hincr Hload.
  assert (Hvalid : Mem.valid_block initial_memory block).
  { eapply Genv.find_symbol_not_fresh; eauto. }
  pose proof (Mem.load_unchanged_on_1
    (fun candidate_block _ => In candidate_block protected_blocks)
    initial_memory memory chunk block offset Hframe Hvalid) as Hsame.
  specialize (Hsame (fun _ _ => Hin)).
  rewrite Hsame in Hload.
  eapply val_inject_incr; [exact Hincr |].
  eapply watpr_private_initial_global_load_inject; eauto.
Qed.

Lemma watpr_nin_definition_is_in_union :
  forall unit units identifier definition,
    nIn unit units ->
    In (identifier, definition) (prog_defs unit) ->
    In (identifier, definition) (unit_global_definitions units).
Proof.
  intros unit units identifier definition Hunit Hdefinition.
  induction units as [head | head rest IH]; cbn in *.
  - subst head. apply in_or_app. now left.
  - destruct Hunit as [-> | Hunit].
    + apply in_or_app. now left.
    + apply in_or_app. right. now apply IH.
Qed.

Lemma watpr_us_table_definitions_are_linked :
  In (WATWG_USI._sInteractionHandlers,
      Gvar WATWG_USI.v_sInteractionHandlers)
      (prog_defs us_official_cleaned_slice) /\
  In (WATWG_USI._sForwardKnockbackActions,
      Gvar WATWG_USI.v_sForwardKnockbackActions)
      (prog_defs us_official_cleaned_slice) /\
  In (WATWG_USI._sBackwardKnockbackActions,
      Gvar WATWG_USI.v_sBackwardKnockbackActions)
      (prog_defs us_official_cleaned_slice).
Proof.
  destruct watwg_us_interaction_table_definitions as
    [Hhandler [Hforward Hbackward]].
  assert (Hunit : nIn WATWG_USI.prog us_units).
  { unfold us_units. do 10 right. left. reflexivity. }
  split.
  - assert (Hfiltered : In
      (WATWG_USI._sInteractionHandlers,
       Gvar WATWG_USI.v_sInteractionHandlers)
      (filter preserve_definition_verbatim
        (unit_global_definitions us_units))).
    { rewrite filter_In. split.
      - exact (watpr_nin_definition_is_in_union WATWG_USI.prog us_units
          WATWG_USI._sInteractionHandlers
          (Gvar WATWG_USI.v_sInteractionHandlers) Hunit Hhandler).
      - reflexivity. }
    exact (us_official_preserves_source_strong_definitions_verbatim _
      Hfiltered).
  - split.
    + assert (Hfiltered : In
        (WATWG_USI._sForwardKnockbackActions,
         Gvar WATWG_USI.v_sForwardKnockbackActions)
        (filter preserve_definition_verbatim
          (unit_global_definitions us_units))).
      { rewrite filter_In. split.
        - exact (watpr_nin_definition_is_in_union WATWG_USI.prog us_units
            WATWG_USI._sForwardKnockbackActions
            (Gvar WATWG_USI.v_sForwardKnockbackActions) Hunit Hforward).
        - reflexivity. }
      exact (us_official_preserves_source_strong_definitions_verbatim _
        Hfiltered).
    + assert (Hfiltered : In
        (WATWG_USI._sBackwardKnockbackActions,
         Gvar WATWG_USI.v_sBackwardKnockbackActions)
        (filter preserve_definition_verbatim
          (unit_global_definitions us_units))).
      { rewrite filter_In. split.
        - exact (watpr_nin_definition_is_in_union WATWG_USI.prog us_units
            WATWG_USI._sBackwardKnockbackActions
            (Gvar WATWG_USI.v_sBackwardKnockbackActions) Hunit Hbackward).
        - reflexivity. }
      exact (us_official_preserves_source_strong_definitions_verbatim _
        Hfiltered).
Qed.

Lemma watpr_jp_table_definitions_are_linked :
  In (WATWG_JPI._sInteractionHandlers,
      Gvar WATWG_JPI.v_sInteractionHandlers)
      (prog_defs jp_official_cleaned_slice) /\
  In (WATWG_JPI._sForwardKnockbackActions,
      Gvar WATWG_JPI.v_sForwardKnockbackActions)
      (prog_defs jp_official_cleaned_slice) /\
  In (WATWG_JPI._sBackwardKnockbackActions,
      Gvar WATWG_JPI.v_sBackwardKnockbackActions)
      (prog_defs jp_official_cleaned_slice).
Proof.
  destruct watwg_jp_interaction_table_definitions as
    [Hhandler [Hforward Hbackward]].
  assert (Hunit : nIn WATWG_JPI.prog jp_units).
  { unfold jp_units. do 10 right. left. reflexivity. }
  split.
  - assert (Hfiltered : In
      (WATWG_JPI._sInteractionHandlers,
       Gvar WATWG_JPI.v_sInteractionHandlers)
      (filter preserve_definition_verbatim
        (unit_global_definitions jp_units))).
    { rewrite filter_In. split.
      - exact (watpr_nin_definition_is_in_union WATWG_JPI.prog jp_units
          WATWG_JPI._sInteractionHandlers
          (Gvar WATWG_JPI.v_sInteractionHandlers) Hunit Hhandler).
      - reflexivity. }
    exact (jp_official_preserves_source_strong_definitions_verbatim _
      Hfiltered).
  - split.
    + assert (Hfiltered : In
        (WATWG_JPI._sForwardKnockbackActions,
         Gvar WATWG_JPI.v_sForwardKnockbackActions)
        (filter preserve_definition_verbatim
          (unit_global_definitions jp_units))).
      { rewrite filter_In. split.
        - exact (watpr_nin_definition_is_in_union WATWG_JPI.prog jp_units
            WATWG_JPI._sForwardKnockbackActions
            (Gvar WATWG_JPI.v_sForwardKnockbackActions) Hunit Hforward).
        - reflexivity. }
      exact (jp_official_preserves_source_strong_definitions_verbatim _
        Hfiltered).
    + assert (Hfiltered : In
        (WATWG_JPI._sBackwardKnockbackActions,
         Gvar WATWG_JPI.v_sBackwardKnockbackActions)
        (filter preserve_definition_verbatim
          (unit_global_definitions jp_units))).
      { rewrite filter_In. split.
        - exact (watpr_nin_definition_is_in_union WATWG_JPI.prog jp_units
            WATWG_JPI._sBackwardKnockbackActions
            (Gvar WATWG_JPI.v_sBackwardKnockbackActions) Hunit Hbackward).
        - reflexivity. }
      exact (jp_official_preserves_source_strong_definitions_verbatim _
        Hfiltered).
Qed.

Lemma watpr_clight_link_result_names_norepet :
  forall (left right linked : Clight.program),
    link left right = Some linked ->
    list_norepet (prog_defs_names (Ctypes.program_of_program linked)).
Proof.
  intros left right linked Hlink.
  pose proof (clight_link_projects_program_components
    left right linked Hlink) as Hcomponents.
  destruct (link_prog_inv
    (Ctypes.program_of_program left)
    (Ctypes.program_of_program right)
    (Ctypes.program_of_program linked) Hcomponents)
    as [_ [_ Hshape]].
  rewrite Hshape. cbn [prog_defs_names].
  apply PTree.elements_keys_norepet.
Qed.

Lemma watpr_NoDup_list_norepet :
  forall (A : Type) (values : list A),
    NoDup values -> list_norepet values.
Proof.
  intros A values Hunique. induction Hunique.
  - constructor.
  - constructor; assumption.
Qed.

Lemma watpr_link_list_result_names_norepet :
  forall units linked,
    NoDup (cleaned_global_identifiers units) ->
    link_list units = Some linked ->
    list_norepet (prog_defs_names (Ctypes.program_of_program linked)).
Proof.
  intros units linked Hunique Hlink.
  destruct units as [unit | unit rest].
  - cbn [link_list] in Hlink. inversion Hlink; subst linked.
    cbn [cleaned_global_identifiers] in Hunique.
    unfold ast_global_names, program_components in Hunique.
    now apply watpr_NoDup_list_norepet.
  - cbn [link_list] in Hlink.
    destruct (link_list rest) as [rest_linked |] eqn:Hrest;
      [| discriminate].
    eapply watpr_clight_link_result_names_norepet; eauto.
Qed.

Lemma watpr_us_official_names_norepet :
  list_norepet
    (prog_defs_names (Ctypes.program_of_program us_official_cleaned_slice)).
Proof.
  eapply watpr_link_list_result_names_norepet.
  - apply identifiers_unique_nodup.
    exact us_cleaned_global_identifiers_unique_checked.
  - exact us_cleaned_units_official_link.
Qed.

Lemma watpr_jp_official_names_norepet :
  list_norepet
    (prog_defs_names (Ctypes.program_of_program jp_official_cleaned_slice)).
Proof.
  eapply watpr_link_list_result_names_norepet.
  - apply identifiers_unique_nodup.
    exact jp_cleaned_global_identifiers_unique_checked.
  - exact jp_cleaned_units_official_link.
Qed.

Lemma watpr_linked_definition_and_symbol_find_variable :
  forall program identifier variable block,
    list_norepet
      (prog_defs_names (Ctypes.program_of_program program)) ->
    In (identifier, Gvar variable) (prog_defs program) ->
    Genv.find_symbol (Clight.globalenv program) identifier = Some block ->
    Genv.find_var_info (Clight.globalenv program) block = Some variable.
Proof.
  intros program identifier variable block Hnorepet Hdefinition Hsymbol.
  pose proof (@prog_defmap_norepet Clight.fundef type
    (Ctypes.program_of_program program) identifier (Gvar variable)
    Hnorepet Hdefinition) as Hmap.
  apply Genv.find_def_symbol in Hmap.
  destruct Hmap as [definition_block [Hdefinition_symbol Hfind]].
  change (Genv.find_symbol (Clight.globalenv program) identifier =
    Some definition_block) in Hdefinition_symbol.
  rewrite Hsymbol in Hdefinition_symbol.
  inversion Hdefinition_symbol; subst definition_block.
  now apply Genv.find_var_info_iff.
Qed.

(** Seal the six large generated table-variable witnesses separately.  The
    version-generic wrapper below then contains only references to these opaque
    facts instead of one proof term carrying all six generated initializers. *)
Lemma watpr_us_interaction_handlers_symbol_finds_variable :
  forall block,
    Genv.find_symbol (Clight.globalenv us_official_cleaned_slice)
      WATWG_USI._sInteractionHandlers = Some block ->
    exists variable,
      Genv.find_var_info (Clight.globalenv us_official_cleaned_slice) block =
        Some variable.
Proof.
  intros block Hsymbol.
  destruct watpr_us_table_definitions_are_linked as [Hhandler _].
  exists WATWG_USI.v_sInteractionHandlers.
  exact (watpr_linked_definition_and_symbol_find_variable
    us_official_cleaned_slice WATWG_USI._sInteractionHandlers
    WATWG_USI.v_sInteractionHandlers block
    watpr_us_official_names_norepet Hhandler Hsymbol).
Qed.

Lemma watpr_us_forward_knockback_symbol_finds_variable :
  forall block,
    Genv.find_symbol (Clight.globalenv us_official_cleaned_slice)
      WATWG_USI._sForwardKnockbackActions = Some block ->
    exists variable,
      Genv.find_var_info (Clight.globalenv us_official_cleaned_slice) block =
        Some variable.
Proof.
  intros block Hsymbol.
  destruct watpr_us_table_definitions_are_linked as [_ [Hforward _]].
  exists WATWG_USI.v_sForwardKnockbackActions.
  exact (watpr_linked_definition_and_symbol_find_variable
    us_official_cleaned_slice WATWG_USI._sForwardKnockbackActions
    WATWG_USI.v_sForwardKnockbackActions block
    watpr_us_official_names_norepet Hforward Hsymbol).
Qed.

Lemma watpr_us_backward_knockback_symbol_finds_variable :
  forall block,
    Genv.find_symbol (Clight.globalenv us_official_cleaned_slice)
      WATWG_USI._sBackwardKnockbackActions = Some block ->
    exists variable,
      Genv.find_var_info (Clight.globalenv us_official_cleaned_slice) block =
        Some variable.
Proof.
  intros block Hsymbol.
  destruct watpr_us_table_definitions_are_linked as [_ [_ Hbackward]].
  exists WATWG_USI.v_sBackwardKnockbackActions.
  exact (watpr_linked_definition_and_symbol_find_variable
    us_official_cleaned_slice WATWG_USI._sBackwardKnockbackActions
    WATWG_USI.v_sBackwardKnockbackActions block
    watpr_us_official_names_norepet Hbackward Hsymbol).
Qed.

Lemma watpr_jp_interaction_handlers_symbol_finds_variable :
  forall block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      WATWG_JPI._sInteractionHandlers = Some block ->
    exists variable,
      Genv.find_var_info (Clight.globalenv jp_official_cleaned_slice) block =
        Some variable.
Proof.
  intros block Hsymbol.
  destruct watpr_jp_table_definitions_are_linked as [Hhandler _].
  exists WATWG_JPI.v_sInteractionHandlers.
  exact (watpr_linked_definition_and_symbol_find_variable
    jp_official_cleaned_slice WATWG_JPI._sInteractionHandlers
    WATWG_JPI.v_sInteractionHandlers block
    watpr_jp_official_names_norepet Hhandler Hsymbol).
Qed.

Lemma watpr_jp_forward_knockback_symbol_finds_variable :
  forall block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      WATWG_JPI._sForwardKnockbackActions = Some block ->
    exists variable,
      Genv.find_var_info (Clight.globalenv jp_official_cleaned_slice) block =
        Some variable.
Proof.
  intros block Hsymbol.
  destruct watpr_jp_table_definitions_are_linked as [_ [Hforward _]].
  exists WATWG_JPI.v_sForwardKnockbackActions.
  exact (watpr_linked_definition_and_symbol_find_variable
    jp_official_cleaned_slice WATWG_JPI._sForwardKnockbackActions
    WATWG_JPI.v_sForwardKnockbackActions block
    watpr_jp_official_names_norepet Hforward Hsymbol).
Qed.

Lemma watpr_jp_backward_knockback_symbol_finds_variable :
  forall block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      WATWG_JPI._sBackwardKnockbackActions = Some block ->
    exists variable,
      Genv.find_var_info (Clight.globalenv jp_official_cleaned_slice) block =
        Some variable.
Proof.
  intros block Hsymbol.
  destruct watpr_jp_table_definitions_are_linked as [_ [_ Hbackward]].
  exists WATWG_JPI.v_sBackwardKnockbackActions.
  exact (watpr_linked_definition_and_symbol_find_variable
    jp_official_cleaned_slice WATWG_JPI._sBackwardKnockbackActions
    WATWG_JPI.v_sBackwardKnockbackActions block
    watpr_jp_official_names_norepet Hbackward Hsymbol).
Qed.

Lemma watpr_us_table_symbol_finds_variable :
  forall identifier block,
    In identifier watwg_us_table_ids ->
    Genv.find_symbol (Clight.globalenv us_official_cleaned_slice)
      identifier = Some block ->
    exists variable,
      Genv.find_var_info (Clight.globalenv us_official_cleaned_slice)
        block = Some variable.
Proof.
  intros identifier block Hin Hsymbol.
  destruct Hin as [Hin | [Hin | [Hin | []]]]; subst identifier.
  - exact (watpr_us_interaction_handlers_symbol_finds_variable block Hsymbol).
  - exact (watpr_us_forward_knockback_symbol_finds_variable block Hsymbol).
  - exact (watpr_us_backward_knockback_symbol_finds_variable block Hsymbol).
Qed.

Lemma watpr_jp_table_symbol_finds_variable :
  forall identifier block,
    In identifier watwg_jp_table_ids ->
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      identifier = Some block ->
    exists variable,
      Genv.find_var_info (Clight.globalenv jp_official_cleaned_slice)
        block = Some variable.
Proof.
  intros identifier block Hin Hsymbol.
  destruct Hin as [Hin | [Hin | [Hin | []]]]; subst identifier.
  - exact (watpr_jp_interaction_handlers_symbol_finds_variable block Hsymbol).
  - exact (watpr_jp_forward_knockback_symbol_finds_variable block Hsymbol).
  - exact (watpr_jp_backward_knockback_symbol_finds_variable block Hsymbol).
Qed.

(** Select the already-sealed concrete resolver without destructing [version]
    inside a proof.  This direct match avoids the enormous equality transports
    that Coq otherwise constructs between the two generated programs. *)
Definition watpr_selected_table_symbol_finds_variable
    (version : GameVersion) :
  forall identifier block,
    In identifier (watwg_linked_source_table_ids version) ->
    Genv.find_symbol (Clight.globalenv (selected_clight_source version))
      identifier = Some block ->
    exists variable,
      Genv.find_var_info (Clight.globalenv (selected_clight_source version))
        block = Some variable :=
  match version with
  | VersionUS => watpr_us_table_symbol_finds_variable
  | VersionJP => watpr_jp_table_symbol_finds_variable
  end.

Lemma watpr_forall2_left_has_right :
  forall (A B : Type) (relation : A -> B -> Prop)
      left_values right_values left_value,
    Forall2 relation left_values right_values ->
    In left_value left_values ->
    exists right_value,
      In right_value right_values /\ relation left_value right_value.
Proof.
  intros A B relation left_values right_values left_value Hrelation.
  induction Hrelation as
      [| left_head right_head left_tail right_tail Hhead Htail IH]; cbn.
  - contradiction.
  - intros [Hequal | Hin].
    + subst left_head. exists right_head. auto.
    + destruct (IH Hin) as [found [Hfound Hrelated]].
      exists found. auto.
Qed.

Lemma watpr_selected_table_identifier_resolves_exact_variable :
  forall version protected_blocks identifier,
    LinkedSourceActionTableBlocks version protected_blocks ->
    In identifier (watwg_linked_source_table_ids version) ->
    exists block variable,
      In block protected_blocks /\
      Genv.find_symbol (Clight.globalenv (selected_clight_source version))
        identifier = Some block /\
      Genv.find_var_info (Clight.globalenv (selected_clight_source version))
        block = Some variable.
Proof.
  intros version protected_blocks identifier Hblocks Hidentifier.
  destruct Hblocks as [_ Hresolved].
  destruct (watpr_forall2_left_has_right _ _ _ _ _ _ Hresolved Hidentifier)
    as [block [Hblock Hsymbol]].
  destruct (watpr_selected_table_symbol_finds_variable
    version identifier block Hidentifier Hsymbol) as [variable Hvariable].
  exists block, variable. repeat split; assumption.
Qed.

Lemma watpr_framed_private_global_deref_inject :
  forall program protected_identifiers protected_blocks initial_memory memory
      identifier variable block value_type chunk offset bitfield value injection,
    ActionTableInitializersAvoid program protected_identifiers ->
    Genv.init_mem program = Some initial_memory ->
    Genv.find_symbol (Clight.globalenv program) identifier = Some block ->
    Genv.find_var_info (Clight.globalenv program) block = Some variable ->
    In block protected_blocks ->
    Mem.unchanged_on
      (fun candidate_block _ => In candidate_block protected_blocks)
      initial_memory memory ->
    inject_incr
      (watpi_private_initial_injection program protected_identifiers)
      injection ->
    access_mode value_type = By_value chunk ->
    Clight.deref_loc value_type memory block offset bitfield value ->
    Val.inject injection value value.
Proof.
  intros program protected_identifiers protected_blocks initial_memory memory
    identifier variable block value_type chunk offset bitfield value injection
    Havoids Hinitial Hsymbol Hvariable Hin Hframe Hincr Hmode Hderef.
  inversion Hderef; subst; try congruence.
  - eapply watpr_framed_private_global_load_inject; eauto.
  - match goal with
    | Hbitfield : Cop.load_bitfield _ _ _ _ _ memory
        (Vptr block offset) value |- _ =>
        inversion Hbitfield; subst; constructor
    end.
Qed.

Lemma watpr_eval_global_reference_has_symbol_block :
  forall (ge : Clight.genv) environment temporaries memory identifier
      value_type block value,
    environment ! identifier = None ->
    Genv.find_symbol ge identifier = Some block ->
    access_mode value_type = By_reference ->
    Clight.eval_expr ge environment temporaries memory
      (Evar identifier value_type) value ->
    value = Vptr block Ptrofs.zero.
Proof.
  intros ge environment temporaries memory identifier value_type block value
    Hlocal Hsymbol Hmode Heval.
  inversion Heval; subst; try discriminate.
  match goal with
  | Hlvalue : Clight.eval_lvalue _ _ _ _
      (Evar identifier value_type) _ _ _ |- _ =>
      inversion Hlvalue; subst; try discriminate
  end.
  - match goal with
    | Hlookup : environment ! identifier = Some _ |- _ =>
        rewrite Hlocal in Hlookup; discriminate
    end.
  - rewrite Hsymbol in H7. inversion H7; subst loc.
    inversion H0; subst; cbn in *; congruence.
Qed.

Lemma watpr_eval_global_copy_has_symbol_block :
  forall (ge : Clight.genv) environment temporaries memory identifier
      value_type block value,
    environment ! identifier = None ->
    Genv.find_symbol ge identifier = Some block ->
    access_mode value_type = By_copy ->
    Clight.eval_expr ge environment temporaries memory
      (Evar identifier value_type) value ->
    value = Vptr block Ptrofs.zero.
Proof.
  intros ge environment temporaries memory identifier value_type block value
    Hlocal Hsymbol Hmode Heval.
  inversion Heval; subst; try discriminate.
  match goal with
  | Hlvalue : Clight.eval_lvalue _ _ _ _
      (Evar identifier value_type) _ _ _ |- _ =>
      inversion Hlvalue; subst; try discriminate
  end.
  - match goal with
    | Hlookup : environment ! identifier = Some _ |- _ =>
        rewrite Hlocal in Hlookup; discriminate
    end.
  - rewrite Hsymbol in H7. inversion H7; subst loc.
    inversion H0; subst; cbn in *; congruence.
Qed.

Lemma watpr_eval_pointer_add_preserves_root_block :
  forall (ge : Clight.genv) environment temporaries memory
      left_expression right_expression result_type element_type signedness
      block value,
    (forall left_value,
      Clight.eval_expr ge environment temporaries memory
        left_expression left_value ->
      exists left_offset, left_value = Vptr block left_offset) ->
    classify_add (typeof left_expression) (typeof right_expression) =
      add_case_pi element_type signedness ->
    Clight.eval_expr ge environment temporaries memory
      (Ebinop Oadd left_expression right_expression result_type) value ->
    exists result_offset, value = Vptr block result_offset.
Proof.
  intros ge environment temporaries memory left_expression right_expression
    result_type element_type signedness block value Hleft Hclassification Heval.
  inversion Heval; subst; try discriminate.
  all: try match goal with
  | Hlvalue : Clight.eval_lvalue _ _ _ _
      (Ebinop Oadd _ _ _) _ _ _ |- _ =>
      inversion Hlvalue
  end.
  match goal with
  | Hleft_eval : Clight.eval_expr ge environment temporaries memory
      left_expression ?left_value |- _ =>
      destruct (Hleft left_value Hleft_eval) as [left_offset ->]
  end.
  unfold sem_binary_operation, sem_add in H6.
  rewrite Hclassification in H6.
  unfold sem_add_ptr_int in H6.
  destruct v2; try discriminate.
  inversion H6; subst.
  eauto.
Qed.

Lemma watpr_eval_reference_deref_preserves_root_block :
  forall (ge : Clight.genv) environment temporaries memory
      address value_type block value,
    (forall address_value,
      Clight.eval_expr ge environment temporaries memory address address_value ->
      exists address_offset, address_value = Vptr block address_offset) ->
    access_mode value_type = By_reference ->
    Clight.eval_expr ge environment temporaries memory
      (Ederef address value_type) value ->
    exists result_offset, value = Vptr block result_offset.
Proof.
  intros ge environment temporaries memory address value_type block value
    Haddress Hmode Heval.
  inversion Heval; subst; try discriminate.
  inversion H; subst; try discriminate.
  destruct (Haddress (Vptr loc ofs) H6) as [address_offset Hequal].
  inversion Hequal; subst loc ofs.
  inversion H0; subst; cbn in *; try congruence.
  eauto.
Qed.

Lemma watpr_eval_copy_deref_preserves_root_block :
  forall (ge : Clight.genv) environment temporaries memory
      address value_type block value,
    (forall address_value,
      Clight.eval_expr ge environment temporaries memory address address_value ->
      exists address_offset, address_value = Vptr block address_offset) ->
    access_mode value_type = By_copy ->
    Clight.eval_expr ge environment temporaries memory
      (Ederef address value_type) value ->
    exists result_offset, value = Vptr block result_offset.
Proof.
  intros ge environment temporaries memory address value_type block value
    Haddress Hmode Heval.
  inversion Heval; subst; try discriminate.
  inversion H; subst; try discriminate.
  destruct (Haddress (Vptr loc ofs) H6) as [address_offset Hequal].
  inversion Hequal; subst loc ofs.
  inversion H0; subst; cbn in *; try congruence.
  eauto.
Qed.

Lemma watpr_eval_direct_framed_table_read_inject :
  forall program protected_identifiers protected_blocks initial_memory memory
      identifier variable block address value_type chunk value injection
      environment temporaries,
    ActionTableInitializersAvoid program protected_identifiers ->
    Genv.init_mem program = Some initial_memory ->
    Genv.find_symbol (Clight.globalenv program) identifier = Some block ->
    Genv.find_var_info (Clight.globalenv program) block = Some variable ->
    In block protected_blocks ->
    Mem.unchanged_on
      (fun candidate_block _ => In candidate_block protected_blocks)
      initial_memory memory ->
    inject_incr
      (watpi_private_initial_injection program protected_identifiers)
      injection ->
    access_mode value_type = By_value chunk ->
    (forall address_value,
      Clight.eval_expr (Clight.globalenv program) environment temporaries memory
        address address_value ->
      exists address_offset, address_value = Vptr block address_offset) ->
    Clight.eval_expr (Clight.globalenv program) environment temporaries memory
      (Ederef address value_type) value ->
    Val.inject injection value value.
Proof.
  intros program protected_identifiers protected_blocks initial_memory memory
    identifier variable block address value_type chunk value injection
    environment temporaries Havoids Hinitial Hsymbol Hvariable Hin Hframe
    Hincr Hmode Haddress Heval.
  inversion Heval; subst; try discriminate.
  inversion H; subst; try discriminate.
  destruct (Haddress (Vptr loc ofs) H6) as [address_offset Hequal].
  inversion Hequal; subst loc ofs.
  eapply watpr_framed_private_global_deref_inject; eauto.
Qed.

Lemma watpr_eval_field_framed_table_read_inject :
  forall program protected_identifiers protected_blocks initial_memory memory
      identifier variable block record_expression composite_identifier
      composite_attributes field value_type chunk value injection
      environment temporaries,
    ActionTableInitializersAvoid program protected_identifiers ->
    Genv.init_mem program = Some initial_memory ->
    Genv.find_symbol (Clight.globalenv program) identifier = Some block ->
    Genv.find_var_info (Clight.globalenv program) block = Some variable ->
    In block protected_blocks ->
    Mem.unchanged_on
      (fun candidate_block _ => In candidate_block protected_blocks)
      initial_memory memory ->
    inject_incr
      (watpi_private_initial_injection program protected_identifiers)
      injection ->
    access_mode value_type = By_value chunk ->
    typeof record_expression =
      Tstruct composite_identifier composite_attributes ->
    (forall record_value,
      Clight.eval_expr (Clight.globalenv program) environment temporaries memory
        record_expression record_value ->
      exists record_offset, record_value = Vptr block record_offset) ->
    Clight.eval_expr (Clight.globalenv program) environment temporaries memory
      (Efield record_expression field value_type) value ->
    Val.inject injection value value.
Proof.
  intros program protected_identifiers protected_blocks initial_memory memory
    identifier variable block record_expression composite_identifier
    composite_attributes field value_type chunk value injection environment
    temporaries Havoids Hinitial Hsymbol Hvariable Hin Hframe Hincr Hmode
    Hrecord_type Hrecord Heval.
  inversion Heval; subst; try discriminate.
  inversion H; subst; try discriminate.
  - destruct (Hrecord (Vptr loc ofs0) H4) as [record_offset Hequal].
    inversion Hequal; subst loc ofs0.
    eapply watpr_framed_private_global_deref_inject; eauto.
  - congruence.
Qed.

Definition watpr_interaction_record_expression
    (table_identifier composite_identifier index_identifier : ident) : expr :=
  Ederef
    (Ebinop Oadd
      (Evar table_identifier
        (tarray (Tstruct composite_identifier noattr) 31))
      (Etempvar index_identifier tint)
      (tptr (Tstruct composite_identifier noattr)))
    (Tstruct composite_identifier noattr).

Lemma watpr_interaction_record_expression_has_table_block :
  forall (ge : Clight.genv) environment temporaries memory
      table_identifier composite_identifier index_identifier table_block
      value,
    environment ! table_identifier = None ->
    Genv.find_symbol ge table_identifier = Some table_block ->
    Clight.eval_expr ge environment temporaries memory
      (watpr_interaction_record_expression table_identifier
        composite_identifier index_identifier) value ->
    exists offset, value = Vptr table_block offset.
Proof.
  intros ge environment temporaries memory table_identifier
    composite_identifier index_identifier table_block value Hlocal Hsymbol
    Heval.
  unfold watpr_interaction_record_expression in Heval.
  eapply watpr_eval_copy_deref_preserves_root_block with
    (value_type := Tstruct composite_identifier noattr);
    [| reflexivity | exact Heval].
  intros address_value Haddress.
  eapply watpr_eval_pointer_add_preserves_root_block with
    (left_expression := Evar table_identifier
      (tarray (Tstruct composite_identifier noattr) 31))
    (right_expression := Etempvar index_identifier tint)
    (element_type := Tstruct composite_identifier noattr)
    (signedness := Signed);
    [| reflexivity | exact Haddress].
  intros table_value Htable.
  exists Ptrofs.zero.
  exact (watpr_eval_global_reference_has_symbol_block
    ge environment temporaries memory table_identifier
    (tarray (Tstruct composite_identifier noattr) 31) table_block table_value
    Hlocal Hsymbol eq_refl Htable).
Qed.

Definition watpr_knockback_row_expression
    (table_identifier row_identifier : ident) : expr :=
  Ederef
    (Ebinop Oadd
      (Evar table_identifier (tarray (tarray tuint 3) 3))
      (Etempvar row_identifier tshort)
      (tptr (tarray tuint 3)))
    (tarray tuint 3).

Definition watpr_knockback_address_expression
    (table_identifier row_identifier column_identifier : ident) : expr :=
  Ebinop Oadd
    (watpr_knockback_row_expression table_identifier row_identifier)
    (Etempvar column_identifier tshort)
    (tptr tuint).

Lemma watpr_knockback_address_expression_has_table_block :
  forall (ge : Clight.genv) environment temporaries memory
      table_identifier row_identifier column_identifier table_block value,
    environment ! table_identifier = None ->
    Genv.find_symbol ge table_identifier = Some table_block ->
    Clight.eval_expr ge environment temporaries memory
      (watpr_knockback_address_expression table_identifier row_identifier
        column_identifier) value ->
    exists offset, value = Vptr table_block offset.
Proof.
  intros ge environment temporaries memory table_identifier row_identifier
    column_identifier table_block value Hlocal Hsymbol Heval.
  unfold watpr_knockback_address_expression in Heval.
  eapply watpr_eval_pointer_add_preserves_root_block with
    (left_expression :=
      watpr_knockback_row_expression table_identifier row_identifier)
    (right_expression := Etempvar column_identifier tshort)
    (element_type := tuint) (signedness := Signed);
    [| reflexivity | exact Heval].
  intros row_value Hrow.
  unfold watpr_knockback_row_expression in Hrow.
  eapply watpr_eval_reference_deref_preserves_root_block with
    (value_type := tarray tuint 3);
    [| reflexivity | exact Hrow].
  intros row_address Hrow_address.
  eapply watpr_eval_pointer_add_preserves_root_block with
    (left_expression :=
      Evar table_identifier (tarray (tarray tuint 3) 3))
    (right_expression := Etempvar row_identifier tshort)
    (element_type := tarray tuint 3) (signedness := Signed);
    [| reflexivity | exact Hrow_address].
  intros table_value Htable.
  exists Ptrofs.zero.
  exact (watpr_eval_global_reference_has_symbol_block
    ge environment temporaries memory table_identifier
    (tarray (tarray tuint 3) 3) table_block table_value
    Hlocal Hsymbol eq_refl Htable).
Qed.

Definition watpr_interaction_field_expression
    (table_identifier composite_identifier index_identifier field : ident)
    (field_type : type) : expr :=
  Efield
    (watpr_interaction_record_expression table_identifier
      composite_identifier index_identifier)
    field field_type.

Definition watpr_knockback_read_expression
    (table_identifier row_identifier column_identifier : ident) : expr :=
  Ederef
    (watpr_knockback_address_expression table_identifier row_identifier
      column_identifier)
    tuint.

Lemma watpr_interaction_field_terminal_read_inject :
  forall program protected_identifiers protected_blocks initial_memory memory
      table_identifier table_variable table_block composite_identifier
      index_identifier field field_type chunk value injection environment
      temporaries,
    ActionTableInitializersAvoid program protected_identifiers ->
    Genv.init_mem program = Some initial_memory ->
    Genv.find_symbol (Clight.globalenv program) table_identifier =
      Some table_block ->
    Genv.find_var_info (Clight.globalenv program) table_block =
      Some table_variable ->
    In table_block protected_blocks ->
    Mem.unchanged_on
      (fun candidate_block _ => In candidate_block protected_blocks)
      initial_memory memory ->
    inject_incr
      (watpi_private_initial_injection program protected_identifiers)
      injection ->
    environment ! table_identifier = None ->
    access_mode field_type = By_value chunk ->
    Clight.eval_expr (Clight.globalenv program) environment temporaries memory
      (watpr_interaction_field_expression table_identifier
        composite_identifier index_identifier field field_type) value ->
    Val.inject injection value value.
Proof.
  intros program protected_identifiers protected_blocks initial_memory memory
    table_identifier table_variable table_block composite_identifier
    index_identifier field field_type chunk value injection environment
    temporaries Havoids Hinitial Hsymbol Hvariable Hin Hframe Hincr Hlocal
    Hmode Heval.
  unfold watpr_interaction_field_expression in Heval.
  eapply watpr_eval_field_framed_table_read_inject; eauto.
  - reflexivity.
  - intros record_value Hrecord.
    eapply watpr_interaction_record_expression_has_table_block; eauto.
Qed.

Lemma watpr_knockback_terminal_read_inject :
  forall program protected_identifiers protected_blocks initial_memory memory
      table_identifier table_variable table_block row_identifier
      column_identifier value injection environment temporaries,
    ActionTableInitializersAvoid program protected_identifiers ->
    Genv.init_mem program = Some initial_memory ->
    Genv.find_symbol (Clight.globalenv program) table_identifier =
      Some table_block ->
    Genv.find_var_info (Clight.globalenv program) table_block =
      Some table_variable ->
    In table_block protected_blocks ->
    Mem.unchanged_on
      (fun candidate_block _ => In candidate_block protected_blocks)
      initial_memory memory ->
    inject_incr
      (watpi_private_initial_injection program protected_identifiers)
      injection ->
    environment ! table_identifier = None ->
    Clight.eval_expr (Clight.globalenv program) environment temporaries memory
      (watpr_knockback_read_expression table_identifier row_identifier
        column_identifier) value ->
    Val.inject injection value value.
Proof.
  intros program protected_identifiers protected_blocks initial_memory memory
    table_identifier table_variable table_block row_identifier
    column_identifier value injection environment temporaries Havoids Hinitial
    Hsymbol Hvariable Hin Hframe Hincr Hlocal Heval.
  unfold watpr_knockback_read_expression in Heval.
  eapply watpr_eval_direct_framed_table_read_inject; eauto.
  - reflexivity.
  - intros address_value Haddress.
    eapply watpr_knockback_address_expression_has_table_block; eauto.
Qed.

Definition watpr_selected_interaction_type_read (version : GameVersion) : expr :=
  match version with
  | VersionUS =>
      watpr_interaction_field_expression
        WATWG_USI._sInteractionHandlers WATWG_USI._InteractionHandler
        WATWG_USI._i WATWG_USI._interactType tuint
  | VersionJP =>
      watpr_interaction_field_expression
        WATWG_JPI._sInteractionHandlers WATWG_JPI._InteractionHandler
        WATWG_JPI._i WATWG_JPI._interactType tuint
  end.

Definition watpr_selected_handler_pointer_type (version : GameVersion) : type :=
  match version with
  | VersionUS =>
      tptr (Tfunction
        ((tptr (Tstruct WATWG_USI._MarioState noattr)) :: tuint ::
         (tptr (Tstruct WATWG_USI._Object noattr)) :: nil)
        tuint cc_default)
  | VersionJP =>
      tptr (Tfunction
        ((tptr (Tstruct WATWG_JPI._MarioState noattr)) :: tuint ::
         (tptr (Tstruct WATWG_JPI._Object noattr)) :: nil)
        tuint cc_default)
  end.

Definition watpr_selected_handler_pointer_read (version : GameVersion) : expr :=
  match version with
  | VersionUS =>
      watpr_interaction_field_expression
        WATWG_USI._sInteractionHandlers WATWG_USI._InteractionHandler
        WATWG_USI._i WATWG_USI._handler
        (watpr_selected_handler_pointer_type VersionUS)
  | VersionJP =>
      watpr_interaction_field_expression
        WATWG_JPI._sInteractionHandlers WATWG_JPI._InteractionHandler
        WATWG_JPI._i WATWG_JPI._handler
        (watpr_selected_handler_pointer_type VersionJP)
  end.

Definition watpr_selected_backward_knockback_read
    (version : GameVersion) : expr :=
  match version with
  | VersionUS =>
      watpr_knockback_read_expression WATWG_USI._sBackwardKnockbackActions
        WATWG_USI._terrainIndex WATWG_USI._strengthIndex
  | VersionJP =>
      watpr_knockback_read_expression WATWG_JPI._sBackwardKnockbackActions
        WATWG_JPI._terrainIndex WATWG_JPI._strengthIndex
  end.

Definition watpr_selected_forward_knockback_read
    (version : GameVersion) : expr :=
  match version with
  | VersionUS =>
      watpr_knockback_read_expression WATWG_USI._sForwardKnockbackActions
        WATWG_USI._terrainIndex WATWG_USI._strengthIndex
  | VersionJP =>
      watpr_knockback_read_expression WATWG_JPI._sForwardKnockbackActions
        WATWG_JPI._terrainIndex WATWG_JPI._strengthIndex
  end.

Definition ActionTableFourTerminalReadsInject
    (version : GameVersion) (memory : mem) (injection : meminj)
    (environment : Clight.env) (temporaries : Clight.temp_env) : Prop :=
  (forall value,
    Clight.eval_expr
      (Clight.globalenv (selected_clight_source version))
      environment temporaries memory
      (watpr_selected_interaction_type_read version) value ->
    Val.inject injection value value) /\
  (forall value,
    Clight.eval_expr
      (Clight.globalenv (selected_clight_source version))
      environment temporaries memory
      (watpr_selected_handler_pointer_read version) value ->
    Val.inject injection value value) /\
  (forall value,
    Clight.eval_expr
      (Clight.globalenv (selected_clight_source version))
      environment temporaries memory
      (watpr_selected_backward_knockback_read version) value ->
    Val.inject injection value value) /\
  (forall value,
    Clight.eval_expr
      (Clight.globalenv (selected_clight_source version))
      environment temporaries memory
      (watpr_selected_forward_knockback_read version) value ->
    Val.inject injection value value).

(** The strengthened source recognizer is semantic: every expression that it
    accepts evaluates, when it produces a pointer, to the same protected
    global block.  This is what turns the source-wide checker into a proof for
    reached statements instead of a four-callsite convention. *)
Lemma watpr_table_rooted_pointer_has_table_block :
  forall (ge : Clight.genv) environment temporaries memory table_identifier
      table_block expression value,
    environment ! table_identifier = None ->
    Genv.find_symbol ge table_identifier = Some table_block ->
    wat_is_table_rooted_pointer table_identifier expression = true ->
    Clight.eval_expr ge environment temporaries memory expression value ->
    exists offset, value = Vptr table_block offset.
Proof.
  intros ge environment temporaries memory table_identifier table_block
    expression.
  induction expression; intros value Hlocal Hsymbol Hroot Heval;
    cbn [wat_is_table_rooted_pointer] in Hroot; try discriminate.
  - apply andb_true_iff in Hroot as [Hidentifier Hmode].
    apply Pos.eqb_eq in Hidentifier. subst i.
    unfold wat_access_mode_is_pointer_result in Hmode.
    destruct (access_mode t) eqn:Haccess; try discriminate.
    + exists Ptrofs.zero.
      eapply watpr_eval_global_reference_has_symbol_block; eauto.
    + exists Ptrofs.zero.
      eapply watpr_eval_global_copy_has_symbol_block; eauto.
  - apply andb_true_iff in Hroot as [Haddress Hmode].
    unfold wat_access_mode_is_pointer_result in Hmode.
    destruct (access_mode t) eqn:Haccess; try discriminate.
    + eapply watpr_eval_reference_deref_preserves_root_block;
        [| exact Haccess | exact Heval].
      intros address_value Haddress_eval.
      eapply IHexpression; eauto.
    + eapply watpr_eval_copy_deref_preserves_root_block;
        [| exact Haccess | exact Heval].
      intros address_value Haddress_eval.
      eapply IHexpression; eauto.
  - destruct b; try discriminate.
    repeat rewrite andb_true_iff in Hroot.
    destruct Hroot as [[Hleft Hright] Hclassification].
    destruct (classify_add (typeof expression1) (typeof expression2))
      eqn:Hclass; try discriminate.
    eapply watpr_eval_pointer_add_preserves_root_block;
      [| exact Hclass | exact Heval].
    intros left_value Hleft_eval.
    eapply IHexpression1; eauto.
Qed.

Lemma watpr_eval_rooted_field_framed_table_read_inject :
  forall program protected_identifiers protected_blocks initial_memory memory
      identifier variable block record_expression field value_type chunk value
      injection environment temporaries,
    ActionTableInitializersAvoid program protected_identifiers ->
    Genv.init_mem program = Some initial_memory ->
    Genv.find_symbol (Clight.globalenv program) identifier = Some block ->
    Genv.find_var_info (Clight.globalenv program) block = Some variable ->
    In block protected_blocks ->
    Mem.unchanged_on
      (fun candidate_block _ => In candidate_block protected_blocks)
      initial_memory memory ->
    inject_incr
      (watpi_private_initial_injection program protected_identifiers)
      injection ->
    access_mode value_type = By_value chunk ->
    (forall record_value,
      Clight.eval_expr (Clight.globalenv program) environment temporaries memory
        record_expression record_value ->
      exists record_offset, record_value = Vptr block record_offset) ->
    Clight.eval_expr (Clight.globalenv program) environment temporaries memory
      (Efield record_expression field value_type) value ->
    Val.inject injection value value.
Proof.
  intros program protected_identifiers protected_blocks initial_memory memory
    identifier variable block record_expression field value_type chunk value
    injection environment temporaries Havoids Hinitial Hsymbol Hvariable Hin
    Hframe Hincr Hmode Hrecord Heval.
  inversion Heval; subst; try discriminate.
  inversion H; subst; try discriminate.
  all: match goal with
  | Hrecord_fun : forall record_value,
      Clight.eval_expr _ _ _ _ ?record_expression record_value -> _,
    Hrecord_eval : Clight.eval_expr _ _ _ _ ?record_expression
      (Vptr ?record_block ?record_base_offset) |- _ =>
      destruct (Hrecord_fun (Vptr record_block record_base_offset) Hrecord_eval)
        as [record_offset Hequal];
      inversion Hequal; subst record_block record_base_offset;
      eapply watpr_framed_private_global_deref_inject; eauto
  end.
Qed.

Theorem watpr_recognized_terminal_table_read_inject :
  forall program protected_identifiers protected_blocks initial_memory memory
      identifier variable block expression value injection environment
      temporaries,
    ActionTableInitializersAvoid program protected_identifiers ->
    Genv.init_mem program = Some initial_memory ->
    Genv.find_symbol (Clight.globalenv program) identifier = Some block ->
    Genv.find_var_info (Clight.globalenv program) block = Some variable ->
    In block protected_blocks ->
    Mem.unchanged_on
      (fun candidate_block _ => In candidate_block protected_blocks)
      initial_memory memory ->
    inject_incr
      (watpi_private_initial_injection program protected_identifiers)
      injection ->
    environment ! identifier = None ->
    wat_is_terminal_table_read identifier expression = true ->
    Clight.eval_expr (Clight.globalenv program) environment temporaries memory
      expression value ->
    Val.inject injection value value.
Proof.
  intros program protected_identifiers protected_blocks initial_memory memory
    identifier variable block expression value injection environment
    temporaries Havoids Hinitial Hsymbol Hvariable Hin Hframe Hincr Hlocal
    Hterminal Heval.
  destruct expression; cbn [wat_is_terminal_table_read] in Hterminal;
    try discriminate.
  - repeat rewrite andb_true_iff in Hterminal.
    destruct Hterminal as [[Hcount Hroot] Hmode].
    unfold wat_access_mode_is_value_read in Hmode.
    destruct (access_mode t) eqn:Haccess; try discriminate.
    eapply watpr_eval_direct_framed_table_read_inject; eauto.
    intros address_value Haddress.
    eapply watpr_table_rooted_pointer_has_table_block; eauto.
  - repeat rewrite andb_true_iff in Hterminal.
    destruct Hterminal as [[Hcount Hroot] Hmode].
    unfold wat_access_mode_is_value_read in Hmode.
    destruct (access_mode t) eqn:Haccess; try discriminate.
    eapply watpr_eval_rooted_field_framed_table_read_inject; eauto.
    intros record_value Hrecord.
    eapply watpr_table_rooted_pointer_has_table_block; eauto.
Qed.

Print Assumptions watpr_recognized_terminal_table_read_inject.
