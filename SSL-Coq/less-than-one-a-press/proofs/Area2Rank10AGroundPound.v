(** Rank 10A: ground-pound startup with moving geometry.

    The selected source really raises Mario and omits the action's air step.
    It does NOT omit the earlier geometry-input queries. The ordinary 11-frame
    animation descriptor gives 15 startup updates (loopEnd + 4), so a granted
    startup over a steadily descending elevator can exceed the wall-height
    cutoff. That is a conditional timing witness, not a controller entry or
    an escape: the action zeros horizontal speed and supplies no B/Z departure.

    Animation bytes, live floor choices, other frame effects and entry
    reachability are explicit residuals. No staged game-memory change is used. *)
From Coq Require Import Bool Lia List Reals Lra ZArith.
From Flocq Require Import Binary Core.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Events Floats Globalenvs IEEE754_extra Integers Linking Maps Memory Values.
From LessThanOneAPress.Generated Require Import
  us_mario_actions_airborne jp_mario_actions_airborne
  us_mario_actions_automatic jp_mario_actions_automatic
  us_mario_actions_cutscene jp_mario_actions_cutscene
  us_mario jp_mario us_obj_behaviors jp_obj_behaviors.
From LessThanOneAPress.Proofs Require Import
  ASTFacts GameTypes Area2Rank11LivePoleExit Area2Rank9ACoinFlight
  UpperElevatorQuarterStepClosure UpperElevatorQueryResolution
  CleanedClightPrograms ClightLinkExecution GlobalInterfaceStructural
  JPSourceSymbolTransport JPWarpLevelEntryResolution LinkedClightPrograms
  NormalizedClightPrograms SelectedClightTarget SuccessfulMakeProgramResolution
  USViewportRepairedNamesNorepet USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USWarpLevelSourceUnionReceipt USWholeASTTagRepair.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Transparent Float32.cmp Float32.compare.
Module GP := us_mario_actions_airborne.
Module GJ := jp_mario_actions_airborne.
Module GM := us_mario.

(** * The five inspected bodies resolve in the actual selected programs. *)
Inductive Rank10ANative := GPGroundPound | GPFreefall | GPSetSpeed
  | GPGeometryInputs | GPElevator.

Definition rank10a_ident native : ident := match native with
| GPGroundPound => GP._act_ground_pound | GPFreefall => GP._act_freefall
| GPSetSpeed => GM._mario_set_forward_vel
| GPGeometryInputs => GM._update_mario_geometry_inputs
| GPElevator => us_obj_behaviors._bhv_pyramid_elevator_loop end.

Definition rank10a_body version native : function := match version, native with
| VersionUS, GPGroundPound => GP.f_act_ground_pound
| VersionJP, GPGroundPound => GJ.f_act_ground_pound
| VersionUS, GPFreefall => GP.f_act_freefall
| VersionJP, GPFreefall => GJ.f_act_freefall
| VersionUS, GPSetSpeed => GM.f_mario_set_forward_vel
| VersionJP, GPSetSpeed => jp_mario.f_mario_set_forward_vel
| VersionUS, GPGeometryInputs => GM.f_update_mario_geometry_inputs
| VersionJP, GPGeometryInputs => jp_mario.f_update_mario_geometry_inputs
| VersionUS, GPElevator => us_obj_behaviors.f_bhv_pyramid_elevator_loop
| VersionJP, GPElevator => jp_obj_behaviors.f_bhv_pyramid_elevator_loop end.

Definition rank10a_unit native : nat := match native with
| GPGroundPound | GPFreefall => 2 | GPSetSpeed | GPGeometryInputs => 1
| GPElevator => 23 end.
Definition rank10a_definitions native := match native with
| GPGroundPound | GPFreefall => GP.global_definitions
| GPSetSpeed | GPGeometryInputs => GM.global_definitions
| GPElevator => us_obj_behaviors.global_definitions end.

Lemma rank10a_us_source_receipt : forall native,
  nth_error (rank10a_definitions native)
    (ueqr_definition_index (rank10a_ident native) (rank10a_definitions native)) =
  Some (rank10a_ident native, Gfun (Internal (rank10a_body VersionUS native))).
Proof. intros []; vm_compute; reflexivity. Qed.

Lemma rank10a_us_unit_receipt : forall native,
  prog_defs (us_nlist_at (rank10a_unit native) us_units) = rank10a_definitions native.
