(** Source-bounded exhaustiveness for an SSL Area-1 platform-created
    MarioState/MarioObject phase split.

    This file separates three questions which are easy to conflate:

    1. which stock Area-1 objects can own a dynamic floor;
    2. whether a completed platform query at the upper pyramid warp can retain
       any of those owners; and
    3. whether the object-pool/free-list mechanics contain a genuine
       three-dimensional payload writer elsewhere in Area 1.

    The finite owner model proves that a stock final query whose MarioObject
    overlaps node 0x1E has no object-owned floor and therefore records a null
    platform.  A small US/JP pre-apply provenance model then rules out a
    platform-created route-relevant split at that collision sample.

    Independently, the free-list model proves the exact two-allocation
    alignment of the current Wing-cap-box / breakable-box candidate, and exact
    CompCert binary32 arithmetic proves that its selected cartoon fragment
    changes X, Y, and Z.  That candidate's old collision object is proved not
    to overlap node 0x1E.  Its controller schedule and detailed object-count
    prehistory are therefore deliberately *not* Layer-B obligations: even a
    reachable instance cannot trigger the required Area-1 warp.

    The live Clight-memory owner/list projection remains the proof obligation
    needed to lift the stock-null result to the linked retail program.  No
    theorem here claims the ultimate no-A result or a reachable
    counterexample. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_ssl_script jp_ssl_script
  us_ssl_area1_macro jp_ssl_area1_macro
  us_macro_special_objects jp_macro_special_objects.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts CollisionMeshFacts Area1PhaseSplit PyramidTopPU
  PyramidTopSurface.

Import ListNotations.
Local Open Scope Z_scope.

Module UArea1Script := us_ssl_script.
Module JArea1Script := jp_ssl_script.
Module UArea1MacroInventory := us_ssl_area1_macro.
Module JArea1MacroInventory := jp_ssl_area1_macro.
Module UMacroPresets := us_macro_special_objects.
Module JMacroPresets := jp_macro_special_objects.

(** Extract the behavior pointers from the generated [MacroPreset] table.
    Each generated record is one pointer followed by two 16-bit fields. *)
Definition macro_preset_behavior
    (values : list init_data) (index : nat) : option init_data :=
  nth_error values (3 * index).

Definition expected_area1_signs : list (list Z) :=
  [ [52; 5702; 614; 2974; 16];
    [52; -3260; 256; 800; 32];
    [52; 5130; 26; -370; 157] ].

Definition expected_area1_cannon : list (list Z) :=
  [ [53; 6863; 0; -6860; 192] ].

Definition expected_area1_shell_box : list (list Z) :=
  [ [94; 5840; 940; 2500; 0] ].

Definition expected_area1_running_box : list (list Z) :=
  [ [110; -1200; 500; 800; 0] ].

(** The Wing-cap and large-breakable records are already named and checked in
    [Area1PhaseSplit].  These remaining tag checks, together with the preset
    table lookups below, cover all macro objects that use the four imported
    stock platform collision meshes. *)
Definition area1_macro_surface_owner_source_claim : Prop :=
  records_with_tag 52
    (gvar_init UArea1MacroInventory.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_signs /\
  records_with_tag 52
    (gvar_init JArea1MacroInventory.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_signs /\
  records_with_tag 53
    (gvar_init UArea1MacroInventory.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_cannon /\
  records_with_tag 53
    (gvar_init JArea1MacroInventory.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_cannon /\
  records_with_tag 94
    (gvar_init UArea1MacroInventory.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_shell_box /\
  records_with_tag 94
    (gvar_init JArea1MacroInventory.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_shell_box /\
  records_with_tag 110
    (gvar_init UArea1MacroInventory.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_running_box /\
  records_with_tag 110
    (gvar_init JArea1MacroInventory.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_running_box /\
  macro_preset_behavior
    (gvar_init UMacroPresets.v_sMacroObjectPresets) 21 =
      Some (Init_addrof UMacroPresets._bhvMessagePanel (Ptrofs.repr 0)) /\
  macro_preset_behavior
    (gvar_init JMacroPresets.v_sMacroObjectPresets) 21 =
      Some (Init_addrof JMacroPresets._bhvMessagePanel (Ptrofs.repr 0)) /\
  macro_preset_behavior
    (gvar_init UMacroPresets.v_sMacroObjectPresets) 22 =
      Some (Init_addrof UMacroPresets._bhvCannonClosed (Ptrofs.repr 0)) /\
  macro_preset_behavior
    (gvar_init JMacroPresets.v_sMacroObjectPresets) 22 =
      Some (Init_addrof JMacroPresets._bhvCannonClosed (Ptrofs.repr 0)) /\
  macro_preset_behavior
    (gvar_init UMacroPresets.v_sMacroObjectPresets) 60 =
      Some (Init_addrof UMacroPresets._bhvExclamationBox (Ptrofs.repr 0)) /\
  macro_preset_behavior
    (gvar_init JMacroPresets.v_sMacroObjectPresets) 60 =
      Some (Init_addrof JMacroPresets._bhvExclamationBox (Ptrofs.repr 0)) /\
  macro_preset_behavior
    (gvar_init UMacroPresets.v_sMacroObjectPresets) 63 =
      Some (Init_addrof UMacroPresets._bhvExclamationBox (Ptrofs.repr 0)) /\
  macro_preset_behavior
    (gvar_init JMacroPresets.v_sMacroObjectPresets) 63 =
      Some (Init_addrof JMacroPresets._bhvExclamationBox (Ptrofs.repr 0)) /\
  macro_preset_behavior
    (gvar_init UMacroPresets.v_sMacroObjectPresets) 69 =
      Some (Init_addrof UMacroPresets._bhvBreakableBox (Ptrofs.repr 0)) /\
  macro_preset_behavior
    (gvar_init JMacroPresets.v_sMacroObjectPresets) 69 =
      Some (Init_addrof JMacroPresets._bhvBreakableBox (Ptrofs.repr 0)) /\
  macro_preset_behavior
    (gvar_init UMacroPresets.v_sMacroObjectPresets) 79 =
      Some (Init_addrof UMacroPresets._bhvExclamationBox (Ptrofs.repr 0)) /\
  macro_preset_behavior
    (gvar_init JMacroPresets.v_sMacroObjectPresets) 79 =
      Some (Init_addrof JMacroPresets._bhvExclamationBox (Ptrofs.repr 0)).

Theorem area1_macro_surface_owner_source_checked :
  area1_macro_surface_owner_source_claim.
Proof.
  unfold area1_macro_surface_owner_source_claim,
    expected_area1_signs, expected_area1_cannon,
    expected_area1_shell_box, expected_area1_running_box,
    macro_preset_behavior.
  vm_compute.
  repeat split.
Qed.

(** Exact generated records for the three Tox Boxes.  The LevelScript engine
    prepends [SpawnInfo] records, so the runtime surface order is the reverse
    of the source insertion order once the separately inserted pyramid top is
    included.  The [rev] calculation below is proved; connecting the prepend
    operation to a linked execution remains part of the Clight refinement. *)
Definition expected_area1_tox_records_us : list init_data :=
  [ Init_int32 (Int.repr 605560775);
    Init_int32 (Int.repr (-84148224));
    Init_int32 (Int.repr (-386334720));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 0);
    Init_addrof UArea1Script._bhvToxBox (Ptrofs.repr 0);
    Init_int32 (Int.repr 605560775);
    Init_int32 (Int.repr 84082688);
    Init_int32 (Int.repr (-318832640));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 65536);
    Init_addrof UArea1Script._bhvToxBox (Ptrofs.repr 0);
    Init_int32 (Int.repr 605560775);
    Init_int32 (Int.repr 319356928);
    Init_int32 (Int.repr (-218562560));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 131072);
    Init_addrof UArea1Script._bhvToxBox (Ptrofs.repr 0) ].

Definition expected_area1_tox_records_jp : list init_data :=
  [ Init_int32 (Int.repr 605560775);
    Init_int32 (Int.repr (-84148224));
    Init_int32 (Int.repr (-386334720));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 0);
    Init_addrof JArea1Script._bhvToxBox (Ptrofs.repr 0);
    Init_int32 (Int.repr 605560775);
    Init_int32 (Int.repr 84082688);
    Init_int32 (Int.repr (-318832640));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 65536);
    Init_addrof JArea1Script._bhvToxBox (Ptrofs.repr 0);
    Init_int32 (Int.repr 605560775);
    Init_int32 (Int.repr 319356928);
    Init_int32 (Int.repr (-218562560));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 131072);
    Init_addrof JArea1Script._bhvToxBox (Ptrofs.repr 0) ].

Inductive Area1RegularSurfaceSource : Type :=
| SourcePyramidTop
| SourceTox1
| SourceTox2
| SourceTox3.

Definition area1_regular_source_insertion_order :
    list Area1RegularSurfaceSource :=
  [SourcePyramidTop; SourceTox1; SourceTox2; SourceTox3].

Definition area1_regular_runtime_surface_order :
    list Area1RegularSurfaceSource :=
  [SourceTox3; SourceTox2; SourceTox1; SourcePyramidTop].

Definition area1_regular_surface_source_claim : Prop :=
  firstn 18 (gvar_init UArea1Script.v_script_func_local_2) =
    expected_area1_tox_records_us /\
  firstn 18 (gvar_init JArea1Script.v_script_func_local_2) =
    expected_area1_tox_records_jp /\
  rev area1_regular_source_insertion_order =
    area1_regular_runtime_surface_order.

Theorem area1_regular_surface_source_checked :
  area1_regular_surface_source_claim.
Proof.
  unfold area1_regular_surface_source_claim,
    expected_area1_tox_records_us, expected_area1_tox_records_jp,
    area1_regular_source_insertion_order,
    area1_regular_runtime_surface_order.
  vm_compute.
  repeat split.
Qed.

(** The finite stock dynamic-floor owner universe used below.  It contains
    fifteen owners: one top, three Tox Boxes, two large breakables, five
    exclamation boxes, one cannon lid, and three message panels. *)
Inductive Area1SurfaceOwnerKind : Type :=
| A1PyramidTop
| A1Tox1
| A1Tox2
| A1Tox3
| A1BreakableSouth
| A1BreakableNorth
| A1ExclamationFar
| A1ExclamationWest
| A1ExclamationShell
| A1ExclamationWing
| A1ExclamationRunning
| A1CannonLid
| A1MessageEast
| A1MessageWest
| A1MessageSouth.

Definition area1_surface_owner_eq_dec :
  forall (left right : Area1SurfaceOwnerKind), {left = right} + {left <> right}.
Proof. decide equality. Defined.

Definition all_area1_surface_owners : list Area1SurfaceOwnerKind :=
  [ A1PyramidTop;
    A1Tox1; A1Tox2; A1Tox3;
    A1BreakableSouth; A1BreakableNorth;
    A1ExclamationFar; A1ExclamationWest; A1ExclamationShell;
    A1ExclamationWing; A1ExclamationRunning;
    A1CannonLid;
    A1MessageEast; A1MessageWest; A1MessageSouth ].

Theorem area1_surface_owner_finite_inventory :
  length all_area1_surface_owners = 15%nat /\
  NoDup all_area1_surface_owners /\
  forall owner, In owner all_area1_surface_owners.
Proof.
  split; [reflexivity |].
  split.
  - repeat constructor; simpl; intuition congruence.
  - intros owner.
    destruct owner; simpl; intuition.
Qed.

Record HorizontalEnvelope : Type := {
  envelope_min_x : Z;
  envelope_max_x : Z;
  envelope_min_z : Z;
  envelope_max_z : Z
}.

Definition inside_horizontal_envelope
    (envelope : HorizontalEnvelope) (position : PositionZ) : Prop :=
  envelope_min_x envelope <= position_x position <=
    envelope_max_x envelope /\
  envelope_min_z envelope <= position_z position <=
    envelope_max_z envelope.

(** Conservative world-space X/Z envelopes.  The fixed-owner values were
    calculated from the generated actor collision-mesh receipts imported from
    [CollisionMeshFacts], but the derivation from live transformed surfaces is
    not yet in the proof term and remains part of the Clight projection gap.
    Sign and cannon bounds use radial padding rather than unrotated local
    extrema, so their nonzero yaw and the cannon lid's opening translation
    remain inside the stated envelopes.
    Tox bounds include the complete stock 512-unit roll paths and a
    conservative 444-unit transformed-mesh radius.  The top envelope is not
    used for horizontal exclusion because it genuinely overlaps node 0x1E in
    X/Z. *)
Definition area1_owner_envelope
    (owner : Area1SurfaceOwnerKind) : HorizontalEnvelope :=
  match owner with
  | A1PyramidTop =>
      {| envelope_min_x := -2812; envelope_max_x := -1282;
         envelope_min_z := -1788; envelope_max_z := -258 |}
  | A1Tox1 =>
      {| envelope_min_x := -3776; envelope_max_x := -840;
         envelope_min_z := -6851; envelope_max_z := -4427 |}
  | A1Tox2 =>
      {| envelope_min_x := 327; envelope_max_x := 3263;
         envelope_min_z := -6333; envelope_max_z := -3397 |}
  | A1Tox3 =>
      {| envelope_min_x := 3917; envelope_max_x := 5829;
         envelope_min_z := -4291; envelope_max_z := -331 |}
  | A1BreakableSouth =>
      {| envelope_min_x := 5800; envelope_max_x := 6000;
         envelope_min_z := 4300; envelope_max_z := 4500 |}
  | A1BreakableNorth =>
      {| envelope_min_x := 5800; envelope_max_x := 6000;
         envelope_min_z := 2211; envelope_max_z := 2411 |}
  | A1ExclamationFar =>
      {| envelope_min_x := 6848; envelope_max_x := 6952;
         envelope_min_z := -5452; envelope_max_z := -5348 |}
  | A1ExclamationWest =>
      {| envelope_min_x := -3052; envelope_max_x := -2948;
         envelope_min_z := 748; envelope_max_z := 852 |}
  | A1ExclamationShell =>
      {| envelope_min_x := 5788; envelope_max_x := 5892;
         envelope_min_z := 2448; envelope_max_z := 2552 |}
  | A1ExclamationWing =>
      {| envelope_min_x := 5808; envelope_max_x := 5912;
         envelope_min_z := 4128; envelope_max_z := 4232 |}
  | A1ExclamationRunning =>
      {| envelope_min_x := -1252; envelope_max_x := -1148;
         envelope_min_z := 748; envelope_max_z := 852 |}
  | A1CannonLid =>
      {| envelope_min_x := 6703; envelope_max_x := 7223;
         envelope_min_z := -7020; envelope_max_z := -6700 |}
  | A1MessageEast =>
      {| envelope_min_x := 5638; envelope_max_x := 5766;
         envelope_min_z := 2910; envelope_max_z := 3038 |}
  | A1MessageWest =>
      {| envelope_min_x := -3324; envelope_max_x := -3196;
         envelope_min_z := 736; envelope_max_z := 864 |}
  | A1MessageSouth =>
      {| envelope_min_x := 5066; envelope_max_x := 5194;
         envelope_min_z := -434; envelope_max_z := -306 |}
  end.

Theorem upper_warp_contact_horizontal_bounds :
  forall position,
    upper_warp_contact position ->
    -2235 < position_x position < -1861 /\
    -1211 < position_z position < -837.
Proof.
  intros position (Hhorizontal & _).
  unfold horizontal_distance_squared, upper_warp_center,
    upper_warp_radius, mario_hitbox_radius,
    upper_warp_x, upper_warp_z in Hhorizontal.
  cbn in Hhorizontal.
  pose proof
    (Z.square_nonneg (position_x position - (-2048))) as Hxsquare.
  pose proof
    (Z.square_nonneg (position_z position - (-1024))) as Hzsquare.
  unfold Z.square in Hxsquare, Hzsquare.
  split; nia.
Qed.

Definition envelope_separated_from_upper_warp_box
    (envelope : HorizontalEnvelope) : Prop :=
  envelope_max_x envelope <= -2235 \/
  -1861 <= envelope_min_x envelope \/
  envelope_max_z envelope <= -1211 \/
  -837 <= envelope_min_z envelope.

Theorem non_top_owner_envelope_separation_certificate :
  forall owner,
    owner <> A1PyramidTop ->
    envelope_separated_from_upper_warp_box
      (area1_owner_envelope owner).
Proof.
  intros owner Hnot_top.
  destruct owner;
    cbn [envelope_separated_from_upper_warp_box area1_owner_envelope]
      in *.
  - contradiction.
  - right; right; left; cbn; lia.
  - right; right; left; cbn; lia.
  - right; left; cbn; lia.
  - right; left; cbn; lia.
  - right; left; cbn; lia.
  - right; left; cbn; lia.
  - left; cbn; lia.
  - right; left; cbn; lia.
  - right; left; cbn; lia.
  - right; left; cbn; lia.
  - right; left; cbn; lia.
  - right; left; cbn; lia.
  - left; cbn; lia.
  - right; left; cbn; lia.
Qed.

Theorem non_top_owner_envelope_disjoint_from_upper_warp :
  forall owner position,
    owner <> A1PyramidTop ->
    upper_warp_contact position ->
    inside_horizontal_envelope (area1_owner_envelope owner) position ->
    False.
Proof.
  intros owner position Hnot_top Hwarp Hinside.
  pose proof (upper_warp_contact_horizontal_bounds position Hwarp)
    as (Hxbounds & Hzbounds).
  destruct Hxbounds as (Hxlower & Hxupper).
  destruct Hzbounds as (Hzlower & Hzupper).
  pose proof
    (non_top_owner_envelope_separation_certificate owner Hnot_top)
    as Hseparated.
  unfold inside_horizontal_envelope in Hinside.
  destruct Hinside as ((Hmin_x & Hmax_x) & Hmin_z & Hmax_z).
  unfold envelope_separated_from_upper_warp_box in Hseparated.
  destruct Hseparated as
    [Hleft | [Hright | [Hbelow | Habove]]];
    lia.
Qed.

Definition stock_area1_dynamic_floor_candidate
    (owner : Area1SurfaceOwnerKind)
    (position : PositionZ)
    (floor_y : Z) : Prop :=
  inside_horizontal_envelope (area1_owner_envelope owner) position /\
  floor_y - platform_floor_tolerance < position_y position /\
  position_y position < floor_y + platform_floor_tolerance /\
  match owner with
  | A1PyramidTop => pyramid_top_floor_min_y <= floor_y
  | _ => True
  end.

Theorem upper_warp_has_no_stock_dynamic_floor_candidate :
  forall owner position floor_y,
    upper_warp_contact position ->
    ~ stock_area1_dynamic_floor_candidate owner position floor_y.
Proof.
  intros owner position floor_y Hwarp
    (Hinside & Hnear_below & Hnear_above & Howner_floor).
  destruct (area1_surface_owner_eq_dec owner A1PyramidTop)
    as [Htop | Hnot_top].
  - subst owner.
    eapply one_coordinate_cannot_contact_warp_and_capture_live_top.
    + exact Hwarp.
    + unfold live_top_platform_capture.
      cbn in Howner_floor.
      exact (conj Howner_floor (conj Hnear_below Hnear_above)).
  - eapply non_top_owner_envelope_disjoint_from_upper_warp;
      eauto.
Qed.

(** Abstract result of the final stock Area-1 platform query.  [None] includes
    both "no floor" and a static floor, because static surfaces carry a null
    owner.  A non-null result must be justified by one of the fifteen dynamic
    candidates. *)
Definition stock_area1_final_platform_query
    (position : PositionZ)
    (platform : option Area1SurfaceOwnerKind) : Prop :=
  match platform with
  | None => True
  | Some owner =>
      exists floor_y,
        stock_area1_dynamic_floor_candidate owner position floor_y
  end.

Theorem stock_upper_warp_final_query_clears_platform :
  forall position platform,
    upper_warp_contact position ->
    stock_area1_final_platform_query position platform ->
    platform = None.
Proof.
  intros position [owner |] Hwarp Hquery.
  - cbn in Hquery.
    destruct Hquery as (floor_y & Hcandidate).
    exfalso.
    eapply upper_warp_has_no_stock_dynamic_floor_candidate;
      eauto.
  - reflexivity.
Qed.

(** Exact generated LevelScript receipts for every stock object that can be
    an Area-1 destination node, plus the five local warp-node routes.  The
    packed route bytes decode as:

      0A -> Area 1 / 0A
      14 -> Area 2 / 0A
      1E -> Area 2 / 14
      1F -> Area 1 / 20
      20 -> Area 1 / 1F

    Thus 0x1E is source-only, while 0x0A, 0x1F, and 0x20 are the complete
    stock destination-node set for Area 1. *)
Definition area1_inbound_0a_object_us : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 42796046);
    Init_int32 (Int.repr 430309376);
    Init_int32 (Int.repr 5898240);
    Init_int32 (Int.repr 655360);
    Init_addrof UArea1Script._bhvSpinAirborneWarp (Ptrofs.repr 0) ].

Definition area1_inbound_0a_object_jp : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 42796046);
    Init_int32 (Int.repr 430309376);
    Init_int32 (Int.repr 5898240);
    Init_int32 (Int.repr 655360);
    Init_addrof JArea1Script._bhvSpinAirborneWarp (Ptrofs.repr 0) ].

