(** Clean-JP reduction for the timer-131 Graphics/Object gap.

    The authenticated conditional JP trace needs the collision Object to
    remain in the upper-warp hitbox while Graphics supplies the timer-131
    midpoint floor query.  [Timer131Surface] proves that this needs at least
    960 integer Y units of Graphics-minus-Object separation (1010 at the warp
    centre).

    This file closes the arithmetic and abstract scheduling part of the
    clean-retail question:

    - a synchronized entry has gap zero;
    - an arbitrary sequence of writes already refined to State-only dataflow
      preserves the pre-existing Object/Graphics gap exactly, regardless of
      whether the source was ordinary motion, a wall push, PU motion, or
      platform displacement;
    - synchronization, either normal shell renderer, the source-bounded water
      composition, and range-certified quicksand/object-tail writers cannot
      reach 960; and
    - consequently the timer-131 midpoint cannot be the endpoint of a trace
      made solely from those certified writer forms.

    This is not a clean-retail impossibility theorem.  The final definitions
    name the remaining linked-Clight obligations: entry-memory projection,
    complete clean-JP writer coverage, quicksand-depth and oGraphYOffset/flag
    closure, and pointer/non-alias refinement.  None is postulated or used as
    an axiom below. *)

From Coq Require Import List Lia ZArith.
From compcert Require Import AST Clight Floats Integers Memory Values.
From LessThanOneAPress.Proofs Require Import
  ASTFacts CleanEntry ClightFacts EntryMemory GameTypes InkFallback
  PyramidTopPU StateFirstInstaller Timer131Surface.

Import ListNotations.
Local Open Scope Z_scope.

(** * The exact target gap *)

Definition jp_graphics_object_y_gap (views : MarioThreeView) : Z :=
  position_y (three_graphics_position views) -
  position_y (three_object_position views).

Definition jp_timer131_midface_collision_sample
    (views : MarioThreeView) : Prop :=
  upper_warp_contact (three_object_position views) /\
  three_graphics_position views = timer131_midface_retry_position.

Theorem jp_timer131_midface_collision_needs_gap_960 :
  forall views,
    jp_timer131_midface_collision_sample views ->
    960 <= jp_graphics_object_y_gap views.
Proof.
  intros views [Hwarp Hgraphics].
  unfold jp_graphics_object_y_gap.
  rewrite Hgraphics.
  now apply timer131_midface_retry_requires_at_least_960_graphics_y_gap.
Qed.

Definition jp_synchronized_views (position : PositionZ) : MarioThreeView := {|
  three_state_position := position;
  three_object_position := position;
  three_graphics_position := position
|}.

Theorem jp_synchronized_views_have_zero_gap :
  forall position,
    jp_graphics_object_y_gap (jp_synchronized_views position) = 0.
Proof.
  intros position.
  unfold jp_graphics_object_y_gap, jp_synchronized_views.
  cbn. lia.
Qed.

Theorem jp_synchronized_sample_cannot_be_timer131_midface :
  forall position,
    ~ jp_timer131_midface_collision_sample
        (jp_synchronized_views position).
Proof.
  intros position Hcandidate.
  pose proof
    (jp_timer131_midface_collision_needs_gap_960
      (jp_synchronized_views position) Hcandidate) as Hgap.
  rewrite jp_synchronized_views_have_zero_gap in Hgap.
  lia.
Qed.

(** * State-only motion cannot install the gap *)

Theorem jp_state_only_prefix_preserves_graphics_object_y_gap :
  forall positions views,
    jp_graphics_object_y_gap (write_state_only_prefix positions views) =
    jp_graphics_object_y_gap views.
Proof.
  intros positions views.
  pose proof
    (state_only_prefix_preserves_collision_and_fallback_samples
      positions views) as (Hobject & Hgraphics & _).
  unfold jp_graphics_object_y_gap.
  now rewrite Hobject, Hgraphics.
Qed.

(** This statement is magnitude-independent.  In particular it does not
    assume local coordinates, bounded velocity, a successful floor query, or
    the absence of an s16/PU alias.  Any such prefix can only *carry* a gap
    that an earlier Object/Graphics writer already created. *)
