(** Rank 9: a concrete upper-platform ledge window and the real star-fall
    branch which retains it. These are selected-Clight fragment executions
    and generated-mesh facts, NOT a cut-starting controller continuation.
    The static query diagnostic is separate from this kernel proof. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Errors Events Floats Globalenvs Integers Maps Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import ASTFacts GameTypes CollisionRegions PyramidTopPU
  Area2Rank11LivePoleExit EyerokRank15LiveMovement SelectedClightTarget
  Area2Rank9AStarSource Area2Rank9AStarExecution Area2Rank9ACoinFlight
  Area2Rank12BContact Area2Rank9ACoinProducers NoExitStarDialogBridge.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

(** * The exact post-air-step decision. A ledge result is 3, not LANDED=1.
    This fragment performs no landing sound, action change, floor snap or
    outside call. The later animation call still needs its own frame. *)
Definition rank9_post_air_decision version :=
  match rank12b_drop_sequences 1 (fn_body (rank9a_body version R9Fall)) with
  | Ssequence (Ssequence _ decision) _ => decision | _ => Sskip end.

Definition rank9_fall_air_call version :=
  match rank12b_drop_sequences 1 (fn_body (rank9a_body version R9Fall)) with
  | Ssequence (Ssequence call _) _ => call | _ => Sskip end.

Theorem rank9_fall_enables_the_ledge_check : forall version,
  rank9_fall_air_call version =
    Scall (Some R9C._t'3)
      (Evar R9C._perform_air_step (Tfunction
        [tptr (Tstruct R9M._MarioState noattr); tuint] tint cc_default))
      [Etempvar R9M._m (tptr (Tstruct R9M._MarioState noattr));
       Econst_int Int.one tint].
Proof. intros []; reflexivity. Qed.

Definition rank9_landing_body version := match rank9_post_air_decision version with
| Sifthenelse _ landed _ => landed | _ => Sskip end.

Theorem rank9_fall_decision_is_generated : forall version,
  rank9_post_air_decision version =
    Sifthenelse (Ebinop Oeq (Etempvar R9C._t'3 tint)
      (Econst_int (Int.repr 1) tint) tint) (rank9_landing_body version) Sskip.
Proof. intros []; reflexivity. Qed.

Theorem rank9_ledge_result_retains_memory :
  forall version environment locals memory,
    locals ! R9C._t'3 = Some (Vint (Int.repr 3)) ->
    ClightBigstep.Clight2.exec_stmt
      (Clight.globalenv (selected_clight_target version)) environment locals memory
      (rank9_post_air_decision version) E0 locals memory Out_normal.
Proof.
  intros version environment locals memory Hresult.
  rewrite rank9_fall_decision_is_generated.
  eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
  - eapply eval_Ebinop; [apply eval_Etempvar; exact Hresult | constructor | reflexivity].
  - reflexivity.
  - constructor.
Qed.

Theorem rank9_ledge_result_smallsteps :
  forall version environment locals memory continuation,
    locals ! R9C._t'3 = Some (Vint (Int.repr 3)) ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv (selected_clight_target version))
      (State (rank9a_body version R9Fall) (rank9_post_air_decision version)
        continuation environment locals memory) E0
      (State (rank9a_body version R9Fall) Sskip
        continuation environment locals memory).
Proof.
  intros version environment locals memory continuation Hresult.
  pose proof (rank9_ledge_result_retains_memory version environment locals memory Hresult) as Hexec.
  destruct (ClightBigstep.exec_stmt_steps Clight.function_entry2
    (selected_clight_target version) _ _ _ _ _ _ _ _ Hexec
    (rank9a_body version R9Fall) continuation) as (last & Hsteps & Hout).
  inversion Hout; subst. exact Hsteps.
Qed.

(** * The two real stores AFTER the position-copy call in check_ledge_grab.
    The caller's floor must come from the same returned local floor and Y.
    We do not grant an unspecified vec3f_copy or atan2s effect. *)
Definition rank9_ledge_floor_commit version :=
  match rank12b_drop_sequences 9 (fn_body (rank9a_body version R9Ledge)) with
  | Ssequence first (Ssequence second _) => Ssequence first second
  | _ => Sskip end.

Definition rank9_surface_pointer := tptr (Tstruct R9S._Surface noattr).
Definition rank9_ledge_floor_statement :=
  Ssequence
    (Ssequence (Sset R9S._t'11 (Evar R9S._ledgeFloor rank9_surface_pointer))
      (Sassign (rank11_mario_field_expression R9M._floor rank9_surface_pointer)
        (Etempvar R9S._t'11 rank9_surface_pointer)))
    (Ssequence
      (Sset R9S._t'10 (Ederef (Ebinop Oadd
        (Evar R9S._ledgePos (tarray tfloat 3))
        (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
      (Sassign (rank11_mario_field_expression R9M._floorHeight tfloat)
        (Etempvar R9S._t'10 tfloat))).

Theorem rank9_ledge_floor_commit_is_generated : forall version,
  rank9_ledge_floor_commit version = rank9_ledge_floor_statement.
Proof. intros []; reflexivity. Qed.

Lemma rank9_floor_field_offset : forall version,
  exists description,
    (genv_cenv (Clight.globalenv (selected_clight_target version))) !
      R9M._MarioState = Some description /\
    field_offset (Clight.globalenv (selected_clight_target version)) R9M._floor
      (co_members description) = OK (104, Full).
Proof.
  intro version.
  assert (Hcheck : match (rank15_selected_header_environment version) ! R9M._MarioState with
    | Some description => rank11_field_offset_check (rank15_selected_header_environment version)
        (co_members description) R9M._floor 104 = true | None => False end).
  { destruct version; vm_compute; reflexivity. }
  rewrite rank15_selected_header_environment_exact in Hcheck.
  destruct ((prog_comp_env (selected_clight_target version)) ! R9M._MarioState)
    as [description |] eqn:E; [| contradiction].
  exists description. split; [exact E |].
  apply rank11_field_offset_check_sound. exact Hcheck.
Qed.

Lemma rank9_floor_field_lvalue : forall version environment locals memory mario,
  locals ! R9M._m = Some (Vptr mario Ptrofs.zero) ->
  eval_lvalue (Clight.globalenv (selected_clight_target version)) environment locals memory
    (rank11_mario_field_expression R9M._floor rank9_surface_pointer)
    mario (Ptrofs.repr 104) Full.
Proof.
  intros version environment locals memory mario Hm.
  destruct (rank9_floor_field_offset version) as (description & Hco & Hoff).
  replace (Ptrofs.repr 104) with (Ptrofs.add Ptrofs.zero (Ptrofs.repr 104)) by reflexivity.
  unfold rank11_mario_field_expression. eapply eval_Efield_struct with (co := description).
  - eapply eval_Elvalue.
    + apply eval_Ederef. apply eval_Etempvar. exact Hm.
    + apply deref_loc_copy. reflexivity.
  - reflexivity.
  - exact Hco.
  - exact Hoff.
Qed.

Definition rank9_commit_locals locals floor_pointer height :=
  PTree.set R9S._t'10 (Vsingle height)
    (PTree.set R9S._t'11 floor_pointer locals).

Definition Rank9LedgeCommitExecution : Prop :=
  forall version environment locals before mario floor_cell ledge_cell floor_block floor_offset height,
    locals ! R9M._m = Some (Vptr mario Ptrofs.zero) ->
    environment ! R9S._ledgeFloor = Some (floor_cell, rank9_surface_pointer) ->
    environment ! R9S._ledgePos = Some (ledge_cell, tarray tfloat 3) ->
    ledge_cell <> mario ->
    Mem.load Mint32 before floor_cell 0 = Some (Vptr floor_block floor_offset) ->
    Mem.load Mfloat32 before ledge_cell 4 = Some (Vsingle height) ->
    Mem.valid_access before Mint32 mario 104 Writable ->
    Mem.valid_access before Mfloat32 mario 112 Writable ->
    exists middle after,
      Mem.store Mint32 before mario 104 (Vptr floor_block floor_offset) = Some middle /\
      Mem.store Mfloat32 middle mario 112 (Vsingle height) = Some after /\
      ClightBigstep.Clight2.exec_stmt
        (Clight.globalenv (selected_clight_target version)) environment locals before
        (rank9_ledge_floor_commit version) E0
        (rank9_commit_locals locals (Vptr floor_block floor_offset) height) after Out_normal /\
      Mem.load Mint32 after mario 104 = Some (Vptr floor_block floor_offset) /\
      Mem.load Mfloat32 after mario 112 = Some (Vsingle height) /\
      (forall offset, In offset [12;60;64;68;72;76;80;84] ->
        Mem.load Mint32 after mario offset = Mem.load Mint32 before mario offset) /\
      (forall offset, In offset [60;64;68;72;76;80;84] ->
        Mem.load Mfloat32 after mario offset = Mem.load Mfloat32 before mario offset).

Theorem rank9_ledge_commits_same_floor_and_height : Rank9LedgeCommitExecution.
Proof.
  unfold Rank9LedgeCommitExecution.
  intros version environment locals before mario floor_cell ledge_cell floor_block floor_offset height
    Hm Hfloorvar Hledgevar Hdistinct Hfloor Hheight Hflooraccess Hheightaccess.
  destruct (Mem.valid_access_store before Mint32 mario 104 (Vptr floor_block floor_offset)
    Hflooraccess) as [middle Hstorefloor].
  assert (Hheight' : Mem.load Mfloat32 middle ledge_cell 4 = Some (Vsingle height)).
  { rewrite <- Hheight. eapply Mem.load_store_other; [exact Hstorefloor | auto]. }
  assert (Hheightaccess' : Mem.valid_access middle Mfloat32 mario 112 Writable).
  { eapply Mem.store_valid_access_1; eauto. }
  destruct (Mem.valid_access_store middle Mfloat32 mario 112 (Vsingle height)
    Hheightaccess') as [after Hstoreheight].
  exists middle, after. split; [exact Hstorefloor |]. split; [exact Hstoreheight |]. split.
  - rewrite rank9_ledge_floor_commit_is_generated.
    unfold rank9_ledge_floor_statement, rank9_commit_locals.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
        -- apply eval_Evar_local. exact Hfloorvar.
        -- eapply deref_loc_value with (chunk := Mint32); eauto.
      * eapply exec_Sassign with (loc := mario) (ofs := Ptrofs.repr 104)
          (bf := Full) (v2 := Vptr floor_block floor_offset) (v := Vptr floor_block floor_offset).
        -- apply rank9_floor_field_lvalue. rewrite PTree.gso by discriminate. exact Hm.
        -- apply eval_Etempvar. apply PTree.gss.
        -- reflexivity.
        -- eapply assign_loc_value with (chunk := Mint32); [reflexivity | exact Hstorefloor].
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply eval_Elvalue with (ofs := Ptrofs.repr 4) (bf := Full).
        -- apply eval_Ederef. eapply eval_Ebinop.
           ++ eapply eval_Elvalue.
              ** apply eval_Evar_local. exact Hledgevar.
              ** apply deref_loc_reference. reflexivity.
           ++ constructor.
           ++ reflexivity.
        -- eapply deref_loc_value with (chunk := Mfloat32); eauto.
      * eapply exec_Sassign with (loc := mario) (ofs := Ptrofs.repr 112)
          (bf := Full) (v2 := Vsingle height) (v := Vsingle height).
        -- eapply rank9a_field_lvalue; [| cbn; auto].
           repeat rewrite PTree.gso by discriminate. exact Hm.
        -- apply eval_Etempvar. apply PTree.gss.
        -- reflexivity.
        -- eapply assign_loc_value with (chunk := Mfloat32); [reflexivity | exact Hstoreheight].
  - split.
    + erewrite Mem.load_store_other by (first [exact Hstoreheight | right; cbn; lia]).
      erewrite Mem.load_store_same by exact Hstorefloor. reflexivity.
    + split.
      * erewrite Mem.load_store_same by exact Hstoreheight. reflexivity.
      * split; intros offset Hin;
          erewrite Mem.load_store_other by (first [exact Hstoreheight | right; cbn in Hin |- *; intuition lia]);
          (eapply Mem.load_store_other; [exact Hstorefloor | right; cbn in Hin |- *; intuition lia]).
Qed.

(** * Generated mesh and exact Float32 candidate. The selected wall is on
    the rear part of the platform, beyond the raised rim's west end.
    None of these facts certifies the live SurfaceNode list or query calls. *)
Definition rank9_platform_wall := ((387,4687,-409),(387,4815,-1125),(387,4687,-1125)).
Definition rank9_platform_floor := ((387,4815,-409),(643,4815,-1125),(387,4815,-1125)).
Definition rank9_destination : Vec3f :=
  {| vec_x := rank9cf_integer 397; vec_y := rank9cf_integer 4815; vec_z := rank9cf_integer (-850) |}.

Theorem rank9_wall_and_destination_are_generated : forall version,
  nth_error (rank12b_faces version) 680 = Some (680%nat, Some rank9_platform_wall) /\
  nth_error (rank12b_faces version) 1400 = Some (1400%nat, Some rank9_platform_floor) /\
  DG.point_in_closed_triangle_xz (397,4815,-850)
    (387,4815,-409) (643,4815,-1125) (387,4815,-1125).
Proof.
  intro version. split.
  - destruct version; vm_compute; reflexivity.
  - split.
    + destruct version; vm_compute; reflexivity.
    + right; vm_compute; repeat split; discriminate.
Qed.

Definition rank9_quarter_y y :=
  Float32.add (rank9cf_integer y)
    (Float32.div (rank9cf_integer (-50)) (rank9cf_integer 4)).
Definition rank9_height_window y :=
  let next := rank9_quarter_y y in
  Float32.cmp Cgt (Float32.add next (rank9cf_integer 150)) (rank9cf_integer 4815) &&
  Float32.cmp Cge (Float32.add next (rank9cf_integer 30)) (rank9cf_integer 4687) &&
  Float32.cmp Cle (Float32.add next (rank9cf_integer 30)) (rank9cf_integer 4815) &&
  Float32.cmp Cgt (Float32.sub (rank9cf_integer 4815) next) (rank9cf_integer 100) &&
  Float32.cmp Cge (Float32.add next (rank9cf_integer 160)) (rank9cf_integer (4815-78)) &&
  Float32.cmp Clt (Float32.add next (rank9cf_integer 160)) (rank9cf_integer 5222).

Theorem rank9_fifty_integral_height_samples :
  filter rank9_height_window (map Z.of_nat (seq 4600 201)) =
    map Z.of_nat (seq 4678 50).
Proof. vm_compute; reflexivity. Qed.

Theorem rank9_sample_exact_snap :
  Float32.to_bits (rank9_quarter_y 4700) = Int.repr 1167227904 /\
  Float32.to_bits (Float32.sub (rank9cf_integer 337)
    (Float32.mul (rank9cf_integer (-1)) (rank9cf_integer 60))) =
    Float32.to_bits (rank9cf_integer 397) /\
  rank9_height_window 4700 = true /\
  Float32.cmp Cgt (Float32.sub (rank9cf_integer 4815) (rank9_quarter_y 4700))
    (rank9cf_integer 100) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

(** A normal fixed coin is nearby for this route, unlike Rank 9A's pole.
    This is conditional hitbox/placement arithmetic, not a collection or
    a proof of the time at which the spawned star samples Mario. *)
Definition rank9_coin_candidate : Vec3f :=
  {| vec_x := rank9cf_integer 290; vec_y := rank9cf_integer 4607; vec_z := rank9cf_integer (-940) |}.
Definition rank9_coin_hitbox : Hitbox :=
  {| hitbox_radius := rank9cf_integer 100; hitbox_height := rank9cf_integer 64;
     hitbox_down_offset := Float32.zero |}.
Definition rank9_coin_contact_sample : Vec3f :=
  {| vec_x := rank9cf_integer 340; vec_y := rank9cf_integer 4600; vec_z := rank9cf_integer (-850) |}.

Definition rank9_vertical_offset_expression version :=
  match rank12b_drop_sequences 3 (fn_body (match version with
    | VersionUS => R9CA.f_spawn_coin_in_formation
    | VersionJP => R9CJ.f_spawn_coin_in_formation end)) with
  | Ssequence (Sswitch _ (LScons (Some 0) _ (LScons (Some 1) branch _))) _ =>
      match branch with Ssequence _ (Ssequence (Sassign _ rhs) _) => rhs
      | _ => Econst_int Int.zero tint end
  | _ => Econst_int Int.zero tint end.

Theorem rank9_coin_descriptor_and_offset_are_generated : forall version,
  gvar_init (match version with VersionUS => R9CA.v_sYellowCoinHitbox
    | VersionJP => R9CJ.v_sYellowCoinHitbox end) =
    [Init_int32 (Int.repr 16); Init_int8 Int.zero; Init_int8 Int.one;
     Init_int8 Int.zero; Init_int8 Int.zero; Init_int16 (Int.repr 100);
     Init_int16 (Int.repr 64); Init_int16 Int.zero; Init_int16 Int.zero] /\
  rank9_vertical_offset_expression version =
    Ebinop Omul (Ebinop Omul (Econst_int (Int.repr 160) tint)
      (Etempvar R9CA._coinIndex tint) tint)
      (Econst_float (Float.of_bits (Int64.repr 4605380978949069210)) tdouble) tdouble /\
  Float.to_int (Float.mul (Float.of_int (Int.repr 160))
    (Float.of_bits (Int64.repr 4605380978949069210))) = Some (Int.repr 128).
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem rank9_nearby_coin_and_star_vertical_window :
  In [41;290;4479;-940;0] rank9ac_formation_records /\
  4479+128=4607 /\
  hitboxes_overlap rank9_coin_contact_sample mario_standard_hitbox_f32
    rank9_coin_candidate rank9_coin_hitbox = true /\
  prepared_settled_star_vertical_overlap_model 4600 4700.
Proof.
  split; [cbn; auto |]. split; [reflexivity |].
  split; [vm_compute; reflexivity | unfold prepared_settled_star_vertical_overlap_model; lia].
Qed.

Definition Rank9UpperStarDanceBoundary : Prop :=
  Rank9LedgeCommitExecution /\
  (forall version environment locals memory continuation,
    locals ! R9C._t'3 = Some (Vint (Int.repr 3)) ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv (selected_clight_target version))
      (State (rank9a_body version R9Fall) (rank9_post_air_decision version)
        continuation environment locals memory) E0
      (State (rank9a_body version R9Fall) Sskip continuation environment locals memory)) /\
  (forall version, rank9_ledge_floor_commit version = rank9_ledge_floor_statement) /\
  (forall version,
    nth_error (rank12b_faces version) 680 = Some (680%nat, Some rank9_platform_wall) /\
    nth_error (rank12b_faces version) 1400 = Some (1400%nat, Some rank9_platform_floor) /\
    DG.point_in_closed_triangle_xz (397,4815,-850)
      (387,4815,-409) (643,4815,-1125) (387,4815,-1125)) /\
  filter rank9_height_window (map Z.of_nat (seq 4600 201)) = map Z.of_nat (seq 4678 50) /\
  (hitboxes_overlap rank9_coin_contact_sample mario_standard_hitbox_f32
    rank9_coin_candidate rank9_coin_hitbox = true /\
    prepared_settled_star_vertical_overlap_model 4600 4700).

Theorem rank9_upper_star_dance_boundary_checked : Rank9UpperStarDanceBoundary.
Proof.
  split; [exact rank9_ledge_commits_same_floor_and_height |].
  split; [exact rank9_ledge_result_smallsteps |].
  split; [exact rank9_ledge_floor_commit_is_generated |].
  split; [exact rank9_wall_and_destination_are_generated |].
  split; [exact rank9_fifty_integral_height_samples |].
  exact (proj2 (proj2 rank9_nearby_coin_and_star_vertical_window)).
Qed.