Definition area1_inbound_1f_object_us : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 454164480);
    Init_int32 (Int.repr (-319225856));
    Init_int32 (Int.repr 10420224);
    Init_int32 (Int.repr 2031616);
    Init_addrof UArea1Script._bhvFadingWarp (Ptrofs.repr 0) ].

Definition area1_inbound_1f_object_jp : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 454164480);
    Init_int32 (Int.repr (-319225856));
    Init_int32 (Int.repr 10420224);
    Init_int32 (Int.repr 2031616);
    Init_addrof JArea1Script._bhvFadingWarp (Ptrofs.repr 0) ].

Definition area1_inbound_20_object_us : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr (-389480448));
    Init_int32 (Int.repr (-321323008));
    Init_int32 (Int.repr 3211264);
    Init_int32 (Int.repr 2097152);
    Init_addrof UArea1Script._bhvFadingWarp (Ptrofs.repr 0) ].

Definition area1_inbound_20_object_jp : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr (-389480448));
    Init_int32 (Int.repr (-321323008));
    Init_int32 (Int.repr 3211264);
    Init_int32 (Int.repr 2097152);
    Init_addrof JArea1Script._bhvFadingWarp (Ptrofs.repr 0) ].

Definition area1_stock_warp_route_words : list init_data :=
  [ Init_int32 (Int.repr 638061064);
    Init_int32 (Int.repr 17432576);
    Init_int32 (Int.repr 638063624);
    Init_int32 (Int.repr 34242560);
    Init_int32 (Int.repr 638066184);
    Init_int32 (Int.repr 34897920);
    Init_int32 (Int.repr 638066440);
    Init_int32 (Int.repr 18874368);
    Init_int32 (Int.repr 638066696);
    Init_int32 (Int.repr 18808832) ].

