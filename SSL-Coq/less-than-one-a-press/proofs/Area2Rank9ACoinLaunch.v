(** The surviving mobile producer: a normal spawned yellow coin.
    Execute its actual post-RNG vertical-launch fragment in the selected
    program. The random call has ALREADY returned at this boundary; no RNG
    seed, Goomba defeat, floor, or controller-reachable installation is assumed
    to have been proved by this local theorem. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Events Floats Globalenvs Integers Linking Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_behavior_actions jp_behavior_actions.
From LessThanOneAPress.Proofs Require Import GameTypes Area2Rank9ACoinProducers
  Area2Rank11BodyResolution EyerokRank15LiveMovement
  CleanedClightPrograms ClightLinkExecution GlobalInterfaceStructural
  JPSourceSymbolTransport JPWarpLevelEntryResolution LinkedClightPrograms
  NormalizedClightPrograms SelectedClightTarget SuccessfulMakeProgramResolution
  USViewportRepairedNamesNorepet USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USWarpLevelSourceUnionReceipt USWholeASTTagRepair.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition rank9ac_launch_body version := match version with
| VersionUS => us_behavior_actions.f_bhv_spawned_coin_init
| VersionJP => jp_behavior_actions.f_bhv_spawned_coin_init end.

Lemma rank9ac_launch_us_source_receipt :
  nth_error R9CA.global_definitions
    (rank11_definition_index R9CA._bhv_spawned_coin_init R9CA.global_definitions) =
  Some (R9CA._bhv_spawned_coin_init, Gfun (Internal (rank9ac_launch_body VersionUS))).
Proof. vm_compute. reflexivity. Qed.

Lemma rank9ac_launch_us_source_member :
  In (R9CA._bhv_spawned_coin_init, Gfun (Internal (rank9ac_launch_body VersionUS)))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at 25 us_units).
  - exact (us_nlist_at_nIn _ 25 us_units).
  - eapply nth_error_In. exact rank9ac_launch_us_source_receipt.
Qed.

Lemma rank9ac_launch_us_selection :
  us_normalized_global_definition_map ! R9CA._bhv_spawned_coin_init =
    Some (Gfun (Internal (rank9ac_launch_body VersionUS))).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance
      (unit_global_definitions us_units)).
  - exact rank9ac_launch_us_source_member.
Qed.

Lemma rank9ac_launch_us_no_repair :
  us_selected_definition_needs_viewport_repair
    (R9CA._bhv_spawned_coin_init, Gfun (Internal (rank9ac_launch_body VersionUS))) = false.
Proof. vm_compute. reflexivity. Qed.

Lemma rank9ac_launch_us_selected_member :
  In (R9CA._bhv_spawned_coin_init, Gfun (Internal (rank9ac_launch_body VersionUS)))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    rewrite rank9ac_launch_us_no_repair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim.
    exact rank9ac_launch_us_selection.
Qed.

Lemma rank9ac_launch_jp_source_receipt :
  (prog_defmap (nlist_at 25 jp_cleaned_units)) ! R9CA._bhv_spawned_coin_init =
    Some (Gfun (Internal (rank9ac_launch_body VersionJP))).
Proof. vm_compute. reflexivity. Qed.

Theorem rank9ac_launch_selected_body_resolves : forall version,
  exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      R9CA._bhv_spawned_coin_init = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      function_block = Some (Internal (rank9ac_launch_body version)).
Proof.
  intros [].
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact rank9ac_launch_us_selected_member.
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link
      (nlist_at 25 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 25 jp_cleaned_units).
    + exact rank9ac_launch_jp_source_receipt.
Qed.

Definition rank9ac_f32 bits := Float32.of_bits (Int.repr bits).
Definition rank9ac_launch_velocity random base :=
  Float32.add (Float32.add (Float32.mul random (rank9ac_f32 1092616192))
    (rank9ac_f32 1106247680)) base.

