(** Zero-A-edge reachability and gap-bound composition over Clight states.

    This file supplies two pieces that were previously only described in
    prose:

    - a concrete reflexive/transitive reachability relation over CompCert
      [Clight.step2] whose every observed memory has the A bit clear in the
      retail [Controller.buttonPressed] field; and
    - the induction that turns entry synchronization plus per-step writer
      refinement into the global [Graphics/Object < 960] conclusion.

    This module does not establish that [program], [controller_block], or
    [entry_state] comes from a clean retail JP entry.  That entry/program
    refinement is separate.  The writer-refinement premise is also
    intentionally exposed.  The generated
    writer census narrows that premise, but neither this file nor the census
    proves pointer validity, non-aliasing, external-call frame conditions, or
    that every reachable retail store belongs to the certified relation. *)

From Coq Require Import List Lia ZArith.
From compcert Require Import
  AST Clight Events Floats Globalenvs Integers Memory Smallstep Values.
From LessThanOneAPress.Generated Require Import
  jp_level_update jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  CleanJPGraphicsGap ClightRefinement EntryMemory GameTypes InkFallback
  InputSemantics JPQuicksandDepth OrdinaryArea1EntryMemory PyramidTopPU.

Local Open Scope Z_scope.

Module JZR_Level := jp_level_update.
Module JZR_Objects := jp_object_list_processor.

(** Every Clight control-state constructor carries a CompCert memory. *)
Definition clight_state_memory (state : Clight.state) : mem :=
  match state with
  | Clight.State _ _ _ _ _ memory => memory
  | Clight.Callstate _ _ _ memory => memory
  | Clight.Returnstate _ _ memory => memory
  end.