Definition area1_inbound_and_route_source_claim : Prop :=
  firstn 6 (skipn 50 (gvar_init UArea1Script.v_level_ssl_entry)) =
    area1_inbound_0a_object_us /\
  firstn 6 (skipn 50 (gvar_init JArea1Script.v_level_ssl_entry)) =
    area1_inbound_0a_object_jp /\
  firstn 6 (skipn 68 (gvar_init UArea1Script.v_level_ssl_entry)) =
    area1_inbound_1f_object_us /\
  firstn 6 (skipn 68 (gvar_init JArea1Script.v_level_ssl_entry)) =
    area1_inbound_1f_object_jp /\
  firstn 6 (skipn 74 (gvar_init UArea1Script.v_level_ssl_entry)) =
    area1_inbound_20_object_us /\
  firstn 6 (skipn 74 (gvar_init JArea1Script.v_level_ssl_entry)) =
    area1_inbound_20_object_jp /\
  firstn 10 (skipn 80 (gvar_init UArea1Script.v_level_ssl_entry)) =
    area1_stock_warp_route_words /\
  firstn 10 (skipn 80 (gvar_init JArea1Script.v_level_ssl_entry)) =
    area1_stock_warp_route_words.

Theorem area1_inbound_and_route_source_checked :
  area1_inbound_and_route_source_claim.
