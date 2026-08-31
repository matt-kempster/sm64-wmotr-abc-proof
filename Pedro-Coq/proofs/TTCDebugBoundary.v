From Coq Require Import Bool Lia List PeanoNat ZArith.
From Pedro.Proofs Require Import DustPool DustPRNG GameTypes.

Import ListNotations.

(** A finite boundary certificate extracted from a runtime object-list walk.
    Slot [n] is represented by [nth_error snapshot_slot_buckets n]: [None]
    means the free list and [Some k] means object list [k].  Thus a list of
    length 240 classifies each retail pool slot exactly once.  This finite
    representation deliberately begins after the runtime probe has walked and
    checked the raw next/previous pointers; it is not a CompCert memory
    refinement theorem for that walk. *)
Record TTCDebugBoundarySnapshot : Type := {
  snapshot_version : GameVersion;
  snapshot_timer : nat;
  snapshot_level : nat;
  snapshot_area : nat;
  snapshot_ttc_speed_setting : Z;
  snapshot_mario_slot : nat;
  snapshot_particle_flags : Z;
  snapshot_active_particle_word : Z;
  snapshot_time_stop_state : Z;
  snapshot_slot_buckets : list (option nat)
}.

Fixpoint count_free_slots (buckets : list (option nat)) : nat :=
  match buckets with
  | [] => O
  | None :: rest => S (count_free_slots rest)
  | Some _ :: rest => count_free_slots rest
  end.

Fixpoint count_bucket_slots
    (needle : nat) (buckets : list (option nat)) : nat :=
  match buckets with
  | [] => O
  | None :: rest => count_bucket_slots needle rest
  | Some bucket :: rest =>
      (if Nat.eqb bucket needle then 1 else 0) +
      count_bucket_slots needle rest
  end.

Definition count_active_slots (buckets : list (option nat)) : nat :=
  length buckets - count_free_slots buckets.

Definition bucket_index_validb (bucket : option nat) : bool :=
  match bucket with
  | None => true
  | Some index => Nat.ltb index 13%nat
  end.

Definition snapshot_dust_requestb
    (snapshot : TTCDebugBoundarySnapshot) : bool :=
  Z.eqb (Z.land (snapshot_particle_flags snapshot) 1) 1.

Definition snapshot_dust_bitb
    (snapshot : TTCDebugBoundarySnapshot) : bool :=
  negb (Z.eqb (Z.land (snapshot_active_particle_word snapshot) 1) 0).

Definition snapshot_normal_timeb
    (snapshot : TTCDebugBoundarySnapshot) : bool :=
  Z.eqb (snapshot_time_stop_state snapshot) 0.

(** These are exactly the finite boundary facts needed by [DustPool].  They do
    not contain, or pretend to contain, a stock-reachability proposition. *)
Definition TTCDebugBoundaryCensusFacts
    (snapshot : TTCDebugBoundarySnapshot) : Prop :=
  snapshot_level snapshot = 14%nat /\
  snapshot_area snapshot = 1%nat /\
  snapshot_ttc_speed_setting snapshot = 0 /\
  length (snapshot_slot_buckets snapshot) = 240%nat /\
  forallb bucket_index_validb (snapshot_slot_buckets snapshot) = true /\
  nth_error (snapshot_slot_buckets snapshot)
    (snapshot_mario_slot snapshot) = Some (Some 0%nat) /\
  snapshot_dust_requestb snapshot = true /\
  snapshot_dust_bitb snapshot = false /\
  snapshot_normal_timeb snapshot = true /\
  (3 <= count_free_slots (snapshot_slot_buckets snapshot) +
        count_bucket_slots 12%nat (snapshot_slot_buckets snapshot))%nat.

(** Object-list indices observed at the discovery boundary, in pool-slot
    order for slots 0 through 124.  Slots 125 through 239 were on the free
    list.  US and JP agreed after erasing version-specific RAM addresses. *)
Definition ttc_level_select_active_buckets : list nat :=
  ([9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9;
   9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9;
   9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9;
   9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 9; 6; 6; 6; 6; 6;
   6; 6; 6; 6; 9; 9; 4; 9; 6; 6; 6; 6; 6; 6; 4; 4;
   11; 4; 6; 6; 6; 6; 6; 4; 9; 6; 9; 2; 2; 6; 9; 9;
   9; 9; 9; 6; 6; 9; 9; 9; 9; 9; 9; 9; 9; 9; 6; 6;
   6; 6; 6; 6; 9; 10; 8; 0; 4; 8; 8; 8; 12])%nat.