(** The selected field is the implementation's edge-triggered controller
    field, not [buttonDown].  Consequently this predicate permits A to remain
    held throughout the run.  The fixed block/base must later be derived from
    the linked program's globals and MarioState.controller pointer. *)
Inductive ControllerNoAEdgeMemory
    (memory : mem) (controller_block : block)
    (controller_base : Z) : Prop :=
| controller_no_a_edge_memory :
  forall down_word pressed_word,
    load_at Mint16unsigned memory controller_block controller_base
      controller_button_down_offset =
    Some (Vint down_word) ->
    load_at Mint16unsigned memory controller_block controller_base
      controller_button_pressed_offset =
    Some (Vint pressed_word) ->
    Int.testbit pressed_word 15 = false ->
    ControllerNoAEdgeMemory memory controller_block controller_base.

Definition ClightStateHasNoAEdge
    (controller_block : block) (controller_base : Z)
    (state : Clight.state) : Prop :=
  ControllerNoAEdgeMemory
    (clight_state_memory state) controller_block controller_base.

(** A held A button is expressly compatible with the live-memory condition:
    [buttonDown] may contain [0x8000] while [buttonPressed] is zero. *)
Theorem jp_live_memory_no_edge_does_not_require_a_up :
  forall memory controller_block controller_base,
    load_at Mint16unsigned memory controller_block controller_base
      controller_button_down_offset = Some (Vint a_button_mask) ->
    load_at Mint16unsigned memory controller_block controller_base
      controller_button_pressed_offset = Some (Vint Int.zero) ->
    ControllerNoAEdgeMemory
      memory controller_block controller_base.
Proof.
  intros memory controller_block controller_base Hdown Hpressed.
  econstructor; [exact Hdown | exact Hpressed |].
  vm_compute. reflexivity.
Qed.

(** Reachability starts at a caller-supplied boundary and retains only executions
    for which the actual [buttonPressed] A bit is clear in every intermediate
    small-step state.  This is deliberately stronger than checking once per
    frame and therefore safe for the target definition once the caller proves
    that the boundary, program, and controller address are the retail ones. *)
Inductive ZeroAEdgeClightReachable
    (program : Clight.program)
    (controller_block : block) (controller_base : Z)
    (entry_state : Clight.state) : Clight.state -> Prop :=
| JPZeroAReachableEntry :
    ClightStateHasNoAEdge controller_block controller_base entry_state ->
    ZeroAEdgeClightReachable
      program controller_block controller_base entry_state entry_state
| JPZeroAReachableStep :
    forall before after trace,
      ZeroAEdgeClightReachable
        program controller_block controller_base entry_state before ->
      @Clight.step2 (Clight.globalenv program) before trace after ->
      ClightStateHasNoAEdge controller_block controller_base after ->
      ZeroAEdgeClightReachable
        program controller_block controller_base entry_state after.

Theorem zero_a_edge_clight_reachable_has_no_a_edge :
  forall program controller_block controller_base entry_state state,
    ZeroAEdgeClightReachable
      program controller_block controller_base entry_state state ->
    ClightStateHasNoAEdge controller_block controller_base state.
Proof.
  intros program controller_block controller_base entry_state state Hreach.
  inversion Hreach; assumption.
Qed.

Theorem zero_a_edge_clight_reachable_is_clight_star :
  forall program controller_block controller_base entry_state state,
    ZeroAEdgeClightReachable
      program controller_block controller_base entry_state state ->
    exists trace,
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        entry_state trace state.
Proof.
  intros program controller_block controller_base entry_state state Hreach.
  induction Hreach as
    [Hentry_no_edge | before after trace Hbefore IH Hstep Hafter_no_edge].
  - exists E0. constructor.
  - destruct IH as [prefix Hprefix].
    exists (prefix ** trace).
    eapply Smallstep.star_right; eauto.
Qed.

Definition JPZeroAProjectionTotal
    (program : Clight.program)
    (controller_block : block) (controller_base : Z)
    (entry_state : Clight.state)
    (project_three_views : Clight.state -> option MarioThreeView) : Prop :=
  forall state,
    ZeroAEdgeClightReachable
      program controller_block controller_base entry_state state ->
    exists views, project_three_views state = Some views.

(** A [PositionZ] projection is tied to three concrete binary32 loads and
    CompCert's truncating float-to-int conversion. *)
Definition LivePositionZProjection
    (memory : mem) (storage_block : block) (base field_offset : Z)
    (position : PositionZ) : Prop :=
  exists x_float y_float z_float x_word y_word z_word,
    load_at Mfloat32 memory storage_block base field_offset =
      Some (Vsingle x_float) /\
    load_at Mfloat32 memory storage_block base (field_offset + 4) =
      Some (Vsingle y_float) /\
    load_at Mfloat32 memory storage_block base (field_offset + 8) =
      Some (Vsingle z_float) /\
    Float32.to_int x_float = Some x_word /\
    Float32.to_int y_float = Some y_word /\
    Float32.to_int z_float = Some z_word /\
    position_x position = Int.signed x_word /\
    position_y position = Int.signed y_word /\
    position_z position = Int.signed z_word.

(** This prevents an arbitrary constant projection from satisfying the gap
    theorem.  Each returned three-view value must be read from the live JP
    MarioState, the object currently named by [gMarioObject], and that
    object's graphical position.  The reciprocal MarioState.marioObj load and
    nonzero active flags rule out projecting an unrelated pool slot.  Slot
    epoch/lifecycle preservation remains part of per-step writer refinement. *)
Definition JPThreeViewProjectionSound
    (program : Clight.program)
    (project_three_views : Clight.state -> option MarioThreeView) : Prop :=
  forall state views,
    project_three_views state = Some views ->
    exists state_storage_block state_pointer_cell_block
      object_pool_block mario_object_pointer_cell_block
      state_base object_base active_flags,
      Genv.find_symbol (Clight.globalenv program) JZR_Level._gMarioStates =
        Some state_storage_block /\
      Genv.find_symbol (Clight.globalenv program) JZR_Level._gMarioState =
        Some state_pointer_cell_block /\
      Genv.find_symbol (Clight.globalenv program) JZR_Objects._gObjectPool =
        Some object_pool_block /\
      Genv.find_symbol (Clight.globalenv program) JZR_Objects._gMarioObject =
        Some mario_object_pointer_cell_block /\
      load_at Mptr (clight_state_memory state)
        state_pointer_cell_block 0 0 =
        Some (Vptr state_storage_block (Ptrofs.repr state_base)) /\
      load_at Mptr (clight_state_memory state)
        mario_object_pointer_cell_block 0 0 =
        Some (Vptr object_pool_block (Ptrofs.repr object_base)) /\
      load_at Mptr (clight_state_memory state)
        state_storage_block state_base mario_state_object_pointer_offset =
        Some (Vptr object_pool_block (Ptrofs.repr object_base)) /\
      load_at Mint16signed (clight_state_memory state)
        object_pool_block object_base object_active_flags_offset =
        Some (Vint active_flags) /\
      active_flags <> Int.zero /\
      LivePositionZProjection (clight_state_memory state)
        state_storage_block state_base mario_state_position_offset
        (three_state_position views) /\
      LivePositionZProjection (clight_state_memory state)
        object_pool_block object_base mario_object_raw_position_offset
        (three_object_position views) /\
      LivePositionZProjection (clight_state_memory state)
        object_pool_block object_base mario_object_graphics_position_offset
        (three_graphics_position views).

Record JPZeroAProjectionContract
    (program : Clight.program)
    (controller_block : block) (controller_base : Z)
    (entry_state : Clight.state)
    (project_three_views : Clight.state -> option MarioThreeView) : Prop := {
  jp_zero_a_projection_total :
    JPZeroAProjectionTotal program controller_block controller_base
      entry_state project_three_views;
  jp_zero_a_projection_reads_live_mario_memory :
    JPThreeViewProjectionSound program project_three_views
}.

(** This is the exact linked-writer closure statement needed by the
    composition proof.  It ranges only over actually reachable, no-edge
    steps, but it must classify every such step, including calls, returns,
    external effects, pointer aliases, and stores through reused slots. *)
Definition JPZeroAGapStepRefinementObligation
    (program : Clight.program)
    (controller_block : block) (controller_base : Z)
    (entry_state : Clight.state)
    (project_three_views : Clight.state -> option MarioThreeView) : Prop :=
  forall before after trace before_views after_views,
    ZeroAEdgeClightReachable
      program controller_block controller_base entry_state before ->
    @Clight.step2 (Clight.globalenv program) before trace after ->
    ClightStateHasNoAEdge controller_block controller_base after ->
    project_three_views before = Some before_views ->
    project_three_views after = Some after_views ->
    JPRangeCertifiedGapStep before_views after_views.

(** The composition part of checklist item 7 is proved: once an audited entry
    projects below the current 208-unit envelope and every reachable Clight
    step satisfies the explicitly named writer-refinement obligation, every
    reachable projection remains below that envelope.  The theorem does not
    discharge either premise. *)
Theorem jp_zero_a_edge_projection_preserves_gap_bound :
  forall program controller_block controller_base entry_state
      project_three_views entry_views state views,
    project_three_views entry_state = Some entry_views ->
    jp_graphics_object_y_gap entry_views <= jp_current_modeled_gap_bound ->
    JPZeroAProjectionContract
      program controller_block controller_base entry_state
      project_three_views ->
    JPZeroAGapStepRefinementObligation
      program controller_block controller_base entry_state
      project_three_views ->
    ZeroAEdgeClightReachable
      program controller_block controller_base entry_state state ->
    project_three_views state = Some views ->
    jp_graphics_object_y_gap views <= jp_current_modeled_gap_bound.
Proof.
  intros program controller_block controller_base entry_state
    project_three_views entry_views state views Hentry Hentry_bound
    Hprojection Hrefinement Hreachable.
  destruct Hprojection as [Htotal Hprojection_sound].
  revert views.
  induction Hreachable as
    [Hentry_no_edge | before after trace Hbefore IH Hstep Hafter_no_edge];
    intros views Hviews.
  - rewrite Hentry in Hviews.
    now injection Hviews as <-.
  - destruct (Htotal before Hbefore) as [before_views Hbefore_views].
    specialize (IH before_views Hbefore_views).
    eapply jp_range_certified_step_preserves_bound; [exact IH |].
    eapply Hrefinement; eauto.
Qed.

Corollary jp_zero_a_edge_projection_stays_below_960 :
  forall program controller_block controller_base entry_state
      project_three_views entry_views state views,
    project_three_views entry_state = Some entry_views ->
    jp_graphics_object_y_gap entry_views <= jp_current_modeled_gap_bound ->
    JPZeroAProjectionContract
      program controller_block controller_base entry_state
      project_three_views ->
    JPZeroAGapStepRefinementObligation
      program controller_block controller_base entry_state
      project_three_views ->
    ZeroAEdgeClightReachable
      program controller_block controller_base entry_state state ->
    project_three_views state = Some views ->
    jp_graphics_object_y_gap views < 960.
Proof.
  intros.
  pose proof
    (jp_zero_a_edge_projection_preserves_gap_bound
      program controller_block controller_base entry_state
      project_three_views entry_views state views H H0 H1 H2 H3 H4)
    as Hbound.
  unfold jp_current_modeled_gap_bound in Hbound.
  lia.
Qed.

Theorem jp_zero_a_edge_projection_cannot_install_timer131_midface :
  forall program controller_block controller_base entry_state
      project_three_views entry_views state views,
    project_three_views entry_state = Some entry_views ->
    jp_graphics_object_y_gap entry_views <= jp_current_modeled_gap_bound ->
    JPZeroAProjectionContract
      program controller_block controller_base entry_state
      project_three_views ->
    JPZeroAGapStepRefinementObligation
      program controller_block controller_base entry_state
      project_three_views ->
    ZeroAEdgeClightReachable
      program controller_block controller_base entry_state state ->
    project_three_views state = Some views ->
    ~ jp_timer131_midface_collision_sample views.
Proof.
  intros program controller_block controller_base entry_state
    project_three_views entry_views state views Hentry Hentry_bound Hprojection
    Hrefinement Hreachable Hviews Hmidface.
  pose proof
    (jp_zero_a_edge_projection_stays_below_960
      program controller_block controller_base entry_state
      project_three_views entry_views state views Hentry Hentry_bound Hprojection
      Hrefinement Hreachable Hviews) as Hsmall.
  pose proof
    (jp_timer131_midface_collision_needs_gap_960 views Hmidface) as Hlarge.
  lia.
Qed.
