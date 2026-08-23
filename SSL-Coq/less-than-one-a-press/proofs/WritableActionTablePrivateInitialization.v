(** Concrete private self-injection at the selected linked initialization.

    CompCert's generic [Genv.initmem_inject] maps every initialized global
    block.  That injection is intentionally too coarse for the writable action
    tables: privacy requires the three table blocks to be absent from the
    injection while every pointer stored elsewhere remains self-injected.

    This file constructs that filtered identity injection.  The proof follows
    CompCert's own initialized-memory injection argument, but removes precisely
    the protected identifiers.  The whole-game initializer and export census
    supplies the two facts that make the restriction sound: no initialized
    word outside or inside the tables contains their address, and none of the
    table identifiers is public. *)

From Coq Require Import List Lia ZArith.
From compcert Require Import
  AST Clight Coqlib Ctypes Events Globalenvs Integers Linking Maps Memdata Memory Values.
From LessThanOneAPress.Proofs Require Import
  ASTFacts CleanedClightPrograms ClightLinkExecution GameTypes
  LinkedClightPrograms NormalizedClightPrograms SelectedClightTarget
  WritableActionTableAliasExternalClosure
  WritableActionTableWholeGameAliases.

Import ListNotations.
Local Open Scope Z_scope.

(** * Boolean receipts as semantic hypotheses *)

Lemma watpi_ident_mem_complete :
  forall identifier identifiers,
    In identifier identifiers -> ident_mem identifier identifiers = true.
Proof.
  intros identifier identifiers.
  induction identifiers as [| head tail IH]; cbn; intros Hin.
  - contradiction.
  - destruct Hin as [Hequal | Hin].
    + subst head. now rewrite Pos.eqb_refl.
    + rewrite IH by exact Hin. now rewrite orb_true_r.
Qed.

Lemma watpi_ident_mem_false :
  forall identifier identifiers,
    ident_mem identifier identifiers = false -> ~ In identifier identifiers.
Proof.
  intros identifier identifiers Hfalse Hin.
  rewrite (watpi_ident_mem_complete identifier identifiers Hin) in Hfalse.
  discriminate.
Qed.

Definition ActionTableInitializersAvoid
    (program : Clight.program) (protected_identifiers : list ident) : Prop :=
  forall owner variable protected_identifier offset,
    In (owner, Gvar variable) (prog_defs program) ->
    In protected_identifier protected_identifiers ->
    ~ In (Init_addrof protected_identifier offset) (gvar_init variable).

Definition ActionTableIdentifiersPrivate
    (program : Clight.program) (protected_identifiers : list ident) : Prop :=
  forall protected_identifier,
    In protected_identifier protected_identifiers ->
    ~ In protected_identifier (prog_public program).

Lemma watpi_program_initializer_checker_sound :
  forall program protected_identifiers,
    watwg_program_has_no_initializer_alias protected_identifiers program = true ->
    ActionTableInitializersAvoid program protected_identifiers.
Proof.
  intros program protected_identifiers Hchecked owner variable
    protected_identifier offset Hdefinition Hprotected Hinitializer.
  unfold watwg_program_has_no_initializer_alias in Hchecked.
  rewrite forallb_forall in Hchecked.
  specialize (Hchecked (owner, Gvar variable) Hdefinition).
  unfold watwg_global_has_no_initializer_alias in Hchecked.
  cbn in Hchecked.
  assert (Hmentioned :
    existsb (watwg_init_datum_mentions_any protected_identifiers)
      (gvar_init variable) = true).
  { apply existsb_exists.
    exists (Init_addrof protected_identifier offset). split;
      [exact Hinitializer |].
    unfold watwg_init_datum_mentions_any.
    apply existsb_exists. exists protected_identifier. split;
      [exact Hprotected |].
    cbn [initializer_mentions_addrof]. now rewrite Pos.eqb_refl. }
  rewrite Hmentioned in Hchecked. discriminate.
Qed.

Lemma watpi_program_export_checker_sound :
  forall program protected_identifiers,
    watwg_program_does_not_export protected_identifiers program = true ->
    ActionTableIdentifiersPrivate program protected_identifiers.