Definition ttc_level_select_slot_buckets : list (option nat) :=
  map (@Some nat) ttc_level_select_active_buckets ++ repeat None 115%nat.

Definition ttc_level_select_snapshot
    (version : GameVersion) : TTCDebugBoundarySnapshot :=
  {| snapshot_version := version;
     snapshot_timer := 414%nat;
     snapshot_level := 14%nat;
     snapshot_area := 1%nat;
     snapshot_ttc_speed_setting := 0;
     snapshot_mario_slot := 119%nat;
     snapshot_particle_flags := 1;
     snapshot_active_particle_word := 0;
     snapshot_time_stop_state := 0;
     snapshot_slot_buckets := ttc_level_select_slot_buckets |}.

Theorem ttc_level_select_snapshot_exact_census :
  count_free_slots ttc_level_select_slot_buckets = 115%nat /\
  count_bucket_slots 12%nat ttc_level_select_slot_buckets = 1%nat /\
  count_active_slots ttc_level_select_slot_buckets = 125%nat /\
  (count_free_slots ttc_level_select_slot_buckets +
    count_bucket_slots 12%nat ttc_level_select_slot_buckets)%nat = 116%nat.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem ttc_level_select_snapshot_boundary_supported :
  forall version,
    TTCDebugBoundaryCensusFacts (ttc_level_select_snapshot version).
Proof.
  intros version.
  unfold TTCDebugBoundaryCensusFacts, ttc_level_select_snapshot.
  vm_compute.
  repeat split; lia.
Qed.

(** This is the useful formal reduction: a finite boundary census with three
    reserve units and a clear bit instantiates all isolated pool/flag premises
    used by the checked dust episode.  It remains conditional only on the
    census facts supplied to it, not on an opaque "reachable tap" proposition. *)
Theorem finite_ttc_boundary_discharges_pool_and_flag_model :
  forall snapshot,
    TTCDebugBoundaryCensusFacts snapshot ->
    exists pool_after,
      dust_three_allocation_trace
        {| free_objects :=
             count_free_slots (snapshot_slot_buckets snapshot);
           unimportant_objects :=
             count_bucket_slots 12%nat (snapshot_slot_buckets snapshot) |} =
        Some pool_after /\
      dust_request_accepted
        (run_dust_bit_same_frame (snapshot_dust_bitb snapshot)) = true /\
      bit_after_spawn_particle
        (run_dust_bit_same_frame (snapshot_dust_bitb snapshot)) = true /\
      bit_after_default_spawner
        (run_dust_bit_same_frame (snapshot_dust_bitb snapshot)) = false.
Proof.
  intros snapshot
    [_ [_ [_ [_ [_ [_ [_ [Hclear [_ Hreserve]]]]]]]]].
  destruct (proj2
    (dust_three_allocations_exist_iff_reserve_at_least_three
      {| free_objects :=
           count_free_slots (snapshot_slot_buckets snapshot);
         unimportant_objects :=
           count_bucket_slots 12%nat (snapshot_slot_buckets snapshot) |})
    Hreserve) as [pool_after Hpool].
  exists pool_after.
  split; [exact Hpool|].
  rewrite Hclear.
  repeat split; reflexivity.
Qed.

Theorem ttc_level_select_snapshot_discharges_finite_model :
  forall version : GameVersion,
    exists pool_after,
      dust_three_allocation_trace
        {| free_objects := 115%nat; unimportant_objects := 1%nat |} =
        Some pool_after /\
      dust_request_accepted (run_dust_bit_same_frame false) = true /\
      bit_after_spawn_particle (run_dust_bit_same_frame false) = true /\
      bit_after_default_spawner (run_dust_bit_same_frame false) = false.
Proof.
  intro version.
  pose proof (finite_ttc_boundary_discharges_pool_and_flag_model
    (ttc_level_select_snapshot version)
    (ttc_level_select_snapshot_boundary_supported version)) as H.
  vm_compute in H |- *.
  exact H.
Qed.

(** The level-select replay leaves the retail TTC speed setting at its
    zero-initialized SLOW value.  RANDOM is the distinct value 2.  Keeping
    this fact in the certificate prevents the discovery trace below from
    being used as evidence about RANDOM-mode spinner scheduling. *)
Definition ttc_speed_slow : Z := 0.
Definition ttc_speed_random : Z := 2.

