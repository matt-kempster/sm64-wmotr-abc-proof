(** A real memory/step case for Rank 15, rather than an assumed projection.

    The generated position-update fragment reloads [gCurrentObject], reads
    that object's Y and vertical velocity, then stores their Float32 sum.
    The proof below executes that exact fragment, derives its memory reads,
    and frames all disjoint observations.  It does not assume a projected
    endpoint or an abstract hand transition.  Reaching the fragment with a
    particular current hand, and the preceding action/floor/velocity choices,
    are separate obligations. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Errors Events Floats Globalenvs Integers Maps Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightFacts ClightProjectionChronology
  CompositeLayoutRefinement EntryMemory FirstTargetRefinement
  EyerokRank15DynamicSupport EyerokRank15LiveProjection GameTypes
  EyerokRank15MovementBodyResolution
  NormalizedClightPrograms OrdinaryArea1EntryMemory RetailExternalFrames
  SelectedClightTarget SuccessfulMakeProgramResolution
  USViewportRepairedProgramCertificate USViewportRepairedProgramSelection
  USWholeASTTagRepair.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition rank15_raw_union_tag (version : GameVersion) : ident :=
  match version with VersionUS => UOH.__764 | VersionJP => JOH.__727 end.

Definition rank15_current_object_expression : expr :=
  Evar UOH._gCurrentObject (tptr (Tstruct UOH._Object noattr)).

Definition rank15_raw_float_expression
    (version : GameVersion) (temporary : ident) (index : expr) : expr :=
  Ederef
    (Ebinop Oadd
      (Efield
        (Efield
          (Ederef (Etempvar temporary (tptr (Tstruct UOH._Object noattr)))
            (Tstruct UOH._Object noattr))
          UOH._rawData (Tunion (rank15_raw_union_tag version) noattr))
        UOH._asF32 (tarray tfloat 80)) index (tptr tfloat)) tfloat.

Definition rank15_y_index : expr :=
  Ebinop Oadd (Econst_int (Int.repr 6) tint)
    (Econst_int (Int.repr 1) tint) tint.

Definition rank15_vy_index : expr := Econst_int (Int.repr 10) tint.

Definition rank15_position_update_fragment (version : GameVersion) : statement :=
  Ssequence (Sset UOH._t'8 rank15_current_object_expression)
  (Ssequence (Sset UOH._t'9 rank15_current_object_expression)
  (Ssequence (Sset UOH._t'10
    (rank15_raw_float_expression version UOH._t'9 rank15_y_index))
  (Ssequence (Sset UOH._t'11 rank15_current_object_expression)
  (Ssequence (Sset UOH._t'12
    (rank15_raw_float_expression version UOH._t'11 rank15_vy_index))
    (Sassign (rank15_raw_float_expression version UOH._t'8 rank15_y_index)
      (Ebinop Oadd (Etempvar UOH._t'10 tfloat)
        (Etempvar UOH._t'12 tfloat) tfloat)))))).

Definition rank15_movement_body (version : GameVersion) : function :=
  match version with
  | VersionUS => UOH.f_cur_obj_move_y_and_get_water_level
  | VersionJP => JOH.f_cur_obj_move_y_and_get_water_level
  end.

Theorem rank15_generated_position_fragment_is_exact : forall version,
  exists velocity clamp tail,
    fn_body (rank15_movement_body version) =
      Ssequence velocity (Ssequence clamp
        (Ssequence (rank15_position_update_fragment version) tail)).
Proof. intros []; do 3 eexists; reflexivity. Qed.

(** Obtain the selected layout through the already checked header, without
    reducing the entire linked program or assuming an arbitrary layout. *)
Lemma rank15_make_program_from_build_result_types :
  forall types definitions public main result Hresult program,
    make_program_from_build_result types definitions public main result Hresult =
      OK program ->
    prog_types program = types.
Proof.
  intros types definitions public main result Hresult program Hmake.
  destruct result; [cbn in Hmake; inversion Hmake; reflexivity | discriminate].
Qed.

Lemma rank15_make_program_success_types :
  forall types definitions public main (program : Clight.program),
    Ctypes.make_program types definitions public main = OK program ->
    prog_types program = types.
Proof.
  intros types definitions public main program Hmake.
  eapply rank15_make_program_from_build_result_types
    with (result := build_composite_env types) (Hresult := eq_refl).
  exact Hmake.
Qed.

Lemma rank15_successful_make_program_types :
  forall types definitions public main fallback result,
    result = Ctypes.make_program types definitions public main ->
    program_result_succeeds result = true ->
    prog_types (select_successful_program result fallback) = types.
Proof.
  intros types definitions public main fallback result Hresult Hsuccess.
  destruct result as [program | error]; [| discriminate].
  cbn. eapply rank15_make_program_success_types. symmetry. exact Hresult.
Qed.

(** Small pointer identities are proved with the real pool dimensions. *)
Lemma rank15_pool_slot_offset_in_pointer_range : forall slot,
  (slot < object_pool_capacity)%nat ->
  0 <= object_slot_offset slot /\
  object_slot_offset slot + object_size <= Ptrofs.max_unsigned.
Proof.
  intros slot Hslot.
  unfold object_pool_capacity in Hslot.
  unfold object_slot_offset, object_size.
  change (0 <= 608 * Z.of_nat slot /\
    608 * Z.of_nat slot + 608 <= 4294967295).
  lia.
Qed.

Definition rank15_selected_header_environment (version : GameVersion) :
    composite_env :=
  match version with
  | VersionUS => us_viewport_repaired_composite_env
  | VersionJP => jp_normalized_composite_env
  end.

Lemma rank15_selected_header_environment_exact : forall version,
  rank15_selected_header_environment version =
    prog_comp_env (selected_clight_target version).
Proof.
  intros []; unfold rank15_selected_header_environment, selected_clight_target.
  - apply normalized_composite_env_matches_program_types.
    unfold us_viewport_repaired_program.
    eapply rank15_successful_make_program_types
      with (definitions := us_viewport_repaired_global_definitions)
        (public := prog_public us_official_cleaned_slice)
        (main := prog_main us_official_cleaned_slice)
        (result := us_viewport_repaired_program_result).
    + reflexivity.
    + rewrite <- us_viewport_repaired_build_flag_is_result_success.
      exact us_viewport_repaired_program_success_flag_checked.
  - apply normalized_composite_env_matches_program_types.
    rewrite jp_official_cleaned_slice_uses_normalized_composite_header.
    exact jp_normalized_slice_types_are_normalized_composites.
Qed.

Definition rank15_raw_layout_check
    (environment : composite_env) (union_tag : ident) : bool :=
  match environment ! UOH._Object, environment ! union_tag with
  | Some object_type, Some raw_type =>
      match field_offset environment UOH._rawData (co_members object_type),
        union_field_offset environment UOH._asF32 (co_members raw_type) with
      | OK (object_offset, Full), OK (raw_offset, Full) =>
          Z.eqb object_offset 136 && Z.eqb raw_offset 0
      | _, _ => false
      end
  | _, _ => false
  end.

Lemma rank15_selected_raw_layout_checked : forall version,
  rank15_raw_layout_check (rank15_selected_header_environment version)
    (rank15_raw_union_tag version) = true.
Proof. intros []; vm_compute; reflexivity. Qed.

Lemma rank15_raw_layout_check_sound : forall environment union_tag,
  rank15_raw_layout_check environment union_tag = true ->
  exists object_type raw_type,
    environment ! UOH._Object = Some object_type /\
    environment ! union_tag = Some raw_type /\
    field_offset environment UOH._rawData (co_members object_type) =
      OK (136, Full) /\
    union_field_offset environment UOH._asF32 (co_members raw_type) =
      OK (0, Full).
Proof.
  intros environment union_tag Hlayout.
  unfold rank15_raw_layout_check in Hlayout.
  destruct (environment ! UOH._Object) as [object_type |] eqn:Hobject;
    try discriminate.
  destruct (environment ! union_tag) as [raw_type |] eqn:Hraw; try discriminate.
  destruct (field_offset environment UOH._rawData (co_members object_type))
    as [[object_offset object_bits] |] eqn:Hobject_offset; try discriminate.
  destruct (union_field_offset environment UOH._asF32 (co_members raw_type))
    as [[raw_offset raw_bits] |] eqn:Hraw_offset;
    [| destruct object_bits; discriminate].
  destruct object_bits, raw_bits; cbn in Hlayout; try discriminate.
  apply andb_true_iff in Hlayout as [Hobject_value Hraw_value].
  apply Z.eqb_eq in Hobject_value. apply Z.eqb_eq in Hraw_value.
  subst object_offset raw_offset.
  exists object_type, raw_type. repeat split; try assumption; try reflexivity.
Qed.

Lemma rank15_selected_raw_layout : forall version,
  let ge := Clight.globalenv (selected_clight_target version) in
  exists object_type raw_type,
    (genv_cenv ge) ! UOH._Object = Some object_type /\
    (genv_cenv ge) ! (rank15_raw_union_tag version) = Some raw_type /\
    field_offset ge UOH._rawData (co_members object_type) = OK (136, Full) /\
    union_field_offset ge UOH._asF32 (co_members raw_type) = OK (0, Full).
Proof.
  intros version ge. apply rank15_raw_layout_check_sound.
  pose proof (rank15_selected_raw_layout_checked version) as Hlayout.
  rewrite rank15_selected_header_environment_exact in Hlayout.
  exact Hlayout.
Qed.

Definition rank15_raw_address (base : ptrofs) (index : int) : ptrofs :=
  Ptrofs.add (Ptrofs.add base (Ptrofs.repr 136))
    (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints index)).

Section RAW_EVALUATION.
Variable version : GameVersion.
Let ge := Clight.globalenv (selected_clight_target version).

Lemma rank15_raw_float_lvalue :
  forall environment locals memory temporary index_expression index
      object_block object_offset,
    locals ! temporary = Some (Vptr object_block object_offset) ->
    eval_expr ge environment locals memory index_expression (Vint index) ->
    typeof index_expression = tint ->
    eval_lvalue ge environment locals memory
      (rank15_raw_float_expression version temporary index_expression)
      object_block (rank15_raw_address object_offset index) Full.
Proof.
  intros environment locals memory temporary index_expression index
    object_block object_offset Htemporary Hindex Hindex_type.
  destruct (rank15_selected_raw_layout version)
    as (object_type & raw_type & Hobject & Hraw & Hobject_offset & Hraw_offset).
  unfold rank15_raw_float_expression, rank15_raw_address.
  apply eval_Ederef.
  eapply eval_Ebinop.
  - eapply eval_Elvalue.
    + eapply eval_Efield_union with (co := raw_type).
      * eapply eval_Elvalue.
        -- eapply eval_Efield_struct with (co := object_type).
           ++ eapply eval_Elvalue.
              ** apply eval_Ederef. apply eval_Etempvar. exact Htemporary.
              ** apply deref_loc_copy. reflexivity.
           ++ reflexivity.
           ++ exact Hobject.
           ++ exact Hobject_offset.
        -- apply deref_loc_copy. reflexivity.
      * reflexivity.
      * exact Hraw.
      * exact Hraw_offset.
    + apply deref_loc_reference. reflexivity.
  - exact Hindex.
  - rewrite Hindex_type. cbn.
    rewrite Ptrofs.add_zero. reflexivity.
Qed.

Lemma rank15_raw_float_read :
  forall environment locals memory temporary index_expression index
      object_block object_offset value,
    locals ! temporary = Some (Vptr object_block object_offset) ->
    eval_expr ge environment locals memory index_expression (Vint index) ->
    typeof index_expression = tint ->
    Mem.load Mfloat32 memory object_block
      (Ptrofs.unsigned (rank15_raw_address object_offset index)) =
      Some (Vsingle value) ->
    eval_expr ge environment locals memory
      (rank15_raw_float_expression version temporary index_expression)
      (Vsingle value).
Proof.
  intros. eapply eval_Elvalue.
  - eapply rank15_raw_float_lvalue; eauto.
  - eapply deref_loc_value with (chunk := Mfloat32); eauto.
Qed.

End RAW_EVALUATION.

Definition rank15_position_update_locals
    (locals : temp_env) (object : val) (y velocity : float32) : temp_env :=
  PTree.set UOH._t'12 (Vsingle velocity)
    (PTree.set UOH._t'11 object
      (PTree.set UOH._t'10 (Vsingle y)
        (PTree.set UOH._t'9 object (PTree.set UOH._t'8 object locals)))).

Lemma rank15_current_object_read :
  forall (ge : Clight.genv) environment locals memory current_block object,
    environment ! UOH._gCurrentObject = None ->
    Genv.find_symbol ge UOH._gCurrentObject = Some current_block ->
    Mem.load Mptr memory current_block 0 = Some object ->
    eval_expr ge environment locals memory
      rank15_current_object_expression object.
Proof.
  intros ge environment locals memory current_block object Hnotlocal Hsymbol Hload.
  unfold rank15_current_object_expression.
  eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
  - eapply eval_Evar_global; eauto.
  - eapply deref_loc_value with (chunk := Mptr); eauto.
Qed.

Lemma rank15_y_index_evaluates : forall ge environment locals memory,
  eval_expr ge environment locals memory rank15_y_index
    (Vint (Int.repr 7)).
Proof.
  intros. unfold rank15_y_index.
  eapply eval_Ebinop; [constructor | constructor | reflexivity].
Qed.

Lemma rank15_vy_index_evaluates : forall ge environment locals memory,
  eval_expr ge environment locals memory rank15_vy_index
    (Vint (Int.repr 10)).
Proof. intros. constructor. Qed.

Ltac rank15_temporary :=
  repeat (rewrite PTree.gss || rewrite PTree.gso by discriminate);
  reflexivity.

(** This is a constructed execution, not a hypothesis that the fragment
    preserves the projection.  Writable permission is the ordinary successful
    in-bounds store condition.  Both inputs are actual loads from one object. *)
Theorem rank15_position_fragment_executes_from_memory :
  forall version environment locals memory current_block object_block
      object_offset y velocity,
    let ge := Clight.globalenv (selected_clight_target version) in
    let address := rank15_raw_address object_offset (Int.repr 7) in
    environment ! UOH._gCurrentObject = None ->
    Genv.find_symbol ge UOH._gCurrentObject = Some current_block ->
    Mem.load Mptr memory current_block 0 =
      Some (Vptr object_block object_offset) ->
    Mem.load Mfloat32 memory object_block (Ptrofs.unsigned address) =
      Some (Vsingle y) ->
    Mem.load Mfloat32 memory object_block
      (Ptrofs.unsigned (rank15_raw_address object_offset (Int.repr 10))) =
      Some (Vsingle velocity) ->
    Mem.valid_access memory Mfloat32 object_block
      (Ptrofs.unsigned address) Writable ->
    exists after,
      Mem.store Mfloat32 memory object_block (Ptrofs.unsigned address)
        (Vsingle (Float32.add y velocity)) = Some after /\
      ClightBigstep.Clight2.exec_stmt ge environment locals memory
        (rank15_position_update_fragment version) E0
        (rank15_position_update_locals locals
          (Vptr object_block object_offset) y velocity) after Out_normal /\
      Mem.load Mfloat32 after object_block (Ptrofs.unsigned address) =
        Some (Vsingle (Float32.add y velocity)) /\
      (forall chunk read_block read_offset,
        read_block <> object_block \/
        read_offset + size_chunk chunk <= Ptrofs.unsigned address \/
        Ptrofs.unsigned address + 4 <= read_offset ->
        Mem.load chunk after read_block read_offset =
          Mem.load chunk memory read_block read_offset).
Proof.
  intros version environment locals memory current_block object_block
    object_offset y velocity ge address Hnotlocal Hsymbol Hcurrent Hy Hvelocity
    Hwritable.
  destruct (Mem.valid_access_store memory Mfloat32 object_block
    (Ptrofs.unsigned address) (Vsingle (Float32.add y velocity)) Hwritable)
    as [after Hstore].
  exists after. split; [exact Hstore |].
  split.
  - unfold rank15_position_update_fragment, rank15_position_update_locals.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + apply exec_Sset. eapply rank15_current_object_read; eauto.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply rank15_current_object_read; eauto.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- apply exec_Sset. eapply rank15_raw_float_read.
           ++ apply PTree.gss.
           ++ apply rank15_y_index_evaluates.
           ++ reflexivity.
           ++ exact Hy.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ apply exec_Sset. eapply rank15_current_object_read; eauto.
           ++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
              ** apply exec_Sset. eapply rank15_raw_float_read.
                 --- apply PTree.gss.
                 --- apply rank15_vy_index_evaluates.
                 --- reflexivity.
                 --- exact Hvelocity.
              ** eapply exec_Sassign with
                   (loc := object_block) (ofs := address) (bf := Full)
                   (v2 := Vsingle (Float32.add y velocity))
                   (v := Vsingle (Float32.add y velocity)).
                 --- eapply rank15_raw_float_lvalue.
                     +++ rank15_temporary.
                     +++ apply rank15_y_index_evaluates.
                     +++ reflexivity.
                 --- eapply eval_Ebinop.
                     +++ apply eval_Etempvar. rank15_temporary.
                     +++ apply eval_Etempvar. apply PTree.gss.
                     +++ reflexivity.
                 --- reflexivity.
                 --- eapply assign_loc_value with (chunk := Mfloat32).
                     +++ reflexivity.
                     +++ exact Hstore.
  - split.
    + exact (Mem.load_store_same _ _ _ _ _ _ Hstore).
    + intros chunk read_block read_offset Hseparate.
      eapply Mem.load_store_other; [exact Hstore |].
      destruct Hseparate as [Hblock | [Hbelow | Habove]]; auto.
Qed.

Theorem rank15_position_fragment_is_connected_clight_execution :
  forall version environment locals memory current_block object_block
      object_offset y velocity,
    let ge := Clight.globalenv (selected_clight_target version) in
    let address := rank15_raw_address object_offset (Int.repr 7) in
    environment ! UOH._gCurrentObject = None ->
    Genv.find_symbol ge UOH._gCurrentObject = Some current_block ->
    Mem.load Mptr memory current_block 0 =
      Some (Vptr object_block object_offset) ->
    Mem.load Mfloat32 memory object_block (Ptrofs.unsigned address) =
      Some (Vsingle y) ->
    Mem.load Mfloat32 memory object_block
      (Ptrofs.unsigned (rank15_raw_address object_offset (Int.repr 10))) =
      Some (Vsingle velocity) ->
    Mem.valid_access memory Mfloat32 object_block
      (Ptrofs.unsigned address) Writable ->
    forall continuation,
    exists after,
      @Smallstep.star _ _ Clight.step2 ge
        (State (rank15_movement_body version)
          (rank15_position_update_fragment version) continuation
          environment locals memory) E0
        (State (rank15_movement_body version) Sskip continuation environment
          (rank15_position_update_locals locals
            (Vptr object_block object_offset) y velocity) after) /\
      Mem.store Mfloat32 memory object_block (Ptrofs.unsigned address)
        (Vsingle (Float32.add y velocity)) = Some after.
Proof.
  intros version environment locals memory current_block object_block
    object_offset y velocity ge address Hnotlocal Hsymbol Hcurrent Hy Hvelocity
    Hwritable continuation.
  destruct (rank15_position_fragment_executes_from_memory
    version environment locals memory current_block object_block object_offset
    y velocity Hnotlocal Hsymbol Hcurrent Hy Hvelocity Hwritable)
    as (after & Hstore & Hexecute & _).
  destruct (ClightBigstep.exec_stmt_steps Clight.function_entry2
    (selected_clight_target version) _ _ _ _ _ _ _ _ Hexecute
    (rank15_movement_body version) continuation)
    as (last & Hsteps & Houtcome).
  inversion Houtcome; subst last.
  exists after. split; assumption.
Qed.

Lemma rank15_slot_y_address_exact : forall slot,
  (slot < object_pool_capacity)%nat ->
  Ptrofs.unsigned
    (rank15_raw_address (Ptrofs.repr (object_slot_offset slot)) (Int.repr 7)) =
    object_slot_offset slot + rank15_position_y_offset.
Proof.
  intros slot Hslot.
  pose proof (rank15_pool_slot_offset_in_pointer_range slot Hslot) as Hrange.
  change (Ptrofs.unsigned (Ptrofs.add
    (Ptrofs.add (Ptrofs.repr (object_slot_offset slot)) (Ptrofs.repr 136))
    (Ptrofs.repr 28)) = object_slot_offset slot + 164).
  rewrite Ptrofs.add_assoc.
  change (Ptrofs.unsigned (Ptrofs.add
    (Ptrofs.repr (object_slot_offset slot)) (Ptrofs.repr 164)) =
    object_slot_offset slot + 164).
  unfold Ptrofs.add.
  rewrite (Ptrofs.unsigned_repr (object_slot_offset slot))
    by (unfold object_size in Hrange; lia).
  change (Ptrofs.unsigned (Ptrofs.repr (object_slot_offset slot + 164)) =
    object_slot_offset slot + 164).
  apply Ptrofs.unsigned_repr. unfold object_size in Hrange. lia.
Qed.

Lemma rank15_slot_vy_address_exact : forall slot,
  (slot < object_pool_capacity)%nat ->
  Ptrofs.unsigned
    (rank15_raw_address (Ptrofs.repr (object_slot_offset slot)) (Int.repr 10)) =
    object_slot_offset slot + rank15_velocity_y_offset.
Proof.
  intros slot Hslot.
  pose proof (rank15_pool_slot_offset_in_pointer_range slot Hslot) as Hrange.
  change (Ptrofs.unsigned (Ptrofs.add
    (Ptrofs.add (Ptrofs.repr (object_slot_offset slot)) (Ptrofs.repr 136))
    (Ptrofs.repr 40)) = object_slot_offset slot + 176).
  rewrite Ptrofs.add_assoc.
  change (Ptrofs.unsigned (Ptrofs.add
    (Ptrofs.repr (object_slot_offset slot)) (Ptrofs.repr 176)) =
    object_slot_offset slot + 176).
  unfold Ptrofs.add.
  rewrite (Ptrofs.unsigned_repr (object_slot_offset slot))
    by (unfold object_size in Hrange; lia).
  change (Ptrofs.unsigned (Ptrofs.repr (object_slot_offset slot + 176)) =
    object_slot_offset slot + 176).
  apply Ptrofs.unsigned_repr. unfold object_size in Hrange. lia.
Qed.

Definition rank15_cells_with_y (cells : Rank15HandCells) (y : float32) :
    Rank15HandCells :=
  {| rank15_cells_active_flags := rank15_cells_active_flags cells;
     rank15_cells_next := rank15_cells_next cells;
     rank15_cells_previous := rank15_cells_previous cells;
     rank15_cells_behavior := rank15_cells_behavior cells;
     rank15_cells_pos_x := rank15_cells_pos_x cells;
     rank15_cells_pos_y := y;
     rank15_cells_pos_z := rank15_cells_pos_z cells;
     rank15_cells_vel_y := rank15_cells_vel_y cells;
     rank15_cells_gravity := rank15_cells_gravity cells;
     rank15_cells_floor_height := rank15_cells_floor_height cells;
     rank15_cells_action := rank15_cells_action cells;
     rank15_cells_floor := rank15_cells_floor cells;
     rank15_cells_floor_owner := rank15_cells_floor_owner cells |}.

Ltac rank15_unfold_observed_offsets :=
  unfold object_next_offset, object_previous_offset, object_active_flags_offset,
    object_behavior_offset, rank15_position_x_offset, rank15_position_y_offset,
    rank15_position_z_offset, rank15_velocity_y_offset, rank15_gravity_offset,
    rank15_floor_height_offset, rank15_action_offset, rank15_floor_pointer_offset,
    object_raw_float_offset in *.

Theorem rank15_position_store_derives_updated_hand_cells :
  forall before after binding slot cells y,
    Rank15HandCellLoads before binding slot cells ->
    Mem.store Mfloat32 before (rank15_binding_pool_block binding)
      (object_slot_offset slot + rank15_position_y_offset) (Vsingle y) =
      Some after ->
    Rank15HandCellLoads after binding slot (rank15_cells_with_y cells y).
Proof.
  intros before after binding slot cells y Hloads Hstore.
  assert (Hframe : forall chunk offset,
    offset + size_chunk chunk <= rank15_position_y_offset \/
    rank15_position_y_offset + 4 <= offset ->
    Mem.load chunk after (rank15_binding_pool_block binding)
      (object_slot_offset slot + offset) =
    Mem.load chunk before (rank15_binding_pool_block binding)
      (object_slot_offset slot + offset)).
  { intros chunk offset Hseparate.
    eapply Mem.load_store_other; [exact Hstore |].
    right. change
      (object_slot_offset slot + offset + size_chunk chunk <=
         object_slot_offset slot + rank15_position_y_offset \/
       object_slot_offset slot + rank15_position_y_offset + 4 <=
         object_slot_offset slot + offset).
    lia. }
  destruct Hloads as [Ha Hn Hp Hb Hx Hy Hz Hv Hg Hfh Hac Hf].
  constructor; cbn [rank15_cells_with_y].
  all: try solve [rewrite Hframe;
    [assumption | rank15_unfold_observed_offsets; vm_compute; intuition discriminate]].
  exact (Mem.load_store_same _ _ _ _ _ _ Hstore).
Qed.

Theorem rank15_position_store_preserves_other_hand_cells :
  forall before after binding written_slot observed_slot cells y,
    written_slot <> observed_slot ->
    Rank15HandCellLoads before binding observed_slot cells ->
    Mem.store Mfloat32 before (rank15_binding_pool_block binding)
      (object_slot_offset written_slot + rank15_position_y_offset)
      (Vsingle y) = Some after ->
    Rank15HandCellLoads after binding observed_slot cells.
Proof.
  intros before after binding written_slot observed_slot cells y
    Hdistinct Hloads Hstore.
  assert (Hslots :
    object_slot_offset written_slot + 608 <= object_slot_offset observed_slot \/
    object_slot_offset observed_slot + 608 <= object_slot_offset written_slot).
  { unfold object_slot_offset, object_size. lia. }
  assert (Hframe : forall chunk offset,
    0 <= offset -> offset + size_chunk chunk <= 608 ->
    Mem.load chunk after (rank15_binding_pool_block binding)
      (object_slot_offset observed_slot + offset) =
    Mem.load chunk before (rank15_binding_pool_block binding)
      (object_slot_offset observed_slot + offset)).
  { intros chunk offset Hlow Hhigh.
    eapply Mem.load_store_other; [exact Hstore |].
    right. change
      (object_slot_offset observed_slot + offset + size_chunk chunk <=
         object_slot_offset written_slot + 164 \/
       object_slot_offset written_slot + 164 + 4 <=
         object_slot_offset observed_slot + offset).
    lia. }
  destruct Hloads as [Ha Hn Hp Hb Hx Hy Hz Hv Hg Hfh Hac Hf].
  constructor; rewrite Hframe;
    try assumption; rank15_unfold_observed_offsets; vm_compute; intuition discriminate.
Qed.

(** A floor owner is a transitive read through a pointer.  Unlike the twelve
    object-cell observations, it is not automatically separated merely by
    knowing the hand's slot.  The exact overlap condition stays visible. *)
Definition Rank15FloorOwnerAvoidsStore
    (floor : val) (written_block : block) (written_offset : Z) : Prop :=
  match floor with
  | Vptr surface_block surface_offset =>
      let owner_offset := Ptrofs.unsigned
        (Ptrofs.add surface_offset (Ptrofs.repr rank15_surface_owner_offset)) in
      surface_block <> written_block \/
      owner_offset + 4 <= written_offset \/
      written_offset + 4 <= owner_offset
  | _ => True
  end.

Theorem rank15_position_store_preserves_disjoint_floor_owner :
  forall before after floor owner written_block written_offset y,
    Rank15FloorOwnerLoad before floor owner ->
    Rank15FloorOwnerAvoidsStore floor written_block written_offset ->
    Mem.store Mfloat32 before written_block written_offset (Vsingle y) =
      Some after ->
    Rank15FloorOwnerLoad after floor owner.
Proof.
  intros before after floor owner written_block written_offset y
    Howner Hseparate Hstore.
  destruct floor; cbn [Rank15FloorOwnerLoad] in *; try exact Howner.
  destruct Howner as [value [Hvalue Hload]].
  exists value. split; [exact Hvalue |].
  rewrite <- Hload. eapply Mem.load_store_other; [exact Hstore |].
  exact Hseparate.
Qed.

Lemma rank15_list_storage_is_separate_from_pool : forall binding,
  rank15_binding_lists_cell_block binding <> rank15_binding_pool_block binding /\
  rank15_binding_list_array_block binding <> rank15_binding_pool_block binding.
Proof.
  intros binding. split.
  - eapply (Genv.global_addresses_distinct
      (Clight.globalenv (selected_clight_target (rank15_binding_version binding)))
      (id1 := rank15_object_lists_ident (rank15_binding_version binding))
      (id2 := rank15_object_pool_ident (rank15_binding_version binding))).
    + destruct (rank15_binding_version binding); vm_compute; discriminate.
    + exact (rank15_binding_lists_cell_symbol binding).
    + exact (rank15_binding_pool_symbol binding).
  - eapply (Genv.global_addresses_distinct
      (Clight.globalenv (selected_clight_target (rank15_binding_version binding)))
      (id1 := rank15_object_list_array_ident (rank15_binding_version binding))
      (id2 := rank15_object_pool_ident (rank15_binding_version binding))).
    + destruct (rank15_binding_version binding); vm_compute; discriminate.
    + exact (rank15_binding_list_array_symbol binding).
    + exact (rank15_binding_pool_symbol binding).
Qed.

Theorem rank15_position_store_preserves_live_list_path :
  forall before after binding written_slot observed_slot y,
    Rank15SurfaceListContains before binding observed_slot ->
    Mem.store Mfloat32 before (rank15_binding_pool_block binding)
      (object_slot_offset written_slot + rank15_position_y_offset)
      (Vsingle y) = Some after ->
    Rank15SurfaceListContains after binding observed_slot.
Proof.
  intros before after binding written_slot observed_slot y Hpath Hstore.
  destruct (rank15_list_storage_is_separate_from_pool binding) as [_ Harray].
  induction Hpath as [slot Hvalid Hhead | previous slot Hpath IH Hvalid Hnext].
  - apply rank15_surface_list_first; [exact Hvalid |].
    rewrite <- Hhead. eapply Mem.load_store_other; eauto.
  - eapply rank15_surface_list_next; [exact IH | exact Hvalid |].
    rewrite <- Hnext. eapply Mem.load_store_other; [exact Hstore |].
    right. change
      (608 * Z.of_nat previous + 96 + 4 <= 608 * Z.of_nat written_slot + 164 \/
       608 * Z.of_nat written_slot + 164 + 4 <= 608 * Z.of_nat previous + 96).
    destruct (Nat.lt_ge_cases previous written_slot); lia.
Qed.

(** The later-hand Y case constructs *all* observations of the old projector:
    both slots, their live list paths, and the two transitive floor-owner reads.
    Only the explicit floor-owner range check and the actual new-Y comparison
    remain.  The proof never assumes the after-state projection. *)
Theorem rank15_later_position_store_derives_pair_projection :
  forall before_state after_state binding pair earlier later y,
    Rank15MemoryFaithfulPairProjection before_state binding pair earlier later ->
    Mem.store Mfloat32 (clight_state_memory before_state)
      (rank15_binding_pool_block binding)
      (object_slot_offset (rank15_binding_later_slot binding) +
        rank15_position_y_offset) (Vsingle y) =
      Some (clight_state_memory after_state) ->
    Rank15FloorOwnerAvoidsStore (rank15_cells_floor earlier)
      (rank15_binding_pool_block binding)
      (object_slot_offset (rank15_binding_later_slot binding) +
        rank15_position_y_offset) ->
    Rank15FloorOwnerAvoidsStore (rank15_cells_floor later)
      (rank15_binding_pool_block binding)
      (object_slot_offset (rank15_binding_later_slot binding) +
        rank15_position_y_offset) ->
    rank15_float_upper_bound y (rank15_hand_y (rank15_later_hand pair)) ->
    Rank15MemoryFaithfulPairProjection after_state binding pair earlier
      (rank15_cells_with_y later y).
Proof.
  intros before_state after_state binding pair earlier later y Hprojection
    Hstore Hearlier_separate Hlater_separate Hy.
  destruct Hprojection as [Hlists Hearlier Hlater Hearlier_owner Hlater_owner
    Hearlier_identity Hlater_identity Horder Hearlier_y Hlater_y
    Hearlier_floor Hlater_floor].
  destruct (rank15_list_storage_is_separate_from_pool binding) as [Hlists_block _].
  constructor; cbn [rank15_cells_with_y].
  - rewrite <- Hlists. eapply Mem.load_store_other; eauto.
  - eapply rank15_position_store_preserves_other_hand_cells
      with (written_slot := rank15_binding_later_slot binding)
        (before := clight_state_memory before_state) (y := y).
    + exact (not_eq_sym (rank15_binding_slots_distinct binding)).
    + exact Hearlier.
    + exact Hstore.
  - eapply rank15_position_store_derives_updated_hand_cells; eauto.
  - eapply rank15_position_store_preserves_disjoint_floor_owner; eauto.
  - eapply rank15_position_store_preserves_disjoint_floor_owner; eauto.
  - destruct Hearlier_identity as [Hbehavior [Hactive Hpath]].
    repeat split; try assumption.
    intros Hlive. eapply rank15_position_store_preserves_live_list_path; eauto.
  - destruct Hlater_identity as [Hbehavior [Hactive Hpath]].
    repeat split; try assumption.
    intros Hlive. eapply rank15_position_store_preserves_live_list_path; eauto.
  - exact Horder.
  - exact Hearlier_y.
  - exact Hy.
  - exact Hearlier_floor.
  - destruct Hlater_floor as [Hnone | Hstatic Hcap | Howner Hcap].
    + apply rank15_later_no_floor. exact Hnone.
    + apply rank15_later_static_floor; assumption.
    + apply rank15_later_earlier_hand_floor; assumption.
Qed.

Lemma rank15_clight_star_has_connected_receipt :
  forall program before trace after,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      before trace after ->
    exists steps : list (ConcreteClightStep program),
      ConcreteClightStepsConnected program steps before after /\
      concrete_clight_steps_trace steps = trace.
Proof.
  intros program before trace after Hsteps.
  induction Hsteps as [state | before t1 middle t2 after trace Hfirst Hrest IH Htrace].
  - exists []; split; constructor.
  - destruct IH as [rest [Hconnected Hrest_trace]].
    exists ({| concrete_step_before := before; concrete_step_trace := t1;
               concrete_step_after := middle; concrete_step_executes := Hfirst |}
      :: rest).
    split; [now constructor |].
    change (t1 ++ concrete_clight_steps_trace rest = trace).
    rewrite Hrest_trace. now subst trace.
Qed.

Lemma rank15_pair_can_stutter : forall pair, Rank15HandPairStep pair pair.
Proof. intros [earlier later]. apply rank15_pair_later. constructor. Qed.

Lemma rank15_position_store_preserves_current_object :
  forall before after binding current_block slot y,
    Genv.find_symbol
      (Clight.globalenv (selected_clight_target (rank15_binding_version binding)))
      UOH._gCurrentObject = Some current_block ->
    Mem.store Mfloat32 before (rank15_binding_pool_block binding)
      (object_slot_offset slot + rank15_position_y_offset) (Vsingle y) =
      Some after ->
    Mem.load Mptr after current_block 0 = Mem.load Mptr before current_block 0.
Proof.
  intros before after binding current_block slot y Hsymbol Hstore.
  eapply Mem.load_store_other; [exact Hstore |].
  left. eapply (Genv.global_addresses_distinct
    (Clight.globalenv (selected_clight_target (rank15_binding_version binding)))
    (id1 := UOH._gCurrentObject)
    (id2 := rank15_object_pool_ident (rank15_binding_version binding))).
  - destruct (rank15_binding_version binding); vm_compute; discriminate.
  - exact Hsymbol.
  - exact (rank15_binding_pool_symbol binding).
Qed.

Definition EyerokRank15LaterPositionChunkConstruction : Prop :=
  forall binding (before : Rank15MemoryFaithfulFrame binding)
      environment locals memory current_block continuation,
    rank15_frame_state _ before =
      State (rank15_movement_body (rank15_binding_version binding))
        (rank15_position_update_fragment (rank15_binding_version binding))
        continuation environment locals memory ->
    environment ! UOH._gCurrentObject = None ->
    Genv.find_symbol
      (Clight.globalenv (selected_clight_target (rank15_binding_version binding)))
      UOH._gCurrentObject = Some current_block ->
    Mem.load Mptr memory current_block 0 =
      Some (rank15_slot_pointer binding (rank15_binding_later_slot binding)) ->
    Mem.valid_access memory Mfloat32 (rank15_binding_pool_block binding)
      (object_slot_offset (rank15_binding_later_slot binding) +
        rank15_position_y_offset) Writable ->
    Rank15FloorOwnerAvoidsStore
      (rank15_cells_floor (rank15_frame_earlier_cells _ before))
      (rank15_binding_pool_block binding)
      (object_slot_offset (rank15_binding_later_slot binding) +
        rank15_position_y_offset) ->
    Rank15FloorOwnerAvoidsStore
      (rank15_cells_floor (rank15_frame_later_cells _ before))
      (rank15_binding_pool_block binding)
      (object_slot_offset (rank15_binding_later_slot binding) +
        rank15_position_y_offset) ->
    rank15_float_upper_bound
      (Float32.add
        (rank15_cells_pos_y (rank15_frame_later_cells _ before))
        (rank15_cells_vel_y (rank15_frame_later_cells _ before)))
      (rank15_hand_y (rank15_later_hand (rank15_frame_pair _ before))) ->
    exists after : Rank15MemoryFaithfulFrame binding,
      inhabited (Rank15ClassifiedClightChunk binding before after) /\
      rank15_frame_pair _ after = rank15_frame_pair _ before /\
      rank15_frame_later_cells _ after =
        rank15_cells_with_y (rank15_frame_later_cells _ before)
          (Float32.add
            (rank15_cells_pos_y (rank15_frame_later_cells _ before))
            (rank15_cells_vel_y (rank15_frame_later_cells _ before))) /\
      Mem.load Mptr (clight_state_memory (rank15_frame_state _ after))
        current_block 0 =
        Some (rank15_slot_pointer binding (rank15_binding_later_slot binding)).

Theorem rank15_later_position_chunk_is_constructed :
  EyerokRank15LaterPositionChunkConstruction.
Proof.
  intros binding before environment locals memory current_block continuation
    Hstate Hnotlocal Hsymbol Hcurrent Hwritable Hearlier_owner Hlater_owner Hbound.
  pose proof (rank15_frame_projection _ before) as Hprojection.
  pose proof (rank15_projection_later_loads _ _ _ _ _ Hprojection) as Hloads.
  rewrite Hstate in Hloads. cbn [clight_state_memory] in Hloads.
  pose proof (rank15_load_pos_y _ _ _ _ Hloads) as Hy.
  pose proof (rank15_load_vel_y _ _ _ _ Hloads) as Hv.
  pose proof (rank15_binding_later_valid binding) as Hvalid.
  rewrite <- (rank15_slot_y_address_exact _ Hvalid) in Hy, Hwritable.
  rewrite <- (rank15_slot_vy_address_exact _ Hvalid) in Hv.
  destruct (rank15_position_fragment_is_connected_clight_execution
    (rank15_binding_version binding) environment locals memory current_block
    (rank15_binding_pool_block binding)
    (Ptrofs.repr (object_slot_offset (rank15_binding_later_slot binding)))
    (rank15_cells_pos_y (rank15_frame_later_cells _ before))
    (rank15_cells_vel_y (rank15_frame_later_cells _ before))
    Hnotlocal Hsymbol Hcurrent Hy Hv Hwritable continuation)
    as (after_memory & Hsteps & Hstore).
  rewrite (rank15_slot_y_address_exact _ Hvalid) in Hstore.
  set (after_state := State
    (rank15_movement_body (rank15_binding_version binding)) Sskip continuation
    environment (rank15_position_update_locals locals
      (rank15_slot_pointer binding (rank15_binding_later_slot binding))
      (rank15_cells_pos_y (rank15_frame_later_cells _ before))
      (rank15_cells_vel_y (rank15_frame_later_cells _ before))) after_memory).
  assert (Hafter_projection : Rank15MemoryFaithfulPairProjection after_state binding
    (rank15_frame_pair _ before) (rank15_frame_earlier_cells _ before)
    (rank15_cells_with_y (rank15_frame_later_cells _ before)
      (Float32.add (rank15_cells_pos_y (rank15_frame_later_cells _ before))
        (rank15_cells_vel_y (rank15_frame_later_cells _ before))))).
  { eapply rank15_later_position_store_derives_pair_projection.
    - exact Hprojection.
    - rewrite Hstate. exact Hstore.
    - exact Hearlier_owner.
    - exact Hlater_owner.
    - exact Hbound. }
  set (after := {| rank15_frame_state := after_state;
    rank15_frame_pair := rank15_frame_pair _ before;
    rank15_frame_earlier_cells := rank15_frame_earlier_cells _ before;
    rank15_frame_later_cells := rank15_cells_with_y
      (rank15_frame_later_cells _ before)
      (Float32.add (rank15_cells_pos_y (rank15_frame_later_cells _ before))
        (rank15_cells_vel_y (rank15_frame_later_cells _ before)));
    rank15_frame_projection := Hafter_projection |}).
  change (@Smallstep.star _ _ Clight.step2
    (Clight.globalenv (selected_clight_target (rank15_binding_version binding)))
    (State (rank15_movement_body (rank15_binding_version binding))
      (rank15_position_update_fragment (rank15_binding_version binding))
      continuation environment locals memory) E0 after_state) in Hsteps.
  rewrite <- Hstate in Hsteps.
  destruct (rank15_clight_star_has_connected_receipt _ _ _ _ Hsteps)
    as [steps [Hconnected _]].
  assert (Hnonempty : steps <> []).
  { intros Hempty. subst steps.
    assert (Hequal : rank15_frame_state _ before = after_state)
      by (inversion Hconnected; reflexivity).
    rewrite Hstate in Hequal. discriminate. }
  exists after. split.
  - constructor.
    refine (@Build_Rank15ClassifiedClightChunk binding before after
      steps Hnonempty _ _).
    + exact Hconnected.
    + change (Rank15HandPairStep (rank15_frame_pair _ before)
        (rank15_frame_pair _ before)).
      apply rank15_pair_can_stutter.
  - split; [reflexivity |].
    split; [reflexivity |].
    change (Mem.load Mptr after_memory current_block 0 =
      Some (rank15_slot_pointer binding (rank15_binding_later_slot binding))).
    rewrite <- Hcurrent.
    eapply rank15_position_store_preserves_current_object
      with (binding := binding); eauto.
Qed.

Print Assumptions rank15_later_position_chunk_is_constructed.

Definition EyerokRank15LiveMovementBoundary : Prop :=
  (forall version,
    exists function_block,
      Genv.find_symbol (Clight.globalenv (selected_clight_target version))
        UOH._cur_obj_move_y_and_get_water_level = Some function_block /\
      Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
        function_block = Some (Internal (rank15_movement_body version)) /\
      exists velocity clamp tail,
        fn_body (rank15_movement_body version) =
          Ssequence velocity (Ssequence clamp
            (Ssequence (rank15_position_update_fragment version) tail))) /\
  EyerokRank15LaterPositionChunkConstruction.

Theorem eyerok_rank15_live_movement_boundary_checked :
  EyerokRank15LiveMovementBoundary.
Proof.
  split.
  - intros [|].
    + destruct rank15_us_selected_movement_body_resolves
        as [function_block [Hsymbol Hfunction]].
      exists function_block. split; [exact Hsymbol |].
      split; [exact Hfunction |].
      apply rank15_generated_position_fragment_is_exact.
    + destruct rank15_jp_selected_movement_body_resolves
        as [function_block [Hsymbol Hfunction]].
      exists function_block. split; [exact Hsymbol |].
      split; [exact Hfunction |].
      apply rank15_generated_position_fragment_is_exact.
  - exact rank15_later_position_chunk_is_constructed.
Qed.