Proof.
  intros program protected_identifiers Hchecked protected_identifier Hprotected.
  unfold watwg_program_does_not_export in Hchecked.
  rewrite forallb_forall in Hchecked.
  specialize (Hchecked protected_identifier Hprotected).
  rewrite negb_true_iff in Hchecked.
  now apply watpi_ident_mem_false.
Qed.

Lemma watpi_nlist_initializers_avoid :
  forall source_units protected_identifiers,
    watwg_nlist_all
      (watwg_program_has_no_initializer_alias protected_identifiers)
      source_units = true ->
    forall owner variable protected_identifier offset,
      In (owner, Gvar variable) (unit_global_definitions source_units) ->
      In protected_identifier protected_identifiers ->
      ~ In (Init_addrof protected_identifier offset) (gvar_init variable).
Proof.
  intros source_units protected_identifiers Hchecked.
  induction source_units as [source_unit | source_unit rest IH].
  - intros owner variable protected_identifier offset Hdefinition Hprotected.
    cbn [watwg_nlist_all] in Hchecked.
    unfold unit_global_definitions in Hdefinition.
    cbn [nlist_to_list] in Hdefinition.
    change (In (owner, Gvar variable) (prog_defs source_unit ++ []))
      in Hdefinition.
    apply in_app_or in Hdefinition.
    destruct Hdefinition as [Hdefinition | Hempty]; [| contradiction].
    exact (watpi_program_initializer_checker_sound
      source_unit protected_identifiers Hchecked owner variable
      protected_identifier offset Hdefinition Hprotected).
  - cbn [watwg_nlist_all] in Hchecked.
    apply andb_true_iff in Hchecked as [Hunit Hrest].
    intros owner variable protected_identifier offset Hdefinition Hprotected.
    unfold unit_global_definitions in Hdefinition.
    cbn [nlist_to_list] in Hdefinition.
    apply in_app_or in Hdefinition. destruct Hdefinition as [Hunit_definition | Hrest_definition].
    + eapply watpi_program_initializer_checker_sound; eauto.
    + eapply IH; eauto.
Qed.

Lemma watpi_nlist_identifiers_private :
  forall source_units protected_identifiers,
    watwg_nlist_all
      (watwg_program_does_not_export protected_identifiers)
      source_units = true ->
    forall protected_identifier,
      In protected_identifier protected_identifiers ->
      ~ In protected_identifier (unit_public_idents source_units).
Proof.
  intros source_units protected_identifiers Hchecked.
  induction source_units as [source_unit | source_unit rest IH].
  - intros protected_identifier Hprotected Hin.
    cbn [watwg_nlist_all] in Hchecked.
    unfold unit_public_idents in Hin.
    cbn [nlist_to_list] in Hin.
    change (In protected_identifier (prog_public source_unit ++ [])) in Hin.
    apply in_app_or in Hin. destruct Hin as [Hin | Hempty]; [| contradiction].
    exact (watpi_program_export_checker_sound
      source_unit protected_identifiers Hchecked
      protected_identifier Hprotected Hin).
  - cbn [watwg_nlist_all] in Hchecked.
    apply andb_true_iff in Hchecked as [Hunit Hrest].
    intros protected_identifier Hprotected Hin.
    unfold unit_public_idents in Hin.
    cbn [nlist_to_list] in Hin.
    apply in_app_or in Hin. destruct Hin as [Hin | Hin].
    + eapply watpi_program_export_checker_sound; eauto.
    + eapply IH; eauto.
Qed.

Lemma watpi_pointwise_public_provenance :
  forall normalized source_units cleaned_units,
    nlist_forall2
      (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader normalized)
      source_units cleaned_units ->
    incl (unit_public_idents cleaned_units)
         (unit_public_idents source_units).