Proof.
  unfold area1_inbound_and_route_source_claim,
    area1_inbound_0a_object_us, area1_inbound_0a_object_jp,
    area1_inbound_1f_object_us, area1_inbound_1f_object_jp,
    area1_inbound_20_object_us, area1_inbound_20_object_jp,
    area1_stock_warp_route_words.
  vm_compute.
  repeat split.
Qed.

Theorem area1_inbound_and_route_packed_arithmetic :
  42796046 = 653 * 65536 + 1038 /\
  430309376 = 6566 * 65536 /\
  655360 = 10 * 65536 /\
  454164480 = 6930 * 65536 /\
  -319225856 = -4871 * 65536 /\
  2031616 = 31 * 65536 /\
  -389480448 = -5943 * 65536 /\
  -321323008 = -4903 * 65536 /\
  2097152 = 32 * 65536 /\
  638061064 = 38 * 16777216 + 8 * 65536 + 10 * 256 + 8 /\
  17432576 = 1 * 16777216 + 10 * 65536 /\
  638063624 = 38 * 16777216 + 8 * 65536 + 20 * 256 + 8 /\
  34242560 = 2 * 16777216 + 10 * 65536 + 128 * 256 /\
  638066184 = 38 * 16777216 + 8 * 65536 + 30 * 256 + 8 /\
  34897920 = 2 * 16777216 + 20 * 65536 + 128 * 256 /\
  638066440 = 38 * 16777216 + 8 * 65536 + 31 * 256 + 8 /\
  18874368 = 1 * 16777216 + 32 * 65536 /\
  638066696 = 38 * 16777216 + 8 * 65536 + 32 * 256 + 8 /\
  18808832 = 1 * 16777216 + 31 * 65536.
