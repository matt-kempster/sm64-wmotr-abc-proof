(** Audited-source reduction for the Area-1 "moving skipped final query"
    escape.

    Within the audited generated level/object-update source, the two modeled
    omission shapes are: omit the whole object update, or enter
    [update_mario_platform] with a null [gMarioObject].  This module records
    the exact bilateral source shapes that make the first shape stationary in
    the object-warp path and the second shape incapable of moving an existing
    Mario object under the explicit premises below.

    The result is deliberately not a linked execution theorem.  In
    particular, the syntax checks do not prove that an indirect transition
    callback has its intended target, that external callees preserve Mario's
    memory, or that a null global cannot coexist with an aliased live Object.
    Those conditions are explicit in [LinkedMovingSkipBoundary] below.

    Result: no concrete moving-skip witness was found in these audited source
    shapes.  The branch reduces to the named linked-execution obligations; it
    is not an exhaustive stock-scheduler or retail-binary closure until those
    obligations are discharged. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_level_update us_object_list_processor us_platform_displacement
  jp_level_update jp_object_list_processor jp_platform_displacement.
From LessThanOneAPress.Proofs Require Import ASTFacts Area1QueryScheduleClosure.

Import ListNotations.

Module A1MSUSLevel := us_level_update.
Module A1MSUSObjects := us_object_list_processor.
Module A1MSUSPlatform := us_platform_displacement.
Module A1MSJPLevel := jp_level_update.
Module A1MSJPObjects := jp_object_list_processor.
Module A1MSJPPlatform := jp_platform_displacement.

Definition moving_direct_call_count
    (callee : ident) (body : statement) : nat :=
  count_occ Pos.eq_dec (direct_callees_s body) callee.

Fixpoint indirect_call_count_s (body : statement) : nat :=
  match body with
  | Scall _ (Evar _ _) _ => 0%nat
  | Scall _ _ _ => 1%nat
  | Ssequence first second | Sloop first second =>
      (indirect_call_count_s first + indirect_call_count_s second)%nat
  | Sifthenelse _ yes no =>
      (indirect_call_count_s yes + indirect_call_count_s no)%nat
  | Sswitch _ cases => indirect_call_count_ls cases
  | Slabel _ nested => indirect_call_count_s nested
  | _ => 0%nat
  end
with indirect_call_count_ls (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (indirect_call_count_s body + indirect_call_count_ls rest)%nat
  end.

(** A direct call with an exact first integer argument and a null function
    pointer in the second argument. *)
Definition is_int_null_call_s
    (callee : ident) (argument : Int.int) (body : statement) : bool :=
  match body with
  | Scall _ (Evar found _)
      [Econst_int found_argument _;
       Ecast (Econst_int null_value _) _] =>
      Pos.eqb found callee &&
      Int.eq found_argument argument &&
      Int.eq null_value Int.zero
  | _ => false
  end.

Fixpoint int_null_call_count_s
    (callee : ident) (argument : Int.int) (body : statement) : nat :=
  match body with
  | Scall _ _ _ => if is_int_null_call_s callee argument body then 1 else 0
  | Ssequence first second | Sloop first second =>
      (int_null_call_count_s callee argument first +
       int_null_call_count_s callee argument second)%nat
  | Sifthenelse _ yes no =>
      (int_null_call_count_s callee argument yes +
       int_null_call_count_s callee argument no)%nat
  | Sswitch _ cases => int_null_call_count_ls callee argument cases
  | Slabel _ nested => int_null_call_count_s callee argument nested
  | _ => 0%nat
  end
with int_null_call_count_ls
    (callee : ident) (argument : Int.int)
    (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (int_null_call_count_s callee argument body +
       int_null_call_count_ls callee argument rest)%nat
  end.

(** A direct call with an exact first integer argument and a named callback
    in the second argument. *)
Definition is_int_named_callback_call_s
    (callee callback : ident) (argument : Int.int)
    (body : statement) : bool :=
  match body with
  | Scall _ (Evar found_callee _)
      [Econst_int found_argument _; Evar found_callback _] =>
      Pos.eqb found_callee callee &&
      Int.eq found_argument argument &&
      Pos.eqb found_callback callback
  | _ => false
  end.

Fixpoint int_named_callback_call_count_s
    (callee callback : ident) (argument : Int.int)
    (body : statement) : nat :=
  match body with
  | Scall _ _ _ =>
      if is_int_named_callback_call_s callee callback argument body
      then 1 else 0
  | Ssequence first second | Sloop first second =>
      (int_named_callback_call_count_s callee callback argument first +
       int_named_callback_call_count_s callee callback argument second)%nat
  | Sifthenelse _ yes no =>
      (int_named_callback_call_count_s callee callback argument yes +
       int_named_callback_call_count_s callee callback argument no)%nat
  | Sswitch _ cases =>
      int_named_callback_call_count_ls callee callback argument cases
  | Slabel _ nested =>
      int_named_callback_call_count_s callee callback argument nested
  | _ => 0%nat
  end
with int_named_callback_call_count_ls
    (callee callback : ident) (argument : Int.int)
    (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (int_named_callback_call_count_s
         callee callback argument body +
       int_named_callback_call_count_ls
         callee callback argument rest)%nat
  end.

(** The object pipeline contains the final platform updater as a straight-line
    call in both versions.  Thus none of time-stop, object-list behavior, or
    unload branches suppresses the call itself. *)
Definition area1_full_update_query_call_source_claim : Prop :=
  moving_direct_call_count A1MSUSObjects._update_mario_platform
    (fn_body A1MSUSObjects.f_update_objects) = 1%nat /\
  moving_direct_call_count A1MSJPObjects._update_mario_platform
    (fn_body A1MSJPObjects.f_update_objects) = 1%nat /\
  ident_subsequenceb
    [A1MSUSObjects._apply_mario_platform_displacement;
     A1MSUSObjects._update_non_terrain_objects;
     A1MSUSObjects._unload_deactivated_objects;
     A1MSUSObjects._update_mario_platform]
    (straightline_callees_s (fn_body A1MSUSObjects.f_update_objects)) = true /\
  ident_subsequenceb
    [A1MSJPObjects._apply_mario_platform_displacement;
     A1MSJPObjects._update_non_terrain_objects;
     A1MSJPObjects._unload_deactivated_objects;
     A1MSJPObjects._update_mario_platform]
    (straightline_callees_s (fn_body A1MSJPObjects.f_update_objects)) = true /\
  contains_global_null_return_void_s A1MSUSPlatform._gMarioObject
    (fn_body A1MSUSPlatform.f_update_mario_platform) = true /\
  contains_global_null_return_void_s A1MSJPPlatform._gMarioObject
    (fn_body A1MSJPPlatform.f_update_mario_platform) = true.

Theorem area1_full_update_query_call_source_checked :
  area1_full_update_query_call_source_claim.
Proof.
  unfold area1_full_update_query_call_source_claim, moving_direct_call_count.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** Normal play performs area-warp handling and the instant-warp check before
    its one full object update.  Both functions may change coordinates, but
    neither can create a coordinate-changing query-free suffix of that normal
    frame.  [basic_update], the only non-null transition callback installed by
    this translation unit, also performs one full object update. *)
Definition area1_moving_paths_reach_full_update_source_claim : Prop :=
  ident_subsequenceb
    [A1MSUSLevel._warp_area;
     A1MSUSLevel._check_instant_warp;
     A1MSUSLevel._area_update_objects]
    (straightline_callees_s (fn_body A1MSUSLevel.f_play_mode_normal)) = true /\
  ident_subsequenceb
    [A1MSJPLevel._warp_area;
     A1MSJPLevel._check_instant_warp;
     A1MSJPLevel._area_update_objects]
    (straightline_callees_s (fn_body A1MSJPLevel.f_play_mode_normal)) = true /\
  moving_direct_call_count A1MSUSLevel._area_update_objects
    (fn_body A1MSUSLevel.f_basic_update) = 1%nat /\
  moving_direct_call_count A1MSJPLevel._area_update_objects
    (fn_body A1MSJPLevel.f_basic_update) = 1%nat /\
  int_named_callback_call_count_s
    A1MSUSLevel._level_set_transition A1MSUSLevel._basic_update
    (Int.repr 74) (fn_body A1MSUSLevel.f_initiate_painting_warp) = 1%nat /\
  int_named_callback_call_count_s
    A1MSJPLevel._level_set_transition A1MSJPLevel._basic_update
    (Int.repr 74) (fn_body A1MSJPLevel.f_initiate_painting_warp) = 1%nat.

Theorem area1_moving_paths_reach_full_update_source_checked :
  area1_moving_paths_reach_full_update_source_claim.
Proof.
  unfold area1_moving_paths_reach_full_update_source_claim,
    moving_direct_call_count.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** The retail dispatcher has the same five explicit play-mode cases in both
    translations.  This makes the later skip audit a finite case split rather
    than an assumed list of modes.  The receipts still do not establish the
    live value of [sCurrPlayMode]. *)
Definition area1_play_mode_dispatch_source_claim : Prop :=
  switch_case_calls_ident_s 0 A1MSUSLevel._play_mode_normal
    (fn_body A1MSUSLevel.f_update_level) = true /\
  switch_case_calls_ident_s 2 A1MSUSLevel._play_mode_paused
    (fn_body A1MSUSLevel.f_update_level) = true /\
  switch_case_calls_ident_s 3 A1MSUSLevel._play_mode_change_area
    (fn_body A1MSUSLevel.f_update_level) = true /\
  switch_case_calls_ident_s 4 A1MSUSLevel._play_mode_change_level
    (fn_body A1MSUSLevel.f_update_level) = true /\
  switch_case_calls_ident_s 5 A1MSUSLevel._play_mode_frame_advance
    (fn_body A1MSUSLevel.f_update_level) = true /\
  switch_case_calls_ident_s 0 A1MSJPLevel._play_mode_normal
    (fn_body A1MSJPLevel.f_update_level) = true /\
  switch_case_calls_ident_s 2 A1MSJPLevel._play_mode_paused
    (fn_body A1MSJPLevel.f_update_level) = true /\
  switch_case_calls_ident_s 3 A1MSJPLevel._play_mode_change_area
    (fn_body A1MSJPLevel.f_update_level) = true /\
  switch_case_calls_ident_s 4 A1MSJPLevel._play_mode_change_level
    (fn_body A1MSJPLevel.f_update_level) = true /\
  switch_case_calls_ident_s 5 A1MSJPLevel._play_mode_frame_advance
    (fn_body A1MSJPLevel.f_update_level) = true.

Theorem area1_play_mode_dispatch_source_checked :
  area1_play_mode_dispatch_source_claim.
Proof.
  unfold area1_play_mode_dispatch_source_claim.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** The delayed object warp installs the sole two-frame NULL callback in the
    level-update translation unit.  The bodies used while its countdown is
    active contain no direct coordinate or platform updater and do not even
    mention the position fields.  The change-area body does contain one
    indirect callback call, hence the NULL-target/refinement condition remains
    essential; a raw call-count fact alone cannot prove that call absent. *)
Definition area1_null_callback_skip_source_claim : Prop :=
  int_null_call_count_s A1MSUSLevel._level_set_transition (Int.repr 2)
    (fn_body A1MSUSLevel.f_initiate_delayed_warp) = 1%nat /\
  int_null_call_count_s A1MSJPLevel._level_set_transition (Int.repr 2)
    (fn_body A1MSJPLevel.f_initiate_delayed_warp) = 1%nat /\
  moving_direct_call_count A1MSUSLevel._area_update_objects
    (fn_body A1MSUSLevel.f_play_mode_change_area) = 0%nat /\
  moving_direct_call_count A1MSJPLevel._area_update_objects
    (fn_body A1MSJPLevel.f_play_mode_change_area) = 0%nat /\
  moving_direct_call_count A1MSUSLevel._area_update_objects
    (fn_body A1MSUSLevel.f_play_mode_paused) = 0%nat /\
  moving_direct_call_count A1MSJPLevel._area_update_objects
    (fn_body A1MSJPLevel.f_play_mode_paused) = 0%nat /\
  moving_direct_call_count A1MSUSLevel._area_update_objects
    (fn_body A1MSUSLevel.f_play_mode_change_level) = 0%nat /\
  moving_direct_call_count A1MSJPLevel._area_update_objects
    (fn_body A1MSJPLevel.f_play_mode_change_level) = 0%nat /\
  moving_direct_call_count A1MSUSLevel._play_mode_normal
    (fn_body A1MSUSLevel.f_play_mode_frame_advance) = 1%nat /\
  moving_direct_call_count A1MSJPLevel._play_mode_normal
    (fn_body A1MSJPLevel.f_play_mode_frame_advance) = 1%nat /\
  indirect_call_count_s
    (fn_body A1MSUSLevel.f_play_mode_change_area) = 1%nat /\
  indirect_call_count_s
    (fn_body A1MSJPLevel.f_play_mode_change_area) = 1%nat /\
  statement_mentions_ident_s A1MSUSLevel._gMarioStates
    (fn_body A1MSUSLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1MSJPLevel._gMarioStates
    (fn_body A1MSJPLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1MSUSLevel._pos
    (fn_body A1MSUSLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1MSJPLevel._pos
    (fn_body A1MSJPLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1MSUSLevel._rawData
    (fn_body A1MSUSLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1MSJPLevel._rawData
    (fn_body A1MSJPLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1MSUSLevel._gfx
    (fn_body A1MSUSLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1MSJPLevel._gfx
    (fn_body A1MSJPLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1MSUSPlatform._gMarioPlatform
    (fn_body A1MSUSLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1MSJPPlatform._gMarioPlatform
    (fn_body A1MSJPLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1MSUSLevel._gMarioStates
    (fn_body A1MSUSLevel.f_play_mode_frame_advance) = false /\
  statement_mentions_ident_s A1MSJPLevel._gMarioStates
    (fn_body A1MSJPLevel.f_play_mode_frame_advance) = false /\
  statement_mentions_ident_s A1MSUSLevel._pos
    (fn_body A1MSUSLevel.f_play_mode_frame_advance) = false /\
  statement_mentions_ident_s A1MSJPLevel._pos
    (fn_body A1MSJPLevel.f_play_mode_frame_advance) = false /\
  statement_mentions_ident_s A1MSUSLevel._rawData
    (fn_body A1MSUSLevel.f_play_mode_frame_advance) = false /\
  statement_mentions_ident_s A1MSJPLevel._rawData
    (fn_body A1MSJPLevel.f_play_mode_frame_advance) = false /\
  statement_mentions_ident_s A1MSUSPlatform._gMarioPlatform
    (fn_body A1MSUSLevel.f_play_mode_frame_advance) = false /\
  statement_mentions_ident_s A1MSJPPlatform._gMarioPlatform
    (fn_body A1MSJPLevel.f_play_mode_frame_advance) = false.

Theorem area1_null_callback_skip_source_checked :
  area1_null_callback_skip_source_claim.
Proof.
  unfold area1_null_callback_skip_source_claim, moving_direct_call_count.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** A small semantic mirror of exactly the property needed from a query-free
    frame.  It separates the checked result from the linked-program premise:
    the latter must establish that a skipped frame is one of these preserving
    transitions. *)
Record MovingSkipView (pointer : Type) : Type := {
  moving_skip_platform : option pointer;
  moving_skip_state : SchedulePosition;
  moving_skip_object : SchedulePosition;
  moving_skip_graphics : SchedulePosition
}.

Arguments moving_skip_platform {pointer} _.
Arguments moving_skip_state {pointer} _.
Arguments moving_skip_object {pointer} _.
Arguments moving_skip_graphics {pointer} _.

Definition preserving_skip_step {pointer}
    (view : MovingSkipView pointer) : MovingSkipView pointer := view.

Fixpoint preserving_skip_run {pointer}
    (frames : nat) (view : MovingSkipView pointer) : MovingSkipView pointer :=
  match frames with
  | O => view
  | S rest => preserving_skip_run rest (preserving_skip_step view)
  end.

Theorem preserving_query_free_run_moves_neither_views_nor_pointer :
  forall pointer frames (view : MovingSkipView pointer),
    moving_skip_platform (preserving_skip_run frames view) =
      moving_skip_platform view /\
    moving_skip_state (preserving_skip_run frames view) =
      moving_skip_state view /\
    moving_skip_object (preserving_skip_run frames view) =
      moving_skip_object view /\
    moving_skip_graphics (preserving_skip_run frames view) =
      moving_skip_graphics view.
Proof.
  intros pointer frames view.
  induction frames; cbn.
  - repeat split; reflexivity.
  - exact IHframes.
Qed.

(** A Type-valued package names the six propositions supplied by a future
    linked-execution proof.  [LinkedMovingSkipBoundary] below, rather than the
    package by itself, requires proofs of every proposition. *)
Record LinkedMovingSkipPremises : Type := {
  linked_normal_update_reaches_checked_query : Prop;
  linked_transition_callback_is_null_or_basic_update : Prop;
  linked_null_callback_frames_preserve_mario_views : Prop;
  linked_null_mario_means_no_live_mario_object_to_move : Prop;
  linked_skip_external_calls_preserve_mario_and_platform : Prop;
  linked_skip_aliases_cannot_write_mario_or_platform : Prop
}.

Definition LinkedMovingSkipBoundary
    (premises : LinkedMovingSkipPremises) : Prop :=
  linked_normal_update_reaches_checked_query premises /\
  linked_transition_callback_is_null_or_basic_update premises /\
  linked_null_callback_frames_preserve_mario_views premises /\
  linked_null_mario_means_no_live_mario_object_to_move premises /\
  linked_skip_external_calls_preserve_mario_and_platform premises /\
  linked_skip_aliases_cannot_write_mario_or_platform premises.

(** Under the explicit linked boundary, the checked scheduler has no remaining
    moving skipped-query case.  This theorem is an assumption ledger, not an
    execution proof: each field names exactly the bridge still required. *)
Theorem linked_boundary_reduces_moving_skip_to_preservation :
  forall premises,
    LinkedMovingSkipBoundary premises ->
    area1_full_update_query_call_source_claim /\
    area1_moving_paths_reach_full_update_source_claim /\
    area1_play_mode_dispatch_source_claim /\
    area1_null_callback_skip_source_claim /\
    linked_null_callback_frames_preserve_mario_views premises /\
    linked_null_mario_means_no_live_mario_object_to_move premises.
Proof.
  intros premises boundary.
  unfold LinkedMovingSkipBoundary in boundary.
  destruct boundary as
    [_ [_ [Hpreserve [Hnull [_ _]]]]].
  split; [exact area1_full_update_query_call_source_checked |].
  split; [exact area1_moving_paths_reach_full_update_source_checked |].
  split; [exact area1_play_mode_dispatch_source_checked |].
  split; [exact area1_null_callback_skip_source_checked |].
  split; assumption.
Qed.

Definition Area1MovingSkippedQueryCheckedBoundary : Prop :=
  area1_full_update_query_call_source_claim /\
  area1_moving_paths_reach_full_update_source_claim /\
  area1_play_mode_dispatch_source_claim /\
  area1_null_callback_skip_source_claim /\
  (forall pointer frames (view : MovingSkipView pointer),
    moving_skip_platform (preserving_skip_run frames view) =
      moving_skip_platform view /\
    moving_skip_state (preserving_skip_run frames view) =
      moving_skip_state view /\
    moving_skip_object (preserving_skip_run frames view) =
      moving_skip_object view /\
    moving_skip_graphics (preserving_skip_run frames view) =
      moving_skip_graphics view).

Theorem area1_moving_skipped_query_checked_boundary_holds :
  Area1MovingSkippedQueryCheckedBoundary.
Proof.
  split; [exact area1_full_update_query_call_source_checked |].
  split; [exact area1_moving_paths_reach_full_update_source_checked |].
  split; [exact area1_play_mode_dispatch_source_checked |].
  split; [exact area1_null_callback_skip_source_checked |].
  exact preserving_query_free_run_moves_neither_views_nor_pointer.
Qed.
