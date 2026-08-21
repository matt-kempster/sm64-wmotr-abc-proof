(** The real JP clear/load/spawn prefix for the timer-131 Ink route.

    This file corrects an important chronology mistake in the earlier entry
    boundary.  [clear_objects] is called by the level-script INIT_LEVEL
    command; [load_mario_area] and [init_mario] are reached later through
    [level_update.init_level], and Mario is allocated by the nested
    [spawn_objects_from_info] call.  They are not one C call chain.

    [InkTimer131CellClassifiedReach] is a small-step execution certificate:
    every constructor contains one actual [Clight.step2] and classifies that
    step's memory effect.  [JPInkTimer131RealEntryPrefix] joins five such
    segments at the exact generated internal functions.  Consequently an
    inhabitant is a continuous execution from the official task start through
    clearing, Area-1 loading, Mario spawning, and Mario initialization—not a
    list of unrelated source receipts.

    The official cleaned program still contains unresolved OS/audio/graphics
    externals.  This module therefore does not manufacture an inhabitant by
    assigning those calls arbitrary effects.  Each reached external must be
    represented by a protected-frame or checked-writer constructor before the
    certificate can be built.  This is the intended, defined-behavior proof
    boundary; invalid pointers, OOB execution, ACE, and asynchronous DMA are
    outside CompCert Clight. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes Events Floats Globalenvs
  Integers Memory Smallstep Values.
From LessThanOneAPress.Generated Require Import
  jp_area jp_game_init jp_level_script jp_level_update jp_mario
  jp_object_list_processor jp_spawn_object.
From LessThanOneAPress.Proofs Require Import
  ASTFacts CleanedClightPrograms DefaultArea1StartChronology EntryMemory GameTypes
  InkTimer131ClightTraceBridge
  InkTimer131EntryExecutionClosure InkTimer131LiveIdentityClosure
  JPSelectedRuntimeTaskStart
  OrdinaryArea1EntryMemory SelectedClightTarget.

Import ListNotations.

Module IT131P_Script := jp_level_script.
Module IT131P_Update := jp_level_update.
Module IT131P_Area := jp_area.
Module IT131P_Objects := jp_object_list_processor.
Module IT131P_Spawn := jp_spawn_object.
Module IT131P_Mario := jp_mario.

(** * Exact generated phase order *)

Definition ink_timer131_real_prefix_source_claim : Prop :=
  straightline_callees_s (fn_body IT131P_Script.f_level_cmd_init_level) =
    [IT131P_Script._init_graph_node_start;
     IT131P_Script._clear_objects;
     IT131P_Script._clear_areas;
     IT131P_Script._main_pool_push_state] /\
  ident_subsequenceb
    [IT131P_Update._load_mario_area; IT131P_Update._init_mario]
    (direct_callees_s (fn_body IT131P_Update.f_init_level)) = true /\
  ident_subsequenceb
    [IT131P_Area._load_area; IT131P_Area._spawn_objects_from_info]
    (direct_callees_s (fn_body IT131P_Area.f_load_mario_area)) = true /\
  calls_ident_s IT131P_Objects._create_object
    (fn_body IT131P_Objects.f_spawn_objects_from_info) = true /\
  calls_ident_s IT131P_Spawn._allocate_object
    (fn_body IT131P_Spawn.f_create_object) = true /\
  calls_ident_s IT131P_Objects._clear_object_lists
    (fn_body IT131P_Objects.f_clear_objects) = true.

Theorem ink_timer131_real_prefix_source_checked :
  ink_timer131_real_prefix_source_claim.
Proof.
  unfold ink_timer131_real_prefix_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** * An actual step-by-step cell classifier *)

Inductive InkTimer131CellClassifiedReach
    (program : Clight.program) (addresses : Area1EntryAddresses) :
    Clight.state -> Clight.state -> Prop :=
| InkPrefixReachRefl :
    forall state,
      InkTimer131CellClassifiedReach program addresses state state
| InkPrefixReachStep :
    forall before step_trace middle final,
      Clight.step2 (Clight.globalenv program)
        before step_trace middle ->
      InkTimer131CellEffect
        (ink_timer131_clight_state_memory before)
        (ink_timer131_clight_state_memory middle) addresses ->
      InkTimer131CellClassifiedReach program addresses middle final ->
      InkTimer131CellClassifiedReach program addresses before final.

Lemma ink_timer131_cell_effect_preserves_safety :
  forall before after addresses,
    InkTimer131CellEffect before after addresses ->
    ink_timer131_cells_safe before (area1_object_pool_block addresses)
      (area1_mario_slot addresses) ->
    ink_timer131_cells_safe after (area1_object_pool_block addresses)
      (area1_mario_slot addresses).