Theorem jp_timer131_midface_after_state_only_prefix_needs_preexisting_gap :
  forall positions before,
    jp_timer131_midface_collision_sample
      (write_state_only_prefix positions before) ->
    960 <= jp_graphics_object_y_gap before.
Proof.
  intros positions before Hcandidate.
  pose proof
    (jp_timer131_midface_collision_needs_gap_960
      (write_state_only_prefix positions before) Hcandidate) as Hgap.
  rewrite jp_state_only_prefix_preserves_graphics_object_y_gap in Hgap.
  exact Hgap.
Qed.

Corollary jp_state_only_prefix_from_synchronized_entry_cannot_install_midface :
  forall positions entry_position,
    ~ jp_timer131_midface_collision_sample
        (write_state_only_prefix positions
          (jp_synchronized_views entry_position)).
Proof.
  intros positions entry_position Hcandidate.
  pose proof
    (jp_timer131_midface_after_state_only_prefix_needs_preexisting_gap
      positions (jp_synchronized_views entry_position) Hcandidate) as Hgap.
  rewrite jp_synchronized_views_have_zero_gap in Hgap.
  lia.
Qed.

(** * Range-certified end-of-frame writer forms *)

Definition jp_current_modeled_gap_bound : Z := 208.

(** The two water contributions are kept separate here.  This prevents the
    total [208] envelope from being mistaken for a source-derived magic
    constant: a future Clight refinement must establish the [<= 60] pitch and
    [< 148] bob premises on each live path. *)
Theorem jp_water_pitch_and_bob_stay_below_208 :
  forall pitch bob,
    pitch <= 60 ->
    bob < 148 ->
    pitch + bob <= jp_current_modeled_gap_bound.
Proof.
  intros pitch bob Hpitch Hbob.
  unfold jp_current_modeled_gap_bound.
  lia.
Qed.

Theorem jp_shell_normal_form_stays_below_208 :
  forall mode state_position,
    jp_graphics_object_y_gap
      (riding_shell_normal_frame mode state_position) <=
    jp_current_modeled_gap_bound.
Proof.
  intros mode state_position.
  pose proof
    (riding_shell_normal_frame_gap_is_fixed mode state_position)
      as [Hgap Hbound].
  unfold jp_graphics_object_y_gap.
  unfold jp_current_modeled_gap_bound.
  lia.
Qed.

(** A negative quicksand depth is a real precision-sensitive escape avenue.
    The first theorem is deliberately a *single-sink, zero-incoming-gap*
    statement: its [gap = -depth] premise must not be used for a stalled
    action that preserves an earlier Graphics raise. *)
Theorem jp_quicksand_writer_needs_depth_at_most_minus_960 :
  forall depth gap,
    gap = - depth ->
    960 <= gap ->
    depth <= -960.
Proof. intros depth gap Hgap Hlarge; lia. Qed.

Fixpoint jp_repeated_modeled_quicksand_sink
    (ticks : nat) (depth : Z) (views : MarioThreeView) : MarioThreeView :=
  match ticks with
  | O => views
  | S remaining =>
      modeled_graphics_sink_only depth
        (jp_repeated_modeled_quicksand_sink remaining depth views)
  end.

Theorem jp_modeled_quicksand_sink_gap_equation :
  forall views depth,
    jp_graphics_object_y_gap
      (modeled_graphics_sink_only depth views) =
    jp_graphics_object_y_gap views - depth.
Proof.
  intros views depth.
  unfold jp_graphics_object_y_gap, modeled_graphics_sink_only,
    position_with_y.
  cbn. lia.
Qed.

(** This recurrence captures the [act_reading_automatic_dialog]-style risk:
    if a continuing action omits a Graphics re-anchor, each negative-depth
    sink can retain the previous raise and add another one.  This is a theorem
    of the explicit integer projection, not a claim that such an action/depth
    state is clean-JP reachable. *)
Theorem jp_repeated_modeled_quicksand_sink_gap_equation :
  forall ticks depth views,
    jp_graphics_object_y_gap
      (jp_repeated_modeled_quicksand_sink ticks depth views) =
    jp_graphics_object_y_gap views - Z.of_nat ticks * depth.
Proof.
  induction ticks as [| ticks IH]; intros depth views.
  - cbn. lia.
  - cbn [jp_repeated_modeled_quicksand_sink].
    rewrite jp_modeled_quicksand_sink_gap_equation, IH.
    rewrite Nat2Z.inj_succ.
    lia.
