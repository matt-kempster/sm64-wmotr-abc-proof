(** Rank 9: the star's actual home-Y stores and a single startup's timing.
    This is a selected-Clight memory fragment plus explicitly finite Float32
    consequences, not a clean 99-coin arrival or a whole gameplay suffix. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_behavior_actions jp_behavior_actions.
From LessThanOneAPress.Proofs Require Import ASTFacts GameTypes CollisionRegions PyramidTopPU
  Area2Rank9UpperStarDance Area2Rank9ACoinLaunch Area2Rank10AGroundPound
  EyerokRank15LiveMovement Area2Rank11LivePoleExit Area2Rank11BodyResolution Area2Rank9ACoinFlight
  Area2Rank12BContact NoExitStarDialogBridge SelectedClightTarget
  CleanedClightPrograms ClightLinkExecution GlobalInterfaceStructural
  JPSourceSymbolTransport JPWarpLevelEntryResolution LinkedClightPrograms
  NormalizedClightPrograms SuccessfulMakeProgramResolution
  USViewportRepairedNamesNorepet USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USWarpLevelSourceUnionReceipt USWholeASTTagRepair.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Module ST := us_behavior_actions.

Definition rank9t_home_body version := match version with
| VersionUS => ST.f_set_home_to_mario
| VersionJP => jp_behavior_actions.f_set_home_to_mario end.

Lemma rank9t_home_us_receipt :
  nth_error ST.global_definitions
    (rank11_definition_index ST._set_home_to_mario ST.global_definitions) =
  Some (ST._set_home_to_mario, Gfun (Internal (rank9t_home_body VersionUS))).
Proof. vm_compute; reflexivity. Qed.

Lemma rank9t_home_us_member :
  In (ST._set_home_to_mario, Gfun (Internal (rank9t_home_body VersionUS)))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union with
    (unit := us_nlist_at 25 us_units).
  - exact (us_nlist_at_nIn _ 25 us_units).
  - eapply nth_error_In. exact rank9t_home_us_receipt.
Qed.

Lemma rank9t_home_us_selection :
  us_normalized_global_definition_map ! ST._set_home_to_mario =
    Some (Gfun (Internal (rank9t_home_body VersionUS))).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact rank9t_home_us_member.
Qed.

Local Opaque normalize_global_definition_map normalize_global_definitions.
Lemma rank9t_home_us_selected :
  In (ST._set_home_to_mario, Gfun (Internal (rank9t_home_body VersionUS)))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions. apply fixed_point_enters_mapped_list.
  - reflexivity.
  - exact (every_selected_internal_body_is_preserved_verbatim
      (unit_global_definitions us_units) ST._set_home_to_mario _ rank9t_home_us_selection).
Qed.

Lemma rank9t_home_jp_receipt :
  (prog_defmap (nlist_at 25 jp_cleaned_units)) ! ST._set_home_to_mario =
    Some (Gfun (Internal (rank9t_home_body VersionJP))).
Proof. vm_compute; reflexivity. Qed.

Theorem rank9t_home_resolves : forall version, exists function_block,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    ST._set_home_to_mario = Some function_block /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
    function_block = Some (Internal (rank9t_home_body version)).
Proof.
  intros [].
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact rank9t_home_us_selected.
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link (nlist_at 25 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 25 jp_cleaned_units).
    + exact rank9t_home_jp_receipt.
Qed.

Definition rank9t_object_pointer := tptr (Tstruct ST._Object noattr).
Definition rank9t_index (home : bool) := if home then Econst_int (Int.repr 56) tint
  else Ebinop Oadd (Econst_int (Int.repr 6) tint) (Econst_int Int.one tint) tint.
Definition rank9t_index_value (home : bool) := Int.repr (if home then 56 else 7).
Definition rank9t_250 := Float32.of_bits (Int.repr 1132068864).
Definition rank9t_raise (add250 : bool) y := if add250
  then Float32.add y rank9t_250 else y.
Definition rank9t_transfer version destination source value source_global from_home to_home (add250 : bool) :=
  Ssequence (Sset destination rank15_current_object_expression)
  (Ssequence (Sset source (Evar source_global rank9t_object_pointer))
  (Ssequence (Sset value
    (rank15_raw_float_expression version source (rank9t_index from_home)))
    (Sassign (rank15_raw_float_expression version destination (rank9t_index to_home))
      (if add250 then Ebinop Oadd (Etempvar value tfloat)
        (Econst_single rank9t_250 tfloat) tfloat
       else Etempvar value tfloat)))).
Definition rank9t_transfer_locals locals destination source value target origin y :=
  PTree.set value (Vsingle y) (PTree.set source origin (PTree.set destination target locals)).

Definition rank9t_y_sequence version :=
  Ssequence (rank9t_transfer version ST._t'17 ST._t'18 ST._t'19 ST._gMarioObject false true false)
    (Ssequence (rank9t_transfer version ST._t'14 ST._t'15 ST._t'16 ST._gCurrentObject true true true)
      (rank9t_transfer version ST._t'11 ST._t'12 ST._t'13 ST._gCurrentObject true false false)).

Definition rank9t_extracted_y_sequence version :=
  match rank12b_drop_sequences 2 (fn_body (rank9t_home_body version)) with
  | Ssequence a (Ssequence b (Ssequence c _)) => Ssequence a (Ssequence b c)
  | _ => Sskip end.

Lemma rank9t_extracted_y_sequence_exact : forall version,
  rank9t_extracted_y_sequence version = rank9t_y_sequence version.
Proof. intros []; reflexivity. Qed.

Theorem rank9t_home_y_sequence_is_generated : forall version,
  exists copy_x copy_z tail,
    fn_body (rank9t_home_body version) =
      Ssequence copy_x (Ssequence copy_z
        (Ssequence
          (rank9t_transfer version ST._t'17 ST._t'18 ST._t'19 ST._gMarioObject false true false)
          (Ssequence
            (rank9t_transfer version ST._t'14 ST._t'15 ST._t'16 ST._gCurrentObject true true true)
            (Ssequence
              (rank9t_transfer version ST._t'11 ST._t'12 ST._t'13 ST._gCurrentObject true false false)
              tail)))).
Proof. intros []; do 3 eexists; reflexivity. Qed.

Lemma rank9t_index_evaluates : forall home ge environment locals memory,
  eval_expr ge environment locals memory (rank9t_index home) (Vint (rank9t_index_value home)).
Proof. intros [] ge environment locals memory; [constructor |].
  eapply eval_Ebinop; [constructor | constructor | reflexivity]. Qed.

Lemma rank9t_global_pointer_read : forall (ge : Clight.genv) environment locals memory name cell object,
  environment ! name = None -> Genv.find_symbol ge name = Some cell ->
  Mem.load Mptr memory cell 0 = Some object ->
  eval_expr ge environment locals memory (Evar name rank9t_object_pointer) object.
Proof.
  intros. eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
  - eapply eval_Evar_global; eauto.
  - eapply deref_loc_value with (chunk := Mptr); eauto.
Qed.

Lemma rank9t_transfer_executes :
  forall version environment locals memory destination source value source_global
    from_home to_home add250 current_cell source_cell target origin target_ofs origin_ofs y after,
  destination <> source -> destination <> value -> source <> value ->
  environment ! ST._gCurrentObject = None -> environment ! source_global = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) ST._gCurrentObject = Some current_cell ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) source_global = Some source_cell ->
  Mem.load Mptr memory current_cell 0 = Some (Vptr target target_ofs) ->
  Mem.load Mptr memory source_cell 0 = Some (Vptr origin origin_ofs) ->
  Mem.load Mfloat32 memory origin
    (Ptrofs.unsigned (rank15_raw_address origin_ofs (rank9t_index_value from_home))) = Some (Vsingle y) ->
  Mem.store Mfloat32 memory target
    (Ptrofs.unsigned (rank15_raw_address target_ofs (rank9t_index_value to_home)))
    (Vsingle (rank9t_raise add250 y)) = Some after ->
  ClightBigstep.Clight2.exec_stmt
    (Clight.globalenv (selected_clight_target version)) environment locals memory
    (rank9t_transfer version destination source value source_global from_home to_home add250) E0
    (rank9t_transfer_locals locals destination source value
      (Vptr target target_ofs) (Vptr origin origin_ofs) y) after Out_normal.
Proof.
  intros version environment locals memory destination source value source_global
    from_home to_home add250 current_cell source_cell target origin target_ofs origin_ofs y after
    Hds Hdv Hsv Hng Hns Hsg Hss Hlg Hls Hy Hstore.
  unfold rank9t_transfer, rank9t_transfer_locals.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply rank15_current_object_read; eauto.
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + apply exec_Sset. eapply rank9t_global_pointer_read; eauto.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply rank15_raw_float_read.
        -- apply PTree.gss.
        -- apply rank9t_index_evaluates.
        -- destruct from_home; reflexivity.
        -- exact Hy.
      * eapply exec_Sassign with
          (loc := target) (ofs := rank15_raw_address target_ofs (rank9t_index_value to_home))
          (bf := Full) (v2 := Vsingle (rank9t_raise add250 y)) (v := Vsingle (rank9t_raise add250 y)).
        -- eapply rank15_raw_float_lvalue.
           ++ rewrite PTree.gso by congruence. rewrite PTree.gso by congruence. apply PTree.gss.
           ++ apply rank9t_index_evaluates.
           ++ destruct to_home; reflexivity.
        -- destruct add250; cbn [rank9t_raise].
           ++ eapply eval_Ebinop; [apply eval_Etempvar; apply PTree.gss | constructor | reflexivity].
           ++ apply eval_Etempvar. apply PTree.gss.
        -- destruct add250; reflexivity.
        -- eapply assign_loc_value with (chunk := Mfloat32); [destruct add250; reflexivity | exact Hstore].
Qed.

(** The same Object block is allowed for Mario and the star: they normally
    occupy different subranges of one pool. No false block-distinctness
    premise separates the two objects. Global current-pointer storage must
    be separate from the destination object block. *)
Definition Rank9HomeYExecution : Prop :=
  forall version environment locals before current_cell mario_cell star mario star_ofs mario_ofs y,
  environment ! ST._gCurrentObject = None -> environment ! ST._gMarioObject = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) ST._gCurrentObject = Some current_cell ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) ST._gMarioObject = Some mario_cell ->
  current_cell <> star ->
  Mem.load Mptr before current_cell 0 = Some (Vptr star star_ofs) ->
  Mem.load Mptr before mario_cell 0 = Some (Vptr mario mario_ofs) ->
  Mem.load Mfloat32 before mario
    (Ptrofs.unsigned (rank15_raw_address mario_ofs (Int.repr 7))) = Some (Vsingle y) ->
  Mem.valid_access before Mfloat32 star
    (Ptrofs.unsigned (rank15_raw_address star_ofs (Int.repr 56))) Writable ->
  Mem.valid_access before Mfloat32 star
    (Ptrofs.unsigned (rank15_raw_address star_ofs (Int.repr 7))) Writable ->
  exists after final_locals,
    ClightBigstep.Clight2.exec_stmt
      (Clight.globalenv (selected_clight_target version)) environment locals before
      (rank9t_extracted_y_sequence version) E0 final_locals after Out_normal /\
    Mem.load Mfloat32 after star
      (Ptrofs.unsigned (rank15_raw_address star_ofs (Int.repr 7))) =
        Some (Vsingle (Float32.add y rank9t_250)) /\
    (forall chunk block offset,
      (block <> star \/ offset + size_chunk chunk <=
        Ptrofs.unsigned (rank15_raw_address star_ofs (Int.repr 56)) \/
        Ptrofs.unsigned (rank15_raw_address star_ofs (Int.repr 56)) + 4 <= offset) ->
      (block <> star \/ offset + size_chunk chunk <=
        Ptrofs.unsigned (rank15_raw_address star_ofs (Int.repr 7)) \/
        Ptrofs.unsigned (rank15_raw_address star_ofs (Int.repr 7)) + 4 <= offset) ->
      Mem.load chunk after block offset = Mem.load chunk before block offset).

Theorem rank9t_home_y_executes : Rank9HomeYExecution.
Proof.
  unfold Rank9HomeYExecution.
  intros version environment locals before current_cell mario_cell star mario star_ofs mario_ofs y
    Hng Hnm Hsg Hsm Hdistinct Hlg Hlm Hy Hwh Hwp.
  destruct (Mem.valid_access_store _ _ _ _ (Vsingle y) Hwh) as [m1 Hs1].
  assert (Hwh1 : Mem.valid_access m1 Mfloat32 star
    (Ptrofs.unsigned (rank15_raw_address star_ofs (Int.repr 56))) Writable)
    by (eapply Mem.store_valid_access_1; eauto).
  destruct (Mem.valid_access_store _ _ _ _ (Vsingle (Float32.add y rank9t_250)) Hwh1)
    as [m2 Hs2].
  assert (Hwp2 : Mem.valid_access m2 Mfloat32 star
    (Ptrofs.unsigned (rank15_raw_address star_ofs (Int.repr 7))) Writable).
  { eapply Mem.store_valid_access_1; [exact Hs2 |]. eapply Mem.store_valid_access_1; eauto. }
  destruct (Mem.valid_access_store _ _ _ _ (Vsingle (Float32.add y rank9t_250)) Hwp2)
    as [after Hs3].
  assert (Hlg1 : Mem.load Mptr m1 current_cell 0 = Some (Vptr star star_ofs)).
  { erewrite Mem.load_store_other by (first [exact Hs1 | left; congruence]). exact Hlg. }
  assert (Hlg2 : Mem.load Mptr m2 current_cell 0 = Some (Vptr star star_ofs)).
  { erewrite Mem.load_store_other by (first [exact Hs2 | left; congruence]). exact Hlg1. }
  assert (Hy1 : Mem.load Mfloat32 m1 star
    (Ptrofs.unsigned (rank15_raw_address star_ofs (Int.repr 56))) = Some (Vsingle y)).
  { erewrite Mem.load_store_same by exact Hs1. reflexivity. }
  assert (Hy2 : Mem.load Mfloat32 m2 star
    (Ptrofs.unsigned (rank15_raw_address star_ofs (Int.repr 56))) =
      Some (Vsingle (Float32.add y rank9t_250))).
  { erewrite Mem.load_store_same by exact Hs2. reflexivity. }
  exists after. eexists. split.
  - rewrite rank9t_extracted_y_sequence_exact. unfold rank9t_y_sequence.
    eapply exec_Sseq_1 with (m1 := m1) (t1 := E0) (t2 := E0).
    + eapply rank9t_transfer_executes; try discriminate; eauto.
    + eapply exec_Sseq_1 with (m1 := m2) (t1 := E0) (t2 := E0).
      * eapply rank9t_transfer_executes; try discriminate; eauto.
      * eapply rank9t_transfer_executes; try discriminate; eauto.
  - split.
    + erewrite Mem.load_store_same by exact Hs3. reflexivity.
    + intros chunk block offset Hhome Hpos.
      erewrite Mem.load_store_other by (first [exact Hs3 | exact Hpos]).
      erewrite Mem.load_store_other by (first [exact Hs2 | exact Hhome]).
      eapply Mem.load_store_other; [exact Hs1 | exact Hhome].
Qed.

(** Float32 replay, not a replacement for the spawned-star Clight loop.
    Action/velocity/gravity tests follow its pre-movement branch order. *)
(* Keep only 32-bit representations between ticks, avoiding duplication of
   Flocq proof terms when the complete 77-update receipt is normalized. *)
Definition rank9t_orbit_state := (Z * int * int * int)%type.
Definition rank9t_orbit_step home (s : rank9t_orbit_state) : rank9t_orbit_state :=
  let '(action,ybits,vbits,gbits) := s in
  let y := Float32.of_bits ybits in
  let v := Float32.of_bits vbits in
  let g := Float32.of_bits gbits in
  let '(a,v',g') :=
    if Z.eqb action 0 then
      if Float32.cmp Clt v Float32.zero && Float32.cmp Clt y home
      then (1,rank9cf_integer 20,rank9cf_integer (-1)) else (0,v,g)
    else if Z.eqb action 1 then
      let capped := if Float32.cmp Clt v (rank9cf_integer (-4)) then rank9cf_integer (-4) else v in
      if Float32.cmp Clt capped Float32.zero && Float32.cmp Clt y home
      then (2,Float32.zero,Float32.zero) else (1,capped,g)
    else (action,v,g) in
  let velocity := Float32.add v' g' in
  (a,Float32.to_bits (Float32.add y velocity),Float32.to_bits velocity,Float32.to_bits g').

Definition rank9t_orbit home := Nat.iter 77 (rank9t_orbit_step home)
  (0,Float32.to_bits home,Float32.to_bits (rank9cf_integer 50),Float32.to_bits (rank9cf_integer (-4))).
Definition rank9t_lift timer := if (timer <? 10)%nat
  then rank9cf_integer (20-2*Z.of_nat timer) else Float32.zero.
Fixpoint rank9t_startup_y (count : nat) base : float32 := match count with
| O => base | S n => Float32.add (rank9t_startup_y n base) (rank9t_lift n) end.
Definition rank9t_star_y base collection_timer :=
  let sampled := rank9t_startup_y (S collection_timer) base in
  let '(_,y,_,_) := rank9t_orbit (Float32.add sampled (rank9cf_integer 250)) in Float32.of_bits y.
Definition rank9t_contact base collection_timer completed :=
  Float32.cmp Cge (Float32.add (rank9t_startup_y completed base) (rank9cf_integer 160))
    (rank9t_star_y base collection_timer).

Theorem rank9t_orbit_and_first_contact :
  rank9t_orbit (rank9cf_integer 4848) =
    (2,Float32.to_bits (rank9cf_integer 4843),Int.zero,Int.zero) /\
  map (fun n => Float32.to_bits (rank9t_startup_y n (rank9cf_integer 4578))) (seq 0 11) =
    map (fun z => Float32.to_bits (rank9cf_integer z))
      [4578;4598;4616;4632;4646;4658;4668;4676;4682;4686;4688] /\
  map (rank9t_contact (rank9cf_integer 4578) 0) (seq 1 10) =
    [false;false;false;false;false;false;false;false;true;true] /\
  rank9_height_window 4686 = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Definition rank9t_pose x y z : Vec3f :=
  {| vec_x := rank9cf_integer x; vec_y := rank9cf_integer y; vec_z := rank9cf_integer z |}.

Definition Rank9TimedContactSamples : Prop :=
  hitboxes_overlap (rank9t_pose 340 4578 (-850)) mario_standard_hitbox_f32
    rank9_coin_candidate rank9_coin_hitbox = true /\
  hitboxes_overlap (rank9t_pose 337 4682 (-850)) mario_standard_hitbox_f32
    (rank9t_pose 340 4843 (-850)) collect_star_hitbox = false /\
  hitboxes_overlap (rank9t_pose 337 4686 (-850)) mario_standard_hitbox_f32
    (rank9t_pose 340 4843 (-850)) collect_star_hitbox = true.

Theorem rank9t_timed_contacts_checked : Rank9TimedContactSamples.
Proof. vm_compute; repeat split; reflexivity. Qed.

(** If collection occurs with timer >= 1, its own update takes another lift
    BEFORE the star samples Y. Even granting every remaining lift, the same
    startup cannot touch the settled star. This does not exclude a new jump,
    moving support, later approach or a previously placed star. *)
Theorem rank9t_late_collection_cannot_use_same_startup :
  map (rank9t_contact (rank9cf_integer 4578) 0) [9%nat] = [true] /\
  map (fun timer => rank9t_contact (rank9cf_integer 4578) timer 10) (seq 1 9) =
    repeat false 9.
Proof. vm_compute; split; reflexivity. Qed.

Theorem rank9t_remaining_lift_budget :
  map (fun k => 110 - Z.of_nat k * (21-Z.of_nat k)) (seq 1 10) =
    [90;72;56;42;30;20;12;6;2;0] /\
  forall k, 2 <= k <= 10 -> 110-k*(21-k) < 85.
Proof. split; [reflexivity | intros k H; nia]. Qed.

Definition Rank9StarTimingBoundary : Prop :=
  Rank9HomeYExecution /\ Rank9TimedContactSamples /\
  (forall version, exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version)) ST._set_home_to_mario = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) function_block =
      Some (Internal (rank9t_home_body version))) /\
  rank9t_contact (rank9cf_integer 4578) 0 8 = false /\
  rank9t_contact (rank9cf_integer 4578) 0 9 = true /\
  rank9_height_window 4686 = true /\
  map (fun timer => rank9t_contact (rank9cf_integer 4578) timer 10) (seq 1 9) = repeat false 9.

Theorem rank9t_star_timing_boundary_checked : Rank9StarTimingBoundary.
Proof.
  split; [exact rank9t_home_y_executes |].
  split; [exact rank9t_timed_contacts_checked |].
  split; [exact rank9t_home_resolves |].
  vm_compute; repeat split; reflexivity.
Qed.
