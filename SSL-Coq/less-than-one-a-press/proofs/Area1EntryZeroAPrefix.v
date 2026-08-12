(** Ordinary SSL Area-1 entry as a zero-A Clight prefix boundary.

    This module deliberately does not choose or construct a linked program.
    It is parameterized by the caller's [Clight.program], so it depends only
    on the live ordinary-entry memory contract and the zero-A reachability
    relation.  Supplying the concrete program and its castle-to-[warp_level]
    execution remains a separate refinement obligation. *)

From Coq Require Import List ZArith.
From compcert Require Import
  Clight Ctypes Events Globalenvs Memory Smallstep Values.
From LessThanOneAPress.Generated Require Import jp_level_update jp_mario.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms InputSemantics JPWarpLevelEntryResolution
  JPZeroAReachability OrdinaryArea1EntryMemory.

Import ListNotations.
Local Open Scope Z_scope.

(** The ordinary-entry postcondition contains both controller loads.  A
    no-A edge in the matching predecessor/current input sample therefore
    yields the live controller predicate used by zero-A reachability. *)
Theorem jp_ordinary_area1_entry_memory_has_no_a_edge :
  forall memory_before memory_after addresses x y z
      previous_down current_down,
    JPArea1EntryMemoryPostcondition memory_before memory_after addresses
      x y z (entry_sample_from_history previous_down current_down) ->
    frame_has_no_a_press
      {| frame_previous_down := previous_down;
         frame_current_down := current_down |} ->
    ControllerNoAEdgeMemory memory_after
      (area1_controller_storage_block addresses) 0.
Proof.
  intros memory_before memory_after addresses x y z
    previous_down current_down [Hentry _] Hno_a.
  pose proof (no_a_frame_yields_no_a_entry_sample
    previous_down current_down Hno_a) as Hsample_no_a.
  unfold entry_sample_has_no_a_edge in Hsample_no_a.
  econstructor.
  - exact (ordinary_area1_controller_down _ _ _ _ _ _ Hentry).
  - exact (ordinary_area1_controller_pressed _ _ _ _ _ _ Hentry).
  - exact Hsample_no_a.
Qed.

(** The entry return state is a reflexive zero-A reachable state.  This is a
    genuine constructor application, not an assumed nonempty reachability
    relation. *)
Corollary jp_ordinary_area1_return_starts_zero_a_reachability :
  forall program continuation memory_before memory_after addresses x y z
      previous_down current_down,
    JPArea1EntryMemoryPostcondition memory_before memory_after addresses
      x y z (entry_sample_from_history previous_down current_down) ->
    frame_has_no_a_press
      {| frame_previous_down := previous_down;
         frame_current_down := current_down |} ->
    ZeroAEdgeClightReachable program
      (area1_controller_storage_block addresses) 0
      (Clight.Returnstate Vundef continuation memory_after)
      (Clight.Returnstate Vundef continuation memory_after).
Proof.
  intros program continuation memory_before memory_after addresses x y z
    previous_down current_down Hentry Hno_a.
  constructor.
  unfold ClightStateHasNoAEdge, clight_state_memory; cbn.
  eapply jp_ordinary_area1_entry_memory_has_no_a_edge; eauto.
Qed.

(** Conditional composition of the caller-supplied route prefix with the
    actual [warp_level] prefix.  Every global-environment occurrence uses the
    same caller-supplied program.  The conclusion pins the controller block
    to the JP symbol binding and starts the reflexive zero-A suffix at the
    real return state; it does not assert that either prefix exists. *)