Proof.
  intros normalized source_units cleaned_units Hpointwise.
  induction Hpointwise;
    cbn [unit_public_idents nlist_to_list] in *.
  - intros identifier Hin.
    unfold unit_public_idents in Hin |- *.
    cbn [nlist_to_list] in Hin |- *.
    apply in_app_or in Hin. apply in_or_app.
    destruct Hin as [Hin | Hempty].
    + left. exact (proj1 (proj2 H) identifier Hin).
    + contradiction.
  - intros identifier Hin. apply in_app_or in Hin.
    apply in_or_app. destruct Hin as [Hin | Hin].
    + left. exact (proj1 (proj2 H) identifier Hin).
    + right. exact (IHHpointwise identifier Hin).
Qed.

Lemma watpi_link_list_public_provenance :
  forall (units : nlist Clight.program) linked identifier,
    link_list units = Some linked ->
    In identifier (prog_public linked) ->
    In identifier (unit_public_idents units).
Proof.
  intros units. induction units as [unit | unit rest IH];
    intros linked identifier Hlink Hpublic;
    cbn [link_list unit_public_idents nlist_to_list] in *.
  - inversion Hlink; subst linked.
    unfold unit_public_idents. cbn [nlist_to_list].
    apply in_or_app. now left.
  - destruct (link_list rest) as [rest_linked |] eqn:Hrest;
      [| discriminate].
    pose proof (clight_link_projects_program_components
      unit rest_linked linked Hlink) as Hast_link.
    destruct (link_prog_inv
      (program_components unit) (program_components rest_linked)
      (program_components linked) Hast_link) as [_ [_ Hlinked]].
    assert (Hpublic_linked :
      prog_public linked = prog_public unit ++ prog_public rest_linked).
    { pose proof (f_equal
        (@AST.prog_public Clight.fundef type) Hlinked) as Hpublic_components.
      exact Hpublic_components. }
    rewrite Hpublic_linked in Hpublic.
    apply in_app_or in Hpublic. apply in_or_app.
    destruct Hpublic as [Hunit | Hrest_public].
    + now left.
    + right. eapply IH; eauto.
Qed.

Lemma watpi_official_public_provenance :
  forall normalized source_units cleaned_units linked,
    nlist_forall2
      (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader normalized)
      source_units cleaned_units ->
    link_list cleaned_units = Some linked ->
    incl (prog_public linked) (unit_public_idents source_units).
Proof.
  intros normalized source_units cleaned_units linked Hpointwise Hlink
    identifier Hpublic.
  eapply watpi_pointwise_public_provenance; [exact Hpointwise |].
  eapply watpi_link_list_public_provenance; eauto.
Qed.

Theorem watpi_us_initialization_facts :
  ActionTableInitializersAvoid us_official_cleaned_slice watwg_us_table_ids /\
  ActionTableIdentifiersPrivate us_official_cleaned_slice watwg_us_table_ids.
Proof.
  destruct (watwg_nlist_all_private_split watwg_us_table_ids us_units
    watwg_us_source_units_are_private) as [Hinitializers Hexports].
  split.
  - intros owner variable protected_identifier offset Hdefinition Hprotected.
    pose proof (us_official_source_definition_provenance
      owner (Gvar variable) Hdefinition) as Hsource_definition.
    exact (watpi_nlist_initializers_avoid
      us_units watwg_us_table_ids Hinitializers owner variable
      protected_identifier offset Hsource_definition Hprotected).
  - intros protected_identifier Hprotected Hpublic.
    pose proof (watpi_official_public_provenance
      us_normalized_semantic_slice us_units us_cleaned_units
      us_official_cleaned_slice us_cleaned_units_pointwise_ownership
      us_cleaned_units_official_link protected_identifier Hpublic)
      as Hsource_public.
    exact (watpi_nlist_identifiers_private
      us_units watwg_us_table_ids Hexports protected_identifier
      Hprotected Hsource_public).
Qed.

Theorem watpi_jp_initialization_facts :
  ActionTableInitializersAvoid jp_official_cleaned_slice watwg_jp_table_ids /\
  ActionTableIdentifiersPrivate jp_official_cleaned_slice watwg_jp_table_ids.