Proof.
  repeat split; reflexivity.
Qed.

(** Exhaustive stock destinations into Area 1 for a clean, non-credits
    gameplay warp entry.  Node 0x1E is source-only: it exits to Area 2 node
    0x14.  The LevelScript default MARIO_POS and the credits-only placement
    are deliberately outside [CleanPyramidEntry]; these three warp objects
    are the only in-scope entry samples relevant to a retained pointer. *)
Inductive Area1InboundNode : Type :=
| A1Inbound0A
| A1Inbound1F
| A1Inbound20.

Definition area1_inbound_position (node : Area1InboundNode) : PositionZ :=
  match node with
  | A1Inbound0A =>
      {| position_x := 653; position_y := 1038; position_z := 6566 |}
  | A1Inbound1F =>
      {| position_x := 6930; position_y := 0; position_z := -4871 |}
  | A1Inbound20 =>
      {| position_x := -5943; position_y := 0; position_z := -4903 |}
  end.

Theorem no_stock_area1_inbound_node_overlaps_upper_warp :
  forall node,
    ~ upper_warp_contact (area1_inbound_position node).
Proof.
  intros node Hwarp.
  pose proof
    (upper_warp_contact_horizontal_bounds
      (area1_inbound_position node) Hwarp) as Hbounds.
  destruct node; cbn in Hbounds; lia.