Proof. intros []; reflexivity. Qed.

Lemma rank10a_us_source_member : forall native,
  In (rank10a_ident native, Gfun (Internal (rank10a_body VersionUS native)))
    (unit_global_definitions us_units).
Proof.
  intro native. eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at (rank10a_unit native) us_units).
  - exact (us_nlist_at_nIn _ (rank10a_unit native) us_units).
  - rewrite rank10a_us_unit_receipt. eapply nth_error_In.
    exact (rank10a_us_source_receipt native).
Qed.

Lemma rank10a_us_selection : forall native,
  us_normalized_global_definition_map ! (rank10a_ident native) =
    Some (Gfun (Internal (rank10a_body VersionUS native))).
Proof.
  intro native. eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance
      (unit_global_definitions us_units)).
  - exact (rank10a_us_source_member native).
Qed.

Lemma rank10a_us_no_repair : forall native,
  us_selected_definition_needs_viewport_repair
    (rank10a_ident native, Gfun (Internal (rank10a_body VersionUS native))) = false.
Proof. intros []; vm_compute; reflexivity. Qed.

Lemma rank10a_us_selected_member : forall native,
  In (rank10a_ident native, Gfun (Internal (rank10a_body VersionUS native)))
    us_viewport_repaired_global_definitions.
Proof.
  intro native. unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    rewrite rank10a_us_no_repair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim.
    exact (rank10a_us_selection native).
Qed.

Lemma rank10a_jp_source_receipt : forall native,
  (prog_defmap (nlist_at (rank10a_unit native) jp_cleaned_units)) !
    (rank10a_ident native) = Some (Gfun (Internal (rank10a_body VersionJP native))).
Proof. intros []; vm_compute; reflexivity. Qed.

Theorem rank10a_selected_bodies_resolve : forall version native,
  exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      (rank10a_ident native) = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      function_block = Some (Internal (rank10a_body version native)).
Proof.
  intros [] native.
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact (rank10a_us_selected_member native).
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link
      (nlist_at (rank10a_unit native) jp_cleaned_units)).
    + exact (nlist_at_nIn _ (rank10a_unit native) jp_cleaned_units).
    + exact (rank10a_jp_source_receipt native).
Qed.

(** * Exact branch and store, rather than unrelated constant occurrences. *)
Definition rank10a_startup version : statement :=
  match fn_body (rank10a_body version GPGroundPound) with
  | Ssequence _ (Ssequence (Ssequence _ (Sifthenelse _ startup _)) _) => startup
  | _ => Sskip end.