Proof.
  intros before after addresses Heffect Hsafe.
  destruct Heffect as [Hstore | Hframe].
  - eapply ink_clean_store_step_preserves_timer131_cell_safety; eauto.
  - eapply ink_timer131_protected_cell_frame_preserves_safety; eauto.
Qed.

Theorem classified_reach_is_an_actual_clight_star :
  forall program addresses start final,
    InkTimer131CellClassifiedReach program addresses start final ->
    exists trace,
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        start trace final.
Proof.
  intros program addresses start final Hreach.
  induction Hreach.
  - exists E0. constructor.
  - destruct IHHreach as [tail Htail].
    exists (step_trace ** tail).
    eapply Smallstep.star_step; eauto.
Qed.

Theorem classified_reach_preserves_timer131_cells :
  forall program addresses start final,
    InkTimer131CellClassifiedReach program addresses start final ->
    ink_timer131_cells_safe (ink_timer131_clight_state_memory start)
      (area1_object_pool_block addresses) (area1_mario_slot addresses) ->
    ink_timer131_cells_safe (ink_timer131_clight_state_memory final)
      (area1_object_pool_block addresses) (area1_mario_slot addresses).
Proof.
  intros program addresses start final Hreach.
  induction Hreach; intro Hsafe.
  - exact Hsafe.
  - apply IHHreach.
    eapply ink_timer131_cell_effect_preserves_safety; eauto.
Qed.

Lemma classified_reach_trans :
  forall program addresses first middle final,
    InkTimer131CellClassifiedReach program addresses first middle ->
    InkTimer131CellClassifiedReach program addresses middle final ->
    InkTimer131CellClassifiedReach program addresses first final.
Proof.
  intros program addresses first middle final Hfirst Hsecond.
  induction Hfirst.
  - exact Hsecond.
  - econstructor; eauto.
Qed.

Definition clight_calls_internal
    (body : function) (state : Clight.state) : Prop :=
  exists arguments continuation memory,
    state = Clight.Callstate (Internal body)
      arguments continuation memory.

(** The five certificate segments deliberately cross subsystem boundaries.
    The intermediate states are shared, so the segments cannot be assembled
    from different runs. *)
Record JPInkTimer131RealEntryPrefix
    (addresses : Area1EntryAddresses) : Type := {
  jp_ink_prefix_task_start : Clight.state;
  jp_ink_prefix_clear_call : Clight.state;
  jp_ink_prefix_load_call : Clight.state;
  jp_ink_prefix_spawn_call : Clight.state;
  jp_ink_prefix_init_call : Clight.state;
  jp_ink_prefix_final : Clight.state;

  jp_ink_prefix_official_start :
    SelectedRuntimeTaskStart VersionJP jp_official_cleaned_slice
      jp_ink_prefix_task_start;
  jp_ink_prefix_clear_is_real :
    clight_calls_internal IT131P_Objects.f_clear_objects
      jp_ink_prefix_clear_call;
  jp_ink_prefix_load_is_real :
    clight_calls_internal IT131P_Area.f_load_mario_area
      jp_ink_prefix_load_call;
  jp_ink_prefix_spawn_is_real :
    clight_calls_internal IT131P_Objects.f_spawn_objects_from_info
      jp_ink_prefix_spawn_call;
  jp_ink_prefix_init_is_real :
    clight_calls_internal IT131P_Mario.f_init_mario
      jp_ink_prefix_init_call;

  jp_ink_prefix_to_clear :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      jp_ink_prefix_task_start jp_ink_prefix_clear_call;
  jp_ink_prefix_clear_to_load :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      jp_ink_prefix_clear_call jp_ink_prefix_load_call;
  jp_ink_prefix_load_to_spawn :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      jp_ink_prefix_load_call jp_ink_prefix_spawn_call;
  jp_ink_prefix_spawn_to_init :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      jp_ink_prefix_spawn_call jp_ink_prefix_init_call;
  jp_ink_prefix_init_to_final :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      jp_ink_prefix_init_call jp_ink_prefix_final
}.

Definition jp_ink_timer131_whole_prefix
    {addresses} (prefix : JPInkTimer131RealEntryPrefix addresses) :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      (jp_ink_prefix_task_start _ prefix) (jp_ink_prefix_final _ prefix) :=
  classified_reach_trans _ _ _ _ _ (jp_ink_prefix_to_clear _ prefix)
    (classified_reach_trans _ _ _ _ _ (jp_ink_prefix_clear_to_load _ prefix)
      (classified_reach_trans _ _ _ _ _ (jp_ink_prefix_load_to_spawn _ prefix)
        (classified_reach_trans _ _ _ _ _
          (jp_ink_prefix_spawn_to_init _ prefix)
          (jp_ink_prefix_init_to_final _ prefix)))).