Qed.

Theorem jp_repeated_negative_modeled_quicksand_sink_can_reach_960 :
  forall ticks magnitude views,
    0 < magnitude ->
    960 <=
      jp_graphics_object_y_gap views + Z.of_nat ticks * magnitude ->
    960 <= jp_graphics_object_y_gap
      (jp_repeated_modeled_quicksand_sink ticks (- magnitude) views).
Proof.
  intros ticks magnitude views Hpositive Hlarge.
  rewrite jp_repeated_modeled_quicksand_sink_gap_equation.
  nia.
Qed.

(** In the existing projected sink transition, nonnegative depth cannot
    increase the Graphics/Object gap at all.  This statement is deliberately
    about [modeled_graphics_sink_only]; the last binary32 projection
    obligation below must justify its use for a live JP memory step. *)
Theorem jp_nonnegative_modeled_quicksand_sink_does_not_increase_gap :
  forall views depth,
    0 <= depth ->
    jp_graphics_object_y_gap
      (modeled_graphics_sink_only depth views) <=
    jp_graphics_object_y_gap views.
Proof.
  intros views depth Hdepth.
  unfold jp_graphics_object_y_gap, modeled_graphics_sink_only,
    position_with_y.
  cbn. lia.
Qed.

Corollary jp_nonnegative_modeled_quicksand_sink_preserves_208_bound :
  forall views depth,
    0 <= depth ->
    jp_graphics_object_y_gap views <= jp_current_modeled_gap_bound ->
    jp_graphics_object_y_gap
      (modeled_graphics_sink_only depth views) <=
    jp_current_modeled_gap_bound.
Proof.
  intros views depth Hdepth Hbound.
  pose proof
    (jp_nonnegative_modeled_quicksand_sink_does_not_increase_gap
      views depth Hdepth).
  lia.
Qed.

(** Likewise, the generic object-behavior tail can only directly create this
    size of projected gap if its effective graphical Y offset is itself at
    least 960.  Proving the Mario object's flag bit remains clear, or bounding
    [oGraphYOffset] whenever it is set, is deliberately left to retail
    writer/slot closure. *)
Theorem jp_object_graphics_tail_needs_offset_at_least_960 :
  forall offset gap,
    gap = offset ->
    960 <= gap ->
    960 <= offset.
Proof. intros offset gap Hgap Hlarge; lia. Qed.

(** [JPRangeCertifiedGapStep] is an explicit normal-form relation.  It is not
    claimed to cover retail execution.  Constructors either mirror an exact
    transition already proved in [InkFallback], or carry the narrow numeric
    side condition that a later linked-memory proof must derive. *)
Inductive JPRangeCertifiedGapStep :
    MarioThreeView -> MarioThreeView -> Prop :=
| JPCertifiedStateOnly :
    forall before next_state,
      JPRangeCertifiedGapStep before (write_state_only next_state before)
| JPCertifiedSynchronization :
    forall before position,
      JPRangeCertifiedGapStep before (jp_synchronized_views position)
| JPCertifiedShellNormal :
    forall before mode state_position,
      JPRangeCertifiedGapStep before
        (riding_shell_normal_frame mode state_position)
| JPCertifiedWaterVisual :
    forall before after pitch bob,
      jp_graphics_object_y_gap after = pitch + bob ->
      pitch <= 60 ->
      bob < 148 ->
      JPRangeCertifiedGapStep before after
| JPCertifiedNonnegativeQuicksandSink :
    forall before depth,
      0 <= depth ->
      JPRangeCertifiedGapStep before
        (modeled_graphics_sink_only depth before)
| JPCertifiedQuicksandVisual :
    forall before after graphical_raise,
      jp_graphics_object_y_gap after = graphical_raise ->
      graphical_raise <= 45 ->
      JPRangeCertifiedGapStep before after
| JPCertifiedObjectGraphicsTail :
    forall before after graphical_offset,
      jp_graphics_object_y_gap after = graphical_offset ->
      graphical_offset <= jp_current_modeled_gap_bound ->
      JPRangeCertifiedGapStep before after.