Proof.
  destruct (watwg_nlist_all_private_split watwg_jp_table_ids jp_units
    watwg_jp_source_units_are_private) as [Hinitializers Hexports].
  split.
  - intros owner variable protected_identifier offset Hdefinition Hprotected.
    pose proof (jp_official_source_definition_provenance
      owner (Gvar variable) Hdefinition) as Hsource_definition.
    exact (watpi_nlist_initializers_avoid
      jp_units watwg_jp_table_ids Hinitializers owner variable
      protected_identifier offset Hsource_definition Hprotected).
  - intros protected_identifier Hprotected Hpublic.
    pose proof (watpi_official_public_provenance
      jp_normalized_semantic_slice jp_units jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_pointwise_ownership
      jp_cleaned_units_official_link protected_identifier Hpublic)
      as Hsource_public.
    exact (watpi_nlist_identifiers_private
      jp_units watwg_jp_table_ids Hexports protected_identifier
      Hprotected Hsource_public).
Qed.

Theorem watpi_selected_initialization_facts :
  forall version,
    ActionTableInitializersAvoid
      (selected_clight_source version)
      (watwg_linked_source_table_ids version) /\
    ActionTableIdentifiersPrivate
      (selected_clight_source version)
      (watwg_linked_source_table_ids version).
Proof.
  intros []; [exact watpi_us_initialization_facts |
              exact watpi_jp_initialization_facts].
Qed.


(** * The filtered identity injection *)

Definition watpi_private_initial_injection
    (program : Clight.program) (protected_identifiers : list ident) : meminj :=
  fun source_block =>
    match Genv.invert_symbol (Clight.globalenv program) source_block with
    | Some identifier =>
        if in_dec ident_eq identifier protected_identifiers
        then None
        else Some (source_block, 0)
    | None => None
    end.

Lemma watpi_private_initial_injection_eq :
  forall program protected_identifiers identifier global_block,
    Genv.find_symbol (Clight.globalenv program) identifier = Some global_block ->
    ~ In identifier protected_identifiers ->
    watpi_private_initial_injection program protected_identifiers global_block =
      Some (global_block, 0).
Proof.
  intros program protected_identifiers identifier global_block Hsymbol Hprivate.
  unfold watpi_private_initial_injection.
  erewrite Genv.find_invert_symbol by exact Hsymbol.
  destruct (in_dec ident_eq identifier protected_identifiers);
    [contradiction | reflexivity].
Qed.

Lemma watpi_private_initial_injection_omits :
  forall program protected_identifiers identifier global_block,
    Genv.find_symbol (Clight.globalenv program) identifier = Some global_block ->
    In identifier protected_identifiers ->
    watpi_private_initial_injection program protected_identifiers global_block =
      None.
Proof.
  intros program protected_identifiers identifier global_block Hsymbol Hprotected.
  unfold watpi_private_initial_injection.
  erewrite Genv.find_invert_symbol by exact Hsymbol.
  destruct (in_dec ident_eq identifier protected_identifiers);
    [reflexivity | contradiction].
Qed.

Lemma watpi_private_initial_injection_invert :
  forall program protected_identifiers source_block target_block delta,
    watpi_private_initial_injection program protected_identifiers source_block =
      Some (target_block, delta) ->
    target_block = source_block /\ delta = 0 /\
    exists identifier,
      Genv.find_symbol (Clight.globalenv program) identifier = Some source_block /\
      ~ In identifier protected_identifiers.
Proof.
  intros program protected_identifiers source_block target_block delta Hmapping.
  unfold watpi_private_initial_injection in Hmapping.
  destruct (Genv.invert_symbol (Clight.globalenv program) source_block)
    as [identifier |] eqn:Hidentifier; [| discriminate].
  destruct (in_dec ident_eq identifier protected_identifiers) as
    [Hprotected | Hprivate]; [discriminate |].
  inversion Hmapping; subst target_block delta.
  split; [reflexivity |]. split; [reflexivity |].
  exists identifier. split; [| exact Hprivate].
  now apply Genv.invert_find_symbol.
Qed.

Lemma watpi_clight_public_symbol_is_program_public :
  forall program identifier,
    Senv.public_symbol (Clight.globalenv program) identifier = true ->
    In identifier (prog_public program).