Theorem ttc_level_select_snapshot_is_slow_not_random :
  forall version,
    snapshot_ttc_speed_setting (ttc_level_select_snapshot version) =
      ttc_speed_slow /\
    snapshot_ttc_speed_setting (ttc_level_select_snapshot version) <>
      ttc_speed_random.
Proof. intros version; split; [reflexivity | discriminate]. Qed.

(** Normalized projection of the complete [random_u16] entry/return receipt
    over timer 414 (F) and timer 415 (F+1).  Raw US/JP object and behavior
    addresses are checked by [check-ttc-runtime-snapshot.py]; this projection
    retains their scheduler-relevant semantic owner and every state field used
    by the exact-call argument. *)
Inductive TTCDebugRngOwner : Type :=
| TTCDebugOutsideList2
| TTCDebugDustPuff1
| TTCDebugDustPuff2.

Definition ttc_debug_rng_behavior_address
    (version : GameVersion) (owner : TTCDebugRngOwner) : Z :=
  match version, owner with
  | VersionUS, TTCDebugOutsideList2 => 2148459252
  | VersionUS, TTCDebugDustPuff1 => 2148456028
  | VersionUS, TTCDebugDustPuff2 => 2148456064
  | VersionJP, TTCDebugOutsideList2 => 2148447348
  | VersionJP, TTCDebugDustPuff1 => 2148444156
  | VersionJP, TTCDebugDustPuff2 => 2148444192
  end.

Record TTCDebugRngEvent : Type := {
  event_call_index : nat;
  event_timer : nat;
  event_owner : TTCDebugRngOwner;
  event_object_slot : nat;
  event_object_list : nat;
  event_object_action : Z;
  event_object_timer : Z;
  event_seed_before : Z;
  event_seed_after : Z
}.

Definition ttc_debug_rng_event
    (call timer : nat) (owner : TTCDebugRngOwner)
    (slot list_index : nat) (action object_timer before after : Z)
    : TTCDebugRngEvent :=
  {| event_call_index := call;
     event_timer := timer;
     event_owner := owner;
     event_object_slot := slot;
     event_object_list := list_index;
     event_object_action := action;
     event_object_timer := object_timer;
     event_seed_before := before;
     event_seed_after := after |}.

Definition ttc_debug_slow_frame_f_events : list TTCDebugRngEvent :=
  [ttc_debug_rng_event 33%nat 414%nat TTCDebugOutsideList2
     92%nat 2%nat 0 17 26276 45745;
   ttc_debug_rng_event 34%nat 414%nat TTCDebugDustPuff1
     126%nat 8%nat 0 0 45745 9776;
   ttc_debug_rng_event 35%nat 414%nat TTCDebugDustPuff1
     126%nat 8%nat 0 0 9776 63567;
   ttc_debug_rng_event 36%nat 414%nat TTCDebugDustPuff2
     127%nat 12%nat 0 0 63567 22932;
   ttc_debug_rng_event 37%nat 414%nat TTCDebugDustPuff2
     127%nat 12%nat 0 0 22932 13554].

Definition ttc_debug_slow_frame_f1_events : list TTCDebugRngEvent :=
  [ttc_debug_rng_event 38%nat 415%nat TTCDebugOutsideList2
     92%nat 2%nat 0 18 13554 39397;
   ttc_debug_rng_event 39%nat 415%nat TTCDebugDustPuff1
     128%nat 8%nat 0 0 39397 37423;
   ttc_debug_rng_event 40%nat 415%nat TTCDebugDustPuff1
     128%nat 8%nat 0 0 37423 27121;
   ttc_debug_rng_event 41%nat 415%nat TTCDebugDustPuff2
     129%nat 12%nat 0 0 27121 38985;
   ttc_debug_rng_event 42%nat 415%nat TTCDebugDustPuff2
     129%nat 12%nat 0 0 38985 23201].

Definition ttc_debug_slow_rng_events : list TTCDebugRngEvent :=
  ttc_debug_slow_frame_f_events ++ ttc_debug_slow_frame_f1_events.

Definition ttc_debug_rng_owner_is_dustb
    (owner : TTCDebugRngOwner) : bool :=
  match owner with
  | TTCDebugOutsideList2 => false
  | TTCDebugDustPuff1 | TTCDebugDustPuff2 => true
  end.