Theorem jp_range_certified_step_preserves_bound :
  forall before after,
    jp_graphics_object_y_gap before <= jp_current_modeled_gap_bound ->
    JPRangeCertifiedGapStep before after ->
    jp_graphics_object_y_gap after <= jp_current_modeled_gap_bound.
Proof.
  intros before after Hbefore Hstep.
  inversion Hstep; subst.
  - unfold jp_graphics_object_y_gap, write_state_only.
    cbn. exact Hbefore.
  - rewrite jp_synchronized_views_have_zero_gap.
    unfold jp_current_modeled_gap_bound. lia.
  - apply jp_shell_normal_form_stays_below_208.
  - unfold jp_current_modeled_gap_bound in *. lia.
  - unfold jp_graphics_object_y_gap, modeled_graphics_sink_only,
      position_with_y in *.
    cbn in *. lia.
  - unfold jp_current_modeled_gap_bound in *. lia.
  - unfold jp_current_modeled_gap_bound in *. lia.
Qed.

Inductive JPRangeCertifiedGapExecution :
    MarioThreeView -> MarioThreeView -> Prop :=
| JPCertifiedExecutionNil :
    forall views,
      JPRangeCertifiedGapExecution views views
| JPCertifiedExecutionCons :
    forall before middle after,
      JPRangeCertifiedGapStep before middle ->
      JPRangeCertifiedGapExecution middle after ->
      JPRangeCertifiedGapExecution before after.

Theorem jp_range_certified_execution_preserves_bound :
  forall before after,
    jp_graphics_object_y_gap before <= jp_current_modeled_gap_bound ->
    JPRangeCertifiedGapExecution before after ->
    jp_graphics_object_y_gap after <= jp_current_modeled_gap_bound.
Proof.
  intros before after Hbound Hexecution.
  induction Hexecution as
    [views | before middle after Hstep Hexecution IH].
  - exact Hbound.
  - apply IH.
    eapply jp_range_certified_step_preserves_bound; eauto.
Qed.

Theorem jp_range_certified_execution_from_synchronized_entry_stays_below_960 :
  forall entry_position after,
    JPRangeCertifiedGapExecution
      (jp_synchronized_views entry_position) after ->
    jp_graphics_object_y_gap after < 960.
Proof.
  intros entry_position after Hexecution.
  assert (Hentry :
    jp_graphics_object_y_gap (jp_synchronized_views entry_position) <=
      jp_current_modeled_gap_bound).
  { rewrite jp_synchronized_views_have_zero_gap.
    unfold jp_current_modeled_gap_bound. lia. }
  pose proof
    (jp_range_certified_execution_preserves_bound
      (jp_synchronized_views entry_position) after Hentry Hexecution)
      as Hpreserves.
  unfold jp_current_modeled_gap_bound in Hpreserves.
  lia.
Qed.

(** This is the closed reduction for the current writer model.  Any actual
    clean-JP midpoint installer must therefore violate entry synchronization
    or escape at least one range-certified step constructor. *)
Theorem jp_timer131_midface_requires_writer_coverage_escape :
  forall entry_position target,
    jp_timer131_midface_collision_sample target ->
    ~ JPRangeCertifiedGapExecution
        (jp_synchronized_views entry_position) target.
Proof.
  intros entry_position target Hcandidate Hexecution.
  pose proof
    (jp_timer131_midface_collision_needs_gap_960 target Hcandidate) as Hlarge.
  pose proof
    (jp_range_certified_execution_from_synchronized_entry_stays_below_960
      entry_position target Hexecution) as Hsmall.
  lia.
Qed.

(** This audit begins in SSL Area 1, before the upper object warp.  It must not
    reuse [CleanPyramidEntry], whose [clean_area] field deliberately fixes
    Area 2.  The predicate below records only the source-relevant cleanliness
    needed at the Area-1 audit boundary; connecting an ordinary castle entry
    to it remains an execution obligation. *)
Definition jp_gap_area1_id : Int.int := Int.repr 1.