Theorem jp_ink_timer131_real_prefix_is_one_actual_execution :
  forall addresses (prefix : JPInkTimer131RealEntryPrefix addresses),
    exists trace,
      @Smallstep.star _ _ Clight.step2
        (Clight.globalenv jp_official_cleaned_slice)
        (jp_ink_prefix_task_start _ prefix) trace
        (jp_ink_prefix_final _ prefix).
Proof.
  intros addresses prefix.
  apply (classified_reach_is_an_actual_clight_star
    jp_official_cleaned_slice addresses).
  exact (jp_ink_timer131_whole_prefix prefix).
Qed.

(** * Entry consequence of a completed certificate *)

Record JPInkTimer131RealEntryResult
    (addresses : Area1EntryAddresses)
    (prefix : JPInkTimer131RealEntryPrefix addresses)
    (x y z : float32) (sample : EntryControllerSample)
    (behavior_block : block)
    (loads : list InkTimer131ProtectedLoad) : Prop := {
  jp_ink_prefix_symbols :
    JPArea1EntrySymbolBindings
      (Clight.globalenv jp_official_cleaned_slice) addresses;
  jp_ink_prefix_entry_memory :
    OrdinaryArea1EntryMemoryPostcondition
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      addresses x y z sample;
  jp_ink_prefix_behavior_load :
    load_at Mptr
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_object_pool_block addresses) (mario_object_base addresses)
      object_behavior_offset = Some (Vptr behavior_block Ptrofs.zero);
  jp_ink_prefix_list_zero_membership :
    InkTimer131MarioInListZero
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      addresses;
  jp_ink_prefix_protected_loads :
    InkTimer131ProtectedLoadsHold
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix)) loads
}.

Theorem completed_real_prefix_supplies_live_timer131_invariant :
  forall addresses (prefix : JPInkTimer131RealEntryPrefix addresses)
      x y z sample behavior_block loads,
    JPInkTimer131RealEntryResult addresses prefix x y z sample
      behavior_block loads ->
    InkTimer131LiveInvariant
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      addresses behavior_block loads.
Proof.
  intros addresses prefix x y z sample behavior_block loads Hresult.
  destruct Hresult as [Hsymbols Hentry Hbehavior Hlist Hloads].
  assert (Hinitial_safe :
    ink_timer131_cells_safe
      (ink_timer131_clight_state_memory (jp_ink_prefix_task_start _ prefix))
      (area1_object_pool_block addresses) (area1_mario_slot addresses)).
  {
    destruct (jp_ink_prefix_official_start _ prefix) as
      (initial_memory & entry_block & entry_function & Hinitial & Hsymbol &
       Hfunction & Hstart & step_trace & next_state & Hstep).
    rewrite Hstart.
    cbn [ink_timer131_clight_state_memory
      default_area1_clight_state_memory].
    apply ink_timer131_entry_tail_cells_are_safe.
    eapply jp_official_initial_memory_supplies_timer131_entry_tail_cells.
    - exact Hinitial.
    - exact Hsymbols.
    - exact (ordinary_area1_slots_valid _ _ _ _ _ _ Hentry).
  }
  pose proof (classified_reach_preserves_timer131_cells
    jp_official_cleaned_slice addresses
    (jp_ink_prefix_task_start _ prefix) (jp_ink_prefix_final _ prefix)
    (jp_ink_timer131_whole_prefix prefix) Hinitial_safe) as Hsafe.
  constructor.
  - exact Hsafe.
  - eapply ordinary_entry_plus_behavior_and_list_supplies_ink_identity;
      eauto.
  - exact Hloads.
Qed.

Definition InkTimer131RealEntryPrefixCheckedBoundary : Prop :=
  ink_timer131_real_prefix_source_claim /\
  (forall program addresses start final,
    InkTimer131CellClassifiedReach program addresses start final ->
    exists trace,
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        start trace final) /\
  (forall addresses (prefix : JPInkTimer131RealEntryPrefix addresses)
      x y z sample behavior_block loads,
    JPInkTimer131RealEntryResult addresses prefix x y z sample
      behavior_block loads ->
    InkTimer131LiveInvariant
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      addresses behavior_block loads).

Theorem ink_timer131_real_entry_prefix_checked_boundary_holds :
  InkTimer131RealEntryPrefixCheckedBoundary.
Proof.
  split; [exact ink_timer131_real_prefix_source_checked |].
  split; [exact classified_reach_is_an_actual_clight_star |].
  exact completed_real_prefix_supplies_live_timer131_invariant.
Qed.