Proof.
  intros program identifier Hpublic.
  change (Genv.public_symbol
    (Genv.globalenv (Ctypes.program_of_program program)) identifier = true)
    in Hpublic.
  unfold Genv.public_symbol in Hpublic.
  rewrite Genv.globalenv_public in Hpublic.
  destruct (Genv.find_symbol
    (Genv.globalenv (Ctypes.program_of_program program)) identifier)
    as [global_block |] eqn:Hsymbol.
  - exact (proj_sumbool_true _ Hpublic).
  - cbn in Hpublic. discriminate.
Qed.

Lemma watpi_private_initial_injection_symbols :
  forall program protected_identifiers,
    ActionTableIdentifiersPrivate program protected_identifiers ->
    symbols_inject
      (watpi_private_initial_injection program protected_identifiers)
      (Clight.globalenv program) (Clight.globalenv program).
Proof.
  intros program protected_identifiers Hprivate.
  unfold symbols_inject.
  split; [reflexivity |].
  split.
  - intros identifier source_block target_block delta Hmapping Hsymbol.
    destruct (watpi_private_initial_injection_invert
      program protected_identifiers source_block target_block delta Hmapping)
      as [-> [-> _]].
    split; [reflexivity | exact Hsymbol].
  - split.
    + intros identifier source_block Hpublic Hsymbol.
      assert (Hnot_protected : ~ In identifier protected_identifiers).
      { intro Hprotected.
        apply (Hprivate identifier Hprotected).
        now apply watpi_clight_public_symbol_is_program_public. }
      exists source_block. split.
      * now apply watpi_private_initial_injection_eq with (identifier := identifier).
      * exact Hsymbol.
    + intros source_block target_block delta Hmapping.
      destruct (watpi_private_initial_injection_invert
        program protected_identifiers source_block target_block delta Hmapping)
        as [-> [-> _]].
      reflexivity.
Qed.


(** * Initialized bytes inject under the filtered identity *)

Local Opaque Genv.globalenv.

Lemma watpi_bytes_of_init_data_list_inject :
  forall program protected_identifiers initializers,
    (forall identifier offset,
      In identifier protected_identifiers ->
      ~ In (Init_addrof identifier offset) initializers) ->
    list_forall2
      (memval_inject
        (watpi_private_initial_injection program protected_identifiers))
      (Genv.bytes_of_init_data_list
        (Genv.globalenv (Ctypes.program_of_program program)) initializers)
      (Genv.bytes_of_init_data_list
        (Genv.globalenv (Ctypes.program_of_program program)) initializers).
Proof.
  intros program protected_identifiers initializers.
  induction initializers as [| initializer rest IH]; cbn; intros Hprivate.
  - constructor.
  - apply list_forall2_app.
    + destruct initializer as
        [i8 | i16 | i32 | i64 | float32 | float64 | space |
         referenced_identifier pointer_offset];
        cbn; try apply inj_bytes_inject.
      * induction (Z.to_nat space); cbn; constructor. constructor. exact IHn.
      * destruct (Genv.find_symbol
          (Genv.globalenv (Ctypes.program_of_program program))
          referenced_identifier)
          as [global_block |] eqn:Hsymbol.
        -- assert (Hidentifier_private :
             ~ In referenced_identifier protected_identifiers).
           { intro Hprotected.
             exact (Hprivate referenced_identifier pointer_offset Hprotected
               (or_introl eq_refl)). }
           apply inj_value_inject. econstructor.
           ++ exact (watpi_private_initial_injection_eq
                program protected_identifiers referenced_identifier
                global_block Hsymbol Hidentifier_private).
           ++ symmetry. apply Ptrofs.add_zero.
        -- apply repeat_Undef_inject_self.
    + apply IH. intros identifier offset Hprotected Hin.
      exact (Hprivate identifier offset Hprotected (or_intror Hin)).
Qed.

Lemma watpi_mem_getN_forall2 :
  forall (relation : memval -> memval -> Prop) contents1 contents2
      address count start,
    list_forall2 relation
      (Mem.getN count start contents1) (Mem.getN count start contents2) ->
    start <= address -> address < start + Z.of_nat count ->
    relation (ZMap.get address contents1) (ZMap.get address contents2).