Record CleanJPArea1GapAuditState (initial : GameState) : Prop := {
  clean_jp_area1_version : state_version initial = VersionJP;
  clean_jp_area1_level : state_level initial = ssl_level_id;
  clean_jp_area1_course : state_course initial = ssl_course_id;
  clean_jp_area1_act : valid_act (state_act initial);
  clean_jp_area1_area : state_area initial = jp_gap_area1_id;
  clean_jp_area1_act3_bit :
    star_bit (state_save_flags initial) act3_index = false;
  clean_jp_area1_act6_bit :
    star_bit (state_save_flags initial) act6_index = false;
  clean_jp_area1_save_coherent : target_save_coherent initial;
  clean_jp_area1_pool : state_pool_well_formed initial = true;
  clean_jp_area1_lists : state_lists_well_formed initial = true;
  clean_jp_area1_no_pending_interaction :
    state_pending_star_interaction initial = false;
  clean_jp_area1_no_delayed_exit : state_delayed_star_exit initial = false;
  clean_jp_area1_no_delayed_warp : state_delayed_warp_pending initial = false;
  clean_jp_area1_input_history : input_history_well_formed initial;
  clean_jp_area1_no_a_edge : entry_controller_has_no_a_edge initial
}.

(** A [GameState] does not itself expose the three separate live-memory views.
    This record therefore adds the projection evidence instead of hiding it in
    the Area-1 cleanliness predicate. *)
Record CleanJPArea1ProjectedGapEntry
    (initial : GameState) (entry_views : MarioThreeView) : Prop := {
  clean_jp_area1_projected_state : CleanJPArea1GapAuditState initial;
  clean_jp_area1_projected_object_graphics_equal :
    three_object_position entry_views = three_graphics_position entry_views
}.

Theorem clean_jp_area1_projected_certified_trace_cannot_install_midface :
  forall initial entry_views target,
    CleanJPArea1ProjectedGapEntry initial entry_views ->
    JPRangeCertifiedGapExecution entry_views target ->
    ~ jp_timer131_midface_collision_sample target.
Proof.
  intros initial entry_views target Hentry Hexecution Hcandidate.
  pose proof
    (jp_timer131_midface_collision_needs_gap_960 target Hcandidate) as Hlarge.
  pose proof
    (jp_range_certified_execution_preserves_bound
      entry_views target) as Hpreserves.
  apply Hpreserves in Hexecution.
  - unfold jp_current_modeled_gap_bound in Hexecution.
    lia.
  - unfold jp_graphics_object_y_gap.
    rewrite (clean_jp_area1_projected_object_graphics_equal
      initial entry_views Hentry).
    unfold jp_current_modeled_gap_bound.
    lia.
Qed.

(** The collision-prefix version isolates scheduling from writer coverage.
    A State-only prefix can be arbitrarily large in State space, so this
    theorem covers any ordinary-motion or PU/platform-displacement phase once
    a source refinement establishes that the relevant prefix is State-only;
    it does not itself prove that classification. *)
Theorem jp_timer131_midface_collision_prefix_requires_prior_writer_escape :
  forall entry_position prior positions,
    JPRangeCertifiedGapExecution
      (jp_synchronized_views entry_position) prior ->
    ~ jp_timer131_midface_collision_sample
        (write_state_only_prefix positions prior).
Proof.
  intros entry_position prior positions Hexecution Hcandidate.
  pose proof
    (jp_timer131_midface_after_state_only_prefix_needs_preexisting_gap
      positions prior Hcandidate) as Hlarge.
  pose proof
    (jp_range_certified_execution_from_synchronized_entry_stays_below_960
      entry_position prior Hexecution) as Hsmall.
  lia.
Qed.

(** * Concrete JP source and entry-memory receipts *)

Definition CleanJPGraphicsGapSourceShapeKernel : Prop :=
  mario_entry_coordinate_sync_source_shape_jp_claim /\
  mario_entry_field_reset_source_shape_jp_claim /\
  graph_spawninfo_position_source_shape_jp_claim /\
  graphical_floor_fallback_source_shape_jp_claim /\
  shell_graphics_y_offsets_source_shape_jp_claim /\
  shell_ground_quicksand_reset_source_shape_jp_claim /\
  shell_air_quicksand_reset_source_shape_jp_claim /\
  warp_precedes_shell_interaction_source_shape_jp_claim /\
  bhv_mario_flag_and_callbacks_source_shape_jp_claim /\
  mario_misc_graphics_writer_inventory_source_shape_jp_claim /\
  wall_position_writer_source_shape_jp_claim /\
  StateFirstSchedulingSourceShapeReceipts.