Definition rank9ac_launch_rhs : expr :=
  Ebinop Oadd
    (Ebinop Oadd
      (Ebinop Omul (Etempvar R9CA._t'1 tfloat)
        (Econst_single (rank9ac_f32 1092616192) tfloat) tfloat)
      (Econst_single (rank9ac_f32 1106247680) tfloat) tfloat)
    (Etempvar R9CA._t'9 tfloat) tfloat.

Definition rank9ac_launch_fragment version : statement :=
  Ssequence (Sset R9CA._t'7 rank15_current_object_expression)
  (Ssequence (Sset R9CA._t'8 rank15_current_object_expression)
  (Ssequence (Sset R9CA._t'9
    (rank15_raw_float_expression version R9CA._t'8
      (Econst_int (Int.repr 34) tint)))
    (Sassign (rank15_raw_float_expression version R9CA._t'7
      (Econst_int (Int.repr 10) tint)) rank9ac_launch_rhs))).

Theorem rank9ac_launch_fragment_is_generated : forall version,
  exists tail,
    fn_body (rank9ac_launch_body version) =
      Ssequence
        (Ssequence
          (Scall (Some R9CA._t'1)
            (Evar R9CA._random_float (Tfunction [] tfloat cc_default)) [])
          (rank9ac_launch_fragment version)) tail.
Proof. intros []; eexists; reflexivity. Qed.

Definition rank9ac_launch_locals locals object base :=
  PTree.set R9CA._t'9 (Vsingle base)
    (PTree.set R9CA._t'8 object (PTree.set R9CA._t'7 object locals)).

Theorem rank9ac_launch_executes_from_live_memory :
  forall version environment locals memory current_block coin_block
      coin_offset random base,
    let ge := Clight.globalenv (selected_clight_target version) in
    let address := rank15_raw_address coin_offset (Int.repr 10) in
    environment ! R9CA._gCurrentObject = None ->
    Genv.find_symbol ge R9CA._gCurrentObject = Some current_block ->
    Mem.load Mptr memory current_block 0 = Some (Vptr coin_block coin_offset) ->
    locals ! R9CA._t'1 = Some (Vsingle random) ->
    Mem.load Mfloat32 memory coin_block
      (Ptrofs.unsigned (rank15_raw_address coin_offset (Int.repr 34))) =
      Some (Vsingle base) ->
    Mem.valid_access memory Mfloat32 coin_block (Ptrofs.unsigned address) Writable ->
    exists after,
      Mem.store Mfloat32 memory coin_block (Ptrofs.unsigned address)
        (Vsingle (rank9ac_launch_velocity random base)) = Some after /\
      ClightBigstep.Clight2.exec_stmt ge environment locals memory
        (rank9ac_launch_fragment version) E0
        (rank9ac_launch_locals locals (Vptr coin_block coin_offset) base)
        after Out_normal /\
      Mem.load Mfloat32 after coin_block (Ptrofs.unsigned address) =
        Some (Vsingle (rank9ac_launch_velocity random base)) /\
      (forall chunk read_block read_offset,
        read_block <> coin_block \/
        read_offset + size_chunk chunk <= Ptrofs.unsigned address \/
        Ptrofs.unsigned address + 4 <= read_offset ->
        Mem.load chunk after read_block read_offset =
          Mem.load chunk memory read_block read_offset).
Proof.
  intros version environment locals memory current_block coin_block
    coin_offset random base ge address Hnotlocal Hsymbol Hcurrent Hrandom Hbase Haccess.
  destruct (Mem.valid_access_store memory Mfloat32 coin_block
    (Ptrofs.unsigned address) (Vsingle (rank9ac_launch_velocity random base)) Haccess)
    as [after Hstore].
  exists after. split; [exact Hstore |]. split.
  - unfold rank9ac_launch_fragment, rank9ac_launch_locals.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + apply exec_Sset. eapply rank15_current_object_read; eauto.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply rank15_current_object_read; eauto.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- apply exec_Sset. eapply rank15_raw_float_read.
           ++ apply PTree.gss.
           ++ constructor.
           ++ reflexivity.
           ++ exact Hbase.
        -- eapply exec_Sassign with (loc := coin_block) (ofs := address) (bf := Full)
             (v2 := Vsingle (rank9ac_launch_velocity random base))
             (v := Vsingle (rank9ac_launch_velocity random base)).
           ++ eapply rank15_raw_float_lvalue.
              ** repeat rewrite PTree.gso by discriminate. apply PTree.gss.
              ** constructor.
              ** reflexivity.
           ++ unfold rank9ac_launch_rhs, rank9ac_launch_velocity.
              eapply eval_Ebinop.
              ** eapply eval_Ebinop.
                 --- eapply eval_Ebinop.
                     +++ apply eval_Etempvar.
                         repeat rewrite PTree.gso by discriminate. exact Hrandom.
                     +++ constructor.
                     +++ reflexivity.
                 --- constructor.
                 --- reflexivity.
              ** apply eval_Etempvar. apply PTree.gss.
              ** reflexivity.
           ++ reflexivity.
           ++ eapply assign_loc_value with (chunk := Mfloat32); [reflexivity | exact Hstore].
  - split.
    + exact (Mem.load_store_same _ _ _ _ _ _ Hstore).
    + intros chunk read_block read_offset Hseparate.
      eapply Mem.load_store_other; [exact Hstore |].
      destruct Hseparate as [Hblock | [Hbelow | Habove]]; auto.
Qed.

(** At an object base, the generated launch writes byte 176, NOT position
    bytes 160/164/168. There is no in-place teleport in this fragment. *)
Theorem rank9ac_launch_store_preserves_xyz :
  forall memory after coin_block velocity,
    Mem.store Mfloat32 memory coin_block 176 (Vsingle velocity) = Some after ->
    forall offset, In offset [160; 164; 168] ->
      Mem.load Mfloat32 after coin_block offset =
        Mem.load Mfloat32 memory coin_block offset.
Proof.
  intros memory after coin_block velocity Hstore offset Hin.
  eapply Mem.load_store_other; [exact Hstore |].
  right. left. cbn in Hin. cbn.
  repeat destruct Hin as [<- | Hin]; try contradiction; lia.
Qed.

(** Concrete endpoint arithmetic only. 65535/65536 is the largest ordinary
    random_float result, but connecting a specific random return or proving
    a whole trajectory for every return is not asserted by these examples. *)
Theorem rank9ac_normal_loot_launch_endpoint_arithmetic :
  Float32.to_bits (rank9ac_launch_velocity Float32.zero (rank9ac_f32 1101004800)) =
    Int.repr 1112014848 /\
  Float32.to_bits (rank9ac_launch_velocity (rank9ac_f32 1065352960)
    (rank9ac_f32 1101004800)) = Int.repr 1114636248 /\
  Float32.cmp Clt (rank9ac_launch_velocity (rank9ac_f32 1065352960)
    (rank9ac_f32 1101004800)) (rank9ac_f32 1114636288) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition Rank9ACoinLaunchBoundary : Prop :=
  (forall version, exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      R9CA._bhv_spawned_coin_init = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      function_block = Some (Internal (rank9ac_launch_body version))) /\
  (forall version environment locals memory current_block coin_block
      coin_offset random base,
    environment ! R9CA._gCurrentObject = None ->
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      R9CA._gCurrentObject = Some current_block ->
    Mem.load Mptr memory current_block 0 = Some (Vptr coin_block coin_offset) ->
    locals ! R9CA._t'1 = Some (Vsingle random) ->
    Mem.load Mfloat32 memory coin_block
      (Ptrofs.unsigned (rank15_raw_address coin_offset (Int.repr 34))) = Some (Vsingle base) ->
    Mem.valid_access memory Mfloat32 coin_block
      (Ptrofs.unsigned (rank15_raw_address coin_offset (Int.repr 10))) Writable ->
    exists after,
      ClightBigstep.Clight2.exec_stmt
        (Clight.globalenv (selected_clight_target version)) environment locals memory
        (rank9ac_launch_fragment version) E0
        (rank9ac_launch_locals locals (Vptr coin_block coin_offset) base) after Out_normal /\
      Mem.load Mfloat32 after coin_block
        (Ptrofs.unsigned (rank15_raw_address coin_offset (Int.repr 10))) =
        Some (Vsingle (rank9ac_launch_velocity random base))).

Theorem rank9ac_coin_launch_boundary_checked : Rank9ACoinLaunchBoundary.
Proof.
  split; [exact rank9ac_launch_selected_body_resolves |].
  intros version environment locals memory current_block coin_block coin_offset random base
    Hnotlocal Hsymbol Hcurrent Hrandom Hbase Haccess.
  destruct (rank9ac_launch_executes_from_live_memory version environment locals memory
    current_block coin_block coin_offset random base Hnotlocal Hsymbol Hcurrent Hrandom
    Hbase Haccess) as (after & _ & Hexec & Hload & _).
  exists after. auto.
Qed.