Qed.

(** Bounded provenance for the platform pointer immediately before a stock
    Area-1 apply.  The first constructor represents uninterrupted normal
    frames, where the preceding final query is the last writer.  A US
    area-spawn path clears the pointer.  JP cross-area entry and US/JP
    same-area 0x1F <-> 0x20 warps may retain a pointer, but collision still
    samples one of the finite stock inbound positions above.

    A linked Clight proof must show that every relevant retail pre-apply state
    projects to this relation. *)
Inductive StockArea1PreapplyPlatform :
    PositionZ -> option Area1SurfaceOwnerKind -> Prop :=
| PreapplyFromCompletedFinalQuery :
    forall position platform,
      stock_area1_final_platform_query position platform ->
      StockArea1PreapplyPlatform position platform
| PreapplyFromUSSpawnClear :
    forall position,
      StockArea1PreapplyPlatform position None
| PreapplyFromRetainedInboundPointer :
    forall node retained,
      StockArea1PreapplyPlatform
        (area1_inbound_position node) retained
| PreapplyAfterFrozenFrames :
    forall position platform,
      StockArea1PreapplyPlatform position platform ->
      StockArea1PreapplyPlatform position platform.

Inductive Area1PreapplyScheduleClass : Type :=
| ScheduleCompletedFinalQuery
| ScheduleUSSpawnClear
| ScheduleInboundRetention
| ScheduleFrozenCarry.

Definition area1_preapply_schedule_witness
    (schedule_class : Area1PreapplyScheduleClass)
    (position : PositionZ)
    (platform : option Area1SurfaceOwnerKind) : Prop :=
  match schedule_class with
  | ScheduleCompletedFinalQuery =>
      stock_area1_final_platform_query position platform
  | ScheduleUSSpawnClear =>
      platform = None
  | ScheduleInboundRetention =>
      exists node, position = area1_inbound_position node
  | ScheduleFrozenCarry =>
      StockArea1PreapplyPlatform position platform
  end.

Theorem stock_area1_preapply_schedule_classified :
  forall position platform,
    StockArea1PreapplyPlatform position platform ->
    exists schedule_class : Area1PreapplyScheduleClass,
      area1_preapply_schedule_witness
        schedule_class position platform.
Proof.
  intros position platform Horigin.
  destruct Horigin as
    [query_position query_platform Hquery
    | clear_position
    | node retained
    | frozen_position frozen_platform Hprior].
  - exists ScheduleCompletedFinalQuery.
    exact Hquery.
  - exists ScheduleUSSpawnClear.
    reflexivity.
  - exists ScheduleInboundRetention.
    exists node.
    reflexivity.
  - exists ScheduleFrozenCarry.
    exact Hprior.
Qed.

Theorem stock_area1_upper_warp_preapply_platform_null :
  forall position platform,
    StockArea1PreapplyPlatform position platform ->
    upper_warp_contact position ->
    platform = None.