Theorem clean_jp_graphics_gap_source_shape_kernel_checked :
  CleanJPGraphicsGapSourceShapeKernel.
Proof.
  unfold CleanJPGraphicsGapSourceShapeKernel.
  split; [exact mario_entry_coordinate_sync_source_shape_jp |].
  split; [exact mario_entry_field_reset_source_shape_jp |].
  split; [exact graph_spawninfo_position_source_shape_jp |].
  split; [exact graphical_floor_fallback_source_shape_jp |].
  split; [exact shell_graphics_y_offsets_source_shape_jp |].
  split; [exact shell_ground_quicksand_reset_source_shape_jp |].
  split; [exact shell_air_quicksand_reset_source_shape_jp |].
  split; [exact warp_precedes_shell_interaction_source_shape_jp |].
  split; [exact bhv_mario_flag_and_callbacks_source_shape_jp |].
  split; [exact mario_misc_graphics_writer_inventory_source_shape_jp |].
  split; [exact wall_position_writer_source_shape_jp |].
  exact state_first_scheduling_source_shape_receipts_checked.
Qed.

(** The concrete entry postcondition stores the same binary32 Y value in raw
    Object and Graphics memory.  This is a memory theorem, not a PositionZ
    approximation. *)
Theorem retail_entry_memory_raw_and_graphics_y_are_equal :
  forall memory mario_state_block mario_object_block controller_block
    mario_state_base mario_object_base controller_base x y z sample,
    RetailEntryMemoryPostcondition
      memory mario_state_block mario_object_block controller_block
      mario_state_base mario_object_base controller_base x y z sample ->
    load_at AST.Mfloat32 memory mario_object_block mario_object_base
      (mario_object_raw_position_offset + 4) =
    load_at AST.Mfloat32 memory mario_object_block mario_object_base
      (mario_object_graphics_position_offset + 4).
Proof.
  intros memory mario_state_block mario_object_block controller_block
    mario_state_base mario_object_base controller_base x y z sample Hentry.
  rewrite (entry_object_raw_y _ _ _ _ _ _ _ _ _ _ _ Hentry).
  rewrite (entry_object_graphics_y _ _ _ _ _ _ _ _ _ _ _ Hentry).
  reflexivity.
Qed.

Theorem retail_entry_memory_cannot_expose_distinct_raw_graphics_y :
  forall memory mario_state_block mario_object_block controller_block
    mario_state_base mario_object_base controller_base x y z sample
    raw_y graphics_y,
    RetailEntryMemoryPostcondition
      memory mario_state_block mario_object_block controller_block
      mario_state_base mario_object_base controller_base x y z sample ->
    load_at AST.Mfloat32 memory mario_object_block mario_object_base
      (mario_object_raw_position_offset + 4) = Some (Vsingle raw_y) ->
    load_at AST.Mfloat32 memory mario_object_block mario_object_base
      (mario_object_graphics_position_offset + 4) = Some (Vsingle graphics_y) ->
    raw_y = graphics_y.
Proof.
  intros memory mario_state_block mario_object_block controller_block
    mario_state_base mario_object_base controller_base x y z sample
    raw_y graphics_y Hentry Hraw Hgraphics.
  pose proof
    (retail_entry_memory_raw_and_graphics_y_are_equal
      memory mario_state_block mario_object_block controller_block
      mario_state_base mario_object_base controller_base x y z sample Hentry)
      as Hequal.
  rewrite Hraw, Hgraphics in Hequal.
  now injection Hequal.
Qed.

(** * Precisely named remaining retail obligations *)

(** This entry obligation connects the clean Area-1 audit boundary and the
    actual linked JP initialization call to [RetailEntryMemoryPostcondition].
    It is not proved merely by the syntax receipts above. *)
Definition CleanJPGraphicsGapEntryMemoryRefinementObligation
    (linked_clean_jp_entry :
      GameState -> Clight.state -> mem ->
      block -> block -> block -> Z -> Z -> Z ->
      float32 -> float32 -> float32 -> EntryControllerSample -> Prop) : Prop :=
  forall initial entry_state memory
    mario_state_block mario_object_block controller_block
    mario_state_base mario_object_base controller_base x y z sample,
    CleanJPArea1GapAuditState initial ->
    linked_clean_jp_entry initial entry_state memory
      mario_state_block mario_object_block controller_block
      mario_state_base mario_object_base controller_base x y z sample ->
    RetailEntryMemoryPostcondition
      memory mario_state_block mario_object_block controller_block
      mario_state_base mario_object_base controller_base x y z sample.

