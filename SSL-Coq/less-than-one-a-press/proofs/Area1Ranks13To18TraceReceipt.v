(** Finite read-only JP receipt for Ranks 13, 13A, 13B, and 18.

    These constants are checked against the debugger receipt by
    [instrumentation/jp-ranks13-18/verify_receipt.py].  They describe the same
    2,462-frame zero-A run as Rank 5, now with actual interaction dispatch,
    copy index, each coordinate store/readback, and upper-warp floor watches.
    The result is NOT a universal controller-history theorem or an
    IDO-machine-to-Clight simulation.  The separate Rank-18 allocation/read
    theorem is about actual Clight steps and does not depend on this receipt. *)

From Coq Require Import List ZArith.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import
  Area1InteractionShortCircuitClosure Area1PrecollisionWriterClosure
  Area1Rank5StateSplitTraceReceipt.

Import ListNotations.
Local Open Scope Z_scope.

(** Field suffixes deliberately match RANK13_RESULT literally, so the checker
    can reject a missing, added, or changed metric without a renaming map. *)
Definition jp_rank13_frames : Z := 2462.
Definition jp_rank13_actionEntries : Z := 2462.
Definition jp_rank13_inputReturns : Z := 2462.
Definition jp_rank13_interactionEntries : Z := 2462.
Definition jp_rank13_interactionReturns : Z := 2462.
Definition jp_rank13_copyEntries : Z := 2462.
Definition jp_rank13_copyIndices : Z := 2462.
Definition jp_rank13_copyReturns : Z := 2462.
Definition jp_rank13_handlerCalls : Z := 65.
Definition jp_rank13_handlerReturns : Z := 65.
Definition jp_rank13_failures : Z := 0.
Definition jp_rank13_decodeFailures : Z := 0.
Definition jp_rank13_immutableWrites : Z := 0.
Definition jp_rank13_statePointerWrites : Z := 0.
Definition jp_rank13_currentWritesInCopy : Z := 0.
Definition jp_rank13_stateWritesInCopy : Z := 0.
Definition jp_rank13_objectWritesOutsideCopy : Z := 0.
Definition jp_rank13_acceptedWarps : Z := 1.
Definition jp_rank13_warpReturns : Z := 1.
Definition jp_rank13_laterHandlers : Z := 0.
Definition jp_rank13_warpXZStores : Z := 0.
Definition jp_rank13_warpYStores : Z := 3.
Definition jp_rank13_badWarpYStores : Z := 0.
Definition jp_rank13_warpFloorWrites : Z := 0.
Definition jp_rank13_floorSnapChecks : Z := 3.
Definition jp_rank13_disappearedCalls : Z := 3.
Definition jp_rank13_disappearedReturns : Z := 3.
Definition jp_rank13_finalQueries : Z := 3.
Definition jp_rank13_poolPointerWrites : Z := 0.
Definition jp_rank13_invariant : Z := 1.

Definition jp_ranks13_component_stores : list Z := [2462; 2462; 2462].
Definition jp_ranks13_component_readbacks : list Z := [2462; 2462; 2462].
Definition jp_ranks13_handler_counts : list (Z * Z * Z) :=
  [(0, 5, 0); (4, 1, 1); (9, 45, 1); (19, 4, 0); (29, 10, 6)].

(** Twenty stage snapshots have exactly these State and Object words.
    The three final queries return the same NONNULL, ownerless floor.
    A null cached-platform pointer is not a null floor result. *)
Definition jp_ranks13_snapshot_count : Z := 20.
Definition jp_ranks13_warp_xyz_bits : list Z :=
  [3304995876; 1145044992; 3296829920].
Definition jp_ranks13_warp_floor : Z := 2149146032.
Definition jp_ranks13_warp_floor_height : Z := 1145044992.
Definition jp_ranks13_warp_floor_owner : Z := 0.
Definition jp_ranks13_warp_query_timers : list Z := [2807; 2808; 2809].