Proof.
  intros relation contents1 contents2 address count.
  induction count; cbn [Mem.getN]; intros start Hvalues Hlower Hupper.
  - cbn in Hupper. lia.
  - inversion Hvalues; subst.
    rewrite Nat2Z.inj_succ in Hupper.
    destruct (zeq address start).
    + congruence.
    + eapply IHcount; eauto; lia.
Qed.

Lemma watpi_private_initial_mem_inj :
  forall program protected_identifiers initial_memory,
    ActionTableInitializersAvoid program protected_identifiers ->
    Genv.init_mem program = Some initial_memory ->
    Mem.mem_inj
      (watpi_private_initial_injection program protected_identifiers)
      initial_memory initial_memory.
Proof.
  intros program protected_identifiers initial_memory Hprivate Hinitial.
  constructor; intros.
  - destruct (watpi_private_initial_injection_invert
      program protected_identifiers b1 b2 delta H)
      as [-> [-> _]].
    now rewrite Z.add_0_r.
  - destruct (watpi_private_initial_injection_invert
      program protected_identifiers b1 b2 delta H)
      as [-> [-> _]].
    apply Z.divide_0_r.
  - destruct (watpi_private_initial_injection_invert
      program protected_identifiers b1 b2 delta H)
      as [-> [-> [identifier [Hsymbol Hidentifier_private]]]].
    assert (Hdefinition_map : exists definition,
      (prog_defmap (Ctypes.program_of_program program)) ! identifier =
        Some definition).
    { apply prog_defmap_dom.
      eapply Genv.find_symbol_inversion; eauto. }
    destruct Hdefinition_map as [definition Hdefinition_map].
    assert (Hdefinition_in :
      In (identifier, definition) (prog_defs program)).
    { exact (@in_prog_defmap Clight.fundef type
        (Ctypes.program_of_program program) identifier definition
        Hdefinition_map). }
    rewrite Genv.find_def_symbol in Hdefinition_map.
    destruct Hdefinition_map as
      [definition_block [Hdefinition_symbol Hdefinition]].
    assert (Hsymbol_underlying :
      Genv.find_symbol (Genv.globalenv (Ctypes.program_of_program program))
        identifier = Some b1).
    { exact Hsymbol. }
    rewrite Hsymbol_underlying in Hdefinition_symbol.
    inversion Hdefinition_symbol.
    subst definition_block.
    pose proof (@Genv.init_mem_characterization_gen
      Clight.fundef type (Ctypes.program_of_program program)
      initial_memory Hinitial) as Hcharacterization.
    destruct definition as [function_definition | variable].
    + destruct (Hcharacterization b1 (Gfun function_definition) Hdefinition)
        as [_ Hpermissions].
      apply Hpermissions in H0. destruct H0. discriminate.
    + destruct (Hcharacterization b1 (Gvar variable) Hdefinition)
        as [_ [Hpermissions [_ Hbytes]]].
      apply Hpermissions in H0. destruct H0 as [Hoffset Hpermission].
      assert (Hnot_volatile : gvar_volatile variable = false).
      { unfold Genv.perm_globvar in Hpermission.
        destruct (gvar_volatile variable); [inversion Hpermission | reflexivity]. }
      Local Transparent Mem.loadbytes.
      generalize (Hbytes Hnot_volatile).
      unfold Mem.loadbytes.
      destruct Mem.range_perm_dec as [Hrange | Hrange]; intros Hloaded;
        [| discriminate].
      injection Hloaded as Hcontents.
      rewrite Z.add_0_r.
      eapply watpi_mem_getN_forall2 with
        (start := 0)
        (count := Z.to_nat (init_data_list_size (gvar_init variable))).
      * rewrite Hcontents.
        apply watpi_bytes_of_init_data_list_inject.
        intros protected_identifier offset Hprotected Hdatum.
        exact (Hprivate identifier variable protected_identifier offset
          Hdefinition_in Hprotected Hdatum).
      * lia.
      * rewrite Z2Nat.id by
          (apply Z.ge_le; apply init_data_list_size_pos).
        lia.
Qed.