Theorem jp_ordinary_area1_prefix_fixes_zero_a_boundary :
  forall program program_initial route_trace continuation memory_before
      entry_trace memory_after addresses warp_level_block x y z
      previous_down current_down,
    Genv.find_symbol (Clight.globalenv program)
      jp_level_update._warp_level = Some warp_level_block ->
    Genv.find_funct_ptr (Clight.globalenv program) warp_level_block =
      Some (Ctypes.Internal jp_level_update.f_warp_level) ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv program)
      program_initial route_trace
      (Clight.Callstate (Ctypes.Internal jp_level_update.f_warp_level)
        [] continuation memory_before) ->
    JPArea1EntrySymbolBindings
      (Clight.globalenv program) addresses ->
    OrdinaryArea1WarpRequestMemory memory_before addresses ->
    OrdinaryArea1ControllerHistoryMemory memory_before addresses
      previous_down current_down ->
    frame_has_no_a_press
      {| frame_previous_down := previous_down;
         frame_current_down := current_down |} ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv program)
      (Clight.Callstate (Ctypes.Internal jp_level_update.f_warp_level)
        [] continuation memory_before)
      entry_trace (Clight.Returnstate Vundef continuation memory_after) ->
    JPArea1EntryMemoryPostcondition memory_before memory_after addresses
      x y z (entry_sample_from_history previous_down current_down) ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv program)
      program_initial (route_trace ** entry_trace)
      (Clight.Returnstate Vundef continuation memory_after) /\
    Genv.find_symbol (Clight.globalenv program) jp_mario._gControllers =
      Some (area1_controller_storage_block addresses) /\
    ClightStateHasNoAEdge
      (area1_controller_storage_block addresses) 0
      (Clight.Returnstate Vundef continuation memory_after) /\
    ZeroAEdgeClightReachable program
      (area1_controller_storage_block addresses) 0
      (Clight.Returnstate Vundef continuation memory_after)
      (Clight.Returnstate Vundef continuation memory_after).
Proof.
  intros program program_initial route_trace continuation memory_before
    entry_trace memory_after addresses warp_level_block x y z
    previous_down current_down _ _ Hroute Hsymbols _ _ Hno_a
    Hentry_steps Hentry_memory.
  split.
  - eapply Smallstep.star_trans; eauto.
  - split.
    + exact (jp_area1_controller_storage_symbol _ _ Hsymbols).
    + split.
      * unfold ClightStateHasNoAEdge, clight_state_memory; cbn.
        eapply jp_ordinary_area1_entry_memory_has_no_a_edge; eauto.
      * eapply jp_ordinary_area1_return_starts_zero_a_reachability; eauto.
Qed.

(** For the official cleaned JP link, exact [_warp_level] resolution is
    already discharged.  All execution and live-memory premises remain
    explicit. *)
Corollary jp_official_cleaned_ordinary_area1_prefix_fixes_zero_a_boundary :
  forall program_initial route_trace continuation memory_before
      entry_trace memory_after addresses x y z previous_down current_down,
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv jp_official_cleaned_slice)
      program_initial route_trace
      (Clight.Callstate (Ctypes.Internal jp_level_update.f_warp_level)
        [] continuation memory_before) ->
    JPArea1EntrySymbolBindings
      (Clight.globalenv jp_official_cleaned_slice) addresses ->
    OrdinaryArea1WarpRequestMemory memory_before addresses ->
    OrdinaryArea1ControllerHistoryMemory memory_before addresses
      previous_down current_down ->
    frame_has_no_a_press
      {| frame_previous_down := previous_down;
         frame_current_down := current_down |} ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv jp_official_cleaned_slice)
      (Clight.Callstate (Ctypes.Internal jp_level_update.f_warp_level)
        [] continuation memory_before)
      entry_trace (Clight.Returnstate Vundef continuation memory_after) ->
    JPArea1EntryMemoryPostcondition memory_before memory_after addresses
      x y z (entry_sample_from_history previous_down current_down) ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv jp_official_cleaned_slice)
      program_initial (route_trace ** entry_trace)
      (Clight.Returnstate Vundef continuation memory_after) /\
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_mario._gControllers =
      Some (area1_controller_storage_block addresses) /\
    ClightStateHasNoAEdge
      (area1_controller_storage_block addresses) 0
      (Clight.Returnstate Vundef continuation memory_after) /\
    ZeroAEdgeClightReachable jp_official_cleaned_slice
      (area1_controller_storage_block addresses) 0
      (Clight.Returnstate Vundef continuation memory_after)
      (Clight.Returnstate Vundef continuation memory_after).
Proof.
  intros program_initial route_trace continuation memory_before
    entry_trace memory_after addresses x y z previous_down current_down
    Hroute Hsymbols Hwarp_request Hcontroller_history Hno_a
    Hentry_steps Hentry_memory.
  destruct jp_warp_level_resolves_exact_body as
    [warp_level_block [Hwarp_symbol Hwarp_body]].
  eapply jp_ordinary_area1_prefix_fixes_zero_a_boundary; eauto.
Qed.