Proof.
  intros position platform Horigin Hwarp.
  induction Horigin.
  - eapply stock_upper_warp_final_query_clears_platform; eauto.
  - reflexivity.
  - exfalso.
    eapply no_stock_area1_inbound_node_overlaps_upper_warp; eauto.
  - apply IHHorigin.
    exact Hwarp.
Qed.

Definition Area1StockPreapplyProjectionSound
    (project :
      Clight.state ->
        option (PositionZ * option Area1SurfaceOwnerKind)) : Prop :=
  forall state position platform,
    project state = Some (position, platform) ->
    StockArea1PreapplyPlatform position platform.

Theorem sound_projected_upper_warp_preapply_platform_null :
  forall project state position platform,
    Area1StockPreapplyProjectionSound project ->
    project state = Some (position, platform) ->
    upper_warp_contact position ->
    platform = None.
Proof.
  intros project state position platform Hsound Hproject Hwarp.
  eapply stock_area1_upper_warp_preapply_platform_null; eauto.
Qed.

Definition platform_created_route_relevant_area1_split
    (boundary : Area1StateObjectPhaseBoundary)
    (platform : option Area1SurfaceOwnerKind) : Prop :=
  platform <> None /\
  route_relevant_area1_phase_split boundary.

Theorem stock_upper_warp_has_no_platform_created_route_split :
  forall boundary platform,
    StockArea1PreapplyPlatform
      (area1_collision_object_position boundary) platform ->
    ~ platform_created_route_relevant_area1_split boundary platform.
Proof.
  intros boundary platform Hpreapply (Hnon_null & Hroute).
  destruct Hroute as (Hwarp & _).
  pose proof
    (stock_area1_upper_warp_preapply_platform_null
      (area1_collision_object_position boundary)
      platform Hpreapply Hwarp) as Hnull.
  contradiction.
Qed.

(** A minimal free-list mirror for one concrete depth-1 witness.  Deallocation
    pushes onto the head; allocation
    pops the head.  If a watched large box is freed and the later-updated
    pyramid top is then freed, the next list begins [top; watched; ...].
    With mist suppressed, exclamation action 4 allocates its contents first
    and its first cartoon fragment second.  Other depths, intervening frees,
    and other payload writers exist, but route relevance has already been
    eliminated by the stock-null theorem above. *)
Definition deallocate_slot (slot : nat) (free_list : list nat) : list nat :=
  slot :: free_list.

Definition allocate_slot
    (free_list : list nat) : option (nat * list nat) :=
  match free_list with
  | [] => None
  | slot :: rest => Some (slot, rest)
  end.

Definition first_two_allocations
    (free_list : list nat) : option (nat * nat * list nat) :=
  match allocate_slot free_list with
  | None => None
  | Some (first, after_first) =>
      match allocate_slot after_first with
      | None => None
      | Some (second, after_second) =>
          Some (first, second, after_second)
      end
  end.

Theorem area1_candidate_free_list_alignment :
  forall top_slot watched_box_slot tail,
    deallocate_slot top_slot
      (deallocate_slot watched_box_slot tail) =
        top_slot :: watched_box_slot :: tail /\
    first_two_allocations
      (deallocate_slot top_slot
        (deallocate_slot watched_box_slot tail)) =
      Some (top_slot, watched_box_slot, tail).
Proof.
  intros.
  split; reflexivity.
Qed.

Definition stock_mist_count_from_previous_object_count
    (previous_count : Z) : Z :=
  if previous_count <=? 150 then 20
  else if previous_count <=? 210 then 10
  else 0.

(** Source-level census arithmetic for the current candidate:

    - conservative live baseline: 67;
    - the earlier small-box burst leaves the preceding count at 111;
    - the two following 51-object bursts produce 212;
    - 212 suppresses the next mist allocation and remains below pool size 240.

    This census is retained only to explain why the allocator mechanism is
    genuine.  Its controller realization is not pursued as an outstanding
    route obligation, because the old collision object below is disjoint from
    node 0x1E. *)
Definition area1_candidate_baseline_count : Z := 67.
Definition area1_candidate_f8_previous_count : Z :=
  area1_candidate_baseline_count + 44.
Definition area1_candidate_f9_count : Z :=
  area1_candidate_baseline_count - 1 + 44 + 102.

Theorem area1_candidate_count_arithmetic_checked :
  area1_candidate_f8_previous_count = 111 /\
  stock_mist_count_from_previous_object_count
    area1_candidate_f8_previous_count = 20 /\
  area1_candidate_f9_count = 212 /\
  stock_mist_count_from_previous_object_count
    area1_candidate_f9_count = 0 /\
  area1_candidate_f9_count < 240.
Proof.
  vm_compute.
  repeat split.
Qed.

(** Exact binary32 consequence of the seed-zero cartoon-fragment payload at
    the concrete candidate locations:

      prior copied Object / captured breakable top = (5900, 251, 4400)
      Wing-cap fragment pivot after rebound         = (5860,1080,4180)
      displaced MarioState                         =
        (6250.38134765625, 327.80126953125, 4042.01220703125)

    Every coordinate changes, so this is a genuine 3D State/Object split
    capability.  Its Y rise is only about 76.8, far below the separate
    385-unit upper-warp bootstrap lower bound. *)