Theorem watpi_private_initial_memory_injects :
  forall program protected_identifiers initial_memory,
    ActionTableInitializersAvoid program protected_identifiers ->
    Genv.init_mem program = Some initial_memory ->
    Mem.inject
      (watpi_private_initial_injection program protected_identifiers)
      initial_memory initial_memory.
Proof.
  intros program protected_identifiers initial_memory Hprivate Hinitial.
  constructor; intros.
  - now apply watpi_private_initial_mem_inj.
  - destruct (watpi_private_initial_injection program protected_identifiers b)
      as [[target_block delta] |] eqn:Hmapping; [| reflexivity].
    exfalso. apply H.
    destruct (watpi_private_initial_injection_invert
      program protected_identifiers b target_block delta Hmapping)
      as [_ [_ [identifier [Hsymbol _]]]].
    eapply Genv.find_symbol_not_fresh; eauto.
  - destruct (watpi_private_initial_injection_invert
      program protected_identifiers b b' delta H)
      as [-> [_ [identifier [Hsymbol _]]]].
    eapply Genv.find_symbol_not_fresh; eauto.
  - red. intros.
    destruct (watpi_private_initial_injection_invert
      program protected_identifiers b1 b1' delta1 H0)
      as [-> [-> _]].
    destruct (watpi_private_initial_injection_invert
      program protected_identifiers b2 b2' delta2 H1)
      as [-> [-> _]].
    now left.
  - destruct (watpi_private_initial_injection_invert
      program protected_identifiers b b' delta H)
      as [-> [-> _]].
    split; [lia |].
    generalize (Ptrofs.unsigned_range_2 ofs). lia.
  - destruct (watpi_private_initial_injection_invert
      program protected_identifiers b1 b2 delta H)
      as [-> [-> _]].
    left. now rewrite Z.add_0_r in H0.
Qed.

(** * Concrete selected start *)

Lemma watpi_forall2_resolved_block_is_omitted :
  forall program protected_identifiers protected_blocks,
    Forall2
      (fun identifier global_block =>
        Genv.find_symbol (Clight.globalenv program) identifier =
          Some global_block)
      protected_identifiers protected_blocks ->
    forall protected_block,
      In protected_block protected_blocks ->
      watpi_private_initial_injection
        program protected_identifiers protected_block = None.
Proof.
  intros program protected_identifiers protected_blocks Hresolved
    protected_block Hin.
  destruct (watwg_forall2_right_has_left _ _ _ _ _ _ Hresolved Hin)
    as [identifier [Hprotected Hsymbol]].
  eapply watpi_private_initial_injection_omits; eauto.
Qed.

Theorem selected_source_initial_private_external_ready :
  forall version initial_memory protected_blocks,
    Genv.init_mem (selected_clight_source version) = Some initial_memory ->
    LinkedSourceActionTableBlocks version protected_blocks ->
    ActionTablePrivateExternalReady
      (Clight.globalenv (selected_clight_source version))
      [Vnullptr] initial_memory protected_blocks.
Proof.
  intros version initial_memory protected_blocks Hinitial Hblocks.
  destruct (watpi_selected_initialization_facts version)
    as [Hinitializers Hprivate].
  exists (watpi_private_initial_injection
    (selected_clight_source version)
    (watwg_linked_source_table_ids version)).
  split.
  - now apply watpi_private_initial_injection_symbols.
  - split.
    + now apply watpi_private_initial_memory_injects.
    + split.
      * repeat constructor.
      * destruct Hblocks as [_ Hresolved].
        now apply watpi_forall2_resolved_block_is_omitted.
Qed.

Definition WritableActionTablePrivateInitializationClosure : Prop :=
  forall version initial_memory protected_blocks,
    Genv.init_mem (selected_clight_source version) = Some initial_memory ->
    LinkedSourceActionTableBlocks version protected_blocks ->
    ActionTablePrivateExternalReady
      (Clight.globalenv (selected_clight_source version))
      [Vnullptr] initial_memory protected_blocks.

Theorem writable_action_table_private_initialization_closure_holds :
  WritableActionTablePrivateInitializationClosure.
Proof.
  exact selected_source_initial_private_external_ready.
Qed.