Definition ttc_debug_dust_call_count
    (events : list TTCDebugRngEvent) : nat :=
  length
    (filter
      (fun event => ttc_debug_rng_owner_is_dustb (event_owner event))
      events).

Definition ttc_debug_rng_event_stepb (event : TTCDebugRngEvent) : bool :=
  Z.eqb
    (random_u16_step_z (event_seed_before event))
    (event_seed_after event).

Definition ttc_debug_rng_trace_chainb
    (events : list TTCDebugRngEvent) : bool :=
  forallb
    (fun pair =>
      Z.eqb
        (event_seed_after (fst pair))
        (event_seed_before (snd pair)))
    (combine events (tl events)).

Theorem ttc_debug_slow_trace_exact_scheduler_projection :
  map event_call_index ttc_debug_slow_rng_events = seq 33%nat 10%nat /\
  map event_timer ttc_debug_slow_frame_f_events = repeat 414%nat 5%nat /\
  map event_timer ttc_debug_slow_frame_f1_events = repeat 415%nat 5%nat /\
  map event_object_list ttc_debug_slow_frame_f_events =
    ([2; 8; 8; 12; 12])%nat /\
  map event_object_list ttc_debug_slow_frame_f1_events =
    ([2; 8; 8; 12; 12])%nat /\
  ttc_debug_dust_call_count ttc_debug_slow_frame_f_events = 4%nat /\
  ttc_debug_dust_call_count ttc_debug_slow_frame_f1_events = 4%nat.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem ttc_debug_slow_trace_exact_seed_advances :
  forallb ttc_debug_rng_event_stepb ttc_debug_slow_rng_events = true /\
  ttc_debug_rng_trace_chainb ttc_debug_slow_rng_events = true /\
  rng_steps 5%nat 26276 = 13554 /\
  rng_steps 5%nat 13554 = 23201 /\
  rng_steps 10%nat 26276 = 23201.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem ttc_debug_slow_trace_dust_owned_offset_is_four :
  forall frame,
    frame = ttc_debug_slow_frame_f_events \/
    frame = ttc_debug_slow_frame_f1_events ->
    length frame = 5%nat /\ ttc_debug_dust_call_count frame = 4%nat.
Proof.
  intros frame [-> | ->]; vm_compute; split; reflexivity.
Qed.

(** Evidence provenance is kept separate from the finite state.  The concrete
    replay used an emulator level-select code to reach TTC; the input plugin
    itself performed no RAM writes.  Therefore this receipt is discovery and
    regression evidence, not a stock controller-only reachability witness. *)
Inductive SnapshotOrigin : Type :=
| StockControllerOnly
| DebugLevelSelect.

Definition origin_is_stockb (origin : SnapshotOrigin) : bool :=
  match origin with
  | StockControllerOnly => true
  | DebugLevelSelect => false
  end.

Definition ttc_level_select_snapshot_origin : SnapshotOrigin :=
  DebugLevelSelect.

Theorem ttc_level_select_snapshot_is_not_stock_origin :
  origin_is_stockb ttc_level_select_snapshot_origin = false.
Proof. reflexivity. Qed.

(** This claim is intentionally named a debug-replay reduction.  A future
    stock theorem must replace [DebugLevelSelect] with a controller-only movie
    from an ordinary save/door entry (or a linked Clight execution) and prove
    that execution refines the same finite census. *)
Definition ttc_debug_replay_boundary_reduction_claim : Prop :=
  (forall version, dust_pool_source_receipt version) /\
  (forall version,
     TTCDebugBoundaryCensusFacts (ttc_level_select_snapshot version)) /\
  (forall version : GameVersion,
     exists pool_after,
       dust_three_allocation_trace
         {| free_objects := 115%nat; unimportant_objects := 1%nat |} =
         Some pool_after) /\
  origin_is_stockb ttc_level_select_snapshot_origin = false.

Theorem checked_ttc_debug_replay_boundary_reduction_us_jp :
  ttc_debug_replay_boundary_reduction_claim.
Proof.
  unfold ttc_debug_replay_boundary_reduction_claim.
  split.
  - intro version. apply dust_pool_source_receipt_supported.
  - split.
    + intro version. apply ttc_level_select_snapshot_boundary_supported.
    + split.
      * intro version.
        destruct (ttc_level_select_snapshot_discharges_finite_model version)
          as [pool_after [Hpool _]].
        exists pool_after. exact Hpool.
      * exact ttc_level_select_snapshot_is_not_stock_origin.
Qed.