Definition rank10a_field := rank11_mario_field_expression.
Definition rank10a_y := rank11_mario_y_expression.
Definition rank10a_float bits := Econst_single (Float32.of_bits (Int.repr bits)) tfloat.
Definition rank10a_y_write :=
  Ssequence (Sset GP._t'25 rank10a_y)
    (Sassign rank10a_y
      (Ebinop Oadd (Etempvar GP._t'25 tfloat) (Etempvar GP._yOffset tfloat) tfloat)).

Definition rank10a_lift_fragment (peak_and_graphics : statement) :=
  Ssequence (Sset GP._t'20 (rank10a_field GP._actionTimer tushort))
    (Sifthenelse (Ebinop Olt (Etempvar GP._t'20 tushort)
      (Econst_int (Int.repr 10) tint) tint)
      (Ssequence
        (Ssequence (Sset GP._t'26 (rank10a_field GP._actionTimer tushort))
          (Sset GP._yOffset (Ecast
            (Ebinop Osub (Econst_int (Int.repr 20) tint)
              (Ebinop Omul (Econst_int (Int.repr 2) tint)
                (Etempvar GP._t'26 tushort) tint) tint) tfloat)))
        (Ssequence (Sset GP._t'21 rank10a_y)
          (Ssequence (Sset GP._t'22 (rank10a_field GP._ceilHeight tfloat))
            (Sifthenelse (Ebinop Olt
              (Ebinop Oadd (Ebinop Oadd (Etempvar GP._t'21 tfloat)
                (Etempvar GP._yOffset tfloat) tfloat)
                (rank10a_float 1126170624) tfloat)
              (Etempvar GP._t'22 tfloat) tint)
              (Ssequence rank10a_y_write peak_and_graphics) Sskip)))) Sskip).

Definition rank10a_speed_stop : statement :=
  Scall None (Evar GP._mario_set_forward_vel
    (Tfunction [tptr (Tstruct GP._MarioState noattr); tfloat] tvoid cc_default))
    [Etempvar GP._m (tptr (Tstruct GP._MarioState noattr)); rank10a_float 0].

Theorem rank10a_startup_prefix_is_generated : forall version,
  exists peak_and_graphics tail,
    rank10a_startup version =
      Ssequence (rank10a_lift_fragment peak_and_graphics)
        (Ssequence
          (Sassign
            (Ederef (Ebinop Oadd (rank10a_field GP._vel (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
            (Eunop Oneg (rank10a_float 1112014848) tfloat))
          (Ssequence rank10a_speed_stop tail)).
Proof. intros []; do 2 eexists; reflexivity. Qed.

Theorem rank10a_startup_calls_are_exact : forall version,
  direct_callees_s (rank10a_startup version) =
    [GP._vec3f_copy; GP._mario_set_forward_vel; GP._set_mario_animation;
     GP._play_sound; GP._play_sound] /\
  calls_ident_s GP._perform_air_step (rank10a_startup version) = false /\
  calls_ident_s GP._set_mario_action (rank10a_startup version) = false /\
  calls_ident_s GP._update_air_without_turn
    (fn_body (rank10a_body version GPGroundPound)) = false.
Proof. intros []; vm_compute; auto. Qed.

Theorem rank10a_geometry_queries_still_precede_the_first_branch : forall version,
  fst (ueqr_calls_before_control
    (fn_body (rank10a_body version GPGeometryInputs))) =
    [GM._f32_find_wall_collision; GM._f32_find_wall_collision; GM._find_floor].
Proof. intros []; reflexivity. Qed.

Theorem rank10a_startup_has_no_direct_sideways_position_write : forall version,
  assigns_array_slot_s GP._pos 0 (rank10a_startup version) = false /\
  assigns_array_slot_s GP._pos 1 (rank10a_startup version) = true /\
  assigns_array_slot_s GP._pos 2 (rank10a_startup version) = false.
Proof. intros []; vm_compute; auto. Qed.

(** Read the actual speed setter's multiplication operands. These checks do
    not assert that its table reads have already occurred in a live run. *)
Fixpoint rank10a_field_writes field statement : list expr := match statement with
| Sassign (Efield (Ederef (Etempvar mario _) _) found _) rhs =>
    if Pos.eqb mario GP._m && Pos.eqb field found then [rhs] else []
| Ssequence a b => rank10a_field_writes field a ++ rank10a_field_writes field b
| _ => [] end.

Theorem rank10a_speed_setter_multiplications_are_generated : forall version,
  rank10a_field_writes GM._slideVelX (fn_body (rank10a_body version GPSetSpeed)) =
    [Ebinop Omul (Etempvar GM._t'7 tfloat) (Etempvar GM._t'8 tfloat) tfloat] /\
  rank10a_field_writes GM._slideVelZ (fn_body (rank10a_body version GPSetSpeed)) =
    [Ebinop Omul (Etempvar GM._t'4 tfloat) (Etempvar GM._t'5 tfloat) tfloat] /\
  direct_callees_s (fn_body (rank10a_body version GPSetSpeed)) = [].
Proof. intros []; vm_compute; auto. Qed.

Theorem rank10a_zero_speed_has_no_hidden_horizontal_magnitude : forall trig,
  rank9cf_finite trig ->
  rank9cf_finite (Float32.mul trig (rank9cf_integer 0)) /\
  rank9cf_real (Float32.mul trig (rank9cf_integer 0)) = 0%R.
Proof.
  intros trig Ft. destruct (rank9cf_integer_exact 0 ltac:(lia)) as [R0 F0].
  destruct (rank9cf_mul_range trig (rank9cf_integer 0) 0 0 Ft F0
    ltac:(lia) ltac:(lia) ltac:(lia) ltac:(rewrite R0; lra)) as [F H].
  split; [exact F |]. change (0 <= rank9cf_real
    (Float32.mul trig (rank9cf_integer 0)) <= 0)%R in H. lra.
Qed.

(** Execute the REAL post-headroom Y update in selected Clight memory. This
    is a local fragment: it does not assume a controller can reach its entry. *)
Theorem rank10a_y_write_executes :
  forall version environment locals memory mario y offset after,
    locals ! GP._m = Some (Vptr mario Ptrofs.zero) ->
    locals ! GP._yOffset = Some (Vsingle offset) ->
    Mem.load Mfloat32 memory mario 64 = Some (Vsingle y) ->
    Mem.store Mfloat32 memory mario 64 (Vsingle (Float32.add y offset)) = Some after ->
    ClightBigstep.Clight2.exec_stmt
      (Clight.globalenv (selected_clight_target version)) environment locals memory
      rank10a_y_write E0 (PTree.set GP._t'25 (Vsingle y) locals) after Out_normal.
Proof.
  intros version environment locals memory mario y offset after Hm Ho Hy Hstore.
  unfold rank10a_y_write. eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sset. eapply rank11_mario_y_read; eauto.
  - eapply exec_Sassign with (v := Vsingle (Float32.add y offset))
      (v2 := Vsingle (Float32.add y offset)) (ofs := Ptrofs.repr 64) (bf := Full).
    + unfold rank10a_y, rank11_mario_y_expression.
      apply eval_Ederef. eapply eval_Ebinop.
      * eapply eval_Elvalue.
        -- eapply rank11_mario_field_lvalue.
           ++ rewrite PTree.gso by discriminate. exact Hm.
           ++ cbn; auto.
        -- apply deref_loc_reference. reflexivity.
      * constructor.
      * reflexivity.
    + eapply eval_Ebinop.
      * apply eval_Etempvar. apply PTree.gss.
      * apply eval_Etempvar. rewrite PTree.gso by discriminate. exact Ho.
      * reflexivity.
    + reflexivity.
    + eapply assign_loc_value with (chunk := Mfloat32); try reflexivity.
      exact Hstore.
Qed.

Theorem rank10a_y_store_preserves_mario_xz : forall memory after mario y offset,
  Mem.store Mfloat32 memory mario 64 (Vsingle (Float32.add y offset)) = Some after ->
  Mem.load Mfloat32 after mario 60 = Mem.load Mfloat32 memory mario 60 /\
  Mem.load Mfloat32 after mario 68 = Mem.load Mfloat32 memory mario 68.
Proof.
  intros memory after mario y offset Hstore. split;
    eapply Mem.load_store_other;
      [exact Hstore | right; left; cbn; lia | exact Hstore | right; right; cbn; lia].
Qed.

(** * Direct entry census. These are syntactic requests, not a transitive
    action-reachability proof. In particular, hanging release also qualifies. *)
Definition rank10a_ground_pound_action : Z := 8390825.
Definition rank10a_requests_ground_pound (body : statement) : bool :=
  calls_ident_with_two_int_literals_s GP._set_mario_action rank10a_ground_pound_action 0 body ||
  calls_ident_with_two_int_literals_s GP._set_mario_action rank10a_ground_pound_action 1 body ||
  calls_ident_with_two_int_literals_s GP._drop_and_set_mario_action rank10a_ground_pound_action 0 body.

Fixpoint rank10a_requesters (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal f)) :: rest =>
      if rank10a_requests_ground_pound (fn_body f)
      then id :: rank10a_requesters rest else rank10a_requesters rest
  | _ :: rest => rank10a_requesters rest end.

Definition rank10a_expected_airborne_requesters :=
  [GP._act_jump; GP._act_double_jump; GP._act_triple_jump; GP._act_backflip;
   GP._act_freefall; GP._act_hold_jump; GP._act_hold_freefall; GP._act_side_flip;
   GP._act_wall_kick_air; GP._act_flying; GP._act_flying_triple_jump;
   GP._act_special_triple_jump].

Theorem rank10a_direct_entry_census : forall version,
  rank10a_requesters (match version with VersionUS => GP.global_definitions
    | VersionJP => GJ.global_definitions end) = rank10a_expected_airborne_requesters /\
  rank10a_requesters (match version with
    | VersionUS => us_mario_actions_automatic.global_definitions
    | VersionJP => jp_mario_actions_automatic.global_definitions end) =
    [us_mario_actions_automatic._act_start_hanging;
     us_mario_actions_automatic._act_hanging; us_mario_actions_automatic._act_hang_moving] /\
  rank10a_requests_ground_pound (fn_body (match version with
    | VersionUS => us_mario_actions_cutscene.f_act_spawn_no_spin_airborne
    | VersionJP => jp_mario_actions_cutscene.f_act_spawn_no_spin_airborne end)) = false.
Proof. intros []; vm_compute; auto. Qed.

(** * Float32 startup bounds. An interrupted/restarted ground pound is a NEW
    episode, not another step in this monotonically advancing timer prefix. *)
Definition rank10a_offset timer := if timer <? 10 then 20 - 2 * timer else 0.
Definition rank10a_budget timer :=
  if timer <? 10 then 110 - timer * (21 - timer) else 0.

Theorem rank10a_ten_offsets_checked :
  map rank10a_offset (map Z.of_nat (seq 0 15)) =
    [20;18;16;14;12;10;8;6;4;2;0;0;0;0;0] /\
  (forall timer, 0 <= timer < 10 ->
    Float32.to_bits (Float32.of_int (Int.sub (Int.repr 20)
      (Int.mul (Int.repr 2) (Int.repr timer)))) =
    Float32.to_bits (rank9cf_integer (rank10a_offset timer))).
Proof.
  split; [reflexivity |]. intros timer Ht.
  assert (Ht' : timer = 0 \/ timer = 1 \/ timer = 2 \/ timer = 3 \/ timer = 4 \/
    timer = 5 \/ timer = 6 \/ timer = 7 \/ timer = 8 \/ timer = 9) by lia.
  repeat destruct Ht' as [Ht' | Ht']; subst timer; vm_compute; reflexivity.
Qed.

Lemma rank10a_budget_step : forall timer,
  0 <= timer ->
  0 <= rank10a_offset timer <= 20 /\
  0 <= rank10a_budget timer <= 110 /\
  rank10a_budget timer = rank10a_offset timer + rank10a_budget (timer + 1).
Proof.
  intros timer Ht. unfold rank10a_offset, rank10a_budget.
  destruct (timer <? 10) eqn:E; apply Z.ltb_lt in E || apply Z.ltb_ge in E;
    destruct (timer + 1 <? 10) eqn:F; apply Z.ltb_lt in F || apply Z.ltb_ge in F;
    repeat split; nia.
Qed.

Inductive Rank10AStartupReach (origin : Z) : Z -> float32 -> Prop :=
| Rank10AStartupInitial : forall y,
    rank9cf_finite y -> (-32768 <= rank9cf_real y <= IZR origin)%R ->
    Rank10AStartupReach origin 0 y
| Rank10AStartupLift : forall timer y,
    Rank10AStartupReach origin timer y ->
    Rank10AStartupReach origin (timer + 1)
      (Float32.add y (rank9cf_integer (rank10a_offset timer)))
| Rank10AStartupBlocked : forall timer y,
    Rank10AStartupReach origin timer y -> Rank10AStartupReach origin (timer + 1) y.

(** Each headroom test may independently pass or fail. Granting all these
    choices is an over-approximation. The integer ceiling is on the actual
    rounded binary32 Y, not on a translation-invariant real recurrence. *)
Theorem rank10a_every_headroom_schedule_is_bounded : forall origin timer y,
  -16000 <= origin <= 16000 -> Rank10AStartupReach origin timer y ->
  0 <= timer /\ rank9cf_finite y /\
  (-32768 <= rank9cf_real y <= IZR (origin + 110 - rank10a_budget timer))%R.
Proof.
  intros origin timer y Ho Hrun. induction Hrun as
    [y Fy Hy | timer y Hrun IH | timer y Hrun IH].
  - split; [lia |]. split; [exact Fy |].
    replace (origin + 110 - rank10a_budget 0) with origin
      by (unfold rank10a_budget; cbn; lia). exact Hy.
  - destruct IH as [Ht [Fy Hy]].
    destruct (rank10a_budget_step timer Ht) as [Hd [Hb Heq]].
    destruct (rank9cf_integer_exact (rank10a_offset timer) ltac:(lia)) as [Rd Fd].
    assert (Hrange : (IZR (-32768) <= rank9cf_real y +
      rank9cf_real (rank9cf_integer (rank10a_offset timer)) <=
      IZR (origin + 110 - rank10a_budget (timer + 1)))%R).
    { rewrite Rd. rewrite Heq in Hy.
      assert (Hdz : (0 <= IZR (rank10a_offset timer))%R) by (apply IZR_le; lia).
      repeat rewrite minus_IZR in *; repeat rewrite plus_IZR in *; lra. }
    destruct (rank9cf_add_range y (rank9cf_integer (rank10a_offset timer))
      (-32768) (origin + 110 - rank10a_budget (timer + 1)) Fy Fd
      ltac:(lia) ltac:(pose proof (rank10a_budget_step (timer+1) ltac:(lia)); lia)
      ltac:(pose proof (rank10a_budget_step (timer+1) ltac:(lia)); lia) Hrange) as [Fnew Hnew].
    split; [lia |]. split; assumption.
  - destruct IH as [Ht [Fy Hy]].
    destruct (rank10a_budget_step timer Ht) as [Hd [Hb Heq]].
    split; [lia |]. split; [exact Fy |]. split; [exact (proj1 Hy) |].
    eapply Rle_trans; [exact (proj2 Hy) |]. apply IZR_le. lia.
Qed.

Corollary rank10a_startup_stays_below_entry_ceiling_plus_110 : forall origin timer y,
  -16000 <= origin <= 16000 -> Rank10AStartupReach origin timer y ->
  (rank9cf_real y <= IZR (origin + 110))%R.
Proof.
  intros origin timer y Ho Hr.
  destruct (rank10a_every_headroom_schedule_is_bounded origin timer y Ho Hr)
    as [Ht [Fy Hy]].
  destruct (rank10a_budget_step timer Ht) as [_ [Hb _]].
  eapply Rle_trans; [exact (proj2 Hy) |]. apply IZR_le. lia.
Qed.

(** Exact timing diagnostic: starting at the granted Y=4966 boundary, every
    lift passes, the elevator moves -10 BEFORE each of the 15 Mario updates,
    and no other effect changes either position. The descriptor's loopEnd=11
    is supplied here; its live loading is not a generated Clight fact. *)
Fixpoint rank10a_timing_frames (fuel : nat) (timer : Z) (y elevator : float32)
    : list (float32 * float32) := match fuel with
| O => []
| S rest =>
    let elevator' := Float32.add elevator (ueq_f32 (-10)) in
    let y' := Float32.add y (ueq_f32 (rank10a_offset timer)) in
    (y', elevator') :: rank10a_timing_frames rest (timer + 1) y' elevator'
end.
Definition rank10a_timing := rank10a_timing_frames 15 0 (ueq_f32 4966) (ueq_f32 4966).
Definition rank10a_relative_bits := map (fun p => Float32.to_bits (Float32.sub (fst p) (snd p))).

Theorem rank10a_ordinary_descriptor_has_a_height_window :
  11 + 4 = 15 /\
  rank10a_relative_bits rank10a_timing =
    map (fun z => Float32.to_bits (ueq_f32 z))
      [30;58;84;108;130;150;168;184;198;210;220;230;240;250;260] /\
  map Float32.to_bits (ueq_quarter_positions 4 (ueq_f32 270) (ueq_f32 (-50))) =
    map (fun z => Float32.to_bits (ueq_half_f32 z)) [515;490;465;440] /\
  map (fun y => Float32.to_bits (Float32.sub y (ueq_f32 4806)))
    (ueq_quarter_positions 4 (ueq_f32 5076) (ueq_f32 (-50))) =
    map (fun z => Float32.to_bits (ueq_half_f32 z)) [515;490;465;440].
Proof. vm_compute. auto. Qed.

(** A vertically translating elevator does not create the >100-unit floor
    lag needed by OFF_FLOOR or GROUND_STEP_LEFT_GROUND if each frame actually
    selects and reanchors to its intact base. This excludes the simple
    "the floor descends faster than a grounded Mario" entry mechanism. *)
Theorem rank10a_ten_unit_descent_stays_below_off_floor_threshold : forall bin y,
  -16000 <= bin <= 16000 -> rank9cf_finite y ->
  (IZR bin <= rank9cf_real y <= IZR (bin + 1))%R ->
  let threshold := Float32.add
      (Float32.add y (rank9cf_integer (-10))) (rank9cf_integer 100) in
  rank9cf_finite threshold /\ (rank9cf_real y < rank9cf_real threshold)%R.
Proof.
  intros bin y Hb Fy Hy threshold.
  destruct (rank9cf_integer_exact (-10) ltac:(lia)) as [Rm Fm].
  destruct (rank9cf_integer_exact 100 ltac:(lia)) as [Rp Fp].
  destruct (rank9cf_add_range y (rank9cf_integer (-10)) (bin-10) (bin-9)
    Fy Fm ltac:(lia) ltac:(lia) ltac:(lia)
    ltac:(rewrite Rm; repeat rewrite minus_IZR; rewrite plus_IZR in Hy; lra))
    as [Ffloor Hfloor].
  destruct (rank9cf_add_range _ (rank9cf_integer 100) (bin+90) (bin+91)
    Ffloor Fp ltac:(lia) ltac:(lia) ltac:(lia)
    ltac:(rewrite Rp; repeat rewrite minus_IZR in Hfloor;
      repeat rewrite plus_IZR; lra)) as [Fthreshold Hthreshold].
  split; [exact Fthreshold |].
  unfold threshold. repeat rewrite plus_IZR in *; lra.
Qed.

Corollary rank10a_ten_unit_descent_cannot_pass_off_floor_test : forall bin y,
  -16000 <= bin <= 16000 -> rank9cf_finite y ->
  (IZR bin <= rank9cf_real y <= IZR (bin + 1))%R ->
  Float32.cmp Cgt y (Float32.add
    (Float32.add y (rank9cf_integer (-10))) (rank9cf_integer 100)) = false.
Proof.
  intros bin y Hb Fy Hy.
  destruct (rank10a_ten_unit_descent_stays_below_off_floor_threshold bin y Hb Fy Hy)
    as [Ft Hlt].
  unfold Float32.cmp, Float32.compare.
  rewrite Bcompare_correct by assumption.
  rewrite Rcompare_Lt by exact Hlt. reflexivity.
Qed.

(** Stable capstone: it exposes the remaining entry/whole-frame projection
    rather than asserting that an arbitrary gameplay history is closed. *)
Definition Rank10AGroundPoundBoundary : Prop :=
  (forall version native, exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      (rank10a_ident native) = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) function_block =
      Some (Internal (rank10a_body version native))) /\
  (forall version,
    calls_ident_s GP._perform_air_step (rank10a_startup version) = false /\
    fst (ueqr_calls_before_control
      (fn_body (rank10a_body version GPGeometryInputs))) =
      [GM._f32_find_wall_collision; GM._f32_find_wall_collision; GM._find_floor]) /\
  (forall version environment locals memory mario y offset after,
    locals ! GP._m = Some (Vptr mario Ptrofs.zero) ->
    locals ! GP._yOffset = Some (Vsingle offset) ->
    Mem.load Mfloat32 memory mario 64 = Some (Vsingle y) ->
    Mem.store Mfloat32 memory mario 64 (Vsingle (Float32.add y offset)) = Some after ->
    ClightBigstep.Clight2.exec_stmt
      (Clight.globalenv (selected_clight_target version)) environment locals memory
      rank10a_y_write E0 (PTree.set GP._t'25 (Vsingle y) locals) after Out_normal) /\
  (forall origin timer y, -16000 <= origin <= 16000 ->
    Rank10AStartupReach origin timer y ->
    (rank9cf_real y <= IZR (origin + 110))%R) /\
  (rank10a_relative_bits rank10a_timing =
    map (fun z => Float32.to_bits (ueq_f32 z))
      [30;58;84;108;130;150;168;184;198;210;220;230;240;250;260]) /\
  (forall trig, rank9cf_finite trig ->
    rank9cf_real (Float32.mul trig (rank9cf_integer 0)) = 0%R) /\
  (forall bin y, -16000 <= bin <= 16000 -> rank9cf_finite y ->
    (IZR bin <= rank9cf_real y <= IZR (bin + 1))%R ->
    Float32.cmp Cgt y (Float32.add
      (Float32.add y (rank9cf_integer (-10))) (rank9cf_integer 100)) = false).

Theorem rank10a_ground_pound_boundary_checked : Rank10AGroundPoundBoundary.
Proof.
  split; [exact rank10a_selected_bodies_resolve |].
  split.
  - intro version. split.
    + exact (proj1 (proj2 (rank10a_startup_calls_are_exact version))).
    + exact (rank10a_geometry_queries_still_precede_the_first_branch version).
  - split; [exact rank10a_y_write_executes |].
    split; [exact rank10a_startup_stays_below_entry_ceiling_plus_110 |].
    split; [exact (proj1 (proj2 rank10a_ordinary_descriptor_has_a_height_window)) |].
    split.
    + intros trig H. exact (proj2 (rank10a_zero_speed_has_no_hidden_horizontal_magnitude trig H)).
    + exact rank10a_ten_unit_descent_cannot_pass_off_floor_test.
Qed.