Definition area1_candidate_old_object : F32Vec3 := {|
  f32_x := f32_of_Z 5900;
  f32_y := f32_of_Z 251;
  f32_z := f32_of_Z 4400
|}.

Definition area1_candidate_old_collision_position : PositionZ := {|
  position_x := 5900;
  position_y := 251;
  position_z := 4400
|}.

Theorem area1_candidate_cannot_trigger_upper_warp :
  ~ upper_warp_contact area1_candidate_old_collision_position.
Proof.
  intro Hwarp.
  pose proof
    (upper_warp_contact_horizontal_bounds
      area1_candidate_old_collision_position Hwarp) as Hbounds.
  cbn in Hbounds.
  lia.
Qed.

Definition area1_candidate_fragment_pivot : F32Vec3 := {|
  f32_x := f32_of_Z 5860;
  f32_y := f32_of_Z 1080;
  f32_z := f32_of_Z 4180
|}.

Definition concrete_area1_candidate_displaced_state : F32Vec3 :=
  let offset :=
    f32_vec_sub area1_candidate_old_object
      area1_candidate_fragment_pivot in
  let relative :=
    f32_linear_transpose_mul fragment_previous_matrix offset in
  let new_offset :=
    f32_linear_mul fragment_current_matrix relative in
  f32_vec_add area1_candidate_fragment_pivot new_offset.

Theorem concrete_area1_candidate_is_three_dimensional :
  Float32.to_bits
    (f32_x concrete_area1_candidate_displaced_state) =
      Int.repr 1170428685 /\
  Float32.to_bits
    (f32_y concrete_area1_candidate_displaced_state) =
      Int.repr 1134814864 /\
  Float32.to_bits
    (f32_z concrete_area1_candidate_displaced_state) =
      Int.repr 1165795378 /\
  Float32.cmp Ceq
    (f32_x area1_candidate_old_object)
    (f32_x concrete_area1_candidate_displaced_state) = false /\
  Float32.cmp Ceq
    (f32_y area1_candidate_old_object)
    (f32_y concrete_area1_candidate_displaced_state) = false /\
  Float32.cmp Ceq
    (f32_z area1_candidate_old_object)
    (f32_z concrete_area1_candidate_displaced_state) = false /\
  Float32.cmp Clt
    (f32_y area1_candidate_old_object)
    (f32_y concrete_area1_candidate_displaced_state) = true /\
  Float32.cmp Clt
    (f32_y concrete_area1_candidate_displaced_state)
    (f32_of_Z (251 + 385)) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Definition area1_platform_source_model_claim : Prop :=
  area1_macro_surface_owner_source_claim /\
  area1_regular_surface_source_claim /\
  area1_inbound_and_route_source_claim /\
  (forall owner position floor_y,
    upper_warp_contact position ->
    ~ stock_area1_dynamic_floor_candidate owner position floor_y) /\
  (forall position platform,
    StockArea1PreapplyPlatform position platform ->
    upper_warp_contact position ->
    platform = None) /\
  ~ upper_warp_contact area1_candidate_old_collision_position /\
  (forall top_slot watched_box_slot tail,
    first_two_allocations
      (deallocate_slot top_slot
        (deallocate_slot watched_box_slot tail)) =
      Some (top_slot, watched_box_slot, tail)) /\
  (Float32.cmp Ceq
    (f32_x area1_candidate_old_object)
    (f32_x concrete_area1_candidate_displaced_state) = false /\
   Float32.cmp Ceq
    (f32_y area1_candidate_old_object)
    (f32_y concrete_area1_candidate_displaced_state) = false /\
   Float32.cmp Ceq
    (f32_z area1_candidate_old_object)
    (f32_z concrete_area1_candidate_displaced_state) = false).

Theorem area1_platform_source_model_checked :
  area1_platform_source_model_claim.
Proof.
  unfold area1_platform_source_model_claim.
  split; [exact area1_macro_surface_owner_source_checked |].
  split; [exact area1_regular_surface_source_checked |].
  split; [exact area1_inbound_and_route_source_checked |].
  split; [exact upper_warp_has_no_stock_dynamic_floor_candidate |].
  split; [exact stock_area1_upper_warp_preapply_platform_null |].
  split; [exact area1_candidate_cannot_trigger_upper_warp |].
  split.
  - intros.
    exact
      (proj2
        (area1_candidate_free_list_alignment
          top_slot watched_box_slot tail)).
  - repeat split;
      first
        [ exact
            (proj1
              (proj2
                (proj2
                  (proj2
                    concrete_area1_candidate_is_three_dimensional))))
        | exact
            (proj1
              (proj2
                (proj2
                  (proj2
                    (proj2
                      concrete_area1_candidate_is_three_dimensional)))))
        | exact
            (proj1
              (proj2
                (proj2
                  (proj2
                    (proj2
                      (proj2
                        concrete_area1_candidate_is_three_dimensional)))))) ].
Qed.