(** This is the per-step coverage target.  A future linked execution proof
    must project each relevant retail JP memory transition—not just its final
    endpoint—to one of [JPRangeCertifiedGapStep]'s data-bearing constructors.
    The difficult cases are negative quicksand depth, Mario [oFlags] bit zero
    plus [oGraphYOffset], render callbacks/non-aliasing, slot reuse, and any
    writer outside the generated translation set. *)
Definition CleanJPGraphicsGapWriterCoverageObligation
    (clean_jp_no_a_retail_step : Clight.state -> Clight.state -> Prop)
    (project_three_views : Clight.state -> option MarioThreeView) : Prop :=
  forall before_state after_state before_views after_views,
    clean_jp_no_a_retail_step before_state after_state ->
    project_three_views before_state = Some before_views ->
    project_three_views after_state = Some after_views ->
    JPRangeCertifiedGapStep before_views after_views.

(** In particular, writer coverage cannot silently classify repeated
    negative-depth, non-reanchoring frames as safe.  One sound way to close
    that branch is to prove the live depth nonnegative at every clean/no-A JP
    sink call whose action path does not first re-anchor Graphics.  Proving
    that the relevant unsynchronized action (including a stalled automatic
    dialog action) is unreachable is an alternative way to make the premise
    empty. *)
Definition CleanJPUnsynchronizedSinkDepthRefinementObligation
    (clean_jp_no_a_unsynchronized_sink_state : Clight.state -> Prop)
    (project_quicksand_depth : Clight.state -> option float32) : Prop :=
  forall state depth,
    clean_jp_no_a_unsynchronized_sink_state state ->
    project_quicksand_depth state = Some depth ->
    Float32.cmp Cle positive_f32_zero depth = true.

(** The arithmetic in this file uses the exact local Object/Graphics integer
    samples consumed by the collision/floor model.  This obligation prevents
    silently treating their binary32 loads as mathematical integers.  It
    intentionally places no conversion premise on MarioState: the State-only
    preservation theorem is magnitude-independent and therefore continues to
    cover an out-of-range/PU State sample.  The compiled behavior of any
    out-of-range State cast remains a separate surface-refinement concern. *)
Definition CleanJPGraphicsGapBinary32ProjectionObligation
    (project_three_views : Clight.state -> option MarioThreeView)
    (project_binary32_object_graphics_y :
      Clight.state -> option (float32 * float32)) : Prop :=
  forall state views object_y graphics_y,
    project_three_views state = Some views ->
    project_binary32_object_graphics_y state =
      Some (object_y, graphics_y) ->
      Float32.to_int object_y = Some (Int.repr
        (position_y (three_object_position views))) /\
      Float32.to_int graphics_y = Some (Int.repr
        (position_y (three_graphics_position views))).

(** No theorem above assumes these obligations.  The checked boundary says
    exactly what is closed now. *)
Definition CleanJPGraphicsGapCheckedBoundary : Prop :=
  CleanJPGraphicsGapSourceShapeKernel /\
  (forall views,
    jp_timer131_midface_collision_sample views ->
    960 <= jp_graphics_object_y_gap views) /\
  (forall positions views,
    jp_graphics_object_y_gap (write_state_only_prefix positions views) =
      jp_graphics_object_y_gap views) /\
  (forall entry_position target,
    jp_timer131_midface_collision_sample target ->
    ~ JPRangeCertifiedGapExecution
        (jp_synchronized_views entry_position) target).

Theorem clean_jp_graphics_gap_checked_boundary_holds :
  CleanJPGraphicsGapCheckedBoundary.
Proof.
  unfold CleanJPGraphicsGapCheckedBoundary.
  split; [exact clean_jp_graphics_gap_source_shape_kernel_checked |].
  split; [exact jp_timer131_midface_collision_needs_gap_960 |].
  split; [exact jp_state_only_prefix_preserves_graphics_object_y_gap |].
  exact jp_timer131_midface_requires_writer_coverage_escape.
Qed.