Record JPRanks13To18CopyInteractionReceipt : Prop := {
  jp_ranks13_same_interval : jp_rank13_frames = jp_rank5_trace_frames;
  jp_ranks13_every_phase_once_per_frame :
    [jp_rank13_actionEntries; jp_rank13_inputReturns;
     jp_rank13_interactionEntries; jp_rank13_interactionReturns;
     jp_rank13_copyEntries; jp_rank13_copyIndices; jp_rank13_copyReturns] =
      repeat jp_rank13_frames 7;
  jp_ranks13_each_copy_store_is_read_back :
    jp_ranks13_component_stores = repeat jp_rank13_frames 3 /\
    jp_ranks13_component_readbacks = jp_ranks13_component_stores;
  jp_ranks13_dispatches_return_and_match_the_table :
    jp_rank13_handlerCalls = 65 /\
    jp_rank13_handlerReturns = jp_rank13_handlerCalls /\
    jp_ranks13_handler_counts =
      [(0, 5, 0); (4, 1, 1); (9, 45, 1); (19, 4, 0); (29, 10, 6)];
  jp_ranks13_no_unclassified_or_retargeted_store :
    [jp_rank13_failures; jp_rank13_decodeFailures; jp_rank13_immutableWrites;
     jp_rank13_statePointerWrites; jp_rank13_currentWritesInCopy;
     jp_rank13_stateWritesInCopy; jp_rank13_objectWritesOutsideCopy;
     jp_rank13_poolPointerWrites] = repeat 0 8;
  jp_ranks13_warp_stops_the_handler_loop :
    jp_rank13_acceptedWarps = 1 /\ jp_rank13_warpReturns = 1 /\
    jp_rank13_laterHandlers = 0;
  jp_ranks13_only_three_checked_floor_snaps :
    jp_rank13_warpXZStores = 0 /\ jp_rank13_warpYStores = 3 /\
    jp_rank13_badWarpYStores = 0 /\ jp_rank13_floorSnapChecks = 3 /\
    jp_rank13_disappearedCalls = 3 /\ jp_rank13_disappearedReturns = 3;
  jp_ranks13_floor_survives_through_final_queries :
    jp_rank13_warpFloorWrites = 0 /\ jp_rank13_finalQueries = 3 /\
    jp_ranks13_warp_query_timers = [2807; 2808; 2809] /\
    jp_ranks13_warp_floor = 2149146032 /\
    jp_ranks13_warp_floor_height = 1145044992 /\
    jp_ranks13_warp_floor_owner = 0;
  jp_ranks13_warp_snapshots_stay_at_the_rank5_sample :
    jp_ranks13_snapshot_count = 20 /\
    jp_ranks13_warp_xyz_bits = jp_rank5_upper_warp_xyz_bits;
  jp_ranks13_audit_passed : jp_rank13_invariant = 1
}.

Theorem jp_ranks13_to18_copy_interaction_receipt_checked :
  JPRanks13To18CopyInteractionReceipt.
Proof. constructor; cbv; repeat split; reflexivity. Qed.

(** Rank 13: the new watches include the entire action/copy interval that
    the old post-copy/next-preapply watches did not classify. *)
Theorem jp_rank13_only_checked_copy_writes_on_this_trace :
  jp_rank13_objectWritesOutsideCopy = 0 /\
  jp_ranks13_component_stores = [2462; 2462; 2462] /\
  jp_ranks13_component_readbacks = jp_ranks13_component_stores /\
  jp_rank13_failures = 0 /\ jp_rank13_decodeFailures = 0.
Proof. cbv; repeat split; reflexivity. Qed.

(** Rank 13A: these are watched-store facts, not just equal endpoint samples.
    The runner requires the complete old Rank-5 receipt to match exactly. *)
Theorem jp_rank13a_no_extra_precollision_writer_on_this_trace :
  jp_rank5_preapply_state_writes = 0 /\
  jp_rank5_preapply_object_writes = 0 /\
  jp_rank5_postapply_state_writes = 0 /\
  jp_rank5_postapply_object_writes = 0 /\
  jp_rank5_postapply_graphics_writes = 0.
Proof. cbv; repeat split; reflexivity. Qed.

(** Rank 13B: a genuine cached-floor snap occurs, but its binary32 height is
    the already occupied height 768.  The observed floor is not a platform. *)
Theorem jp_rank13b_warp_snap_is_not_a_height_source_on_this_trace :
  jp_rank13_laterHandlers = 0 /\ jp_rank13_warpXZStores = 0 /\
  jp_rank13_warpYStores = 3 /\ jp_rank13_badWarpYStores = 0 /\
  jp_rank13_warpFloorWrites = 0 /\
  nth 1 jp_ranks13_warp_xyz_bits 0 = jp_ranks13_warp_floor_height /\
  Float32.to_bits (Float32.of_int (Int.repr 768)) =
    Int.repr jp_ranks13_warp_floor_height /\
  jp_ranks13_warp_floor <> 0 /\ jp_ranks13_warp_floor_owner = 0.
Proof. vm_compute; repeat split; congruence. Qed.

(** Rank 18: every actual branch index and component store was checked, with
    unchanged source coordinates and current-object pointer during the copy. *)
Theorem jp_rank18_no_copy_escape_on_this_trace :
  jp_rank13_copyEntries = jp_rank13_frames /\
  jp_rank13_copyIndices = jp_rank13_frames /\
  jp_rank13_copyReturns = jp_rank13_frames /\
  jp_rank13_failures = 0 /\ jp_rank13_currentWritesInCopy = 0 /\
  jp_rank13_stateWritesInCopy = 0 /\ jp_rank13_statePointerWrites = 0 /\
  jp_ranks13_component_stores = repeat jp_rank13_frames 3 /\
  jp_ranks13_component_readbacks = jp_ranks13_component_stores.
Proof. cbv; repeat split; reflexivity. Qed.

Definition Area1Ranks13To18TraceCheckedBoundary : Prop :=
  Area1PrecollisionWriterSourceBoundary /\
  Area1InteractionShortCircuitSourceBoundary /\
  JPRank5StateSplitTraceReceipt /\ JPRanks13To18CopyInteractionReceipt.

Theorem area1_ranks13_to18_trace_checked_boundary_holds :
  Area1Ranks13To18TraceCheckedBoundary.
Proof.
  split; [exact area1_precollision_writer_source_boundary_checked |].
  split; [exact area1_interaction_short_circuit_source_boundary_holds |].
  split; [exact jp_rank5_state_split_trace_receipt_checked |].
  exact jp_ranks13_to18_copy_interaction_receipt_checked.
Qed.
